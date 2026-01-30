import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/form_fields.dart';
import '../../theme/colors.dart';
import '../home/home_page.dart';

class RegisterNursePage extends StatefulWidget {
  const RegisterNursePage({Key? key}) : super(key: key);

  @override
  State<RegisterNursePage> createState() => _RegisterNursePageState();
}

class _RegisterNursePageState extends State<RegisterNursePage> {
  final AuthController authController = Get.find();
  final TextEditingController idController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController institutionController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String? selectedIdType = 'CC';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Registro de Enfermera',
          style: TextStyle(
            color: Color(0xFF111318),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111318)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111318),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Regístrate para gestionar vacunaciones y expedientes de pacientes incluso sin conexión.',
                style: TextStyle(fontSize: 15, color: Color(0xFF616F89)),
              ),
              const SizedBox(height: 20),
              // ID Type
              FormFields.buildDropdownField(
                label: 'Tipo de identificación',
                value: selectedIdType ?? 'CC',
                items: const [
                  'CC - Cédula de Ciudadanía',
                  'CE - Cédula de Extranjería',
                  'PA - Pasaporte',
                  'TI - Tarjeta de Identidad',
                ],
                onChanged: (value) {
                  setState(() {
                    selectedIdType = value;
                  });
                },
                required: true,
              ),
              // ID Number
              FormFields.buildTextField(
                label: 'Número de identificación',
                controller: idController,
                placeholder: 'Ingresa tu número de identificación',
                keyboardType: TextInputType.number,
                required: true,
              ),
              // Names
              Row(
                children: [
                  Expanded(
                    child: FormFields.buildTextField(
                      label: 'Nombre(s)',
                      controller: firstNameController,
                      placeholder: 'Ejemplo: Juana',
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormFields.buildTextField(
                      label: 'Apellido(s)',
                      controller: lastNameController,
                      placeholder: 'Ejemplo: Pérez',
                      required: true,
                    ),
                  ),
                ],
              ),
              // Email
              FormFields.buildTextField(
                label: 'Correo electrónico',
                controller: emailController,
                placeholder: 'ejemplo@salud.org',
                keyboardType: TextInputType.emailAddress,
                required: true,
              ),
              // Phone
              FormFields.buildTextField(
                label: 'Teléfono',
                controller: phoneController,
                placeholder: '3001234567',
                keyboardType: TextInputType.phone,
                required: true,
              ),
              // Institution
              FormFields.buildTextField(
                label: 'Institución de salud',
                controller: institutionController,
                placeholder: 'Nombre del hospital o clínica',
                required: true,
              ),
              // Password
              FormFields.buildPasswordField(
                label: 'Contraseña',
                controller: passwordController,
                placeholder: 'Crea una contraseña segura',
                required: true,
              ),
              FormFields.buildPasswordField(
                label: 'Confirmar contraseña',
                controller: confirmPasswordController,
                placeholder: 'Repite tu contraseña',
                required: true,
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
              const SizedBox(height: 8),
              // Register button
              Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: authController.isLoading.value
                        ? null
                        : () async {
                            authController.clearError();

                            // Validaciones
                            if (selectedIdType == null ||
                                selectedIdType == '') {
                              Get.snackbar(
                                'Error',
                                'Selecciona un tipo de identificación',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (idController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Ingresa tu número de identificación',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (firstNameController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Ingresa tu nombre',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (lastNameController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Ingresa tu apellido',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (!emailController.text.contains('@')) {
                              Get.snackbar(
                                'Error',
                                'Ingresa un correo válido',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (phoneController.text.length != 10) {
                              Get.snackbar(
                                'Error',
                                'El teléfono debe tener 10 dígitos',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (institutionController.text.trim().isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Ingresa tu institución de salud',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (passwordController.text.length < 6) {
                              Get.snackbar(
                                'Error',
                                'La contraseña debe tener al menos 6 caracteres',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              Get.snackbar(
                                'Error',
                                'Las contraseñas no coinciden',
                                backgroundColor: Colors.red.shade100,
                                colorText: Colors.red.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              return;
                            }

                            // Registrar
                            final success = await authController.register(
                              idType: selectedIdType!,
                              idNumber: idController.text.trim(),
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              phone: phoneController.text.trim(),
                              institution: institutionController.text.trim(),
                              password: passwordController.text,
                            );

                            if (success) {
                              Get.snackbar(
                                'Éxito',
                                'Cuenta creada exitosamente. Bienvenido ${authController.currentNurse.value!.fullName}',
                                backgroundColor: Colors.green.shade100,
                                colorText: Colors.green.shade900,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                              Get.offAll(() => const HomePage());
                            }
                          },
                    child: authController.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'REGISTRARME',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text.rich(
                    TextSpan(
                      text: '¿Ya tienes cuenta? ',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Inicia sesión',
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
    );
  }
}
