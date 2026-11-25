import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/comentarios_model.dart';
import 'session_service.dart';

class ComentarioService {
  static String get baseUrl => ApiConfig.baseUrl;

  /// GET /comentarios?blog_id=X — comentarios de una publicación.
  Future<List<ComentarioModel>> obtenerComentarios({int? blogId}) async {
    final uri = Uri.parse('$baseUrl/comentarios').replace(
      queryParameters: blogId == null ? null : {'blog_id': '$blogId'},
    );

    final respuesta = await http
        .get(uri, headers: SessionService.headers)
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al consultar comentarios: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    return datos
        .map((json) => ComentarioModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// POST /comentarios — el autor lo toma el servidor del token.
  Future<void> agregarComentario(ComentarioModel comentario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/comentarios'),
          headers: SessionService.headers,
          body: jsonEncode(comentario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode != 201) {
      throw Exception('No se pudo registrar el comentario: ${respuesta.body}');
    }
  }
}
