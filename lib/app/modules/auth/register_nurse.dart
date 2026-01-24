import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/InputField.dart';
import '../../widgets/PasswordField.dart';
import '../../widgets/DropdownField.dart';
import '../../theme/colors.dart';

class RegisterNursePage extends StatefulWidget {
  const RegisterNursePage({Key? key}) : super(key: key);

  @override
  State<RegisterNursePage> createState() => _RegisterNursePageState();
}

class _RegisterNursePageState extends State<RegisterNursePage> {
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
              const SizedBox(height: 24),
              // Register button
              SizedBox(
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
                  onPressed: () {},
                  child: const Text(
                    'REGISTRARME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {},
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
