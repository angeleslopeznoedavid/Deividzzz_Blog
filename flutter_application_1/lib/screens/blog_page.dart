
import 'package:flutter/material.dart';
import '../widgets/category_chip.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import 'post_detail_page.dart';
import '../models/post_model.dart';
import '../widgets/admin_drawer.dart';
import '../services/session_service.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  final PostService postService = PostService();
  late Future<List<PostModel>> futuroPosts;

  String nombreUsuario = 'Usuario';
  Map<String, dynamic> usuarioActual = {
    'nom_usr': 'Usuario',
    'mail': '',
    'tip_usu': 2,
  };
  bool argumentoLeido = false;

  final TextEditingController searchController =
      TextEditingController();

  String categoriaSeleccionada = 'Todos';
  String busqueda = '';
  bool mostrarBuscador = false;

  static const Color azul = Color(0xFF4F46E5);
  static const Color oscuro = Color(0xFF172033);
  static const Color fondo = Color(0xFFF7F8FC);

  final List<String> categorias = [
    'Todos',
    'Flutter',
    'IA',
    'Diseño',
    'Programación',
    'Mis posts',
  ];

  @override
  void initState() {
    super.initState();
    futuroPosts = postService.obtenerPosts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!argumentoLeido) {
      final argumento = ModalRoute.of(context)?.settings.arguments;

      if (argumento is Map<String, dynamic>) {
        usuarioActual = Map<String, dynamic>.from(argumento);
        nombreUsuario = usuarioActual['nom_usr']?.toString() ?? 'Usuario';
      } else if (argumento is String && argumento.isNotEmpty) {
        nombreUsuario = argumento;
        usuarioActual = {'nom_usr': nombreUsuario, 'mail': '', 'tip_usu': 2};
      }

      argumentoLeido = true;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void recargarPosts() {
    setState(() {
      futuroPosts = postService.obtenerPosts();
    });
  }

  bool get esAdmin =>
      ((usuarioActual['tip_usu'] as num?) ?? 2).toInt() == 1;

  int? get miId => (usuarioActual['id_usr'] as num?)?.toInt();

  Future<void> cerrarSesion() async {
    await SessionService.cerrar();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: fondo,

      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: oscuro,
        elevation: 0,
        titleSpacing: 22,
        title: Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: azul,
              size: 30,
            ),
            const SizedBox(width: 7),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DeividBlog',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: oscuro,
                  ),
                ),
                Text(
                  'Bienvenido, $nombreUsuario',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: recargarPosts,
          ),
          IconButton(
            tooltip: mostrarBuscador
                ? 'Cerrar búsqueda'
                : 'Buscar artículos',
            onPressed: () {
              setState(() {
                mostrarBuscador = !mostrarBuscador;

                if (!mostrarBuscador) {
                  busqueda = '';
                  searchController.clear();
                }
              });
            },
            icon: Icon(
              mostrarBuscador
                  ? Icons.close_rounded
                  : Icons.search_rounded,
              size: 25,
            ),
          ),

          IconButton(
            onPressed: cerrarSesion,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Cerrar sesión',
          ),
          
          const SizedBox(width: 10),
        ],
      ),

      // El menú lateral solo aparece para el administrador (tip_usu == 1).
      drawer: esAdmin
          ? AdminDrawer(usuario: usuarioActual, rutaActual: '/blog')
          : null,

      // Cualquier usuario autenticado puede publicar.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Nueva publicación',
        onPressed: () async {
          await Navigator.pushNamed(
            context,
            '/add-blog',
            arguments: usuarioActual,
          );
          if (mounted) recargarPosts();
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<PostModel>>(
  future: futuroPosts,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (snapshot.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48),
              const SizedBox(height: 12),
              const Text('No se pudieron cargar los artículos.'),
              const SizedBox(height: 8),
              Text( 
                '${snapshot.error}',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: recargarPosts,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final todosLosPosts = snapshot.data ?? <PostModel>[];

    final posts = todosLosPosts.where((post) {
      // El backend guarda las etiquetas en un solo texto ("flutter, IA"),
      // por eso se separan por comas antes de comparar.
      final etiquetas = post.categoria
          .split(',')
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();

      // 'Mis posts' filtra por autor; las demás categorías por etiqueta.
      final coincideCategoria =
          categoriaSeleccionada == 'Todos' ||
          (categoriaSeleccionada == 'Mis posts'
              ? post.usuarioId == miId
              : etiquetas.contains(categoriaSeleccionada.toLowerCase()));

      final texto = busqueda.trim().toLowerCase();

      final coincideBusqueda = texto.isEmpty ||
          post.titulo.toLowerCase().contains(texto) ||
          post.descripcion.toLowerCase().contains(texto) ||
          post.contenido.toLowerCase().contains(texto) ||
          post.autor.toLowerCase().contains(texto) ||
          post.categoria.toLowerCase().contains(texto);

      return coincideCategoria && coincideBusqueda;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
          // ENCABEZADO PRINCIPAL
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(23),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF312E81),
                  Color(0xFF4F46E5),
                  Color(0xFF818CF8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -8,
                  top: -12,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 100,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'TECNOLOGÍA · IDEAS · CREATIVIDAD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(height: 23),

                    const Text(
                      'El conocimiento\nno tiene límites.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        height: 1.18,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'Descubre ideas, aprende nuevas habilidades '
                      'y explora el mundo digital.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${todosLosPosts.length} artículos disponibles',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // BUSCADOR
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: mostrarBuscador
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: TextField(
                controller: searchController,
                onChanged: (valor) {
                  setState(() {
                    busqueda = valor;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Buscar artículos, autores...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF929AAF),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: azul,
                  ),
                  suffixIcon: busqueda.isNotEmpty
                      ? IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () {
                            searchController.clear();
                            setState(() {
                              busqueda = '';
                            });
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                          ),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 17,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7EAF2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7EAF2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17),
                    borderSide: const BorderSide(
                      color: azul,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            secondChild: const SizedBox(
              width: double.infinity,
              height: 0,
            ),
          ),

          // TÍTULO DE CATEGORÍAS
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Explora por tema',
                  style: TextStyle(
                    color: oscuro,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              Icon(
                Icons.tune_rounded,
                color: azul,
                size: 21,
              ),
            ],
          ),

          const SizedBox(height: 15),

          // FILTROS FUNCIONALES
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categorias.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 9),
              itemBuilder: (context, index) {
                final categoria = categorias[index];

                return CategoryChip(
                  text: categoria,
                  selected:
                      categoriaSeleccionada == categoria,
                  onTap: () {
                    setState(() {
                      categoriaSeleccionada = categoria;
                    });
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 28),

          // ENCABEZADO DE PUBLICACIONES
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  'Descubre artículos',
                  style: TextStyle(
                    color: oscuro,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                  ),
                ),
              ),
              Text(
                '${posts.length} resultados',
                style: const TextStyle(
                  color: Color(0xFF7B8499),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            'Contenido seleccionado para ti',
            style: TextStyle(
              color: Color(0xFF8991A4),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 19),

          // LISTA DE PUBLICACIONES O ESTADO VACÍO
          if (posts.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 35,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFE7EAF2),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 55,
                    color: Color(0xFFA5AEC2),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'No encontramos artículos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: oscuro,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Prueba con otra búsqueda o selecciona '
                    'una categoría diferente.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7B8499),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        busqueda = '';
                        categoriaSeleccionada = 'Todos';
                      });
                    },
                    icon: const Icon(
                      Icons.refresh_rounded,
                    ),
                    label: const Text('Mostrar todos'),
                  ),
                ],
              ),
            )
          else
            ...posts.map(
              (post) => PostCard(
                post: post,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PostDetailPage(post: post),
                    ),
                  );
                },
              ),
            ),

          const SizedBox(height: 10),

          // PIE DE PÁGINA
          const Center(
            child: Text(
              'DeividBlog  •  Aprende algo nuevo cada día',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9AA2B4), 
                fontSize: 10,
                letterSpacing: 0.7,
                fontWeight: FontWeight.w600,
                ),
            ),
          ),
        ],
      ); // Cierra ListView
    }, // Cierra builder
  ), // Cierra FutureBuilder
); // Cierra Scaffold
  }
}