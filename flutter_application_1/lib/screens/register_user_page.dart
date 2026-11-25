import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../widgets/auth_background.dart';
import '../widgets/auth_card.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({
    super.key,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // Estos campos deben estar dentro de _RegisterPageState.
  final TextEditingController confirmarPasswordController =
      TextEditingController();

  final AuthService authService = AuthService();

  // Puede cambiar mientras se procesa el registro.
  bool cargando = false;

  // Tipo de usuario a crear: 1 = administrador, 2 = general.
  int tipoUsuario = 2;

  // Datos del usuario que tiene la sesión (llegan desde el Drawer).
  Map<String, dynamic>? _sesion;

  // Solo un administrador puede elegir el tipo de cuenta. El registro
  // público (desde el login) siempre crea usuarios generales.
  bool get esAdmin =>
      ((_sesion?['tip_usu'] as num?) ?? 2).toInt() == 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _sesion = Map<String, dynamic>.from(args);
    }
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();

    super.dispose();
  }

  // Conserva aquí tu método registrarUsuario()
  // y el método build() que ya tienes.

  
Future<void> registrarUsuario() async {
  debugPrint('Iniciando registro de usuario...');

  if (cargando) return;

  final nombre = nombreController.text.trim();
  final correo = correoController.text.trim();
  final password = passwordController.text;
  final confirmarPassword = confirmarPasswordController.text;

  // Validar los campos.
  final mensaje = authService.validarRegistro(
    nombre: nombre,
    correo: correo,
    password: password,
    confirmarPassword: confirmarPassword,
  );

  if (mensaje != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
    return;
  }

  // Activar el indicador de carga.
  setState(() {
    cargando = true;
  });

  try {
    debugPrint('Enviando registro a FastAPI...');

    // Registrar realmente al usuario en la base de datos.
    await authService.registrar(
      nombre: nombre,
      correo: correo,
      password: password,
      tipoUsuario: esAdmin ? tipoUsuario : 2,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada correctamente'),
      ),
    );

    // Si hay pantalla anterior (login) se regresa; si se llegó desde el
    // Drawer (pushReplacement) se vuelve a la gestión de usuarios.
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/users',
        arguments: ModalRoute.of(context)?.settings.arguments,
      );
    }

  } catch (e) {
    if (!mounted) return;

    final mensajeError =
        e.toString().replaceFirst('Exception: ', '');

    debugPrint('Error durante el registro: $mensajeError');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensajeError)),
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
                  Icons.person_add,
                  size: 65,
                  color:
                      Color(0xFF2196F3),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'CREAR CUENTA',

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
                  controller:
                      nombreController,

                  label:
                      'Nombre completo',

                  prefixIcon:
                      Icons.person,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      correoController,

                  label:
                      'Correo electrónico',

                  prefixIcon:
                      Icons.email,

                  keyboardType:
                      TextInputType.emailAddress,
                ),

                const SizedBox(
                  height: 15,
                ),

                CustomTextField(
                  controller:
                      passwordController,

                  label:
                      'Contraseña',

                  prefixIcon:
                      Icons.lock,

                  obscureText: true,
                ),

                const SizedBox(
                  height: 15,
                ),
                CustomTextField(
                  controller:
                      confirmarPasswordController,
                  label:
                      'Confirmar contraseña',
                  prefixIcon:
                      Icons.lock_outline,
                  obscureText: true,
                ),
                if (esAdmin) ...[
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: tipoUsuario,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de usuario',
                      prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('General')),
                      DropdownMenuItem(value: 1, child: Text('Administrador')),
                    ],
                    onChanged: cargando
                        ? null
                        : (valor) =>
                            setState(() => tipoUsuario = valor ?? 2),
                  ),
                ],

                const SizedBox(
                  height: 25,
                ),

                PrimaryButton(
                  text: cargando ? 'REGISTRANDO...' : 'REGISTRARME',
                  onPressed: registrarUsuario,
                ),

                const SizedBox(
                  height: 15,
                ),

                TextButton(

                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushReplacementNamed(
                        context,
                        '/users',
                        arguments: ModalRoute.of(context)?.settings.arguments,
                      );
                    }
                  },

                  child: const Text(
                    'Ya tengo una cuenta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}