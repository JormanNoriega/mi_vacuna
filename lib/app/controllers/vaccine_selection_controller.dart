import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/vaccine.dart';
import '../models/vaccine_config_option.dart';
import '../models/applied_dose.dart';
import '../services/vaccine_service.dart';
import '../services/applied_dose_service.dart';
import '../widgets/custom_snackbar.dart';

/// Modelo para almacenar la información de UNA DOSIS específica
class DoseData {
  final String doseOptionId;
  String doseValue; // Valor de la dosis para guardar
  String doseDisplayName; // Nombre para mostrar

  String? selectedLaboratoryId;
  String? selectedSyringeId;
  String? selectedDropperId;
  String? selectedPneumococcalTypeId;
  String? selectedObservationId;
  DateTime? applicationDate;

  // Campos de texto libre
  final TextEditingController lotController = TextEditingController();
  final TextEditingController syringeLotController = TextEditingController();
  final TextEditingController diluentController = TextEditingController();
  final TextEditingController vialCountController = TextEditingController();
  final TextEditingController customObservationController = TextEditingController(); // Campo de observación libre

  // Estado de la dosis
  bool isLocked; // Ya registrada previamente (solo lectura)
  bool isActive; // Dosis actualmente siendo editada
  bool isCompleted; // Dosis completada en esta sesión

  DoseData({
    required this.doseOptionId,
    required this.doseValue,
    required this.doseDisplayName,
    this.isLocked = false,
    this.isActive = false,
    this.isCompleted = false,
  });

  void dispose() {
    lotController.dispose();
    syringeLotController.dispose();
    diluentController.dispose();
    vialCountController.dispose();
    customObservationController.dispose();
  }

  /// Valida que la dosis tenga todos los campos requeridos
  bool validate(Vaccine vaccine) {
    // ❌ CAMPOS OBLIGATORIOS BÁSICOS
    if (applicationDate == null) return false;
    if (lotController.text.trim().isEmpty) return false;
    
    // ❌ CAMPOS OBLIGATORIOS SEGÚN CONFIGURACIÓN DE LA VACUNA
    if (vaccine.hasLaboratory && (selectedLaboratoryId == null || selectedLaboratoryId!.isEmpty)) {
      return false;
    }
    if (vaccine.hasSyringe && (selectedSyringeId == null || selectedSyringeId!.isEmpty)) {
      return false;
    }
    if (vaccine.hasSyringeLot && syringeLotController.text.trim().isEmpty) {
      return false;
    }
    if (vaccine.hasDiluent && diluentController.text.trim().isEmpty) {
      return false;
    }
    if (vaccine.hasDropper && (selectedDropperId == null || selectedDropperId!.isEmpty)) {
      return false;
    }
    if (vaccine.hasPneumococcalType && (selectedPneumococcalTypeId == null || selectedPneumococcalTypeId!.isEmpty)) {
      return false;
    }
    if (vaccine.hasObservation && (selectedObservationId == null || selectedObservationId!.isEmpty)) {
      return false;
    }
    if (vaccine.hasVialCount && vialCountController.text.trim().isEmpty) {
      return false;
    }
    
    // ✅ customObservation es opcional
    return true;
  }
}

/// Modelo para almacenar la información de una vacuna seleccionada
class SelectedVaccineData {
  final String vaccineId;

  // Mapa de dosis: doseOptionId -> DoseData
  final Map<String, DoseData> doses = {};

  // Dosis activas (pueden ser múltiples)
  final Set<String> activeDoses = {};

  // Verifica si tiene dosis bloqueadas
  bool get hasLockedDoses => doses.values.any((d) => d.isLocked);

  // Verifica si tiene al menos una dosis completada
  bool get hasCompletedDoses =>
      doses.values.any((d) => d.isCompleted || d.isLocked);

  SelectedVaccineData({required this.vaccineId});

  void dispose() {
    for (var dose in doses.values) {
      dose.dispose();
    }
    doses.clear();
    activeDoses.clear();
  }

  /// Obtiene o crea una dosis
  DoseData getOrCreateDose(
    String doseOptionId,
    String doseValue,
    String doseDisplayName, {
    bool isLocked = false,
  }) {
    if (!doses.containsKey(doseOptionId)) {
      doses[doseOptionId] = DoseData(
        doseOptionId: doseOptionId,
        doseValue: doseValue,
        doseDisplayName: doseDisplayName,
        isLocked: isLocked,
      );
    }
    return doses[doseOptionId]!;
  }

