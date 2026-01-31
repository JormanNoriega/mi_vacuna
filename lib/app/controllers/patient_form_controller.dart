import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/applied_dose.dart';
import '../services/patient_service.dart';
import '../services/applied_dose_service.dart';
import '../widgets/custom_snackbar.dart';
import 'vaccine_selection_controller.dart';

/// Controlador para el formulario de registro de pacientes
/// Gestiona los pasos del formulario (datos básicos, adicionales, vacunas y revisión)
class PatientFormController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppliedDoseService _appliedDoseService = AppliedDoseService();

  // ==================== ESTADO ====================
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  // ==================== CONTROL DE NAVEGACIÓN ====================
  final pageController = PageController();
  final RxInt currentStep = 0.obs;
  final int totalSteps =
      4; // Paso 1 (básicos), Paso 2 (adicionales), Paso 3 (vacunas), Paso 4 (revisión)

  // ==================== PASO 1: DATOS BÁSICOS ====================
  // Controllers de texto
  final idNumberController = TextEditingController();
  final firstNameController = TextEditingController();
  final secondNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final secondLastNameController = TextEditingController();

  // Valores seleccionables
  final selectedIdType = 'CC - Cédula de Ciudadanía'.obs;
  final selectedSex = Rx<Sexo>(Sexo.hombre);
  final birthDate = Rx<DateTime?>(null);
  final attentionDate = Rx<DateTime>(DateTime.now());
  final completeScheme = false.obs;

  // ==================== PASO 2: DATOS ADICIONALES ====================
  // Datos demográficos
  final selectedGender = Rx<Genero?>(null);
  final selectedSexualOrientation = Rx<OrientacionSexual?>(null);
  final selectedMigratoryStatus = Rx<EstatusMigratorio?>(null);
  final selectedEthnicity = Rx<PertenenciaEtnica>(PertenenciaEtnica.ninguno);
  final selectedHealthRegime = Rx<RegimenAfiliacion?>(null);
  final selectedArea = Rx<Area?>(null);

  // Controllers de texto - Ubicación
  final birthCountryController = TextEditingController(text: 'Colombia');
  final birthPlaceController = TextEditingController();
  final residenceCountryController = TextEditingController(text: 'Colombia');
  final residenceDepartmentController = TextEditingController();
  final residenceMunicipalityController = TextEditingController();
  final communeController = TextEditingController();
  final addressController = TextEditingController();

  // Controllers de texto - Contacto
  final landlineController = TextEditingController();
  final cellphoneController = TextEditingController();
  final emailController = TextEditingController();
  final authorizeCalls = false.obs;
  final authorizeEmail = false.obs;

  // Controllers de texto - Salud
  final insurerController = TextEditingController();
  final gestationalAgeController = TextEditingController();

  // Flags booleanos
  final displaced = false.obs;
  final disabled = false.obs;
  final deceased = false.obs;
  final armedConflictVictim = false.obs;
  final currentlyStudying = Rx<bool?>(null);

  // ==================== DATOS DE LA MADRE ====================
  final showMotherData = false.obs; // Flag para mostrar/ocultar sección madre
  final selectedMotherIdType = Rx<String?>(null);
  final motherIdNumberController = TextEditingController();
  final motherFirstNameController = TextEditingController();
  final motherSecondNameController = TextEditingController();
  final motherLastNameController = TextEditingController();
  final motherSecondLastNameController = TextEditingController();
  final motherEmailController = TextEditingController();
  final motherLandlineController = TextEditingController();
  final motherCellphoneController = TextEditingController();
  final selectedMotherAffiliationRegime = Rx<RegimenAfiliacion?>(null);
  final selectedMotherEthnicity = Rx<PertenenciaEtnica?>(null);
  final motherDisplaced = Rx<bool?>(null);

  // ==================== DATOS DEL CUIDADOR ====================
  final showCaregiverData =
      false.obs; // Flag para mostrar/ocultar sección cuidador
  final selectedCaregiverIdType = Rx<String?>(null);
  final caregiverIdNumberController = TextEditingController();
  final caregiverFirstNameController = TextEditingController();
  final caregiverSecondNameController = TextEditingController();
  final caregiverLastNameController = TextEditingController();
  final caregiverSecondLastNameController = TextEditingController();
  final caregiverRelationshipController = TextEditingController();
  final caregiverEmailController = TextEditingController();
  final caregiverLandlineController = TextEditingController();
  final caregiverCellphoneController = TextEditingController();

  // ==================== ANTECEDENTES MÉDICOS ====================
  final hasContraindication = false.obs;
  final contraindicationDetailsController = TextEditingController();
  final hasPreviousReaction = false.obs;
  final reactionDetailsController = TextEditingController();

  // ==================== HISTÓRICO DE ANTECEDENTES ====================
  final historyRecordDate = Rx<DateTime?>(null);
  final historyTypeController = TextEditingController();
  final historyDescriptionController = TextEditingController();
  final specialObservationsController = TextEditingController();

  // ==================== CONDICIÓN USUARIA (solo mujeres) ====================
  final selectedUserCondition = Rx<CondicionUsuaria?>(null);
  final lastMenstrualDate = Rx<DateTime?>(null);
  final gestationWeeksController = TextEditingController();
  final probableDeliveryDate = Rx<DateTime?>(null);
  final previousPregnanciesController = TextEditingController();

  // ==================== PROPIEDADES CALCULADAS ====================
  double get progress => (currentStep.value + 1) / totalSteps;

  // ==================== LIFECYCLE ====================
  @override
  void onClose() {
    // Liberar recursos
    pageController.dispose();

    // Datos básicos
    idNumberController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    lastNameController.dispose();
    secondLastNameController.dispose();

    // Ubicación
    birthCountryController.dispose();
    birthPlaceController.dispose();
    residenceCountryController.dispose();
    residenceDepartmentController.dispose();
    residenceMunicipalityController.dispose();
    communeController.dispose();
    addressController.dispose();

    // Contacto
    landlineController.dispose();
    cellphoneController.dispose();
    emailController.dispose();

    // Salud
    insurerController.dispose();
    gestationalAgeController.dispose();

    // Madre
    motherIdNumberController.dispose();
    motherFirstNameController.dispose();
    motherSecondNameController.dispose();
    motherLastNameController.dispose();
    motherSecondLastNameController.dispose();
    motherEmailController.dispose();
    motherLandlineController.dispose();
    motherCellphoneController.dispose();

    // Cuidador
    caregiverIdNumberController.dispose();
    caregiverFirstNameController.dispose();
    caregiverSecondNameController.dispose();
    caregiverLastNameController.dispose();
    caregiverSecondLastNameController.dispose();
    caregiverRelationshipController.dispose();
    caregiverEmailController.dispose();
    caregiverLandlineController.dispose();
    caregiverCellphoneController.dispose();

    // Antecedentes
    contraindicationDetailsController.dispose();
    reactionDetailsController.dispose();

    // Histórico
    historyTypeController.dispose();
    historyDescriptionController.dispose();
    specialObservationsController.dispose();

    // Condición usuaria
    gestationWeeksController.dispose();
    previousPregnanciesController.dispose();

    super.onClose();
  }

  // ==================== NAVEGACIÓN ====================
  void nextStep() {
    if (currentStep.value < totalSteps - 1) {
      // Validar paso actual antes de avanzar
      if (currentStep.value == 0 && !validateStep1()) {
        return;
      }
      if (currentStep.value == 1 && !validateStep2()) {
        return;
      }

      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Último paso - guardar
      submitForm();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      currentStep.value = step;
      pageController.animateToPage(
        step,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // ==================== CÁLCULOS ====================
  /// Calcula la edad del paciente basándose en la fecha de nacimiento
  Map<String, int> calculateAge() {
    if (birthDate.value == null) {
      return {'years': 0, 'months': 0, 'days': 0, 'totalMonths': 0};
    }

    final now = DateTime.now();
    final birth = birthDate.value!;

    int years = now.year - birth.year;
    int months = now.month - birth.month;
    int days = now.day - birth.day;

    if (days < 0) {
      months--;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final totalMonths =
        (now.year - birth.year) * 12 + (now.month - birth.month);
    final totalDays = now.difference(birth).inDays;

    return {
      'years': years,
      'months': months,
      'days': totalDays,
      'totalMonths': totalMonths.abs(),
    };
  }

  // ==================== VALIDACIONES ====================
  bool validateStep1() {
    if (idNumberController.text.trim().isEmpty) {
      CustomSnackbar.showError('El número de identificación es requerido');
      return false;
    }

    if (firstNameController.text.trim().isEmpty) {
      CustomSnackbar.showError('El primer nombre es requerido');
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      CustomSnackbar.showError('El primer apellido es requerido');
      return false;
    }

    if (birthDate.value == null) {
      CustomSnackbar.showError('La fecha de nacimiento es requerida');
      return false;
    }

    return true;
  }

  bool validateStep2() {
    // País de Nacimiento (requerido)
    if (birthCountryController.text.trim().isEmpty) {
      CustomSnackbar.showError('El país de nacimiento es requerido');
      return false;
    }

    // Estatus Migratorio (requerido)
    if (selectedMigratoryStatus.value == null) {
      CustomSnackbar.showError('El estatus migratorio es requerido');
      return false;
    }

    // Lugar de Atención del Parto (requerido)
    if (birthPlaceController.text.trim().isEmpty) {
      CustomSnackbar.showError('El lugar de atención del parto es requerido');
      return false;
    }

    // Régimen de Afiliación (requerido)
    if (selectedHealthRegime.value == null) {
      CustomSnackbar.showError('El régimen de afiliación es requerido');
      return false;
    }

    // Aseguradora (requerido)
    if (insurerController.text.trim().isEmpty) {
      CustomSnackbar.showError('La aseguradora (EPS) es requerida');
      return false;
    }

    // Pertenencia Étnica (requerido)
    if (selectedEthnicity.value == PertenenciaEtnica.ninguno) {
      // Esto es válido, ninguno es una opción
    }

    // Departamento y Municipio (requeridos)
    if (residenceDepartmentController.text.trim().isEmpty) {
      CustomSnackbar.showError('El departamento de residencia es requerido');
      return false;
    }

    if (residenceMunicipalityController.text.trim().isEmpty) {
      CustomSnackbar.showError('El municipio de residencia es requerido');
      return false;
    }

    // Área (requerida)
    if (selectedArea.value == null) {
      CustomSnackbar.showError('El área de residencia es requerida');
      return false;
    }

    // Validaciones condicionales para gestantes
    if (selectedUserCondition.value == CondicionUsuaria.gestante) {
      if (lastMenstrualDate.value == null) {
        CustomSnackbar.showError(
          'La fecha de última menstruación es requerida para gestantes',
        );
        return false;
      }
    }

    return true;
  }

  // ==================== OPERACIONES CRUD ====================
  /// Guarda el paciente en la base de datos
  Future<void> submitForm() async {
    print('🔥 submitForm llamado');
    // Validar datos básicos
    if (!validateStep1()) {
      print('❌ Validación de paso 1 falló');
      goToStep(0);
      return;
    }

    print('✅ Validación paso 1 exitosa');
    try {
      isLoading.value = true;
      errorMessage.value = '';
      print('📝 Iniciando guardado de paciente...');

      // Calcular edad
      final age = calculateAge();

      // TODO: Obtener el nurseId del usuario logueado
      // Por ahora usamos 1 como valor por defecto
      final int nurseId = 1;

      // Crear objeto Patient
      final patient = Patient(
        nurseId: nurseId,
        // Datos básicos (Paso 1)
        attentionDate: attentionDate.value,
        idType: selectedIdType.value,
        idNumber: idNumberController.text.trim(),
        firstName: firstNameController.text.trim(),
        secondName: secondNameController.text.trim().isEmpty
            ? null
            : secondNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        secondLastName: secondLastNameController.text.trim().isEmpty
            ? null
            : secondLastNameController.text.trim(),
        birthDate: birthDate.value!,
        years: age['years'],
        months: age['months'],
        days: age['days'],
        totalMonths: age['totalMonths'],
        completeScheme: completeScheme.value,
        sex: selectedSex.value,

        // Datos adicionales (Paso 2)
        birthCountry: birthCountryController.text.trim(),
        birthPlace: birthPlaceController.text.trim().isEmpty
            ? null
            : birthPlaceController.text.trim(),
        residenceCountry: residenceCountryController.text.trim().isEmpty
            ? null
            : residenceCountryController.text.trim(),
        residenceDepartment: residenceDepartmentController.text.trim().isEmpty
            ? null
            : residenceDepartmentController.text.trim(),
        residenceMunicipality:
            residenceMunicipalityController.text.trim().isEmpty
            ? null
            : residenceMunicipalityController.text.trim(),
        commune: communeController.text.trim().isEmpty
            ? null
            : communeController.text.trim(),
        address: addressController.text.trim().isEmpty
            ? null
            : addressController.text.trim(),
        landline: landlineController.text.trim().isEmpty
            ? null
            : landlineController.text.trim(),
        cellphone: cellphoneController.text.trim().isEmpty
            ? null
            : cellphoneController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        authorizeCalls: authorizeCalls.value,
        authorizeEmail: authorizeEmail.value,

        // Datos demográficos
        gender: selectedGender.value,
        sexualOrientation: selectedSexualOrientation.value,
        migrationStatus: selectedMigratoryStatus.value,
        ethnicity: selectedEthnicity.value,
        affiliationRegime: selectedHealthRegime.value,
        area: selectedArea.value,

        // Salud
        insurer: insurerController.text.trim().isEmpty
            ? null
            : insurerController.text.trim(),
        gestationalAge: gestationalAgeController.text.trim().isEmpty
            ? null
            : int.tryParse(gestationalAgeController.text.trim()),

        // Flags
        displaced: displaced.value,
        disabled: disabled.value,
        deceased: deceased.value,
        armedConflictVictim: armedConflictVictim.value,
        currentlyStudying: currentlyStudying.value,

        // Antecedentes médicos
        hasContraindication: hasContraindication.value,
        contraindicationDetails:
            hasContraindication.value &&
                contraindicationDetailsController.text.trim().isNotEmpty
            ? contraindicationDetailsController.text.trim()
            : null,
        hasPreviousReaction: hasPreviousReaction.value,
        reactionDetails:
            hasPreviousReaction.value &&
                reactionDetailsController.text.trim().isNotEmpty
            ? reactionDetailsController.text.trim()
            : null,

        // Histórico de antecedentes
        historyRecordDate: historyRecordDate.value,
        historyType: historyTypeController.text.trim().isEmpty
            ? null
            : historyTypeController.text.trim(),
        historyDescription: historyDescriptionController.text.trim().isEmpty
            ? null
            : historyDescriptionController.text.trim(),
        specialObservations: specialObservationsController.text.trim().isEmpty
            ? null
            : specialObservationsController.text.trim(),

        // Condición usuaria (solo para mujeres)
        userCondition: selectedUserCondition.value,
        lastMenstrualDate: lastMenstrualDate.value,
        gestationWeeks: gestationWeeksController.text.trim().isEmpty
            ? null
            : int.tryParse(gestationWeeksController.text.trim()),
        probableDeliveryDate: probableDeliveryDate.value,
        previousPregnancies: previousPregnanciesController.text.trim().isEmpty
            ? null
            : int.tryParse(previousPregnanciesController.text.trim()),

        // Datos de la madre (solo si showMotherData es true)
        motherIdType: showMotherData.value ? selectedMotherIdType.value : null,
        motherIdNumber:
            showMotherData.value &&
                motherIdNumberController.text.trim().isNotEmpty
            ? motherIdNumberController.text.trim()
            : null,
        motherFirstName:
            showMotherData.value &&
                motherFirstNameController.text.trim().isNotEmpty
            ? motherFirstNameController.text.trim()
            : null,
        motherSecondName:
            showMotherData.value &&
                motherSecondNameController.text.trim().isNotEmpty
            ? motherSecondNameController.text.trim()
            : null,
        motherLastName:
            showMotherData.value &&
                motherLastNameController.text.trim().isNotEmpty
            ? motherLastNameController.text.trim()
            : null,
        motherSecondLastName:
            showMotherData.value &&
                motherSecondLastNameController.text.trim().isNotEmpty
            ? motherSecondLastNameController.text.trim()
            : null,
        motherEmail:
            showMotherData.value && motherEmailController.text.trim().isNotEmpty
            ? motherEmailController.text.trim()
            : null,
        motherLandline:
            showMotherData.value &&
                motherLandlineController.text.trim().isNotEmpty
            ? motherLandlineController.text.trim()
            : null,
        motherCellphone:
            showMotherData.value &&
                motherCellphoneController.text.trim().isNotEmpty
            ? motherCellphoneController.text.trim()
            : null,
        motherAffiliationRegime: showMotherData.value
            ? selectedMotherAffiliationRegime.value
            : null,
        motherEthnicity: showMotherData.value
            ? selectedMotherEthnicity.value
            : null,
        motherDisplaced: showMotherData.value ? motherDisplaced.value : null,

        // Datos del cuidador (solo si showCaregiverData es true)
        caregiverIdType: showCaregiverData.value
            ? selectedCaregiverIdType.value
            : null,
        caregiverIdNumber:
            showCaregiverData.value &&
                caregiverIdNumberController.text.trim().isNotEmpty
            ? caregiverIdNumberController.text.trim()
            : null,
        caregiverFirstName:
            showCaregiverData.value &&
                caregiverFirstNameController.text.trim().isNotEmpty
            ? caregiverFirstNameController.text.trim()
            : null,
        caregiverSecondName:
            showCaregiverData.value &&
                caregiverSecondNameController.text.trim().isNotEmpty
            ? caregiverSecondNameController.text.trim()
            : null,
        caregiverLastName:
            showCaregiverData.value &&
                caregiverLastNameController.text.trim().isNotEmpty
            ? caregiverLastNameController.text.trim()
            : null,
        caregiverSecondLastName:
            showCaregiverData.value &&
                caregiverSecondLastNameController.text.trim().isNotEmpty
            ? caregiverSecondLastNameController.text.trim()
            : null,
        caregiverRelationship:
            showCaregiverData.value &&
                caregiverRelationshipController.text.trim().isNotEmpty
            ? caregiverRelationshipController.text.trim()
            : null,
        caregiverEmail:
            showCaregiverData.value &&
                caregiverEmailController.text.trim().isNotEmpty
            ? caregiverEmailController.text.trim()
            : null,
        caregiverLandline:
            showCaregiverData.value &&
                caregiverLandlineController.text.trim().isNotEmpty
            ? caregiverLandlineController.text.trim()
            : null,
        caregiverCellphone:
            showCaregiverData.value &&
                caregiverCellphoneController.text.trim().isNotEmpty
            ? caregiverCellphoneController.text.trim()
            : null,
      );

      // Guardar en la base de datos
      print('💾 Guardando paciente en la base de datos...');
      final patientId = await _patientService.createPatient(patient);
      print('✅ Paciente guardado con ID: $patientId');

      if (patientId > 0) {
        // Guardar las vacunas aplicadas
        print('💉 Guardando vacunas aplicadas...');
        await _saveAppliedDoses(patientId, nurseId);
        print('✅ Vacunas guardadas exitosamente');

        Get.back();
        CustomSnackbar.showSuccess(
          'Paciente y vacunas registrados correctamente',
        );
      } else {
        throw Exception('No se pudo crear el paciente');
      }
    } catch (e) {
      print('❌ ERROR en submitForm: $e');
      print('Stack trace: ${StackTrace.current}');
      errorMessage.value = 'Error al guardar el paciente: $e';
      CustomSnackbar.showError(errorMessage.value);
    } finally {
      isLoading.value = false;
      print('🏁 submitForm terminado');
    }
  }

  /// Guarda las dosis aplicadas (vacunas seleccionadas)
  Future<void> _saveAppliedDoses(int patientId, int nurseId) async {
    try {
      final vaccineController = Get.find<VaccineSelectionController>();
      final vaccinesData = vaccineController.getVaccinesData();

      for (var vaccineData in vaccinesData) {
        final appliedDose = AppliedDose(
          patientId: patientId,
          nurseId: nurseId,
          vaccineId: vaccineData['vaccine_id'],
          applicationDate: DateTime.parse(vaccineData['application_date']),
          selectedDose: _getOptionDisplayName(
            vaccineData['dose_option_id'],
            vaccineController,
          ),
          selectedLaboratory: _getOptionDisplayName(
            vaccineData['laboratory_option_id'],
            vaccineController,
          ),
          lotNumber: vaccineData['lot'] ?? '',
          selectedSyringe: _getOptionDisplayName(
            vaccineData['syringe_option_id'],
            vaccineController,
          ),
          syringeLot: vaccineData['syringe_lot']?.isEmpty == false
              ? vaccineData['syringe_lot']
              : null,
          diluentLot: vaccineData['diluent']?.isEmpty == false
              ? vaccineData['diluent']
              : null,
          selectedDropper: _getOptionDisplayName(
            vaccineData['dropper_option_id'],
            vaccineController,
          ),
          selectedPneumococcalType: _getOptionDisplayName(
            vaccineData['pneumococcal_type_option_id'],
            vaccineController,
          ),
          vialCount: vaccineData['vial_count']?.isEmpty == false
              ? int.tryParse(vaccineData['vial_count'])
              : null,
          selectedObservation: _getOptionDisplayName(
            vaccineData['observation_option_id'],
            vaccineController,
          ),
        );

        await _appliedDoseService.createDose(appliedDose);
      }
    } catch (e) {
      print('Error guardando dosis aplicadas: $e');
      // No lanzamos error para no bloquear el guardado del paciente
    }
  }

  /// Helper para obtener el displayName de una opción por su ID
  String? _getOptionDisplayName(
    int? optionId,
    VaccineSelectionController controller,
  ) {
    if (optionId == null) return null;

    // Buscar en todos los caches de opciones
    for (var cache in [
      controller.getDoseOptions,
      controller.getLaboratoryOptions,
      controller.getSyringeOptions,
      controller.getDropperOptions,
      controller.getPneumococcalTypeOptions,
      controller.getObservationOptions,
    ]) {
      // Buscar en todas las vacunas
      for (var vaccineId in controller.selectedVaccines.keys) {
        final options = cache(vaccineId);
        final option = options.firstWhereOrNull((opt) => opt.id == optionId);
        if (option != null) return option.displayName;
      }
    }

    return null;
  }

  /// Limpia todos los campos del formulario
  void clearForm() {
    // Datos básicos
    idNumberController.clear();
    firstNameController.clear();
    secondNameController.clear();
    lastNameController.clear();
    secondLastNameController.clear();
    selectedIdType.value = 'CC - Cédula de Ciudadanía';
    selectedSex.value = Sexo.hombre;
    birthDate.value = null;
    attentionDate.value = DateTime.now();
    completeScheme.value = false;

    // Ubicación
    birthCountryController.text = 'Colombia';
    birthPlaceController.clear();
    residenceCountryController.clear();
    residenceDepartmentController.clear();
    residenceMunicipalityController.clear();
    communeController.clear();
    addressController.clear();

    // Contacto
    landlineController.clear();
    cellphoneController.clear();
    emailController.clear();
    authorizeCalls.value = false;
    authorizeEmail.value = false;

    // Demográficos
    selectedGender.value = null;
    selectedSexualOrientation.value = null;
    selectedMigratoryStatus.value = null;
    selectedEthnicity.value = PertenenciaEtnica.ninguno;
    selectedHealthRegime.value = null;
    selectedArea.value = null;

    // Salud
    insurerController.clear();
    gestationalAgeController.clear();

    // Flags
    displaced.value = false;
    disabled.value = false;
    deceased.value = false;
    armedConflictVictim.value = false;
    currentlyStudying.value = null;

    // Madre
    showMotherData.value = false;
    selectedMotherIdType.value = null;
    motherIdNumberController.clear();
    motherFirstNameController.clear();
    motherSecondNameController.clear();
    motherLastNameController.clear();
    motherSecondLastNameController.clear();
    motherEmailController.clear();
    motherLandlineController.clear();
    motherCellphoneController.clear();
    selectedMotherAffiliationRegime.value = null;
    selectedMotherEthnicity.value = null;
    motherDisplaced.value = null;

    // Cuidador
    showCaregiverData.value = false;
    selectedCaregiverIdType.value = null;
    caregiverIdNumberController.clear();
    caregiverFirstNameController.clear();
    caregiverSecondNameController.clear();
    caregiverLastNameController.clear();
    caregiverSecondLastNameController.clear();
    caregiverRelationshipController.clear();
    caregiverEmailController.clear();
    caregiverLandlineController.clear();
    caregiverCellphoneController.clear();

    // Antecedentes médicos
    hasContraindication.value = false;
    contraindicationDetailsController.clear();
    hasPreviousReaction.value = false;
    reactionDetailsController.clear();

    // Histórico
    historyRecordDate.value = null;
    historyTypeController.clear();
    historyDescriptionController.clear();
    specialObservationsController.clear();

    // Condición usuaria
    selectedUserCondition.value = null;
    lastMenstrualDate.value = null;
    gestationWeeksController.clear();
    probableDeliveryDate.value = null;
    previousPregnanciesController.clear();

    // Resetear navegación
    currentStep.value = 0;
  }
}
