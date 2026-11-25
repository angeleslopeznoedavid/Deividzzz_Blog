import 'package:flutter/material.dart';
import '../models/comentarios_model.dart';
import '../models/post_model.dart';
import '../services/comentario_service.dart';
import '../services/session_service.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final ComentarioService _servicio = ComentarioService();
  final TextEditingController _controller = TextEditingController();
  late Future<List<ComentarioModel>> _futuroComentarios;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _cargar() {
    _futuroComentarios =
        _servicio.obtenerComentarios(blogId: widget.post.id);
  }

  Future<void> _enviar() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty || _enviando) return;

    setState(() => _enviando = true);
    try {
      await _servicio.agregarComentario(
        ComentarioModel(
          id: 0,
          comentario: texto,
          fecha: '',
          estatus: 1,
          usuarioId: SessionService.idUsuario ?? 0,
          blogId: widget.post.id,
        ),
      );
      if (!mounted) return;
      _controller.clear();
      FocusScope.of(context).unfocus();
      setState(_cargar);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  String _formatearFecha(String fecha) {
    final limpia = fecha.replaceFirst('T', ' ');
    return limpia.length >= 16 ? limpia.substring(0, 16) : limpia;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                post.imagen.isEmpty
                    ? _sinImagen(230)
                    : Image.network(
                        post.imagen,
                        height: 230,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _sinImagen(230),
                      ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.categoria,
                        style: const TextStyle(
                          color: Color(0xFF2196F3),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.titulo,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF08245C),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Text(post.autor),
                          const SizedBox(width: 10),
                          Text('• ${post.fecha}'),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text(
                        post.contenido,
                        style: const TextStyle(fontSize: 17, height: 1.6),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF08245C),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _listaComentarios(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _cajaComentario(),
        ],
      ),
    );
  }

  Widget _listaComentarios() {
    return FutureBuilder<List<ComentarioModel>>(
      future: _futuroComentarios,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'No se pudieron cargar los comentarios: '
            '${snapshot.error.toString().replaceFirst('Exception: ', '')}',
          );
        }

        final comentarios = snapshot.data ?? [];

        if (comentarios.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Aún no hay comentarios. ¡Sé el primero!'),
          );
        }

        return Column(
          children: comentarios.map((c) {
            final esMio = c.usuarioId == SessionService.idUsuario;
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: esMio ? const Color(0xFFEEF3FF) : null,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(esMio ? '${c.autor} (tú)' : c.autor),
                subtitle: Text(c.comentario),
                trailing: Text(
                  _formatearFecha(c.fecha),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _cajaComentario() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: 2000,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                  counterText: '',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _enviando ? null : _enviar,
              tooltip: 'Enviar comentario',
              icon: _enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sinImagen(double alto) {
    return Container(
      height: alto,
      width: double.infinity,
      color: const Color(0xFFE7EAF2),
      child: const Icon(Icons.image_not_supported_outlined, size: 40),
    );
  }
}
