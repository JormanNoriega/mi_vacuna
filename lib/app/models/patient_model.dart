/// Enums para el modelo de paciente

enum Sexo { mujer, hombre, indeterminado }

enum Genero { masculino, femenino, transgenero, indeterminado }

enum OrientacionSexual {
  homosexual,
  bisexual,
  transexual,
  intersexual,
  heterosexual,
  otro,
  noSabeNoAplica,
}

enum EstatusMigratorio { regular, irregular }

enum RegimenAfiliacion {
  contributivo,
  subsidiado,
  poblacionPobreNoAsegurada,
  excepcionEspecialEInpec,
}

enum PertenenciaEtnica {
  indigena,
  rom,
  raizal,
  palenquero,
  negroAfrocolombiano,
  ninguno,
}

enum Area { rural, urbana }

enum CondicionUsuaria { mujerEdadFertil, gestante, mujerMayor50, noAplica }

/// Modelo de antecedente médico
class MedicalHistory {
  final int? id;
  final int patientId;
  final DateTime registrationDate;
  final String type;
  final String description;
  final String? specialObservations;

  MedicalHistory({
    this.id,
    required this.patientId,
    required this.registrationDate,
    required this.type,
    required this.description,
    this.specialObservations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'registration_date': registrationDate.toIso8601String(),
      'type': type,
      'description': description,
      'special_observations': specialObservations,
    };
  }

  factory MedicalHistory.fromMap(Map<String, dynamic> map) {
    return MedicalHistory(
      id: map['id'],
      patientId: map['patient_id'],
      registrationDate: DateTime.parse(map['registration_date']),
      type: map['type'],
      description: map['description'],
      specialObservations: map['special_observations'],
    );
  }
}