  /// Verifica si una dosis existe
  bool hasDose(String doseOptionId) => doses.containsKey(doseOptionId);

  /// Verifica si una dosis está bloqueada
  bool isDoseLocked(String doseOptionId) =>
      doses[doseOptionId]?.isLocked ?? false;

  /// Verifica si una dosis está activa
  bool isDoseActive(String doseOptionId) => activeDoses.contains(doseOptionId);

  /// Verifica si una dosis tiene datos completados (no vacía)
  bool hasDoseWithData(String doseOptionId) {
    final dose = doses[doseOptionId];
    if (dose == null) return false;
    // Una dosis tiene datos si tiene fecha y lote
    return dose.applicationDate != null && dose.lotController.text.isNotEmpty;
  }
}

/// Controlador para la selección y configuración de vacunas en el paso 3
class VaccineSelectionController extends GetxController {
  final VaccineService _vaccineService = VaccineService();
  final AppliedDoseService _appliedDoseService = AppliedDoseService();

  // Estado
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // Vacunas disponibles para el paciente
  final availableVaccines = <Vaccine>[].obs;

  // Vacunas seleccionadas (ID de vacuna -> datos)
  final selectedVaccines = <String, SelectedVaccineData>{}.obs;

  // Cache de opciones de configuración
  final _doseOptionsCache = <String, List<VaccineConfigOption>>{}.obs;
  final _laboratoryOptionsCache = <String, List<VaccineConfigOption>>{}.obs;
  final _syringeOptionsCache = <String, List<VaccineConfigOption>>{}.obs;
  final _dropperOptionsCache = <String, List<VaccineConfigOption>>{}.obs;
  final _pneumococcalTypeOptionsCache =
      <String, List<VaccineConfigOption>>{}.obs;
  final _observationOptionsCache = <String, List<VaccineConfigOption>>{}.obs;

