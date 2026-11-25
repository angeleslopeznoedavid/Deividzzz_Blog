import 'package:flutter/material.dart';

class RecoverPage extends StatefulWidget {
  const RecoverPage({super.key});

  @override
  State<RecoverPage> createState() => _RecoverPageState();
}

class _RecoverPageState extends State<RecoverPage> {
  final TextEditingController correoController = TextEditingController();

  @override
  void dispose() {
    correoController.dispose();
    super.dispose();
  }

  void recuperarPassword() {
    String correo = correoController.text.trim();

    if (correo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa tu correo electrónico',
          ),
        ),
      );

      return;
    }

    if (!correo.contains('@') || !correo.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ingresa un correo válido',
          ),
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Se envió un correo de recuperación a $correo',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE6F6FF),
              Color(0xFFBFD9FF),
              Color(0xFFD9D1FF),
              Color(0xFFE8DFFF),
            ],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: 340,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_reset,
                      size: 65,
                      color: Color(0xFFC9A227),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'RECUPERAR CONTRASEÑA',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF08245C),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: recuperarPassword,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(
                          double.infinity,
                          48,
                        ),
                        backgroundColor: const Color(
                          0xFF2196F3,
                        ),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'ENVIAR ENLACE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '¿Ya la recordaste?',
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Iniciar sesión',
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