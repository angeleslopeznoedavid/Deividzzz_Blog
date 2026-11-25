import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/post_model.dart';
import 'session_service.dart';

class PostService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// GET /blog — publicaciones propias y de otros usuarios.
  Future<List<PostModel>> obtenerPosts() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/blog'), headers: SessionService.headers)
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar publicaciones: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    return datos
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /blog — crea una publicación (el autor lo define el servidor
  /// a partir del token).
  Future<PostModel> agregarPost({
    required String titulo,
    required String descripcion,
    String? imagen,
    String? tags,
  }) async {
    final imagenLimpia = (imagen ?? '').trim();
    final tagsLimpios = (tags ?? '').trim();

    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/blog'),
          headers: SessionService.headers,
          body: jsonEncode({
            'titulo': titulo.trim(),
            'descripcion': descripcion.trim(),
            'img': imagenLimpia.isEmpty ? null : imagenLimpia,
            'tags': tagsLimpios.isEmpty ? null : tagsLimpios,
          }),
        )
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    dynamic resultado;
    if (respuesta.body.isNotEmpty) {
      try {
        resultado = jsonDecode(utf8.decode(respuesta.bodyBytes));
      } on FormatException {
        resultado = null;
      }
    }

    if ((respuesta.statusCode == 200 || respuesta.statusCode == 201) &&
        resultado is Map<String, dynamic>) {
      return PostModel.fromJson(resultado);
    }

    if (resultado is Map && resultado['detail'] != null) {
      throw Exception(resultado['detail'].toString());
    }

    throw Exception(
      'No se pudo guardar la publicación (HTTP ${respuesta.statusCode})',
    );
  }
}
