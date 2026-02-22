import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../theme/colors.dart';
import '../auth/login.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: Obx(() {
        final nurse = authController.currentNurse.value;
        if (nurse == null) {
          return const Center(child: Text('No hay usuario'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Perfil de usuario
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: isTablet ? 50 : 40,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        nurse.firstName[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: isTablet ? 40 : 32,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    Text(
                      nurse.fullName,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF111318),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nurse.institution,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: const Color(0xFF616F89),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 24 : 20),
                    const Divider(),
                    SizedBox(height: isTablet ? 16 : 12),
                    _buildInfoRow(
                      Icons.badge_outlined,
                      '${nurse.idType}: ${nurse.idNumber}',
                      isTablet,
                    ),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildInfoRow(Icons.email_outlined, nurse.email, isTablet),
                    SizedBox(height: isTablet ? 12 : 8),
                    _buildInfoRow(Icons.phone_outlined, nurse.phone, isTablet),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // Opciones
              Text(
                'Configuración',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111318),
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),

              _buildSettingCard(
                icon: Icons.person_outline,
                title: 'Editar Perfil',
                subtitle: 'Actualizar información personal',
                onTap: () {
                  // TODO: Implementar edición de perfil
                  Get.snackbar(
                    'Próximamente',
                    'Esta función estará disponible pronto',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                },
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 12 : 8),

              _buildSettingCard(
                icon: Icons.lock_outline,
                title: 'Cambiar Contraseña',
                subtitle: 'Actualizar contraseña de acceso',
                onTap: () {
                  // TODO: Implementar cambio de contraseña
                  Get.snackbar(
                    'Próximamente',
                    'Esta función estará disponible pronto',
                    backgroundColor: Colors.orange,
                    colorText: Colors.white,
                  );
                },
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 12 : 8),

              _buildSettingCard(
                icon: Icons.info_outline,
                title: 'Acerca de',
                subtitle: 'Mi Vacuna v1.0.0',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Mi Vacuna',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.vaccines,
                      size: 48,
                      color: primaryColor,
                    ),
                    children: [
                      const Text(
                        'Sistema de gestión de vacunación para instituciones de salud.',
                      ),
                    ],
                  );
                },
                isTablet: isTablet,
              ),
              SizedBox(height: isTablet ? 32 : 24),

              // Cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro que deseas cerrar sesión?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              authController.logout();
                              Get.offAll(() => const LoginPage());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Cerrar Sesión'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar Sesión'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, bool isTablet) {
    return Row(
      children: [
        Icon(icon, size: isTablet ? 22 : 18, color: const Color(0xFF616F89)),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: const Color(0xFF111318),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isTablet,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: isTablet ? 28 : 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111318),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 14 : 13,
            color: const Color(0xFF616F89),
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: isTablet ? 20 : 16,
          color: const Color(0xFF9CA3AF),
        ),
        onTap: onTap,
      ),
    );
  }
}
