import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../models/applied_dose.dart';
import '../services/patient_service.dart';
import '../services/applied_dose_service.dart';
import '../widgets/custom_snackbar.dart';
import '../utils/age_calculator.dart';
import '../data/database_helper.dart';
import 'vaccine_selection_controller.dart';
import 'auth_controller.dart';

/// Controlador para el formulario de registro de pacientes
/// Gestiona los pasos del formulario (datos básicos, adicionales, vacunas y revisión)
class PatientFormController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppliedDoseService _appliedDoseService = AppliedDoseService();

  // ==================== ESTADO ====================
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final isEditMode = false.obs;
  final isModalMode =
      false.obs; // Indica si se abrió como modal desde patient_history
  String? editingPatientId; // Cambiado de int? a String? para UUID

  // ==================== CONTROL DE NAVEGACIÓN ====================
  final pageController = PageController();
  final RxInt currentStep = 0.obs;
  final int totalSteps =
      4; // Paso 1 (básicos), Paso 2 (adicionales), Paso 3 (vacunas), Paso 4 (revisión)

  // ==================== REFERENCIAS DE WIDGETS ====================
  // formKey de Step 1 para validar desde el wrapper
  Rx<GlobalKey<FormState>?> step1FormKey = Rx<GlobalKey<FormState>?>(null);

  void registerStep1FormKey(GlobalKey<FormState> key) {
    step1FormKey.value = key;
  }

  // formKey de Step 2 para validar desde el wrapper
  Rx<GlobalKey<FormState>?> step2FormKey = Rx<GlobalKey<FormState>?>(null);

  void registerStep2FormKey(GlobalKey<FormState> key) {
    step2FormKey.value = key;
  }

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
  final schemeSelected = false.obs; // Track if user selected something

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
  final hasGivenBirth = false.obs; // Flag para mostrar/ocultar "Lugar de Parto"

  // ==================== PROPIEDADES CALCULADAS ====================
  double get progress => (currentStep.value + 1) / totalSteps;

  // ==================== LIFECYCLE ====================
  @override
  void onInit() {
    super.onInit();
    // Resetear el estado al inicializar
    resetForm();
    _setupOptimizations();
  }

  /// Configurar optimizaciones para mejorar rendimiento
  void _setupOptimizations() {
    // Deshabilitar logs innecesarios en producción
    // GetX puede causar overhead con logs excesivos
  }

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
  void nextStep({PageController? customPageController}) {
    if (currentStep.value < totalSteps - 1) {
      // Validar paso actual antes de avanzar
      if (currentStep.value == 0 && !validateStep1()) {
        return;
      }
      if (currentStep.value == 1 && !validateStep2()) {
        return;
      }
      // Validar paso 2 (vacunas) - verificar que todas las dosis activas tengan campos completos
      if (currentStep.value == 2) {
        if (Get.isRegistered<VaccineSelectionController>()) {
          final vaccineController = Get.find<VaccineSelectionController>();
          final validationError = vaccineController.validateAllActiveDoses();
          if (validationError != null) {
            CustomSnackbar.showError(validationError);
            return;
          }
        }
      }

      final controllerToUse = customPageController ?? pageController;
      final nextStep = currentStep.value + 1;

      // Actualizar en batch para evitar múltiples rebuilds
      currentStep.value = nextStep;
      // Usar jumpToPage para transición instantánea sin lag
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controllerToUse.hasClients) {
          controllerToUse.jumpToPage(nextStep);
        }
      });
    } else {
      // Último paso - guardar
      submitForm();
    }
  }

  void previousStep({PageController? customPageController}) {
    if (currentStep.value > 0) {
      final controllerToUse = customPageController ?? pageController;
      final prevStep = currentStep.value - 1;

      // Actualizar en batch para evitar múltiples rebuilds
      currentStep.value = prevStep;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controllerToUse.hasClients) {
          controllerToUse.jumpToPage(prevStep);
        }
      });
    }
  }

  void goToStep(int step, {PageController? customPageController}) {
    if (step >= 0 && step < totalSteps) {
      final controllerToUse = customPageController ?? pageController;

      // Actualizar en batch
      currentStep.value = step;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controllerToUse.hasClients) {
          controllerToUse.jumpToPage(step);
        }
      });
    }
  }

  /// Resetea el formulario al estado inicial
  void resetForm() {
    // Actualizar todos los valores en batch
    currentStep.value = 0;
    isEditMode.value = false;
    isModalMode.value = false;
    editingPatientId = null;

    // Resetear FormKey para evitar conflictos
    step1FormKey.value = null;
    step2FormKey.value = null;

    // Resetear el PageController después del frame actual
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(0);
      }
    });
  }

  /// Verifica si hay datos sin guardar en el formulario
  bool hasUnsavedData() {
    // Validación simplificada: solo verificar si hay texto en el campo de ID
    return idNumberController.text.trim().isNotEmpty;
  }

  /// Busca un paciente por número de identificación
  Future<Patient?> findPatientByIdNumber(String idNumber) async {
    try {
      return await _patientService.getPatientByIdNumber(idNumber);
    } catch (e) {
      return null;
    }
  }

  // ==================== M\u00c9TODO PARA CARGAR DATOS EXISTENTES ====================
  /// Carga los datos de un paciente existente para edici\u00f3n
  /// Carga los datos de un paciente para edición
  /// [isModal] indica si se abrió como modal desde patient_history (true) o desde detección en Step1 (false)
  void loadPatientData(
    Patient patient, {
    bool isModal = false,
    PageController? customPageController,
  }) async {
    isEditMode.value = true;
    isModalMode.value = isModal;
    editingPatientId = patient.id;

    // Resetear FormKey para evitar conflictos
    step1FormKey.value = null;
    step2FormKey.value = null;

    // Resetear navegación al inicio
    currentStep.value = 0;
    final controllerToUse = customPageController ?? pageController;
    if (controllerToUse.hasClients) {
      controllerToUse.jumpToPage(0);
    }

    // Paso 1: Datos b\u00e1sicos
    selectedIdType.value = patient.idType;
    idNumberController.text = patient.idNumber;
    firstNameController.text = patient.firstName;
    secondNameController.text = patient.secondName ?? '';
    lastNameController.text = patient.lastName;
    secondLastNameController.text = patient.secondLastName ?? '';
    selectedSex.value = patient.sex;
    birthDate.value = patient.birthDate;
    attentionDate.value = patient.attentionDate;
    completeScheme.value = patient.completeScheme;

    // Paso 2: Datos adicionales
    birthCountryController.text = patient.birthCountry;
    birthPlaceController.text = patient.birthPlace ?? '';
    residenceCountryController.text = patient.residenceCountry ?? 'Colombia';
    residenceDepartmentController.text = patient.residenceDepartment ?? '';
    residenceMunicipalityController.text = patient.residenceMunicipality ?? '';
    communeController.text = patient.commune ?? '';
    addressController.text = patient.address ?? '';
    landlineController.text = patient.landline ?? '';
    cellphoneController.text = patient.cellphone ?? '';
    emailController.text = patient.email ?? '';
    authorizeCalls.value = patient.authorizeCalls;
    authorizeEmail.value = patient.authorizeEmail;

    selectedGender.value = patient.gender;
    selectedSexualOrientation.value = patient.sexualOrientation;
    selectedMigratoryStatus.value = patient.migrationStatus;
    if (patient.ethnicity != null) {
      selectedEthnicity.value = patient.ethnicity!;
    }
    selectedHealthRegime.value = patient.affiliationRegime;
    selectedArea.value = patient.area;
    insurerController.text = patient.insurer ?? '';
    gestationalAgeController.text = patient.gestationalAge?.toString() ?? '';

    displaced.value = patient.displaced;
    disabled.value = patient.disabled;
    deceased.value = patient.deceased;
    armedConflictVictim.value = patient.armedConflictVictim;
    currentlyStudying.value = patient.currentlyStudying;

    // Antecedentes
    hasContraindication.value = patient.hasContraindication;
    contraindicationDetailsController.text =
        patient.contraindicationDetails ?? '';
    hasPreviousReaction.value = patient.hasPreviousReaction;
    reactionDetailsController.text = patient.reactionDetails ?? '';
    historyRecordDate.value = patient.historyRecordDate;
    historyTypeController.text = patient.historyType ?? '';
    historyDescriptionController.text = patient.historyDescription ?? '';
    specialObservationsController.text = patient.specialObservations ?? '';

    // Condici\u00f3n usuaria
    selectedUserCondition.value = patient.userCondition;
    lastMenstrualDate.value = patient.lastMenstrualDate;
    gestationWeeksController.text = patient.gestationWeeks?.toString() ?? '';
    probableDeliveryDate.value = patient.probableDeliveryDate;
    previousPregnanciesController.text =
        patient.previousPregnancies?.toString() ?? '';

    // ✅ CARGAR: Historia de Parto - hasGivenBirth
    hasGivenBirth.value = patient.birthPlace != null && patient.birthPlace!.isNotEmpty;

    // Datos de la madre
    final hasMotherData = patient.motherIdType != null || 
        patient.motherIdNumber != null ||
        patient.motherFirstName != null ||
        patient.motherLastName != null ||
        patient.motherEmail != null ||
        patient.motherLandline != null ||
        patient.motherCellphone != null ||
        patient.motherAffiliationRegime != null ||
        patient.motherEthnicity != null ||
        patient.motherDisplaced != null;
    
    if (hasMotherData) {
      showMotherData.value = true;
      selectedMotherIdType.value = patient.motherIdType;
      motherIdNumberController.text = patient.motherIdNumber ?? '';
      motherFirstNameController.text = patient.motherFirstName ?? '';
      motherSecondNameController.text = patient.motherSecondName ?? '';
      motherLastNameController.text = patient.motherLastName ?? '';
      motherSecondLastNameController.text = patient.motherSecondLastName ?? '';
      motherEmailController.text = patient.motherEmail ?? '';
      motherLandlineController.text = patient.motherLandline ?? '';
      motherCellphoneController.text = patient.motherCellphone ?? '';
      if (patient.motherAffiliationRegime != null) {
        selectedMotherAffiliationRegime.value = patient.motherAffiliationRegime;
      }
      if (patient.motherEthnicity != null) {
        selectedMotherEthnicity.value = patient.motherEthnicity!;
      }
      motherDisplaced.value = patient.motherDisplaced ?? false;
    }

    // Datos del cuidador
    final hasCaregiverData = patient.caregiverIdType != null ||
        patient.caregiverIdNumber != null ||
        patient.caregiverFirstName != null ||
        patient.caregiverLastName != null ||
        patient.caregiverRelationship != null ||
        patient.caregiverEmail != null ||
        patient.caregiverLandline != null ||
        patient.caregiverCellphone != null;
    
    if (hasCaregiverData) {
      showCaregiverData.value = true;
      selectedCaregiverIdType.value = patient.caregiverIdType;
      caregiverIdNumberController.text = patient.caregiverIdNumber ?? '';
      caregiverFirstNameController.text = patient.caregiverFirstName ?? '';
      caregiverSecondNameController.text = patient.caregiverSecondName ?? '';
      caregiverLastNameController.text = patient.caregiverLastName ?? '';
      caregiverSecondLastNameController.text =
          patient.caregiverSecondLastName ?? '';
      caregiverRelationshipController.text =
          patient.caregiverRelationship ?? '';
      caregiverEmailController.text = patient.caregiverEmail ?? '';
      caregiverLandlineController.text = patient.caregiverLandline ?? '';
      caregiverCellphoneController.text = patient.caregiverCellphone ?? '';
    }

    // Ya no intentamos cargar vacunas aquí, se cargarán cuando el usuario llegue al Step 3
  }

  /// Método público para cargar las vacunas del paciente (llamado desde Step3)
  Future<void> loadPatientVaccinesForEdit(String patientId) async {
    await _loadPatientVaccines(patientId);
  }

  /// Carga las vacunas aplicadas al paciente en modo edición
  Future<void> _loadPatientVaccines(String patientId) async {
    try {
      print('🔍 Cargando vacunas del paciente ID: $patientId...');

      // Obtener el controlador de selección de vacunas
      final vaccineController = Get.find<VaccineSelectionController>();

      // Limpiar selección actual
      vaccineController.selectedVaccines.clear();

      // Cargar las dosis registradas (el controlador se encarga de marcarlas como bloqueadas)
      await vaccineController.loadPatientRegisteredDoses(patientId);

      print('✅ Vacunas cargadas exitosamente en el controlador');
    } catch (e) {
      print('❌ Error al cargar vacunas del paciente: $e');
      CustomSnackbar.showError(
        'No se pudieron cargar las vacunas del paciente. Error: ${e.toString()}',
      );
    }
  }

  // ==================== CÁLCULOS ====================
  /// Calcula la edad del paciente basándose en la fecha de nacimiento
  /// Retorna los valores dinámicamente usando AgeCalculator
  Map<String, int> calculateAge() {
    if (birthDate.value == null) {
      return {'years': 0, 'months': 0, 'days': 0, 'totalMonths': 0};
    }
    return AgeCalculator.calculate(birthDate.value!);
  }

  /// Obtiene el próximo número consecutivo disponible para un nuevo paciente
  /// Consulta el consecutivo más alto existente y suma 1
  Future<int> _getNextConsecutivo() async {
    try {
      final db = await DatabaseHelper.instance.database;
      final result = await db.rawQuery(
        'SELECT MAX(consecutivo) as maxConsecutivo FROM patients',
      );
      
      final maxConsecutivo = result.isNotEmpty && result.first['maxConsecutivo'] != null
          ? result.first['maxConsecutivo'] as int
          : 0;
      
      return maxConsecutivo + 1;
    } catch (e) {
      print('⚠️ Error obteniendo próximo consecutivo: $e');
      // Si hay error, usar timestamp como fallback
      return DateTime.now().millisecondsSinceEpoch ~/ 1000;
    }
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

    // Lugar de Atención del Parto (solo requerido si ha dado a luz)
    if (hasGivenBirth.value && birthPlaceController.text.trim().isEmpty) {
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

      // Calcular edad (solo para validación/visualización)
      final age = calculateAge();
      (age); // Evitar warning de unused variable

      // Obtener el nurseId del usuario logueado
      final authController = Get.find<AuthController>();
      final String? nurseId = authController.currentNurse.value?.id;

      if (nurseId == null) {
        throw Exception('No hay enfermera logueada');
      }

      // Generar consecutivo autoincremental
      final nextConsecutivo = await _getNextConsecutivo();

      // Crear objeto Patient
      final patient = Patient(
        nurseId: nurseId,
        consecutivo: nextConsecutivo,
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
        birthDate: birthDate.value!,  // Los años, meses, días se calculan dinámicamente desde esta fecha
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

      // Guardar o actualizar en la base de datos
      String patientId;
      if (isEditMode.value && editingPatientId != null) {
        print('📝 Actualizando paciente ID: $editingPatientId...');
        final updatedPatient = Patient(
          id: editingPatientId, // Ya es String (UUID)
          nurseId: patient.nurseId,
          consecutivo: patient.consecutivo,
          attentionDate: patient.attentionDate,
          idType: patient.idType,
          idNumber: patient.idNumber,
          firstName: patient.firstName,
          secondName: patient.secondName,
          lastName: patient.lastName,
          secondLastName: patient.secondLastName,
          birthDate: patient.birthDate,  // Los años, meses, días se calculan dinámicamente
          completeScheme: patient.completeScheme,
          sex: patient.sex,
          gender: patient.gender,
          sexualOrientation: patient.sexualOrientation,
          gestationalAge: patient.gestationalAge,
          birthCountry: patient.birthCountry,
          migrationStatus: patient.migrationStatus,
          birthPlace: patient.birthPlace,
          affiliationRegime: patient.affiliationRegime,
          insurer: patient.insurer,
          ethnicity: patient.ethnicity,
          displaced: patient.displaced,
          disabled: patient.disabled,
          deceased: patient.deceased,
          armedConflictVictim: patient.armedConflictVictim,
          currentlyStudying: patient.currentlyStudying,
          residenceCountry: patient.residenceCountry,
          residenceDepartment: patient.residenceDepartment,
          residenceMunicipality: patient.residenceMunicipality,
          commune: patient.commune,
          area: patient.area,
          address: patient.address,
          landline: patient.landline,
          cellphone: patient.cellphone,
          email: patient.email,
          authorizeCalls: patient.authorizeCalls,
          authorizeEmail: patient.authorizeEmail,
          hasContraindication: patient.hasContraindication,
          contraindicationDetails: patient.contraindicationDetails,
          hasPreviousReaction: patient.hasPreviousReaction,
          reactionDetails: patient.reactionDetails,
          historyRecordDate: patient.historyRecordDate,
          historyType: patient.historyType,
          historyDescription: patient.historyDescription,
          specialObservations: patient.specialObservations,
          userCondition: patient.userCondition,
          lastMenstrualDate: patient.lastMenstrualDate,
          gestationWeeks: patient.gestationWeeks,
          probableDeliveryDate: patient.probableDeliveryDate,
          previousPregnancies: patient.previousPregnancies,
          motherIdType: patient.motherIdType,
          motherIdNumber: patient.motherIdNumber,
          motherFirstName: patient.motherFirstName,
          motherSecondName: patient.motherSecondName,
          motherLastName: patient.motherLastName,
          motherSecondLastName: patient.motherSecondLastName,
          motherEmail: patient.motherEmail,
          motherLandline: patient.motherLandline,
          motherCellphone: patient.motherCellphone,
          motherAffiliationRegime: patient.motherAffiliationRegime,
          motherEthnicity: patient.motherEthnicity,
          motherDisplaced: patient.motherDisplaced,
          caregiverIdType: patient.caregiverIdType,
          caregiverIdNumber: patient.caregiverIdNumber,
          caregiverFirstName: patient.caregiverFirstName,
          caregiverSecondName: patient.caregiverSecondName,
          caregiverLastName: patient.caregiverLastName,
          caregiverSecondLastName: patient.caregiverSecondLastName,
          caregiverRelationship: patient.caregiverRelationship,
          caregiverEmail: patient.caregiverEmail,
          caregiverLandline: patient.caregiverLandline,
          caregiverCellphone: patient.caregiverCellphone,
          createdAt: patient.createdAt,
          updatedAt: DateTime.now(),
        );
        await _patientService.updatePatient(updatedPatient);
        patientId = editingPatientId!; // Ya es String (UUID)
        print('✅ Paciente actualizado exitosamente');
      } else {
        print('💾 Guardando paciente nuevo en la base de datos...');
        patientId = await _patientService.createPatient(
          patient,
        ); // Retorna String (UUID)
        print('✅ Paciente guardado con UUID: $patientId');
      }

      if (patientId.isNotEmpty) {
        // Guardar las vacunas aplicadas (nuevas dosis)
        print('💉 Guardando vacunas aplicadas...');
        await _saveAppliedDoses(patientId, nurseId);
        print('✅ Vacunas guardadas exitosamente');

        // Guardar el modo antes de proceder
        final wasEditMode = isEditMode.value;
        final wasModal = isModalMode.value;

        // Mostrar mensaje de éxito SOLO si NO es modal
        if (!wasModal) {
          CustomSnackbar.showSuccess(
            wasEditMode
                ? 'Paciente actualizado correctamente'
                : 'Paciente y vacunas registrados correctamente',
          );
        }

        // Limpiar formulario de inmediato (sin delay para evitar UI lag)
        clearForm();
        // NO llamar resetForm() porque resetForm() solo resetea navegación

        // Manejar navegación según el modo
        if (wasModal) {
          // Modal: el wrapper se encarga de cerrar y mostrar snackbar
          // No hacemos nada aquí
        } else if (wasEditMode) {
          // Tab edición: ya se limpió el formulario
        } else {
          // Tab creación: navegar al home
          Get.back();
        }
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
  Future<void> _saveAppliedDoses(String patientId, String nurseId) async {
    try {
      final vaccineController = Get.find<VaccineSelectionController>();
      final vaccinesData = vaccineController.getVaccinesData();

      print('💉 Guardando ${vaccinesData.length} dosis...');
      for (var i = 0; i < vaccinesData.length; i++) {
        var vaccineData = vaccinesData[i];
        print(
          '  📌 Dosis ${i + 1}: Vacuna ID ${vaccineData['vaccine_id']}, Dosis: ${vaccineData['selected_dose']}',
        );

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
          customObservation: vaccineData['custom_observation']?.isEmpty == false
              ? vaccineData['custom_observation']
              : null,
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
    String? optionId,
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
    schemeSelected.value = false;

    // Ubicación
    birthCountryController.text = 'Colombia';
    birthPlaceController.clear();
    residenceCountryController.text = 'Colombia';
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

    // Demográficos - Resetear a valores por defecto
    selectedGender.value = null;
    selectedSexualOrientation.value = null;
    selectedMigratoryStatus.value = EstatusMigratorio.regular;
    selectedEthnicity.value = PertenenciaEtnica.ninguno;
    selectedHealthRegime.value = null;
    selectedArea.value = Area.urbana;

    // Salud
    insurerController.clear();
    gestationalAgeController.clear();

    // Flags
    displaced.value = false;
    disabled.value = false;
    deceased.value = false;
    armedConflictVictim.value = false;
    currentlyStudying.value = null;

    // Madre - Resetear completamente
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

    // Cuidador - Resetear completamente
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

    // Antecedentes médicos - Resetear completamente
    hasContraindication.value = false;
    contraindicationDetailsController.clear();
    hasPreviousReaction.value = false;
    reactionDetailsController.clear();

    // Histórico
    historyRecordDate.value = null;
    historyTypeController.clear();
    historyDescriptionController.clear();
    specialObservationsController.clear();

    // Condición usuaria - Resetear completamente
    selectedUserCondition.value = CondicionUsuaria.noAplica;
    lastMenstrualDate.value = null;
    gestationWeeksController.clear();
    probableDeliveryDate.value = null;
    previousPregnanciesController.clear();
    hasGivenBirth.value = false;

    // Resetear navegación
    currentStep.value = 0;
  }
}
