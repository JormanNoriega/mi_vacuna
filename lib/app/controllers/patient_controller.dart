import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/caregiver_model.dart';
import '../services/patient_service.dart';
import '../services/caregiver_service.dart';
import '../services/medical_history_service.dart';
import 'auth_controller.dart';

/// Controlador para gestionar pacientes y sus cuidadores
class PatientController extends GetxController {
  final PatientService _patientService = PatientService();
  final CaregiverService _caregiverService = CaregiverService();
  final MedicalHistoryService _medicalHistoryService = MedicalHistoryService();
  final AuthController _authController = Get.find<AuthController>();

  // Observables
  final patients = <Patient>[].obs;
  final selectedPatient = Rx<Patient?>(null);
  final caregivers = <Caregiver>[].obs;
  final medicalHistories = <MedicalHistory>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPatients(); // Cargar solo pacientes de la enfermera logueada
  }

  /// Cargar pacientes de la enfermera logueada
  Future<void> loadMyPatients() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final nurseId = _authController.currentNurse.value?.id;
      if (nurseId == null) {
        errorMessage.value = 'No hay sesión activa';
        return;
      }

      patients.value = await _patientService.getPatientsByNurseId(nurseId);
    } catch (e) {
      errorMessage.value = 'Error al cargar pacientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar todos los pacientes (para administradores)
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

  /// Crear paciente sin cuidador
  Future<bool> createPatient(Patient patient) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final nurseId = _authController.currentNurse.value?.id;
      if (nurseId == null) {
        errorMessage.value = 'No hay sesión activa';
        return false;
      }

      // Verificar si ya existe el número de identificación
      if (await _patientService.idNumberExists(patient.idNumber)) {
        errorMessage.value =
            'Ya existe un paciente con este número de identificación';
        return false;
      }

      // Asignar la enfermera al paciente
      final patientWithNurse = patient.copyWith(nurseId: nurseId);

      // Crear el paciente
      await _patientService.createPatient(patientWithNurse);

      // Recargar lista
      await loadMyPatients();

      return true;
    } catch (e) {
      errorMessage.value = 'Error al crear paciente: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Crear paciente con cuidador (opcional)
  Future<bool> createPatientWithCaregiver({
    required Patient patient,
    Caregiver? caregiver,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final nurseId = _authController.currentNurse.value?.id;
      if (nurseId == null) {
        errorMessage.value = 'No hay sesión activa';
        return false;
      }

      // Verificar si ya existe el número de identificación
      if (await _patientService.idNumberExists(patient.idNumber)) {
        errorMessage.value =
            'Ya existe un paciente con este número de identificación';
        return false;
      }

      // Asignar la enfermera al paciente
      final patientWithNurse = patient.copyWith(nurseId: nurseId);

      // Crear el paciente
      final patientId = await _patientService.createPatient(patientWithNurse);

      // Crear el cuidador asociado si se proporcionó
      if (caregiver != null) {
        final caregiverWithPatientId = caregiver.copyWith(
          patientId: patientId,
          isPrimary: true,
        );
        await _caregiverService.createCaregiver(caregiverWithPatientId);
      }

      // Recargar lista
      await loadMyPatients();

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
        await loadMedicalHistories(patientId);
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

  /// Cargar antecedentes médicos de un paciente
  Future<void> loadMedicalHistories(int patientId) async {
    try {
      medicalHistories.value = await _medicalHistoryService
          .getHistoriesByPatient(patientId);
    } catch (e) {
      errorMessage.value = 'Error al cargar antecedentes médicos: $e';
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
      await loadMyPatients();

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
      await loadMyPatients();

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
    medicalHistories.clear();
  }

  /// Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }

  // ==================== MÉTODOS PARA ANTECEDENTES MÉDICOS ====================

  /// Crear un nuevo antecedente médico
  Future<bool> createMedicalHistory(MedicalHistory history) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _medicalHistoryService.createHistory(history);

      // Recargar antecedentes del paciente seleccionado
      if (selectedPatient.value != null) {
        await loadMedicalHistories(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al crear antecedente médico: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar un antecedente médico
  Future<bool> updateMedicalHistory(MedicalHistory history) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _medicalHistoryService.updateHistory(history);

      // Recargar antecedentes del paciente seleccionado
      if (selectedPatient.value != null) {
        await loadMedicalHistories(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar antecedente médico: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar un antecedente médico
  Future<bool> deleteMedicalHistory(int historyId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _medicalHistoryService.deleteHistory(historyId);

      // Recargar antecedentes del paciente seleccionado
      if (selectedPatient.value != null) {
        await loadMedicalHistories(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al eliminar antecedente médico: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Buscar antecedentes médicos por descripción
  Future<void> searchMedicalHistories(String searchTerm) async {
    if (selectedPatient.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (searchTerm.isEmpty) {
        await loadMedicalHistories(selectedPatient.value!.id!);
      } else {
        medicalHistories.value = await _medicalHistoryService.searchHistories(
          selectedPatient.value!.id!,
          searchTerm,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error en la búsqueda de antecedentes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtrar antecedentes por tipo
  Future<void> filterMedicalHistoriesByType(String type) async {
    if (selectedPatient.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      medicalHistories.value = await _medicalHistoryService.getHistoriesByType(
        selectedPatient.value!.id!,
        type,
      );
    } catch (e) {
      errorMessage.value = 'Error al filtrar antecedentes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar si hay contraindicaciones para vacunación
  Future<List<MedicalHistory>> getContraindicationsForVaccination() async {
    if (selectedPatient.value == null) return [];

    try {
      return await _medicalHistoryService.getContraindicationsForVaccination(
        selectedPatient.value!.id!,
      );
    } catch (e) {
      errorMessage.value = 'Error al verificar contraindicaciones: $e';
      return [];
    }
  }

  /// Obtener tipos de antecedentes únicos del paciente
  Future<List<String>> getMedicalHistoryTypes() async {
    if (selectedPatient.value == null) return [];

    try {
      return await _medicalHistoryService.getUniqueHistoryTypes(
        selectedPatient.value!.id!,
      );
    } catch (e) {
      errorMessage.value = 'Error al obtener tipos de antecedentes: $e';
      return [];
    }
  }

  /// Obtener antecedentes recientes (últimos N días)
  Future<void> loadRecentMedicalHistories(int days) async {
    if (selectedPatient.value == null) return;

    try {
      isLoading.value = true;
      errorMessage.value = '';

      medicalHistories.value = await _medicalHistoryService.getRecentHistories(
        selectedPatient.value!.id!,
        days,
      );
    } catch (e) {
      errorMessage.value = 'Error al cargar antecedentes recientes: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Verificar si el paciente tiene antecedentes de un tipo específico
  Future<bool> hasMedicalHistoryType(String type) async {
    if (selectedPatient.value == null) return false;

    try {
      return await _medicalHistoryService.hasHistoryType(
        selectedPatient.value!.id!,
        type,
      );
    } catch (e) {
      errorMessage.value = 'Error al verificar antecedente: $e';
      return false;
    }
  }

  /// Contar antecedentes médicos del paciente
  Future<int> countMedicalHistories() async {
    if (selectedPatient.value == null) return 0;

    try {
      return await _medicalHistoryService.countHistoriesByPatient(
        selectedPatient.value!.id!,
      );
    } catch (e) {
      errorMessage.value = 'Error al contar antecedentes: $e';
      return 0;
    }
  }
}
