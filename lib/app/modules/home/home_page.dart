import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../theme/colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/action_card.dart';
import '../export/export_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final HomeController homeController = Get.put(HomeController());
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;
    final padding = isTablet ? 32.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundMedium,
      body: Obx(() {
        final nurse = authController.currentNurse.value;
        if (nurse == null) {
          return const Center(child: Text('No hay usuario'));
        }

        if (homeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: homeController.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con información del usuario
                _buildUserHeader(nurse, isTablet),
                SizedBox(height: isTablet ? 32 : 24),

                // Estadísticas principales
                _buildStatistics(homeController, isTablet),
                SizedBox(height: isTablet ? 32 : 24),

                // Centro de acción
                _buildActionCenter(isTablet),
                SizedBox(height: isTablet ? 32 : 24),

                // Últimos registros
                _buildRecentRecords(homeController, isTablet),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUserHeader(dynamic nurse, bool isTablet) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'es_ES');
    final formattedDate = dateFormat.format(now);

    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 40 : 32,
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
              nurse.firstName[0].toUpperCase(),
              style: TextStyle(
                fontSize: isTablet ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, ${nurse.firstName}',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF111318),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: const Color(0xFF616F89),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nurse.institution,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 13,
                    color: const Color(0xFF616F89),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${nurse.idNumber}',
                  style: TextStyle(
                    fontSize: isTablet ? 13 : 12,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(HomeController controller, bool isTablet) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 960
            ? 3
            : (constraints.maxWidth >= 600 ? 3 : 1);

        // Ajustar aspect ratio según número de columnas
        final childAspectRatio = crossAxisCount == 1
            ? 2.8 // Más ancho en modo vertical
            : (isTablet ? 1.5 : 1.3);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: isTablet ? 20 : 12,
          mainAxisSpacing: isTablet ? 20 : 12,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatCard(
              title: 'PACIENTES HOY',
              value: controller.patientsToday.value.toString(),
              icon: Icons.people,
              iconColor: const Color(0xFF4CAF50),
            ),
            StatCard(
              title: 'DOSIS APLICADAS HOY',
              value: controller.dosesToday.value.toString(),
              icon: Icons.vaccines,
              iconColor: const Color(0xFF2196F3),
            ),
            StatCard(
              title: 'VACUNAS REGISTRADAS',
              value: controller.totalVaccines.value.toString(),
              icon: Icons.medical_services,
              iconColor: const Color(0xFF9C27B0),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionCenter(bool isTablet) {
    final navController = Get.find<NavigationController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Centro de Acción',
          style: TextStyle(
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF111318),
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 960
                ? 4
                : (constraints.maxWidth >= 600 ? 2 : 2);

            // Aspect ratio más alto en móvil para evitar overflow
            final childAspectRatio = constraints.maxWidth >= 600
                ? (isTablet ? 1.2 : 1.0)
                : 0.95; // Más cuadrado en móvil

            return GridView.count(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isTablet ? 20 : 12,
              mainAxisSpacing: isTablet ? 20 : 12,
              childAspectRatio: childAspectRatio,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ActionCard(
                  title: 'Nueva Atención',
                  subtitle: 'Registrar paciente',
                  icon: Icons.person_add,
                  isPrimary: true,
                  onTap: () => navController.goToNewPatient(),
                ),
                ActionCard(
                  title: 'Historial',
                  subtitle: 'Ver registros',
                  icon: Icons.history,
                  iconColor: const Color(0xFF2196F3),
                  onTap: () => navController.goToHistory(),
                ),
                ActionCard(
                  title: 'Inventario',
                  subtitle: 'Gestión de vacunas',
                  icon: Icons.inventory_2,
                  iconColor: const Color(0xFF4CAF50),
                  onTap: () => navController.goToInventory(),
                ),
                ActionCard(
                  title: 'Exportar',
                  subtitle: 'Descargar datos',
                  icon: Icons.file_download,
                  iconColor: const Color(0xFFFF9800),
                  onTap: () => Get.to(() => const ExportPage()),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecentRecords(HomeController controller, bool isTablet) {
    if (controller.recentDoses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Últimos Registros',
              style: TextStyle(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF111318),
              ),
            ),
            TextButton(
              onPressed: () {
                final navController = Get.find<NavigationController>();
                navController.goToHistory();
              },
              child: const Text('Ver todos'),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Container(
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentDoses.length > 5
                ? 5
                : controller.recentDoses.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final dose = controller.recentDoses[index];
              return _buildRecentRecordItem(dose, isTablet);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRecordItem(Map<String, dynamic> dose, bool isTablet) {
    final patientName =
        '${dose['patient_first_name']} ${dose['patient_last_name']}';
    final vaccineName = dose['vaccine_name'] ?? 'Vacuna';
    final applicationDate = DateTime.parse(dose['application_date']);
    final timeAgo = _formatTimeAgo(applicationDate);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 12 : 8,
      ),
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF135BEC).withOpacity(0.1),
        child: Icon(
          Icons.person,
          color: const Color(0xFF135BEC),
          size: isTablet ? 24 : 20,
        ),
      ),
      title: Text(
        patientName,
        style: TextStyle(
          fontSize: isTablet ? 16 : 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF111318),
        ),
      ),
      subtitle: Text(
        vaccineName,
        style: TextStyle(
          fontSize: isTablet ? 14 : 13,
          color: const Color(0xFF616F89),
        ),
      ),
      trailing: Text(
        timeAgo,
        style: TextStyle(
          fontSize: isTablet ? 13 : 12,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM').format(dateTime);
    }
  }
}
