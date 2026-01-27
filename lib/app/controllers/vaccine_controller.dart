import 'package:get/get.dart';
import '../models/applied_dose_model.dart';
import '../models/patient_model.dart';
import '../domain/vaccine_config.dart';
import '../domain/vaccine_type.dart';
import '../domain/dose_config.dart';
import '../services/vaccine_service.dart';
import 'auth_controller.dart';

/// Controlador para gestionar la aplicación de vacunas
class VaccineController extends GetxController {
  final VaccineService _vaccineService = VaccineService();
  final AuthController _authController = Get.find<AuthController>();

  // Observables
  final availableVaccines = <VaccineConfig>[].obs;
  final appliedDoses = <AppliedDose>[].obs;
  final pendingDoses = <VaccineType, List<DoseConfig>>{}.obs;
  final selectedVaccine = Rx<VaccineConfig?>(null);
  final selectedPatient = Rx<Patient?>(null);
  final canApplyDose = false.obs;
  final nextDoseDate = Rx<DateTime?>(null);
  final vaccineStats = <VaccineType, int>{}.obs;
  final completionPercentage = 0.0.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  /// Cargar vacunas disponibles para un paciente
  Future<void> loadAvailableVaccinesForPatient(Patient patient) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedPatient.value = patient;

      availableVaccines.value = await _vaccineService.getAvailableVaccines(
        patient,
      );
      await loadPendingDoses(patient);
      await loadAppliedDoses(patient.id!);
      await loadVaccinationStats(patient.id!);
    } catch (e) {
      errorMessage.value = 'Error al cargar vacunas disponibles: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Cargar dosis aplicadas de un paciente
  Future<void> loadAppliedDoses(int patientId) async {
    try {
      appliedDoses.value = await _vaccineService.getDosesByPatient(patientId);
      completionPercentage.value = await _vaccineService
          .getVaccinationCompletionPercentage(patientId);
    } catch (e) {
      errorMessage.value = 'Error al cargar dosis aplicadas: $e';
    }
  }

  /// Cargar dosis pendientes de un paciente
  Future<void> loadPendingDoses(Patient patient) async {
    try {
      pendingDoses.value = await _vaccineService.getPendingDoses(patient);
    } catch (e) {
      errorMessage.value = 'Error al cargar dosis pendientes: $e';
    }
  }

  /// Cargar estadísticas de vacunación del paciente
  Future<void> loadVaccinationStats(int patientId) async {
    try {
      vaccineStats.value = await _vaccineService.getVaccineCountByPatient(
        patientId,
      );
    } catch (e) {
      errorMessage.value = 'Error al cargar estadísticas: $e';
    }
  }

  /// Seleccionar una vacuna para aplicar
  Future<void> selectVaccine(VaccineConfig vaccine, int doseNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      selectedVaccine.value = vaccine;

      if (selectedPatient.value == null) {
        errorMessage.value = 'No hay paciente seleccionado';
        canApplyDose.value = false;
        return;
      }

      // Validar si se puede aplicar la dosis
      canApplyDose.value = await _vaccineService.canApplyDose(
        selectedPatient.value!,
        vaccine.type,
        doseNumber,
      );

      // Calcular fecha de próxima dosis
      if (canApplyDose.value) {
        nextDoseDate.value = await _vaccineService.calculateNextDoseDate(
          selectedPatient.value!.id!,
          vaccine.type,
          doseNumber,
        );
      }
    } catch (e) {
      errorMessage.value = 'Error al seleccionar vacuna: $e';
      canApplyDose.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Aplicar una dosis de vacuna
  Future<bool> applyDose(AppliedDose dose) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final nurseId = _authController.currentNurse.value?.id;
      if (nurseId == null) {
        errorMessage.value = 'No hay sesión activa';
        return false;
      }

      if (selectedPatient.value == null) {
        errorMessage.value = 'No hay paciente seleccionado';
        return false;
      }

      // Validar que se pueda aplicar
      final canApply = await _vaccineService.canApplyDose(
        selectedPatient.value!,
        dose.vaccineType,
        dose.doseNumber,
      );

      if (!canApply) {
        errorMessage.value = 'Esta dosis no puede ser aplicada en este momento';
        return false;
      }

      // Calcular fecha de próxima dosis
      final nextDate = await _vaccineService.calculateNextDoseDate(
        selectedPatient.value!.id!,
        dose.vaccineType,
        dose.doseNumber,
      );

      // Asignar enfermera y próxima dosis
      final doseWithDetails = dose.copyWith(
        nurseId: nurseId,
        patientId: selectedPatient.value!.id!,
        nextDoseDate: nextDate,
      );

      // Aplicar la dosis
      await _vaccineService.applyDose(doseWithDetails);

      // Recargar datos
      await loadAvailableVaccinesForPatient(selectedPatient.value!);

      return true;
    } catch (e) {
      errorMessage.value = 'Error al aplicar dosis: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Actualizar una dosis aplicada
  Future<bool> updateDose(AppliedDose dose) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _vaccineService.updateDose(dose);

      if (selectedPatient.value != null) {
        await loadAppliedDoses(selectedPatient.value!.id!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar dosis: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Eliminar una dosis aplicada
  Future<bool> deleteDose(int doseId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _vaccineService.deleteDose(doseId);

      if (selectedPatient.value != null) {
        await loadAvailableVaccinesForPatient(selectedPatient.value!);
      }

      return true;
    } catch (e) {
      errorMessage.value = 'Error al eliminar dosis: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener dosis de una vacuna específica
  Future<List<AppliedDose>> getDosesByVaccineType(VaccineType type) async {
    if (selectedPatient.value == null) return [];

    try {
      return await _vaccineService.getDosesByVaccineType(
        selectedPatient.value!.id!,
        type,
      );
    } catch (e) {
      errorMessage.value = 'Error al cargar dosis de vacuna: $e';
      return [];
    }
  }

  /// Verificar si una dosis específica está aplicada
  bool isDoseApplied(VaccineType type, int doseNumber) {
    return appliedDoses.any(
      (d) => d.vaccineType == type && d.doseNumber == doseNumber,
    );
  }

  /// Obtener resumen de vacunación para mostrar
  Map<String, dynamic> getVaccinationSummary() {
    if (selectedPatient.value == null) return {};

    return {
      'total_doses': appliedDoses.length,
      'completion_percentage': completionPercentage.value,
      'pending_vaccines': pendingDoses.length,
      'vaccines_by_type': vaccineStats,
      'last_dose_date': appliedDoses.isNotEmpty
          ? appliedDoses.first.applicationDate
          : null,
    };
  }

  /// Buscar dosis por número de lote (trazabilidad)
  Future<List<AppliedDose>> searchByLotNumber(String lotNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      return await _vaccineService.getDosesByLotNumber(lotNumber);
    } catch (e) {
      errorMessage.value = 'Error en búsqueda por lote: $e';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Limpiar selección
  void clearSelection() {
    selectedVaccine.value = null;
    selectedPatient.value = null;
    availableVaccines.clear();
    appliedDoses.clear();
    pendingDoses.clear();
    vaccineStats.clear();
    completionPercentage.value = 0.0;
    canApplyDose.value = false;
    nextDoseDate.value = null;
  }

  /// Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }
}
