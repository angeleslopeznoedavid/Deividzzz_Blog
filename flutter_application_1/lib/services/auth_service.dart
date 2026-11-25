
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'session_service.dart';

class AuthService {
  // Dirección de FastAPI (configurable con --dart-define=API_URL=...).
  static String get _baseUrl => ApiConfig.baseUrl;

  String? validarLogin({
    required String usuario,
    required String password,
  }) {
    if (usuario.trim().isEmpty || password.isEmpty) {
      return 'Completa usuario y contraseña';
    }

    if (!usuario.trim().contains('@')) {
      return 'Ingresa un correo válido';
    }

    return null;
  }

  String? validarRegistro({
    required String nombre,
    required String correo,
    required String password,
    required String confirmarPassword,
  }) {
    if (nombre.trim().isEmpty ||
        correo.trim().isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      return 'Completa todos los campos';
    }

    if (!correo.trim().contains('@')) {
      return 'Ingresa un correo válido';
    }

    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }

    if (password != confirmarPassword) {
      return 'Las contraseñas no coinciden';
    }

    return null;
  }

  // Envía las credenciales a FastAPI y devuelve los datos del usuario.
  Future<Map<String, dynamic>> autenticar({
    required String correo,
    required String password,
  }) async {
    try {
      final respuesta = await http
          .post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'mail': correo.trim().toLowerCase(),
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (respuesta.statusCode == 200) {
        final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

        if (datos is Map<String, dynamic>) {
          // Guarda el JWT y los datos del usuario en almacenamiento cifrado.
          await SessionService.guardar(datos);
          return datos;
        }

        throw Exception('La respuesta de la API no es válida');
      }

      if (respuesta.statusCode == 401) {
        throw Exception('Correo o contraseña incorrectos');
      }

      throw Exception(
        'Error al iniciar sesión (${respuesta.statusCode})',
      );
    } on TimeoutException {
      throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
    } on http.ClientException {
      throw Exception(
        'No se pudo conectar con la API. Verifica que FastAPI esté activo.',
      );
    } on FormatException {
      throw Exception('La API devolvió una respuesta no válida.');
    }
  }
  
Future<Map<String, dynamic>> registrar({
  required String nombre,
  required String correo,
  required String password,
  int tipoUsuario = 2, // 1 = administrador, 2 = general
}) async {
  try {
    final respuesta = await http
        .post(
          Uri.parse('$_baseUrl/usuarios'),
          headers: SessionService.headers,
          body: jsonEncode({
            'nom_usr': nombre.trim(),
            'mail': correo.trim().toLowerCase(),
            'password': password,
            'tip_usu': tipoUsuario,
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (respuesta.statusCode == 201) {
      final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));

      if (datos is Map<String, dynamic>) {
        return datos;
      }

      throw Exception('La respuesta de la API no es válida');
    }

    if (respuesta.statusCode == 409) {
      throw Exception('Este correo ya está registrado');
    }

    if (respuesta.statusCode == 422) {
      throw Exception(
        'Revisa los datos. La contraseña debe tener al menos 8 caracteres.',
      );
    }

    throw Exception(
      'No se pudo registrar el usuario (${respuesta.statusCode})',
    );
  } on TimeoutException {
    throw Exception('La solicitud tardó demasiado. Intenta de nuevo.');
  } on http.ClientException {
    throw Exception(
      'No se pudo conectar con la API. Verifica que FastAPI esté activo.',
    );
  } on FormatException {
    throw Exception('La API devolvió una respuesta no válida.');
  }
}

}