/// Modelo de paciente
class Patient {
  final int? id;
  final DateTime attentionDate;
  final String idType;
  final String idNumber;
  final String firstName;
  final String? secondName;
  final String lastName;
  final String? secondLastName;
  final DateTime birthDate;
  final bool completeScheme;
  final Sexo sex;
  final Genero gender;
  final OrientacionSexual sexualOrientation;
  final int? gestationalWeeks;
  final String birthCountry;
  final EstatusMigratorio migrationStatus;
  final String birthPlace;
  final RegimenAfiliacion affiliationRegime;
  final String insurer;
  final PertenenciaEtnica ethnicity;
  final bool displaced;
  final bool disabled;
  final bool deceased;
  final bool armedConflictVictim;
  final bool currentlyStudying;
  final String residenceCountry;
  final String residenceDepartment;
  final String residenceMunicipality;
  final String? commune;
  final Area area;
  final String? address;
  final String? landline;
  final String? cellphone;
  final String? email;
  final bool authorizeCalls;
  final bool authorizeEmail;
  final bool hasContraindication;
  final String? contraindicationDetails;
  final bool hasPreviousReaction;
  final String? reactionDetails;
  final CondicionUsuaria userCondition;
  final DateTime? lastMenstrualDate;
  final int? previousPregnancies;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Patient({
    this.id,
    required this.attentionDate,
    required this.idType,
    required this.idNumber,
    required this.firstName,
    this.secondName,
    required this.lastName,
    this.secondLastName,
    required this.birthDate,
    required this.completeScheme,
    required this.sex,
    required this.gender,
    required this.sexualOrientation,
    this.gestationalWeeks,
    required this.birthCountry,
    required this.migrationStatus,
    required this.birthPlace,
    required this.affiliationRegime,
    required this.insurer,
    required this.ethnicity,
    required this.displaced,
    required this.disabled,
    required this.deceased,
    required this.armedConflictVictim,
    required this.currentlyStudying,
    required this.residenceCountry,
    required this.residenceDepartment,
    required this.residenceMunicipality,
    this.commune,
    required this.area,
    this.address,
    this.landline,
    this.cellphone,
    this.email,
    required this.authorizeCalls,
    required this.authorizeEmail,
    required this.hasContraindication,
    this.contraindicationDetails,
    required this.hasPreviousReaction,
    this.reactionDetails,
    required this.userCondition,
    this.lastMenstrualDate,
    this.previousPregnancies,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getters calculados
  String get fullName {
    final parts = [firstName, secondName, lastName, secondLastName];
    return parts.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  int get ageYears {
    final today = DateTime.now();
    int years = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      years--;
    }
    return years;
  }

  int get ageMonths {
    final today = DateTime.now();
    int months =
        (today.year - birthDate.year) * 12 + (today.month - birthDate.month);
    if (today.day < birthDate.day) {
      months--;
    }
    return months;
  }

  int get ageDays {
    final today = DateTime.now();
    return today.difference(birthDate).inDays;
  }

  int get totalMonths => ageMonths;

  int? get gestationWeeks {
    if (lastMenstrualDate == null) return null;
    final today = DateTime.now();
    final daysSinceLastPeriod = today.difference(lastMenstrualDate!).inDays;
    return (daysSinceLastPeriod / 7).floor();
  }

  DateTime? get expectedDeliveryDate {
    if (lastMenstrualDate == null) return null;
    // Regla de Naegele: fecha de última menstruación + 280 días (40 semanas)
    return lastMenstrualDate!.add(const Duration(days: 280));
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      'gender': gender.name,
      'sexual_orientation': sexualOrientation.name,
      'gestational_weeks': gestationalWeeks,
      'birth_country': birthCountry,
      'migration_status': migrationStatus.name,
      'birth_place': birthPlace,
      'affiliation_regime': affiliationRegime.name,
      'insurer': insurer,
      'ethnicity': ethnicity.name,
      'displaced': displaced ? 1 : 0,
      'disabled': disabled ? 1 : 0,
      'deceased': deceased ? 1 : 0,
      'armed_conflict_victim': armedConflictVictim ? 1 : 0,
      'currently_studying': currentlyStudying ? 1 : 0,
      'residence_country': residenceCountry,
      'residence_department': residenceDepartment,
      'residence_municipality': residenceMunicipality,
      'commune': commune,
      'area': area.name,
      'address': address,
      'landline': landline,
      'cellphone': cellphone,
      'email': email,
      'authorize_calls': authorizeCalls ? 1 : 0,
      'authorize_email': authorizeEmail ? 1 : 0,
      'has_contraindication': hasContraindication ? 1 : 0,
      'contraindication_details': contraindicationDetails,
      'has_previous_reaction': hasPreviousReaction ? 1 : 0,
      'reaction_details': reactionDetails,
      'user_condition': userCondition.name,
      'last_menstrual_date': lastMenstrualDate?.toIso8601String(),
      'previous_pregnancies': previousPregnancies,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      attentionDate: DateTime.parse(map['attention_date']),
      idType: map['id_type'],
      idNumber: map['id_number'],
      firstName: map['first_name'],
      secondName: map['second_name'],
      lastName: map['last_name'],
      secondLastName: map['second_last_name'],
      birthDate: DateTime.parse(map['birth_date']),
      completeScheme: map['complete_scheme'] == 1,
      sex: Sexo.values.firstWhere((e) => e.name == map['sex']),
      gender: Genero.values.firstWhere((e) => e.name == map['gender']),
      sexualOrientation: OrientacionSexual.values.firstWhere(
        (e) => e.name == map['sexual_orientation'],
      ),
      gestationalWeeks: map['gestational_weeks'],
      birthCountry: map['birth_country'],
      migrationStatus: EstatusMigratorio.values.firstWhere(
        (e) => e.name == map['migration_status'],
      ),
      birthPlace: map['birth_place'],
      affiliationRegime: RegimenAfiliacion.values.firstWhere(
        (e) => e.name == map['affiliation_regime'],
      ),
      insurer: map['insurer'],
      ethnicity: PertenenciaEtnica.values.firstWhere(
        (e) => e.name == map['ethnicity'],
      ),
      displaced: map['displaced'] == 1,
      disabled: map['disabled'] == 1,
      deceased: map['deceased'] == 1,
      armedConflictVictim: map['armed_conflict_victim'] == 1,
      currentlyStudying: map['currently_studying'] == 1,
      residenceCountry: map['residence_country'],
      residenceDepartment: map['residence_department'],
      residenceMunicipality: map['residence_municipality'],
      commune: map['commune'],
      area: Area.values.firstWhere((e) => e.name == map['area']),
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
      userCondition: CondicionUsuaria.values.firstWhere(
        (e) => e.name == map['user_condition'],
      ),
      lastMenstrualDate: map['last_menstrual_date'] != null
          ? DateTime.parse(map['last_menstrual_date'])
          : null,
      previousPregnancies: map['previous_pregnancies'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Patient copyWith({
    int? id,
    DateTime? attentionDate,
    String? idType,
    String? idNumber,
    String? firstName,
    String? secondName,
    String? lastName,
    String? secondLastName,
    DateTime? birthDate,
    bool? completeScheme,
    Sexo? sex,
    Genero? gender,
    OrientacionSexual? sexualOrientation,
    int? gestationalWeeks,
    String? birthCountry,
    EstatusMigratorio? migrationStatus,
    String? birthPlace,
    RegimenAfiliacion? affiliationRegime,
    String? insurer,
    PertenenciaEtnica? ethnicity,
    bool? displaced,
    bool? disabled,
    bool? deceased,
    bool? armedConflictVictim,
    bool? currentlyStudying,
    String? residenceCountry,
    String? residenceDepartment,
    String? residenceMunicipality,
    String? commune,
    Area? area,
    String? address,
    String? landline,
    String? cellphone,
    String? email,
    bool? authorizeCalls,
    bool? authorizeEmail,
    bool? hasContraindication,
    String? contraindicationDetails,
    bool? hasPreviousReaction,
    String? reactionDetails,
    CondicionUsuaria? userCondition,
    DateTime? lastMenstrualDate,
    int? previousPregnancies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      attentionDate: attentionDate ?? this.attentionDate,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      birthDate: birthDate ?? this.birthDate,
      completeScheme: completeScheme ?? this.completeScheme,
      sex: sex ?? this.sex,
      gender: gender ?? this.gender,
      sexualOrientation: sexualOrientation ?? this.sexualOrientation,
      gestationalWeeks: gestationalWeeks ?? this.gestationalWeeks,
      birthCountry: birthCountry ?? this.birthCountry,
      migrationStatus: migrationStatus ?? this.migrationStatus,
      birthPlace: birthPlace ?? this.birthPlace,
      affiliationRegime: affiliationRegime ?? this.affiliationRegime,
      insurer: insurer ?? this.insurer,
      ethnicity: ethnicity ?? this.ethnicity,
      displaced: displaced ?? this.displaced,
      disabled: disabled ?? this.disabled,
      deceased: deceased ?? this.deceased,
      armedConflictVictim: armedConflictVictim ?? this.armedConflictVictim,
      currentlyStudying: currentlyStudying ?? this.currentlyStudying,
      residenceCountry: residenceCountry ?? this.residenceCountry,
      residenceDepartment: residenceDepartment ?? this.residenceDepartment,
      residenceMunicipality:
          residenceMunicipality ?? this.residenceMunicipality,
      commune: commune ?? this.commune,
      area: area ?? this.area,
      address: address ?? this.address,
      landline: landline ?? this.landline,
      cellphone: cellphone ?? this.cellphone,
      email: email ?? this.email,
      authorizeCalls: authorizeCalls ?? this.authorizeCalls,
      authorizeEmail: authorizeEmail ?? this.authorizeEmail,
      hasContraindication: hasContraindication ?? this.hasContraindication,
      contraindicationDetails:
          contraindicationDetails ?? this.contraindicationDetails,
      hasPreviousReaction: hasPreviousReaction ?? this.hasPreviousReaction,
      reactionDetails: reactionDetails ?? this.reactionDetails,
      userCondition: userCondition ?? this.userCondition,
      lastMenstrualDate: lastMenstrualDate ?? this.lastMenstrualDate,
      previousPregnancies: previousPregnancies ?? this.previousPregnancies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
