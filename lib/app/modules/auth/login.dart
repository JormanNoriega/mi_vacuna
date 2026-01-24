import 'package:flutter/material.dart';
import '../../widgets/InputField.dart';
import '../../widgets/PasswordField.dart';
import '../../theme/colors.dart';
import 'register_nurse.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),

            /// ICONO
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.vaccines,
                  size: 48,
                  color: primaryColor,
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// TITULO
            const Text(
              'Gestión de Vacunación',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111318),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Acceso exclusivo para personal de enfermería y salud.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF616F89)),
              ),
            ),

            const SizedBox(height: 32),

            /// FORMULARIO
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      InputField(
                        label: 'Correo electrónico o ID',
                        hint: 'ejemplo@salud.org',
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 16),

                      PasswordField(),

                      const SizedBox(height: 8),

                      /// OLVIDE CONTRASEÑA
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            '¿Olvidaste tu contraseña?',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// BOTON LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.login),
                          label: const Text(
                            'INICIAR SESIÓN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 6,
                            shadowColor: primaryColor.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      const SizedBox(height: 32),

                      // Botón para ir a registro
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => RegisterNursePage(),
                              ),
                            );
                          },
                          child: const Text.rich(
                            TextSpan(
                              text: "¿No tienes cuenta? ",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: "Regístrate",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            /// FOOTER
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Versión 2.4.0 • Sistema Nacional de Salud',
                style: TextStyle(fontSize: 12, color: Color(0xFF616F89)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
