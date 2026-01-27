import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/colors.dart';
import '../auth/login.dart';
import '../vaccination_record/new_patient_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Mi Vacuna',
          style: TextStyle(
            color: Color(0xFF111318),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.logout();
              Get.offAll(() => const LoginPage());
            },
          ),
        ],
      ),
      body: Obx(() {
        final nurse = authController.currentNurse.value;
        if (nurse == null) {
          return const Center(child: Text('No hay usuario'));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: primaryColor.withOpacity(0.1),
                          child: Text(
                            nurse.firstName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nurse.fullName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111318),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                nurse.institution,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF616F89),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.badge_outlined,
                      '${nurse.idType}: ${nurse.idNumber}',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.email_outlined, nurse.email),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.phone_outlined, nurse.phone),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Panel de Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111318),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const NewPatientPage());
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Nuevo Paciente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF135BEC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aquí puedes agregar las funcionalidades de la aplicación...',
                style: TextStyle(color: Color(0xFF616F89)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF616F89)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Color(0xFF111318)),
          ),
        ),
      ],
    );
  }
}