  @override
  void onClose() {
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
        availableVaccines.value = await _vaccineService.getAllActiveVaccines();
      } else {
        availableVaccines.value = await _vaccineService.getAllActiveVaccines();
      }
    } catch (e) {
      errorMessage.value = 'Error al cargar vacunas: $e';
      CustomSnackbar.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  /// Alterna la selección de una vacuna
  Future<void> toggleVaccineSelection(String vaccineId) async {
    if (selectedVaccines.containsKey(vaccineId)) {
      final vaccineData = selectedVaccines[vaccineId];

      // Si tiene dosis bloqueadas, no permitir deseleccionar
      if (vaccineData != null && vaccineData.hasLockedDoses) {
        CustomSnackbar.showError(
          'No puedes deseleccionar una vacuna con dosis ya registradas',
        );
        selectedVaccines.refresh();
        return;
      }

      // Deseleccionar
      vaccineData?.dispose();
      selectedVaccines.remove(vaccineId);
    } else {
      // Seleccionar
      selectedVaccines[vaccineId] = SelectedVaccineData(vaccineId: vaccineId);
      await _loadVaccineOptions(vaccineId);
    }
  }

  /// Verifica si una vacuna está seleccionada
  bool isVaccineSelected(String vaccineId) {
    return selectedVaccines.containsKey(vaccineId);
  }

  /// Carga todas las opciones de configuración de una vacuna
  Future<void> _loadVaccineOptions(String vaccineId) async {
    final vaccine = availableVaccines.firstWhereOrNull(
      (v) => v.id == vaccineId,
    );
    if (vaccine == null) return;

    try {
      _doseOptionsCache[vaccineId] = await _vaccineService.getDoses(vaccineId);

      if (vaccine.hasLaboratory) {
        _laboratoryOptionsCache[vaccineId] = await _vaccineService
            .getLaboratories(vaccineId);
      }
      if (vaccine.hasSyringe) {
        _syringeOptionsCache[vaccineId] = await _vaccineService.getSyringes(
          vaccineId,
        );
      }
      if (vaccine.hasDropper) {
        _dropperOptionsCache[vaccineId] = await _vaccineService.getDroppers(
          vaccineId,
        );
      }
      if (vaccine.hasPneumococcalType) {
        _pneumococcalTypeOptionsCache[vaccineId] = await _vaccineService
            .getPneumococcalTypes(vaccineId);
      }
      if (vaccine.hasObservation) {
        _observationOptionsCache[vaccineId] = await _vaccineService
            .getObservations(vaccineId);
      }

      selectedVaccines.refresh();
    } catch (e) {
      print('Error cargando opciones para vacuna $vaccineId: $e');
    }
  }

  // ==================== MANEJO DE DOSIS ====================

  /// Alterna el estado activo de una dosis
  void toggleDoseSelection(String vaccineId, String doseOptionId) {
    final vaccineData = selectedVaccines[vaccineId];
    if (vaccineData == null) return;

    // Si la dosis está bloqueada, mostrar error
    if (vaccineData.isDoseLocked(doseOptionId)) {
      CustomSnackbar.showError(
        'Esta dosis ya fue registrada y no puede ser modificada',
      );
      return;
    }

    // Obtener info de la dosis
    final doseOptions = getDoseOptions(vaccineId);
    final doseOption = doseOptions.firstWhereOrNull(
      (opt) => opt.id == doseOptionId,
    );
    if (doseOption == null) return;

    if (vaccineData.isDoseActive(doseOptionId)) {
      // Desactivar dosis
      vaccineData.activeDoses.remove(doseOptionId);
      if (vaccineData.hasDose(doseOptionId)) {
        vaccineData.doses[doseOptionId]!.isActive = false;
      }
    } else {
      // Activar dosis y crear si no existe
      final doseData = vaccineData.getOrCreateDose(
        doseOptionId,
        doseOption.value,
        doseOption.displayName,
      );
      doseData.isActive = true;
      vaccineData.activeDoses.add(doseOptionId);

      // Establecer valores predeterminados
      _setDefaultValuesForDose(vaccineId, doseOptionId);
    }

    selectedVaccines.refresh();
  }

  /// Establece valores predeterminados para una dosis
  void _setDefaultValuesForDose(String vaccineId, String doseOptionId) {
    final vaccineData = selectedVaccines[vaccineId];
    if (vaccineData == null) return;

    final doseData = vaccineData.doses[doseOptionId];
    if (doseData == null || doseData.isLocked) return;

    final vaccine = availableVaccines.firstWhereOrNull(
      (v) => v.id == vaccineId,
    );
    if (vaccine == null) return;

    // Fecha por defecto: hoy
    if (doseData.applicationDate == null) {
      doseData.applicationDate = DateTime.now();
    }

    // Establecer opciones predeterminadas
    final labOptions = _laboratoryOptionsCache[vaccineId] ?? [];
    if (labOptions.isNotEmpty && doseData.selectedLaboratoryId == null) {
      final defaultLab = labOptions.firstWhereOrNull((opt) => opt.isDefault);
      doseData.selectedLaboratoryId = defaultLab?.id ?? labOptions.first.id;
    }

    final syringeOptions = _syringeOptionsCache[vaccineId] ?? [];
    if (syringeOptions.isNotEmpty && doseData.selectedSyringeId == null) {
      final defaultSyringe = syringeOptions.firstWhereOrNull(
        (opt) => opt.isDefault,
      );
      doseData.selectedSyringeId =
          defaultSyringe?.id ?? syringeOptions.first.id;
    }
  }

  /// Carga las dosis ya registradas de un paciente
  Future<void> loadPatientRegisteredDoses(String patientId) async {
    try {
      final List<AppliedDose> doses = await _appliedDoseService
          .getDosesByPatient(patientId);

      for (final AppliedDose appliedDose in doses) {
        final vaccineId = appliedDose.vaccineId;

        if (!isVaccineSelected(vaccineId)) {
          await toggleVaccineSelection(vaccineId);
        }

        final vaccineData = selectedVaccines[vaccineId];
        if (vaccineData == null) {
          continue;
        }

        final doseOptions = getDoseOptions(vaccineId);
        if (doseOptions.isEmpty) {
          continue;
        }

        // Buscar por displayName en lugar de value
        final doseOption = doseOptions.firstWhereOrNull(
          (opt) =>
              opt.displayName == appliedDose.selectedDose ||
              opt.value == appliedDose.selectedDose,
        );

        if (doseOption != null) {
          final doseData = vaccineData.getOrCreateDose(
            doseOption.id!,
            doseOption.value,
            doseOption.displayName,
            isLocked: true,
          );

          // Agregar a activeDoses para que se muestre en la UI
          vaccineData.activeDoses.add(doseOption.id!);
          doseData.isActive = true;

          doseData.applicationDate = appliedDose.applicationDate;
          doseData.lotController.text = appliedDose.lotNumber;

          if (appliedDose.syringeLot != null) {
            doseData.syringeLotController.text = appliedDose.syringeLot!;
          }
          if (appliedDose.diluentLot != null) {
            doseData.diluentController.text = appliedDose.diluentLot!;
          }
          if (appliedDose.vialCount != null) {
            doseData.vialCountController.text = appliedDose.vialCount
                .toString();
          }

          // Cargar opciones seleccionadas
          if (appliedDose.selectedLaboratory != null) {
            final labOptions = getLaboratoryOptions(vaccineId);
            final labOption = labOptions.firstWhereOrNull(
              (opt) =>
                  opt.displayName.toUpperCase() ==
                      appliedDose.selectedLaboratory!.toUpperCase() ||
                  opt.value.toUpperCase() ==
                      appliedDose.selectedLaboratory!.toUpperCase(),
            );
            if (labOption != null) {
              doseData.selectedLaboratoryId = labOption.id;
            }
          }

          if (appliedDose.selectedSyringe != null) {
            final syringeOptions = getSyringeOptions(vaccineId);
            final syringeOption = syringeOptions.firstWhereOrNull(
              (opt) =>
                  opt.displayName.toUpperCase() ==
                      appliedDose.selectedSyringe!.toUpperCase() ||
                  opt.value.toUpperCase() ==
                      appliedDose.selectedSyringe!.toUpperCase(),
            );
            if (syringeOption != null) {
              doseData.selectedSyringeId = syringeOption.id;
            }
          }

          if (appliedDose.selectedDropper != null) {
            final dropperOptions = getDropperOptions(vaccineId);
            final dropperOption = dropperOptions.firstWhereOrNull(
              (opt) =>
                  opt.displayName.toUpperCase() ==
                      appliedDose.selectedDropper!.toUpperCase() ||
                  opt.value.toUpperCase() ==
                      appliedDose.selectedDropper!.toUpperCase(),
            );
            if (dropperOption != null) {
              doseData.selectedDropperId = dropperOption.id;
            }
          }

          if (appliedDose.selectedPneumococcalType != null) {
            final pneumoOptions = getPneumococcalTypeOptions(vaccineId);
            final pneumoOption = pneumoOptions.firstWhereOrNull(
              (opt) =>
                  opt.displayName.toUpperCase() ==
                      appliedDose.selectedPneumococcalType!.toUpperCase() ||
                  opt.value.toUpperCase() ==
                      appliedDose.selectedPneumococcalType!.toUpperCase(),
            );
            if (pneumoOption != null) {
              doseData.selectedPneumococcalTypeId = pneumoOption.id;
            }
          }

          if (appliedDose.selectedObservation != null) {
            final obsOptions = getObservationOptions(vaccineId);
            final obsOption = obsOptions.firstWhereOrNull(
              (opt) =>
                  opt.displayName.toUpperCase() ==
                      appliedDose.selectedObservation!.toUpperCase() ||
                  opt.value.toUpperCase() ==
                      appliedDose.selectedObservation!.toUpperCase(),
            );
            if (obsOption != null) {
              doseData.selectedObservationId = obsOption.id;
            }
          }

          // Cargar observación personalizada si existe
          if (appliedDose.customObservation != null && appliedDose.customObservation!.isNotEmpty) {
            doseData.customObservationController.text = appliedDose.customObservation!;
          }
        }
      }
      selectedVaccines.refresh();
    } catch (e) {
      print('❌ Error al cargar dosis registradas: $e');
      CustomSnackbar.showError('Error al cargar historial de vacunas');
    }
  }

  // ==================== GETTERS ====================

  List<VaccineConfigOption> getDoseOptions(String vaccineId) {
    return _doseOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getLaboratoryOptions(String vaccineId) {
    return _laboratoryOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getSyringeOptions(String vaccineId) {
    return _syringeOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getDropperOptions(String vaccineId) {
    return _dropperOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getPneumococcalTypeOptions(String vaccineId) {
    return _pneumococcalTypeOptionsCache[vaccineId] ?? [];
  }

  List<VaccineConfigOption> getObservationOptions(String vaccineId) {
    return _observationOptionsCache[vaccineId] ?? [];
  }

  bool isDoseActive(String vaccineId, String doseOptionId) {
    return selectedVaccines[vaccineId]?.isDoseActive(doseOptionId) ?? false;
  }

  bool isDoseLocked(String vaccineId, String doseOptionId) {
    return selectedVaccines[vaccineId]?.isDoseLocked(doseOptionId) ?? false;
  }

  bool hasDoseData(String vaccineId, String doseOptionId) {
    return selectedVaccines[vaccineId]?.hasDoseWithData(doseOptionId) ?? false;
  }

  Set<String> getActiveDoses(String vaccineId) {
    return selectedVaccines[vaccineId]?.activeDoses ?? {};
  }

  // Getters para valores seleccionados por dosis
  String? getSelectedLaboratory(String vaccineId, String doseOptionId) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    print(
      '🔍 getSelectedLaboratory - VaccineID: $vaccineId, DoseID: $doseOptionId',
    );
    print('   selectedLaboratoryId: ${doseData?.selectedLaboratoryId}');
    if (doseData?.selectedLaboratoryId == null) {
      print('   ❌ selectedLaboratoryId es NULL');
      return null;
    }

    final options = getLaboratoryOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == doseData!.selectedLaboratoryId,
    );
    print('   ✅ Retornando: ${option?.displayName}');
    return option?.displayName;
  }

  String? getSelectedSyringe(String vaccineId, String doseOptionId) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData?.selectedSyringeId == null) return null;

    final options = getSyringeOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == doseData!.selectedSyringeId,
    );
    return option?.displayName;
  }

  String? getSelectedDropper(String vaccineId, String doseOptionId) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData?.selectedDropperId == null) return null;

    final options = getDropperOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == doseData!.selectedDropperId,
    );
    return option?.displayName;
  }

  String? getSelectedPneumococcalType(String vaccineId, String doseOptionId) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData?.selectedPneumococcalTypeId == null) return null;

    final options = getPneumococcalTypeOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == doseData!.selectedPneumococcalTypeId,
    );
    return option?.displayName;
  }

  String? getSelectedObservation(String vaccineId, String doseOptionId) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData?.selectedObservationId == null) return null;

    final options = getObservationOptions(vaccineId);
    final option = options.firstWhereOrNull(
      (opt) => opt.id == doseData!.selectedObservationId,
    );
    return option?.displayName;
  }

  DateTime? getApplicationDate(String vaccineId, String doseOptionId) {
    return selectedVaccines[vaccineId]?.doses[doseOptionId]?.applicationDate;
  }

  TextEditingController? getLotController(
    String vaccineId,
    String doseOptionId,
  ) {
    return selectedVaccines[vaccineId]?.doses[doseOptionId]?.lotController;
  }

  TextEditingController? getSyringeLotController(
    String vaccineId,
    String doseOptionId,
  ) {
    return selectedVaccines[vaccineId]
        ?.doses[doseOptionId]
        ?.syringeLotController;
  }

  TextEditingController? getDiluentController(
    String vaccineId,
    String doseOptionId,
  ) {
    return selectedVaccines[vaccineId]?.doses[doseOptionId]?.diluentController;
  }

  TextEditingController? getVialCountController(
    String vaccineId,
    String doseOptionId,
  ) {
    return selectedVaccines[vaccineId]
        ?.doses[doseOptionId]
        ?.vialCountController;
  }

  // ==================== SETTERS ====================

  void setSelectedLaboratory(
    String vaccineId,
    String doseOptionId,
    String optionId,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.selectedLaboratoryId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedSyringe(
    String vaccineId,
    String doseOptionId,
    String optionId,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.selectedSyringeId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedDropper(
    String vaccineId,
    String doseOptionId,
    String optionId,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.selectedDropperId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedPneumococcalType(
    String vaccineId,
    String doseOptionId,
    String optionId,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.selectedPneumococcalTypeId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setSelectedObservation(
    String vaccineId,
    String doseOptionId,
    String optionId,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.selectedObservationId = optionId;
      selectedVaccines.refresh();
    }
  }

  void setApplicationDate(
    String vaccineId,
    String doseOptionId,
    DateTime date,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null && !doseData.isLocked) {
      doseData.applicationDate = date;
      selectedVaccines.refresh();
    }
  }

  // ==================== VALIDACIÓN ====================

  bool validate() {
    if (selectedVaccines.isEmpty) {
      CustomSnackbar.showError('Debes seleccionar al menos una vacuna');
      return false;
    }

    for (var entry in selectedVaccines.entries) {
      final vaccineId = entry.key;
      final vaccineData = entry.value;
      final vaccine = availableVaccines.firstWhereOrNull(
        (v) => v.id == vaccineId,
      );

      if (vaccine == null) continue;

      // Verificar que tenga al menos una dosis (activa o locked)
      if (vaccineData.activeDoses.isEmpty && !vaccineData.hasLockedDoses) {
        CustomSnackbar.showError(
          'Debes seleccionar al menos una dosis para ${vaccine.name}',
        );
        return false;
      }

      // ⚠️ IMPORTANTE: Si hay dosis activas, TODAS deben estar completadas
      if (vaccineData.activeDoses.isNotEmpty) {
        for (var doseId in vaccineData.activeDoses) {
          final doseData = vaccineData.doses[doseId];
          
          if (doseData == null) {
            CustomSnackbar.showError(
              'Error: No se encontraron datos para una dosis de ${vaccine.name}',
            );
            return false;
          }

          // Si la dosis NO está locked (es nueva), validarla completamente
          if (!doseData.isLocked) {
            if (!doseData.validate(vaccine)) {
              CustomSnackbar.showError(
                'Completa todos los campos requeridos de ${doseData.doseDisplayName} para ${vaccine.name}',
              );
              return false;
            }
          }
        }
      }
    }

    return true;
  }

  /// Obtiene los datos de todas las dosis activas para guardar
  List<Map<String, dynamic>> getVaccinesData() {
    final result = <Map<String, dynamic>>[];

    print('🔍 getVaccinesData: Revisando vacunas seleccionadas...');
    for (var entry in selectedVaccines.entries) {
      final vaccineId = entry.key;
      final vaccineData = entry.value;

      print(
        '  📦 Vacuna ID $vaccineId tiene ${vaccineData.doses.length} dosis',
      );
      // Guardar solo dosis activas (no bloqueadas)
      for (var doseEntry in vaccineData.doses.entries) {
        final doseData = doseEntry.value;

        print(
          '    🔹 Dosis ${doseData.doseDisplayName}: isLocked=${doseData.isLocked}, isActive=${doseData.isActive}',
        );

        // Solo guardar dosis activas y no bloqueadas
        if (!doseData.isLocked && doseData.isActive) {
          print('      ✅ Incluyendo dosis para guardar');
          result.add({
            'vaccine_id': vaccineId,
            'dose_option_id': doseEntry.key,
            'selected_dose': doseData.doseValue,
            'laboratory_option_id': doseData.selectedLaboratoryId,
            'syringe_option_id': doseData.selectedSyringeId,
            'dropper_option_id': doseData.selectedDropperId,
            'pneumococcal_type_option_id': doseData.selectedPneumococcalTypeId,
            'observation_option_id': doseData.selectedObservationId,
            'application_date': doseData.applicationDate?.toIso8601String(),
            'lot': doseData.lotController.text.trim(),
            'syringe_lot': doseData.syringeLotController.text.trim(),
            'diluent': doseData.diluentController.text.trim(),
            'vial_count': doseData.vialCountController.text.trim(),
            'custom_observation': doseData.customObservationController.text.trim(),
          });
        } else {
          print('      ⏭️ Saltando dosis (bloqueada o inactiva)');
        }
      }
    }

    print('📊 Total de dosis a guardar: ${result.length}');
    return result;
  }

  /// Valida que todas las dosis activas tengan los campos requeridos completados
  /// Retorna un String con el error si hay validación fallida, null si todo está bien
  String? validateAllActiveDoses() {
    for (final vaccineEntry in selectedVaccines.entries) {
      final vaccineId = vaccineEntry.key;
      final vaccineData = vaccineEntry.value;

      // Obtener la vacuna para verificar configuración de campos requeridos
      final vaccine = availableVaccines.firstWhereOrNull((v) => v.id == vaccineId);
      if (vaccine == null) continue;

      // Validar cada dosis activa (no bloqueada)
      for (final doseEntry in vaccineData.doses.entries) {
        final doseData = doseEntry.value;

        // Solo validar dosis activas y no bloqueadas (nuevas o siendo editadas)
        if (doseData.isActive && !doseData.isLocked) {
          // Validar usando el método validate de DoseData
          if (!doseData.validate(vaccine)) {
            return 'Por favor completa todos los campos requeridos para ${vaccine.name} - ${doseData.doseDisplayName}';
          }
        }
      }
    }

    return null; // Todas las dosis válidas
  }

  /// Obtiene el controlador de observación personalizada para una dosis
  TextEditingController? getCustomObservationController(
    String vaccineId,
    String doseOptionId,
  ) {
    return selectedVaccines[vaccineId]?.doses[doseOptionId]?.customObservationController;
  }

  /// Establece la observación personalizada para una dosis
  void setCustomObservation(
    String vaccineId,
    String doseOptionId,
    String observation,
  ) {
    final doseData = selectedVaccines[vaccineId]?.doses[doseOptionId];
    if (doseData != null) {
      doseData.customObservationController.text = observation;
    }
  }
}
