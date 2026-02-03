import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/custom_snackbar.dart';
import '../../theme/colors.dart';
import '../home/main_navigation_page.dart';
import 'register_nurse.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Acceso exclusivo para personal de enfermería y salud.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Color(0xFF616F89)),
                  ),
                ),

                const SizedBox(height: 32),

                /// FORMULARIO
                FormFields.buildTextField(
                  label: 'Correo electrónico o ID',
                  controller: emailController,
                  placeholder: 'ejemplo@salud.org',
                  required: true,
                ),

                FormFields.buildPasswordField(
                  label: 'Contraseña',
                  controller: passwordController,
                  placeholder: 'Ingresa tu contraseña',
                  required: true,
                ),

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

                // Mensaje de error
                Obx(() {
                  if (authController.errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authController.errorMessage.value,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                /// BOTON LOGIN
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: authController.isLoading.value
                          ? null
                          : () async {
                              authController.clearError();
                              final success = await authController.login(
                                emailOrId: emailController.text.trim(),
                                password: passwordController.text,
                              );

                              if (success) {
                                CustomSnackbar.showSuccess(
                                  'Bienvenido ${authController.currentNurse.value!.fullName}',
                                );
                                Get.offAll(() => const MainNavigationPage());
                              }
                            },
                      icon: authController.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.login),
                      label: Text(
                        authController.isLoading.value
                            ? 'INGRESANDO...'
                            : 'INICIAR SESIÓN',
                        style: const TextStyle(
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
                ),

                const SizedBox(height: 32),

                // Botón para ir a registro
                Center(
                  child: TextButton(
                    onPressed: () {
                      Get.to(() => const RegisterNursePage());
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "¿No tienes cuenta? ",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
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
        ),
      ),
    );
  }
}
