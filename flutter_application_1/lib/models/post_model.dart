class PostModel {
  final int id;
  final String titulo;
  final String autor;
  final int? usuarioId;
  final String categoria;
  final String descripcion;
  final String contenido;
  final String imagen;
  final String fecha;

  PostModel({
    required this.id,
    required this.titulo,
    required this.autor,
    this.usuarioId,
    required this.categoria,
    required this.descripcion,
    required this.contenido,
    required this.imagen,
    required this.fecha,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final descripcion = json['descripcion']?.toString() ?? '';
    final fechaCruda = json['fecha']?.toString() ?? '';
    final fecha =
    fechaCruda.length >= 10 ? fechaCruda.substring(0, 10) : fechaCruda;

    return PostModel(
      id: (json['id_blog'] as num).toInt(),
      titulo: json['titulo']?.toString() ?? '',
      autor: json['autor']?.toString() ?? 'Anónimo',
      usuarioId: (json['usr_id'] as num?)?.toInt(),
      categoria:
      json['categoria']?.toString() ?? json['tags']?.toString() ?? '',
      descripcion: descripcion,
      contenido: json['contenido']?.toString() ?? descripcion,
      imagen: json['imagen']?.toString() ?? json['img']?.toString() ?? '',
      fecha: fecha,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'categoria': categoria,
      'descripcion': descripcion,
      'contenido': contenido,
      'imagen': imagen,
      'fecha': fecha,
    };
  }
}