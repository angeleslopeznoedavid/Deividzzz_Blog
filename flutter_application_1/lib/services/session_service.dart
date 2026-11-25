import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manejo de sesión: guarda el JWT y los datos del usuario en el
/// almacenamiento cifrado del dispositivo (Android Keystore).
class SessionService {
  static const _storage = FlutterSecureStorage();
  static const _clave = 'sesion_usuario';

  /// Datos del usuario en sesión (incluye 'access_token').
  static Map<String, dynamic>? usuario;

  static String? get token => usuario?['access_token'] as String?;

  static int? get idUsuario => (usuario?['id_usr'] as num?)?.toInt();

  /// Cabeceras para peticiones a la API (agrega el Bearer si hay sesión).
  static Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  /// Lee la sesión guardada (se llama al abrir la app).
  static Future<void> cargar() async {
    try {
      final texto = await _storage.read(key: _clave);
      if (texto != null) {
        usuario = Map<String, dynamic>.from(jsonDecode(texto) as Map);
      }
    } catch (_) {
      usuario = null;
    }
  }

  static Future<void> guardar(Map<String, dynamic> datos) async {
    usuario = Map<String, dynamic>.from(datos);
    await _storage.write(key: _clave, value: jsonEncode(usuario));
  }

  /// Cierra la sesión: borra el token de memoria y del dispositivo.
  static Future<void> cerrar() async {
    usuario = null;
    try {
      await _storage.delete(key: _clave);
    } catch (_) {}
  }

  /// Lanza una excepción legible si la API respondió 401/403.
  static Future<void> validarRespuesta(int codigo) async {
    if (codigo == 401) {
      await cerrar();
      throw Exception('Sesión expirada. Inicia sesión de nuevo.');
    }
    if (codigo == 403) {
      throw Exception('No tienes permisos para esta acción.');
    }
  }
}
