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
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> _pages = [
    const HomePage(),
    const VaccinationFormWrapper(),
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
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: backgroundLight,
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
    Get.snackbar(
      'Estadísticas',
      'Vacunas en el catálogo',
      backgroundColor: primaryColor,
      colorText: Colors.white,
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
