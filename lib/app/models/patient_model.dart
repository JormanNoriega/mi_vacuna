// Modelo del Paciente
import '../utils/age_calculator.dart';

// Enumeraciones para el modelo Patient

enum Sexo { hombre, mujer, indeterminado }

enum Genero { masculino, femenino, transgenero, indeterminado }

enum OrientacionSexual { heterosexual, homosexual, bisexual, noSabeNoAplica }

enum EstatusMigratorio { regular, irregular }

enum RegimenAfiliacion {
  contributivo,
  subsidiado,
  poblacionPobreNoAsegurada,
  especial,
  excepcion,
  noAsegurado,
}

enum PertenenciaEtnica {
  indigena,
  rom,
  raizal,
  palenquero,
  negroAfrocolombiano,
  ninguno,
}

enum Area { urbana, rural }

enum CondicionUsuaria { mujerEdadFertil, gestante, mujerMayor50, noAplica }

class Patient {
  // Identificador UUID
  String? id; // Cambiado de int? a String? para UUID
  String nurseId; // FK a la enfermera que registró (UUID)

  // ============================================
  // DATOS BÁSICOS DEL PACIENTE
  // ============================================
  int? consecutivo;  // Autoincremental único
  DateTime attentionDate;
  String idType;
  String idNumber;
  String firstName;
  String? secondName;
  String lastName;
  String? secondLastName;
  DateTime birthDate;  // De aquí se calculan years, months, days
  bool completeScheme;
  Sexo sex;
  Genero? gender;
  OrientacionSexual? sexualOrientation;
  int? gestationalAge;

  // ============================================
  // DATOS COMPLEMENTARIOS
  // ============================================
  String birthCountry;
  EstatusMigratorio? migrationStatus;
  String? birthPlace;
  RegimenAfiliacion? affiliationRegime;
  String? insurer;
  PertenenciaEtnica? ethnicity;
  bool displaced;
  bool disabled;
  bool deceased;
  bool armedConflictVictim;
  bool? currentlyStudying;
  String? residenceCountry;
  String? residenceDepartment;
  String? residenceMunicipality;
  String? commune;
  Area? area;
  String? address;
  String? landline;
  String? cellphone;
  String? email;
  bool authorizeCalls;
  bool authorizeEmail;

  // ============================================
  // ANTECEDENTES MÉDICOS
  // ============================================
  bool hasContraindication;
  String? contraindicationDetails;
  bool hasPreviousReaction;
  String? reactionDetails;

  // ============================================
  // HISTÓRICO DE ANTECEDENTES
  // ============================================
  DateTime? historyRecordDate;
  String? historyType;
  String? historyDescription;
  String? specialObservations;

  // ============================================
  // CONDICIÓN USUARIA (Para mujeres)
  // ============================================
  CondicionUsuaria? userCondition;
  DateTime? lastMenstrualDate;
  int? gestationWeeks;
  DateTime? probableDeliveryDate;
  int? previousPregnancies;

  // ============================================
  // DATOS DE LA MADRE (Para pacientes menores)
  // ============================================
  String? motherIdType;
  String? motherIdNumber;
  String? motherFirstName;
  String? motherSecondName;
  String? motherLastName;
  String? motherSecondLastName;
  String? motherEmail;
  String? motherLandline;
  String? motherCellphone;
  RegimenAfiliacion? motherAffiliationRegime;
  PertenenciaEtnica? motherEthnicity;
  bool? motherDisplaced;

  // ============================================
  // DATOS DEL CUIDADOR (Tutor/Responsable)
  // ============================================
  String? caregiverIdType;
  String? caregiverIdNumber;
  String? caregiverFirstName;
  String? caregiverSecondName;
  String? caregiverLastName;
  String? caregiverSecondLastName;
  String? caregiverRelationship;
  String? caregiverEmail;
  String? caregiverLandline;
  String? caregiverCellphone;

  // ============================================
  // METADATOS
  // ============================================
  DateTime createdAt;
  DateTime? updatedAt;

