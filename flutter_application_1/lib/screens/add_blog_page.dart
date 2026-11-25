import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../widgets/admin_drawer.dart';

class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  State<AddBlogPage> createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final _titulo = TextEditingController();
  final _descripcion = TextEditingController();
  final _imagen = TextEditingController();
  final _tags = TextEditingController();
  final _servicio = PostService();
  bool _guardando = false;
  Map<String, dynamic> _usuario = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) _usuario = Map<String, dynamic>.from(args);
  }

  @override
  void dispose() {
    _titulo.dispose();
    _descripcion.dispose();
    _imagen.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      await _servicio.agregarPost(
        titulo: _titulo.text,
        descripcion: _descripcion.text,
        imagen: _imagen.text,
        tags: _tags.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Publicación agregada correctamente')),
      );
      _titulo.clear();
      _descripcion.clear();
      _imagen.clear();
      _tags.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _usuario['nom_usr']?.toString() ?? 'Usuario';
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      // El menú lateral es solo para administradores.
      drawer: ((_usuario['tip_usu'] as num?)?.toInt() == 1)
          ? AdminDrawer(usuario: _usuario, rutaActual: '/add-blog')
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Nueva publicación',
                        style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 6),
                      Text('Autor: $nombre'),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titulo,
                        decoration: const InputDecoration(
                          labelText: 'Título',
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 150,
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Ingresa el título';
                          if (t.length < 2) return 'Mínimo 2 caracteres';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descripcion,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Ingresa la descripción' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _imagen,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: 'URL de imagen (opcional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _tags,
                        maxLength: 255,
                        decoration: const InputDecoration(
                          labelText: 'Etiquetas (opcional)',
                          hintText: 'flutter, tecnología, móvil',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _guardando ? null : _guardar,
                        icon: _guardando
                            ? const SizedBox(
                                width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.save),
                        label: Text(_guardando ? 'Guardando...' : 'Guardar publicación'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
