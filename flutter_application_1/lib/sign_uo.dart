import 'package:flutter/material.dart';

void main() {
  runApp(const RegistroApp());
}

class RegistroApp extends StatelessWidget {
  const RegistroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crear cuenta',
      home: const RegistroPage(),
    );
  }
}

class RegistroPage extends StatefulWidget {
  const RegistroPage({super.key});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController correoController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmarPasswordController =
      TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  void registrarse() {
    String nombre = nombreController.text.trim();
    String correo = correoController.text.trim();
    String password = passwordController.text;
    String confirmarPassword =
        confirmarPasswordController.text;

    if (nombre.isEmpty ||
        correo.isEmpty ||
        password.isEmpty ||
        confirmarPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Completa todos los campos',
          ),
        ),
      );

      return;
    }

    if (password != confirmarPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Las contraseñas no coinciden',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Cuenta creada correctamente para $nombre',
        ),
      ),
    );
  }

  InputDecoration estiloCampo({
    required String hint,
    required IconData icono,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF52657A),
        fontSize: 13,
      ),

      prefixIcon: Icon(
        icono,
        color: const Color(0xFF294766),
        size: 19,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: const Color(0xFFF4F8FB),

      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 10,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFD5E0E8),
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFFD5E0E8),
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: Color(0xFF0BB89C),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE9F8F7),
              Color(0xFFF1F7FB),
              Color(0xFFE8EEF7),
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 15,
              ),

              child: Container(
                width: 340,

                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),

                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

        // Imagen de icono
                    Container(
                      width: 82,
                      height: 82,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFBDEEE8),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
                      ),

                      child: ClipOval(
                         child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTcjyS9E6wUw7avfbufwsV50Q0VD_j12QoHBt1zdJjjdsZ2z0P8fOfxGdw&s=10',
                        width: 82,
                        height: 82,
                        fit: BoxFit.cover,
                      ),
                      ),
                    ),

                    const SizedBox(height: 12),

        // ==== Crear cuenta Titulo ====
                    const Text(
                      'CREAR CUENTA',
                      textAlign: TextAlign.center,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: Color(0xFF123B63),
                      ),
                    ),

                    const SizedBox(height: 16),

        // ===== Nombre =====
                    TextField(
                      controller: nombreController,

                      decoration: estiloCampo(
                        hint: 'Nombre completo',
                        icono: Icons.person_outline,
                      ),
                    ),

                    const SizedBox(height: 10),

        // ==== Correo electronico ====
                    TextField(
                      controller: correoController,
                      keyboardType:
                          TextInputType.emailAddress,

                      decoration: estiloCampo(
                        hint: 'Correo electrónico',
                        icono: Icons.email_outlined,
                      ),
                    ),

                    const SizedBox(height: 10),

        // ==== contraseña ====
                    TextField(
                      controller: passwordController,
                      obscureText: ocultarPassword,

                      decoration: estiloCampo(
                        hint: 'Contraseña',
                        icono: Icons.lock_outline,

                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,

                            color: const Color(0xFF52657A),
                            size: 19,
                          ),

                          onPressed: () {
                            setState(() {
                              ocultarPassword =
                                  !ocultarPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

        // ==== Confirmacion de contraseña ====
                    TextField(
                      controller:
                          confirmarPasswordController,

                      obscureText:
                          ocultarConfirmarPassword,

                      decoration: estiloCampo(
                        hint: 'Confirmar contraseña',
                        icono: Icons.lock_outline,

                        suffixIcon: IconButton(
                          icon: Icon(
                            ocultarConfirmarPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,

                            color: const Color(0xFF52657A),
                            size: 19,
                          ),

                          onPressed: () {
                            setState(() {
                              ocultarConfirmarPassword =
                                  !ocultarConfirmarPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

        // ==== Boton de registrarse ====
                    SizedBox(
                      width: double.infinity,
                      height: 45,

                      child: ElevatedButton(
                        onPressed: registrarse,

                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF0BB89C),

                          foregroundColor:
                              Colors.white,

                          elevation: 2,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                        ),

                        child: const Text(
                          'REGISTRARME',

                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

        // ==== Iniciar Sesion =====
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Text(
                          '¿Ya tienes una cuenta? ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF52657A),
                          ),
                        ),

                        GestureDetector(
                          onTap: () {
                            print(
                              'Ir a iniciar sesión',
                            );
                          },

                          child: const Text(
                            'Ingresar',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF174B77),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}