import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../services/applied_dose_service.dart';
import '../widgets/custom_snackbar.dart';

class PatientHistoryController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppliedDoseService _appliedDoseService = AppliedDoseService();

  // Estado
  final isLoading = false.obs;
  final patients = <Patient>[].obs;
  final searchQuery = ''.obs;

  // Mapa de paciente ID -> lista de nombres de vacunas
  final patientVaccines = <int, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  /// Carga todos los pacientes ordenados por fecha de atención
  Future<void> loadPatients() async {
    try {
      isLoading.value = true;
      final result = await _patientService.getAllPatients();
      patients.value = result;

      // Cargar vacunas para cada paciente
      for (var patient in result) {
        if (patient.id != null) {
          await _loadVaccinesForPatient(patient.id!);
        }
      }
    } catch (e) {
      print('Error cargando pacientes: $e');
      CustomSnackbar.showError('Error al cargar pacientes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga las vacunas aplicadas para un paciente específico
  Future<void> _loadVaccinesForPatient(int patientId) async {
    try {
      final doses = await _appliedDoseService.getDosesWithVaccineInfo(
        patientId: patientId,
      );

      // Extraer nombres únicos de vacunas
      final vaccineNames = doses
          .map((dose) => dose['vaccine_name'] as String)
          .toSet()
          .toList();

      patientVaccines[patientId] = vaccineNames;
    } catch (e) {
      print('Error cargando vacunas para paciente $patientId: $e');
      patientVaccines[patientId] = [];
    }
  }

  /// Filtra pacientes por búsqueda
  List<Patient> get filteredPatients {
    if (searchQuery.value.isEmpty) {
      return patients;
    }

    final query = searchQuery.value.toLowerCase();
    return patients.where((patient) {
      final fullName =
          '${patient.firstName} ${patient.secondName ?? ''} ${patient.lastName} ${patient.secondLastName ?? ''}'
              .toLowerCase();
      final idNumber = patient.idNumber.toLowerCase();
      return fullName.contains(query) || idNumber.contains(query);
    }).toList();
  }

  /// Actualiza el término de búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Refresca la lista de pacientes
  Future<void> refreshPatients() async {
    await loadPatients();
  }

  /// Elimina un paciente
  Future<void> deletePatient(int patientId) async {
    try {
      await _patientService.deletePatient(patientId);
      patients.removeWhere((p) => p.id == patientId);
      CustomSnackbar.showSuccess('Paciente eliminado correctamente');
    } catch (e) {
      print('Error eliminando paciente: $e');
      CustomSnackbar.showError('Error al eliminar paciente');
    }
  }
}
