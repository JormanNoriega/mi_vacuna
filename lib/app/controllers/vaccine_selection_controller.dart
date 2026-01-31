import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vaccine.dart';
import '../models/vaccine_config_option.dart';
import '../services/vaccine_service.dart';

/// Modelo para almacenar la información de una vacuna seleccionada
class SelectedVaccineData {
  final int vaccineId;
  int? selectedDoseId;
  int? selectedLaboratoryId;
  int? selectedSyringeId;
  int? selectedDropperId;
  int? selectedPneumococcalTypeId;
  int? selectedObservationId;
  DateTime? applicationDate;

  // Campos de texto libre
  final TextEditingController lotController = TextEditingController();
  final TextEditingController syringeLotController = TextEditingController();
  final TextEditingController diluentController = TextEditingController();
  final TextEditingController vialCountController = TextEditingController();

  SelectedVaccineData({required this.vaccineId});

  void dispose() {
    lotController.dispose();
    syringeLotController.dispose();
    diluentController.dispose();
    vialCountController.dispose();
  }
}

/// Controlador para la selección y configuración de vacunas en el paso 3
class VaccineSelectionController extends GetxController {
  final VaccineService _vaccineService = VaccineService();

  // Estado
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Vacunas disponibles para el paciente
  final availableVaccines = <Vaccine>[].obs;

  // Vacunas seleccionadas (ID de vacuna -> datos)
  final selectedVaccines = <int, SelectedVaccineData>{}.obs;

  // Cache de opciones de configuración
  final _doseOptionsCache = <int, List<VaccineConfigOption>>{}.obs;
  final _laboratoryOptionsCache = <int, List<VaccineConfigOption>>{}.obs;
  final _syringeOptionsCache = <int, List<VaccineConfigOption>>{}.obs;
  final _dropperOptionsCache = <int, List<VaccineConfigOption>>{}.obs;
  final _pneumococcalTypeOptionsCache = <int, List<VaccineConfigOption>>{}.obs;
  final _observationOptionsCache = <int, List<VaccineConfigOption>>{}.obs;

  @override
  void onClose() {
    // Liberar controladores
    for (var data in selectedVaccines.values) {
      data.dispose();
    }
    super.onClose();
  }

