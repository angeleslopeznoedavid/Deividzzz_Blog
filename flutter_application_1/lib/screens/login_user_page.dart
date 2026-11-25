import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/session_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';


class LoginPage extends StatefulWidget {

  const LoginPage({
    super.key,
  });

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState
    extends State<LoginPage> {

  final TextEditingController usuarioController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final AuthService authService =
      AuthService();

  bool ocultarPassword = true;
  bool cargando = false;

  @override
  void initState() {
    super.initState();
    // Si ya hay una sesión guardada, entra directo sin pedir credenciales.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restaurarSesion());
  }

  Future<void> _restaurarSesion() async {
    await SessionService.cargar();
    final u = SessionService.usuario;
    if (u == null || !mounted) return;
    final ruta = (u['tip_usu'] as num?)?.toInt() == 1 ? '/users' : '/blog';
    Navigator.pushNamedAndRemoveUntil(
      context,
      ruta,
      (route) => false,
      arguments: u,
    );
  }

  @override
  void dispose() {
    usuarioController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  
Future<void> iniciarSesion() async {
  if (cargando) return;

  final correo = usuarioController.text.trim();
  final password = passwordController.text;

  // Validar los campos antes de llamar a la API.
  final errorValidacion = authService.validarLogin(
    usuario: correo,
    password: password,
  );

  if (errorValidacion != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorValidacion)),
    );
    return;
  }

  setState(() {
    cargando = true;
  });

  try {
    // Consultar el endpoint POST /login de FastAPI.
    final datos = await authService.autenticar(
      correo: correo,
      password: password,
    );

    if (!mounted) return;

    // Obtener el tipo de usuario devuelto por la API.
    final tipoUsuario = datos['tip_usu'];

    String? ruta;

    if (tipoUsuario == 1) {
      ruta = '/users';
    } else if (tipoUsuario == 2) {
      ruta = '/blog';
    }

    if (ruta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El tipo de usuario no es válido'),
        ),
      );
      return;
    }

    // Entrar a la pantalla correspondiente y quitar el login
    // del historial de navegación.
    // Se envían los datos del usuario para que el Drawer los muestre.
    Navigator.pushNamedAndRemoveUntil(
      context,
      ruta,
      (route) => false,
      arguments: datos,
    );
  } catch (e) {
    if (!mounted) return;

    final mensaje = e.toString().replaceFirst('Exception: ', '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  } finally {
    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }
}


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: AuthBackground(

        child: Center(

          child: AuthCard(

            child: Column(

              mainAxisSize:
                  MainAxisSize.min,

              children: [

                const Icon(
                  Icons.lock,
                  size: 65,
                  color:
                      Color(0xFFC9A227),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'INICIAR SESIÓN',

                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF08245C),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                CustomTextField(
                  controller: usuarioController,
                  label: 'Correo electrónico',
                  prefixIcon: Icons.email_outlined,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label: 'Contraseña',

                  prefixIcon:
                      Icons.lock_outline,

                  obscureText:
                      ocultarPassword,

                  suffixIcon:
                      IconButton(

                    icon: Icon(
                      ocultarPassword
                          ? Icons
                              .visibility_off_outlined
                          : Icons
                              .visibility_outlined,
                    ),

                    onPressed: () {

                      setState(() {

                        ocultarPassword =
                            !ocultarPassword;

                      });
                    },
                  ),
                ),
                const SizedBox(height: 15),

                Align(

                  alignment:
                      Alignment.centerRight,

                  child: TextButton(

                    onPressed: () {
                      
                        Navigator.pushNamed(
                          context,
                          '/recover',
                        );
                    },

                    child: const Text(
                      '¿Olvidaste tu contraseña?',
                    ),
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                PrimaryButton(
                  text: cargando ? 'INGRESANDO...' : 'INGRESAR',
                  onPressed: iniciarSesion,
                ),

                const SizedBox(
                  height: 15,
                ),

                Row(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    const Text(
                      '¿No tienes cuenta?',
                    ),

                    TextButton(

                      onPressed: () {

                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },

                      child: const Text(
                        'Registrarse',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}