  Patient({
    this.id,
    required this.nurseId,
    this.consecutivo,
    required this.attentionDate,
    required this.idType,
    required this.idNumber,
    required this.firstName,
    this.secondName,
    required this.lastName,
    this.secondLastName,
    required this.birthDate,
    this.completeScheme = false,
    required this.sex,
    this.gender,
    this.sexualOrientation,
    this.gestationalAge,
    required this.birthCountry,
    this.migrationStatus,
    this.birthPlace,
    this.affiliationRegime,
    this.insurer,
    this.ethnicity,
    this.displaced = false,
    this.disabled = false,
    this.deceased = false,
    this.armedConflictVictim = false,
    this.currentlyStudying,
    this.residenceCountry,
    this.residenceDepartment,
    this.residenceMunicipality,
    this.commune,
    this.area,
    this.address,
    this.landline,
    this.cellphone,
    this.email,
    this.authorizeCalls = false,
    this.authorizeEmail = false,
    this.hasContraindication = false,
    this.contraindicationDetails,
    this.hasPreviousReaction = false,
    this.reactionDetails,
    this.historyRecordDate,
    this.historyType,
    this.historyDescription,
    this.specialObservations,
    this.userCondition,
    this.lastMenstrualDate,
    this.gestationWeeks,
    this.probableDeliveryDate,
    this.previousPregnancies,
    this.motherIdType,
    this.motherIdNumber,
    this.motherFirstName,
    this.motherSecondName,
    this.motherLastName,
    this.motherSecondLastName,
    this.motherEmail,
    this.motherLandline,
    this.motherCellphone,
    this.motherAffiliationRegime,
    this.motherEthnicity,
    this.motherDisplaced,
    this.caregiverIdType,
    this.caregiverIdNumber,
    this.caregiverFirstName,
    this.caregiverSecondName,
    this.caregiverLastName,
    this.caregiverSecondLastName,
    this.caregiverRelationship,
    this.caregiverEmail,
    this.caregiverLandline,
    this.caregiverCellphone,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ============================================
  // CONVERSIÓN A MAP (SQLite)
  // ============================================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nurse_id': nurseId,
      // Datos básicos
      'consecutivo': consecutivo,
      'attention_date': attentionDate.toIso8601String(),
      'id_type': idType,
      'id_number': idNumber,
      'first_name': firstName,
      'second_name': secondName,
      'last_name': lastName,
      'second_last_name': secondLastName,
      'birth_date': birthDate.toIso8601String(),
      'complete_scheme': completeScheme ? 1 : 0,
      'sex': sex.name,
      'gender': gender?.name,
      'sexual_orientation': sexualOrientation?.name,
      'gestational_age': gestationalAge,
      // Datos complementarios
      'birth_country': birthCountry,
      'migration_status': migrationStatus?.name,
      'birth_place': birthPlace,
      'affiliation_regime': affiliationRegime?.name,
      'insurer': insurer,
      'ethnicity': ethnicity?.name,
      'displaced': displaced ? 1 : 0,
      'disabled': disabled ? 1 : 0,
      'deceased': deceased ? 1 : 0,
      'armed_conflict_victim': armedConflictVictim ? 1 : 0,
      'currently_studying': currentlyStudying == null
          ? null
          : (currentlyStudying! ? 1 : 0),
      'residence_country': residenceCountry,
      'residence_department': residenceDepartment,
      'residence_municipality': residenceMunicipality,
      'commune': commune,
      'area': area?.name,
      'address': address,
      'landline': landline,
      'cellphone': cellphone,
      'email': email,
      'authorize_calls': authorizeCalls ? 1 : 0,
      'authorize_email': authorizeEmail ? 1 : 0,
      // Antecedentes médicos
      'has_contraindication': hasContraindication ? 1 : 0,
      'contraindication_details': contraindicationDetails,
      'has_previous_reaction': hasPreviousReaction ? 1 : 0,
      'reaction_details': reactionDetails,
      // Histórico
      'history_record_date': historyRecordDate?.toIso8601String(),
      'history_type': historyType,
      'history_description': historyDescription,
      'special_observations': specialObservations,
      // Condición usuaria
      'user_condition': userCondition?.name,
      'last_menstrual_date': lastMenstrualDate?.toIso8601String(),
      'gestation_weeks': gestationWeeks,
      'probable_delivery_date': probableDeliveryDate?.toIso8601String(),
      'previous_pregnancies': previousPregnancies,
      // Datos de la madre
      'mother_id_type': motherIdType,
      'mother_id_number': motherIdNumber,
      'mother_first_name': motherFirstName,
      'mother_second_name': motherSecondName,
      'mother_last_name': motherLastName,
      'mother_second_last_name': motherSecondLastName,
      'mother_email': motherEmail,
      'mother_landline': motherLandline,
      'mother_cellphone': motherCellphone,
      'mother_affiliation_regime': motherAffiliationRegime?.name,
      'mother_ethnicity': motherEthnicity?.name,
      'mother_displaced': motherDisplaced == null
          ? null
          : (motherDisplaced! ? 1 : 0),
      // Datos del cuidador
      'caregiver_id_type': caregiverIdType,
      'caregiver_id_number': caregiverIdNumber,
      'caregiver_first_name': caregiverFirstName,
      'caregiver_second_name': caregiverSecondName,
      'caregiver_last_name': caregiverLastName,
      'caregiver_second_last_name': caregiverSecondLastName,
      'caregiver_relationship': caregiverRelationship,
      'caregiver_email': caregiverEmail,
      'caregiver_landline': caregiverLandline,
      'caregiver_cellphone': caregiverCellphone,
      // Metadatos
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ============================================
  // CREAR DESDE MAP (SQLite)
  // ============================================
  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      nurseId: map['nurse_id'],
      consecutivo: map['consecutivo'],
      attentionDate: DateTime.parse(map['attention_date']),
      idType: map['id_type'],
      idNumber: map['id_number'],
      firstName: map['first_name'],
      secondName: map['second_name'],
      lastName: map['last_name'],
      secondLastName: map['second_last_name'],
      birthDate: DateTime.parse(map['birth_date']),
      completeScheme: map['complete_scheme'] == 1,
      sex: Sexo.values.byName(map['sex']),
      gender: map['gender'] != null
          ? Genero.values.byName(map['gender'])
          : null,
      sexualOrientation: map['sexual_orientation'] != null
          ? OrientacionSexual.values.byName(map['sexual_orientation'])
          : null,
      gestationalAge: map['gestational_age'],
      birthCountry: map['birth_country'],
      migrationStatus: map['migration_status'] != null
          ? EstatusMigratorio.values.byName(map['migration_status'])
          : null,
      birthPlace: map['birth_place'],
      affiliationRegime: map['affiliation_regime'] != null
          ? RegimenAfiliacion.values.byName(map['affiliation_regime'])
          : null,
      insurer: map['insurer'],
      ethnicity: map['ethnicity'] != null
          ? PertenenciaEtnica.values.byName(map['ethnicity'])
          : null,
      displaced: map['displaced'] == 1,
      disabled: map['disabled'] == 1,
      deceased: map['deceased'] == 1,
      armedConflictVictim: map['armed_conflict_victim'] == 1,
      currentlyStudying: map['currently_studying'] != null
          ? map['currently_studying'] == 1
          : null,
      residenceCountry: map['residence_country'],
      residenceDepartment: map['residence_department'],
      residenceMunicipality: map['residence_municipality'],
      commune: map['commune'],
      area: map['area'] != null ? Area.values.byName(map['area']) : null,
      address: map['address'],
      landline: map['landline'],
      cellphone: map['cellphone'],
      email: map['email'],
      authorizeCalls: map['authorize_calls'] == 1,
      authorizeEmail: map['authorize_email'] == 1,
      hasContraindication: map['has_contraindication'] == 1,
      contraindicationDetails: map['contraindication_details'],
      hasPreviousReaction: map['has_previous_reaction'] == 1,
      reactionDetails: map['reaction_details'],
      historyRecordDate: map['history_record_date'] != null
          ? DateTime.parse(map['history_record_date'])
          : null,
      historyType: map['history_type'],
      historyDescription: map['history_description'],
      specialObservations: map['special_observations'],
      userCondition: map['user_condition'] != null
          ? CondicionUsuaria.values.byName(map['user_condition'])
          : null,
      lastMenstrualDate: map['last_menstrual_date'] != null
          ? DateTime.parse(map['last_menstrual_date'])
          : null,
      gestationWeeks: map['gestation_weeks'],
      probableDeliveryDate: map['probable_delivery_date'] != null
          ? DateTime.parse(map['probable_delivery_date'])
          : null,
      previousPregnancies: map['previous_pregnancies'],
      motherIdType: map['mother_id_type'],
      motherIdNumber: map['mother_id_number'],
      motherFirstName: map['mother_first_name'],
      motherSecondName: map['mother_second_name'],
      motherLastName: map['mother_last_name'],
      motherSecondLastName: map['mother_second_last_name'],
      motherEmail: map['mother_email'],
      motherLandline: map['mother_landline'],
      motherCellphone: map['mother_cellphone'],
      motherAffiliationRegime: map['mother_affiliation_regime'] != null
          ? RegimenAfiliacion.values.byName(map['mother_affiliation_regime'])
          : null,
      motherEthnicity: map['mother_ethnicity'] != null
          ? PertenenciaEtnica.values.byName(map['mother_ethnicity'])
          : null,
      motherDisplaced: map['mother_displaced'] != null
          ? map['mother_displaced'] == 1
          : null,
      caregiverIdType: map['caregiver_id_type'],
      caregiverIdNumber: map['caregiver_id_number'],
      caregiverFirstName: map['caregiver_first_name'],
      caregiverSecondName: map['caregiver_second_name'],
      caregiverLastName: map['caregiver_last_name'],
      caregiverSecondLastName: map['caregiver_second_last_name'],
      caregiverRelationship: map['caregiver_relationship'],
      caregiverEmail: map['caregiver_email'],
      caregiverLandline: map['caregiver_landline'],
      caregiverCellphone: map['caregiver_cellphone'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  // ============================================
  // HELPERS
  // ============================================
  String get fullName {
    return [
      firstName,
      secondName,
      lastName,
      secondLastName,
    ].where((name) => name != null && name.isNotEmpty).join(' ');
  }

  String? get motherFullName {
    if (motherFirstName == null) return null;
    return [
      motherFirstName,
      motherSecondName,
      motherLastName,
      motherSecondLastName,
    ].where((name) => name != null && name.isNotEmpty).join(' ');
  }

  String? get caregiverFullName {
    if (caregiverFirstName == null) return null;
    return [
      caregiverFirstName,
      caregiverSecondName,
      caregiverLastName,
      caregiverSecondLastName,
    ].where((name) => name != null && name.isNotEmpty).join(' ');
  }

  // ============================================
  // GETTERS CALCULADOS (EDAD DINÁMICA)
  // ============================================
  /// Retorna un mapa con el cálculo de edad basado en la fecha de nacimiento
  /// {years: int, months: int, days: int, totalMonths: int, totalDays: int}
  Map<String, int> get ageMap => AgeCalculator.calculate(birthDate);

  /// Años de edad
  int get years => ageMap['years']!;

  /// Meses dentro del año actual (0-11)
  int get months => ageMap['months']!;

  /// Días dentro del mes actual (0-31)
  int get days => ageMap['days']!;

  /// Total de meses desde el nacimiento
  int get totalMonths => ageMap['totalMonths']!;

  /// Total de días desde el nacimiento
  int get totalDays => ageMap['totalDays']!;

  @override
  String toString() => 'Patient{id: $id, name: $fullName, idNumber: $idNumber}';
}
