
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'session_service.dart';

class UserService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<List<UserModel>> obtenerUsuarios() async {
    final respuesta = await http
        .get(Uri.parse('$baseUrl/usuarios'), headers: SessionService.headers)
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode != 200) {
      throw Exception(
        'Error al obtener los usuarios: ${respuesta.statusCode}',
      );
    }

    final List<dynamic> datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

    return datos
        .map(
          (json) => UserModel.fromJson(
            json as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<UserModel> agregarUsuario(UserModel usuario) async {
    final respuesta = await http
        .post(
          Uri.parse('$baseUrl/usuarios'),
          headers: SessionService.headers,
          body: jsonEncode(usuario.toJsonCrear()),
        )
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode == 201) {
      return UserModel.fromJson(
        jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  Future<UserModel> actualizarUsuario(UserModel usuario) async {
    final respuesta = await http
        .put(
          Uri.parse('$baseUrl/usuarios/${usuario.id}'),
          headers: SessionService.headers,
          body: jsonEncode({
            'nom_usr': usuario.nombre,
            'mail': usuario.correo,
            'dir_usr': usuario.direccion,
            'tip_usu': usuario.tipoUsuario,
          }),
        )
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>,
      );
    }

    throw Exception(_mensajeError(respuesta));
  }

  Future<void> eliminarUsuario(int id) async {
    final respuesta = await http
        .delete(Uri.parse('$baseUrl/usuarios/$id'), headers: SessionService.headers)
        .timeout(const Duration(seconds: 10));

    await SessionService.validarRespuesta(respuesta.statusCode);

    if (respuesta.statusCode != 200 &&
        respuesta.statusCode != 204) {
      throw Exception(_mensajeError(respuesta));
    }
  }

  String _mensajeError(http.Response respuesta) {
    try {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

      if (datos is Map && datos['detail'] != null) {
        return datos['detail'].toString();
      }
    } catch (_) {
      // La respuesta no contiene JSON válido.
    }

    return 'Error HTTP ${respuesta.statusCode}: ${respuesta.body}';
  }
}
