import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/navigation_controller.dart';
import '../../controllers/patient_history_controller.dart';
import '../../controllers/vaccine_management_controller.dart';
import '../../theme/colors.dart';
import '../home/home_page.dart';
import '../vaccination_record/vaccination_form_wrapper.dart';
import '../patient_history/patient_history_page.dart';
import '../vaccine_management/vaccine_management_page.dart';
import '../settings/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final NavigationController navController = Get.put(NavigationController());

  // Key para forzar reconstrucción del formulario cuando sea necesario
  final Key _formKey = UniqueKey();

  List<Widget> get _pages => [
    const HomePage(),
    VaccinationFormWrapper(key: _formKey),
    const PatientHistoryPage(),
    const VaccineManagementPage(),
    const SettingsPage(),
  ];

  final List<NavigationDestination> _destinations = const [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Inicio',
    ),
    NavigationDestination(
      icon: Icon(Icons.add_circle_outline),
      selectedIcon: Icon(Icons.add_circle),
      label: 'Nueva Atención',
    ),
    NavigationDestination(
      icon: Icon(Icons.history),
      selectedIcon: Icon(Icons.history),
      label: 'Historial',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: 'Inventario',
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Ajustes',
    ),
  ];

  final List<String> _titles = [
    'Mi Vacuna',
    'Nueva Atención',
    'Historial',
    'Inventario',
    'Ajustes',
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.add_circle,
    Icons.history,
    Icons.inventory_2,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 768;

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundLight,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _icons[navController.currentIndex.value],
                color: primaryColor,
                size: isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 10),
              Text(
                _titles[navController.currentIndex.value],
                style: TextStyle(
                  color: const Color(0xFF111318),
                  fontWeight: FontWeight.bold,
                  fontSize: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
          centerTitle: false,
          iconTheme: const IconThemeData(color: Color(0xFF111318)),
          actions: _buildAppBarActions(),
        ),
        body: IndexedStack(
          index: navController.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: Material(
          color: backgroundLight,
          surfaceTintColor: Colors.transparent,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.1),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withValues(alpha: 0.2),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                height: isTablet ? 70 : 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(
                    _destinations.length,
                    (index) => _buildNavItem(
                      index: index,
                      destination: _destinations[index],
                      isSelected: navController.currentIndex.value == index,
                      isTablet: isTablet,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    final navController = Get.find<NavigationController>();
    switch (navController.currentIndex.value) {
      case 2: // Historial
        if (Get.isRegistered<PatientHistoryController>()) {
          final controller = Get.find<PatientHistoryController>();
          return [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refreshPatients(),
              tooltip: 'Actualizar',
            ),
          ];
        }
        return [];
      case 3: // Inventario
        if (Get.isRegistered<VaccineManagementController>()) {
          final controller = Get.find<VaccineManagementController>();
          return [
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => _showVaccineStatistics(controller),
              tooltip: 'Estadísticas',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => controller.refresh(),
              tooltip: 'Actualizar',
            ),
          ];
        }
        return [];
      default:
        return [];
    }
  }

  void _showVaccineStatistics(VaccineManagementController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.analytics, color: primaryColor, size: 28),
            SizedBox(width: 12),
            Text(
              'Estadísticas del Catálogo',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total de vacunas
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.vaccines,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${controller.totalVaccinesCount.value}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const Text(
                            'Vacunas activas',
                            style: TextStyle(
                              fontSize: 13,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Por categoría
                const Text(
                  'Por Categoría',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.vaccinesByCategory.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No hay datos disponibles',
                        style: TextStyle(color: textSecondary, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...controller.vaccinesByCategory.entries.map((entry) {
                    final category = entry.key.replaceAll(
                      'Programa Ampliado de Inmunización (PAI)',
                      'PAI',
                    );
                    final count = entry.value;
                    final total = controller.totalVaccinesCount.value;
                    final percentage = total > 0 ? (count / total * 100) : 0.0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimary,
                                    ),
                                  ),
                                ),
                                Text(
                                  '$count vacunas',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: borderColor,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  primaryColor,
                                ),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'CERRAR',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required NavigationDestination destination,
    required bool isSelected,
    required bool isTablet,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => navController.changeTab(index),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icons[index],
              size: isTablet ? 30 : 26,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: isTablet ? 11 : 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