  /// Carga las vacunas disponibles según la edad del paciente
  Future<void> loadAvailableVaccines(DateTime? birthDate) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (birthDate == null) {
        // Si no hay fecha de nacimiento, mostrar todas las vacunas activas
        availableVaccines.value = await _vaccineService.getAllActiveVaccines();
      } else {
        // Obtener vacunas recomendadas para la edad
        // Por ahora mostramos todas las activas (según especificación)
        availableVaccines.value = await _vaccineService.getAllActiveVaccines();
      }
    } catch (e) {
      errorMessage.value = 'Error al cargar vacunas: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Alterna la selección de una vacuna
  void toggleVaccineSelection(int vaccineId) {
    if (selectedVaccines.containsKey(vaccineId)) {
      // Deseleccionar: liberar recursos y remover
      selectedVaccines[vaccineId]?.dispose();
      selectedVaccines.remove(vaccineId);
    } else {
      // Seleccionar: crear datos y cargar opciones
      selectedVaccines[vaccineId] = SelectedVaccineData(vaccineId: vaccineId);
      _loadVaccineOptions(vaccineId);
    }
  }

  /// Verifica si una vacuna está seleccionada
  bool isVaccineSelected(int vaccineId) {
    return selectedVaccines.containsKey(vaccineId);
  }

  /// Carga todas las opciones de configuración de una vacuna
  Future<void> _loadVaccineOptions(int vaccineId) async {
    final vaccine = availableVaccines.firstWhereOrNull(
      (v) => v.id == vaccineId,
    );
    if (vaccine == null) return;

    try {
      // Cargar dosis (siempre)
      _doseOptionsCache[vaccineId] = await _vaccineService.getDoses(vaccineId);

      // Cargar laboratorios (si aplica)
      if (vaccine.hasLaboratory) {
        _laboratoryOptionsCache[vaccineId] = await _vaccineService
            .getLaboratories(vaccineId);
      }

      // Cargar jeringas (si aplica)
      if (vaccine.hasSyringe) {
        _syringeOptionsCache[vaccineId] = await _vaccineService.getSyringes(
          vaccineId,
        );
      }

      // Cargar goteros (si aplica)
      if (vaccine.hasDropper) {
        _dropperOptionsCache[vaccineId] = await _vaccineService.getDroppers(
          vaccineId,
        );
      }

      // Cargar tipos neumococo (si aplica)
      if (vaccine.hasPneumococcalType) {
        _pneumococcalTypeOptionsCache[vaccineId] = await _vaccineService
            .getPneumococcalTypes(vaccineId);
      }

      // Cargar observaciones (si aplica)
      if (vaccine.hasObservation) {
        _observationOptionsCache[vaccineId] = await _vaccineService
            .getObservations(vaccineId);
      }

      // Establecer valores predeterminados
      _setDefaultValues(vaccineId);
    } catch (e) {
      print('Error cargando opciones para vacuna $vaccineId: $e');
    }
  }

  /// Establece valores predeterminados para una vacuna
  void _setDefaultValues(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data == null) return;

    // Fecha de aplicación por defecto: hoy
    data.applicationDate = DateTime.now();

    // Establecer opciones predeterminadas si existen
    final doseOptions = _doseOptionsCache[vaccineId] ?? [];
    if (doseOptions.isNotEmpty) {
      final defaultDose = doseOptions.firstWhereOrNull((opt) => opt.isDefault);
      data.selectedDoseId = defaultDose?.id ?? doseOptions.first.id;
    }

    final labOptions = _laboratoryOptionsCache[vaccineId] ?? [];
    if (labOptions.isNotEmpty) {
      final defaultLab = labOptions.firstWhereOrNull((opt) => opt.isDefault);
      data.selectedLaboratoryId = defaultLab?.id ?? labOptions.first.id;
    }

    final syringeOptions = _syringeOptionsCache[vaccineId] ?? [];
    if (syringeOptions.isNotEmpty) {
      final defaultSyringe = syringeOptions.firstWhereOrNull(
        (opt) => opt.isDefault,
      );
      data.selectedSyringeId = defaultSyringe?.id ?? syringeOptions.first.id;
    }
  }

  // ==================== GETTERS DE OPCIONES ====================

  List<VaccineConfigOption> getDoseOptions(int vaccineId) {
    return _doseOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getLaboratoryOptions(int vaccineId) {
    return _laboratoryOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getSyringeOptions(int vaccineId) {
    return _syringeOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getDropperOptions(int vaccineId) {
    return _dropperOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getPneumococcalTypeOptions(int vaccineId) {
    return _pneumococcalTypeOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getObservationOptions(int vaccineId) {
    return _observationOptionsCache[vaccineId] ?? [];
  }

  // ==================== GETTERS DE VALORES SELECCIONADOS ====================

  String? getSelectedDose(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedDoseId == null) return null;

    final options = getDoseOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedDoseId,
    );
    return option?.displayName;
  }

  String? getSelectedLaboratory(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedLaboratoryId == null) return null;

    final options = getLaboratoryOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedLaboratoryId,
    );
    return option?.displayName;
  }

  String? getSelectedSyringe(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedSyringeId == null) return null;

    final options = getSyringeOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedSyringeId,
    );
    return option?.displayName;
  }

  String? getSelectedDropper(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedDropperId == null) return null;

    final options = getDropperOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedDropperId,
    );
    return option?.displayName;
  }

  String? getSelectedPneumococcalType(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedPneumococcalTypeId == null) return null;

    final options = getPneumococcalTypeOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedPneumococcalTypeId,
    );
    return option?.displayName;
  }

  String? getSelectedObservation(int vaccineId) {
    final data = selectedVaccines[vaccineId];
    if (data?.selectedObservationId == null) return null;

    final options = getObservationOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == data!.selectedObservationId,
    );
    return option?.displayName;
  }

  DateTime? getApplicationDate(int vaccineId) {
    return selectedVaccines[vaccineId]?.applicationDate;
  }

  // ==================== GETTERS DE CONTROLADORES ====================

  TextEditingController getLotController(int vaccineId) {
    return selectedVaccines[vaccineId]!.lotController;
  }

  TextEditingController getSyringeLotController(int vaccineId) {
    return selectedVaccines[vaccineId]!.syringeLotController;
  }

  TextEditingController getDiluentController(int vaccineId) {
    return selectedVaccines[vaccineId]!.diluentController;
  }

  TextEditingController getVialCountController(int vaccineId) {
    return selectedVaccines[vaccineId]!.vialCountController;
  }

  // ==================== SETTERS ====================

  void setSelectedDose(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedDoseId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedLaboratory(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedLaboratoryId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedSyringe(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedSyringeId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedDropper(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedDropperId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedPneumococcalType(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedPneumococcalTypeId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedObservation(int vaccineId, int optionId) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.selectedObservationId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setApplicationDate(int vaccineId, DateTime date) {
    final data = selectedVaccines[vaccineId];
    if (data != null) {
      data.applicationDate = date;
      selectedVaccines.refresh();
    }
  }

  // ==================== VALIDACIÓN ====================

  /// Valida que todas las vacunas seleccionadas tengan los campos requeridos
  bool validate() {
    if (selectedVaccines.isEmpty) {
      Get.snackbar(
        'Atención',
        'Debes seleccionar al menos una vacuna',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    for (var entry in selectedVaccines.entries) {
      final vaccineId = entry.key;
      final data = entry.value;
      final vaccine = availableVaccines.firstWhereOrNull(
        (v) => v.id == vaccineId,
      );

      if (vaccine == null) continue;

      // Validar dosis (requerida)
      if (data.selectedDoseId == null) {
        Get.snackbar(
          'Campo requerido',
          'Selecciona la dosis para ${vaccine.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      // Validar fecha (requerida)
      if (data.applicationDate == null) {
        Get.snackbar(
          'Campo requerido',
          'Selecciona la fecha de aplicación para ${vaccine.name}',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    }

    return true;
  }

  /// Obtiene los datos de las vacunas seleccionadas para guardar
  List<Map<String, dynamic>> getVaccinesData() {
    final result = <Map<String, dynamic>>[];

    for (var entry in selectedVaccines.entries) {
      final vaccineId = entry.key;
      final data = entry.value;

      result.add({
        'vaccine_id': vaccineId,
        'dose_option_id': data.selectedDoseId,
        'laboratory_option_id': data.selectedLaboratoryId,
        'syringe_option_id': data.selectedSyringeId,
        'dropper_option_id': data.selectedDropperId,
        'pneumococcal_type_option_id': data.selectedPneumococcalTypeId,
        'observation_option_id': data.selectedObservationId,
        'application_date': data.applicationDate?.toIso8601String(),
        'lot': data.lotController.text.trim(),
        'syringe_lot': data.syringeLotController.text.trim(),
        'diluent': data.diluentController.text.trim(),
        'vial_count': data.vialCountController.text.trim(),
      });
    }

    return result;
  }
}
