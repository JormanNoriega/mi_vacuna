import 'package:get/get.dart';
import 'patient_history_controller.dart';
import 'vaccine_management_controller.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;

    // Recargar datos automáticamente al cambiar a ciertas pestañas
    _refreshOnTabChange(index);
  }

  void _refreshOnTabChange(int index) {
    switch (index) {
      case 2: // Historial (Pacientes)
        if (Get.isRegistered<PatientHistoryController>()) {
          Get.find<PatientHistoryController>().refreshPatients();
        }
        break;
      case 3: // Inventario (Vacunas)
        if (Get.isRegistered<VaccineManagementController>()) {
          Get.find<VaccineManagementController>().refresh();
        }
        break;
    }
  }

  void goToHome() => changeTab(0);
  void goToNewPatient() => changeTab(1);
  void goToHistory() => changeTab(2);
  void goToInventory() => changeTab(3);
  void goToSettings() => changeTab(4);
}
