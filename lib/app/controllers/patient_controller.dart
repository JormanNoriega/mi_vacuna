import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/caregiver_model.dart';
import '../services/patient_service.dart';
import '../services/caregiver_service.dart';

/// Controlador para gestionar pacientes y sus cuidadores
class PatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final CaregiverService _caregiverService = CaregiverService();

  // Observables
  final patients = <Patient>[].obs;
  final selectedPatient = Rx<Patient?>(null);
  final caregivers = <Caregiver>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllPatients();
  }

  /// Cargar todos los pacientes
  Future<void> loadAllPatients() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      patients.value = await _patientService.getAllPatients();
    } catch (e) {
      errorMessage.value = 'Error al cargar pacientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Crear paciente con su cuidador principal
  Future<bool> createPatientWithCaregiver({
    required Patient patient,
    required Caregiver caregiver,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Verificar si ya existe el número de identificación
      if (await _patientService.idNumberExists(patient.idNumber)) {
        errorMessage.value =
            'Ya existe un paciente con este número de identificación';
        return false;
      }

      // Crear el paciente
      final patientId = await _patientService.createPatient(patient);

      // Crear el cuidador asociado
      final caregiverWithPatientId = caregiver.copyWith(
        patientId: patientId,
        isPrimary: true,
      );
      await _caregiverService.createCaregiver(caregiverWithPatientId);

      // Recargar lista
      await loadAllPatients();

      return true;
    } catch (e) {
      errorMessage.value = 'Error al crear paciente: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Agregar cuidador adicional a un paciente
  Future<bool> addCaregiver(Caregiver caregiver) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _caregiverService.createCaregiver(caregiver);

      // Recargar cuidadores del paciente seleccionado
      if (selectedPatient.value != null) {
        await loadCaregiversForPatient(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al agregar cuidador: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Seleccionar un paciente y cargar sus cuidadores
  Future<void> selectPatient(int patientId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      selectedPatient.value = await _patientService.getPatientById(patientId);

      if (selectedPatient.value != null) {
        await loadCaregiversForPatient(patientId);
      }
    } catch (e) {
      errorMessage.value = 'Error al seleccionar paciente: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar cuidadores de un paciente específico
  Future<void> loadCaregiversForPatient(int patientId) async {
    try {
      caregivers.value = await _caregiverService.getCaregiversByPatientId(
        patientId,
      );
    } catch (e) {
      errorMessage.value = 'Error al cargar cuidadores: $e';
    }
  }

  /// Buscar pacientes por nombre
  Future<void> searchPatients(String searchTerm) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (searchTerm.isEmpty) {
        await loadAllPatients();
      } else {
        patients.value = await _patientService.searchPatientsByName(searchTerm);
      }
    } catch (e) {
      errorMessage.value = 'Error en la búsqueda: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar paciente
  Future<bool> updatePatient(Patient patient) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _patientService.updatePatient(patient);
      await loadAllPatients();

      if (selectedPatient.value?.id == patient.id) {
        selectedPatient.value = patient;
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar paciente: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar cuidador
  Future<bool> updateCaregiver(Caregiver caregiver) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _caregiverService.updateCaregiver(caregiver);

      if (selectedPatient.value != null) {
        await loadCaregiversForPatient(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar cuidador: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Cambiar cuidador principal
  Future<bool> setPrimaryCaregiver(int caregiverId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (selectedPatient.value == null) {
        errorMessage.value = 'No hay paciente seleccionado';
        return false;
      }

      await _caregiverService.setPrimaryCaregiver(
        caregiverId,
        selectedPatient.value!.id!,
      );

      await loadCaregiversForPatient(selectedPatient.value!.id!);

      return true;
    } catch (e) {
      errorMessage.value = 'Error al cambiar cuidador principal: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar paciente
  Future<bool> deletePatient(int patientId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _patientService.deletePatient(patientId);
      await loadAllPatients();

      if (selectedPatient.value?.id == patientId) {
        selectedPatient.value = null;
        caregivers.clear();
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al eliminar paciente: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar cuidador
  Future<bool> deleteCaregiver(int caregiverId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _caregiverService.deleteCaregiver(caregiverId);

      if (selectedPatient.value != null) {
        await loadCaregiversForPatient(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al eliminar cuidador: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener pacientes con esquema incompleto
  Future<void> loadPatientsWithIncompleteScheme() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      patients.value = await _patientService.getPatientsWithIncompleteScheme();
    } catch (e) {
      errorMessage.value =
          'Error al cargar pacientes con esquema incompleto: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener gestantes
  Future<void> loadPregnantPatients() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      patients.value = await _patientService.getPatientsByUserCondition(
        CondicionUsuaria.gestante,
      );
    } catch (e) {
      errorMessage.value = 'Error al cargar gestantes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener estadísticas
  Future<Map<String, int>> getStatistics() async {
    try {
      final total = await _patientService.countPatients();
      final incomplete = await _patientService
          .getPatientsWithIncompleteScheme();
      final deceased = await _patientService.getDeceasedPatients();

      return {
        'total': total,
        'incomplete_scheme': incomplete.length,
        'deceased': deceased.length,
      };
    } catch (e) {
      errorMessage.value = 'Error al cargar estadísticas: $e';
      return {};
    }
  }

  /// Limpiar selección
  void clearSelection() {
    selectedPatient.value = null;
    caregivers.clear();
  }

  /// Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }
}
