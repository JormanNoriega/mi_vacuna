import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/InputField.dart';
import '../../widgets/PasswordField.dart';
import '../../widgets/DropdownField.dart';
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

  String? selectedIdType;
  final List<Map<String, String>> idTypes = [
    {'value': '', 'label': 'Selecciona tipo de ID'},
    {'value': 'CN', 'label': 'CN - Certificado de Nacido Vivo'},
    {'value': 'RC', 'label': 'RC - Registro Civil'},
    {'value': 'TI', 'label': 'TI - Tarjeta de Identidad'},
    {'value': 'CC', 'label': 'CC - Cédula de Ciudadanía'},
    {'value': 'AS', 'label': 'AS - Adulto sin Identificación'},
    {'value': 'MS', 'label': 'MS - Menor sin Identificación'},
    {'value': 'CE', 'label': 'CE - Cédula de Extranjería'},
    {'value': 'PA', 'label': 'PA - Pasaporte'},
    {'value': 'CD', 'label': 'CD - Carné Diplomático'},
    {'value': 'SC', 'label': 'SC - Salvoconducto'},
    {'value': 'PE', 'label': 'PE - Permiso Especial de Permanencia'},
    {'value': 'PPT', 'label': 'PPT - Permiso por Protección Temporal'},
    {'value': 'DE', 'label': 'DE - Documento Extranjero'},
  ];

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
              DropdownField(
                label: 'Tipo de identificación',
                hint: 'Selecciona tipo de ID',
                icon: Icons.badge_outlined,
                items: idTypes,
                value: selectedIdType,
                onChanged: (value) {
                  setState(() {
                    selectedIdType = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              // ID Number
              InputField(
                controller: idController,
                label: 'Número de identificación',
                hint: 'Ingresa tu número de identificación',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Solo se permiten números';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Names
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      controller: firstNameController,
                      label: 'Nombre(s)',
                      hint: 'Ejemplo: Juana',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InputField(
                      controller: lastNameController,
                      label: 'Apellido(s)',
                      hint: 'Ejemplo: Pérez',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Email
              InputField(
                controller: emailController,
                label: 'Correo electrónico',
                hint: 'ejemplo@salud.org',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'El correo debe contener @';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Phone
              InputField(
                controller: phoneController,
                label: 'Teléfono',
                hint: '3001234567',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es requerido';
                  }
                  if (value.length != 10) {
                    return 'El teléfono debe tener 10 dígitos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Institution
              InputField(
                controller: institutionController,
                label: 'Institución de salud',
                hint: 'Nombre del hospital o clínica',
                icon: Icons.domain_outlined,
              ),
              const SizedBox(height: 16),
              // Password
              PasswordField(
                controller: passwordController,
                label: 'Contraseña',
                hintText: 'Crea una contraseña segura',
              ),
              const SizedBox(height: 16),
              PasswordField(
                controller: confirmPasswordController,
                label: 'Confirmar contraseña',
                hintText: 'Repite tu contraseña',
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
