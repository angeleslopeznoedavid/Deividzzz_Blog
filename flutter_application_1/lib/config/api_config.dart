/// Dirección base de la API FastAPI.
///
/// Se puede cambiar SIN tocar el código con --dart-define:
///   Emulador Android (valor por defecto): http://10.0.2.2:8000
///   Celular físico (misma red Wi-Fi):
///     flutter run   --dart-define=API_URL=http://192.168.1.50:8000
///     flutter build apk --dart-define=API_URL=http://192.168.1.50:8000
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
