/// Enums para el modelo de cuidador

enum CaregiverType {
  madre,
  padre,
  abuelo,
  abuela,
  tio,
  tia,
  hermano,
  hermana,
  tutor,
  otro,
}

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

/// Modelo de cuidador/responsable del paciente
class Caregiver {
  final int? id;
  final int patientId;
  final CaregiverType caregiverType; // Tipo de cuidador (madre, padre, etc.)
  final String idType;
  final String idNumber;
  final String firstName;
  final String? secondName;
  final String lastName;
  final String? secondLastName;
  final String relationship; // Parentesco específico
  final String email;
  final String? landline;
  final String? cellphone;
  final RegimenAfiliacion affiliationRegime;
  final PertenenciaEtnica ethnicity;
  final bool displaced;
  final bool isPrimary; // Indica si es el cuidador principal
  final DateTime createdAt;
  final DateTime? updatedAt;

  Caregiver({
    this.id,
    required this.patientId,
    required this.caregiverType,
    required this.idType,
    required this.idNumber,
    required this.firstName,
    this.secondName,
    required this.lastName,
    this.secondLastName,
    required this.relationship,
    required this.email,
    this.landline,
    this.cellphone,
    required this.affiliationRegime,
    required this.ethnicity,
    required this.displaced,
    this.isPrimary = false,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Getter para nombre completo
  String get fullName {
    final parts = [firstName, secondName, lastName, secondLastName];
    return parts.where((p) => p != null && p.isNotEmpty).join(' ');
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'caregiver_type': caregiverType.name,
      'id_type': idType,
      'id_number': idNumber,
      'first_name': firstName,
      'second_name': secondName,
      'last_name': lastName,
      'second_last_name': secondLastName,
      'relationship': relationship,
      'email': email,
      'landline': landline,
      'cellphone': cellphone,
      'affiliation_regime': affiliationRegime.name,
      'ethnicity': ethnicity.name,
      'displaced': displaced ? 1 : 0,
      'is_primary': isPrimary ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Caregiver.fromMap(Map<String, dynamic> map) {
    return Caregiver(
      id: map['id'],
      patientId: map['patient_id'],
      caregiverType: CaregiverType.values.firstWhere(
        (e) => e.name == map['caregiver_type'],
      ),
      idType: map['id_type'],
      idNumber: map['id_number'],
      firstName: map['first_name'],
      secondName: map['second_name'],
      lastName: map['last_name'],
      secondLastName: map['second_last_name'],
      relationship: map['relationship'],
      email: map['email'],
      landline: map['landline'],
      cellphone: map['cellphone'],
      affiliationRegime: RegimenAfiliacion.values.firstWhere(
        (e) => e.name == map['affiliation_regime'],
      ),
      ethnicity: PertenenciaEtnica.values.firstWhere(
        (e) => e.name == map['ethnicity'],
      ),
      displaced: map['displaced'] == 1,
      isPrimary: map['is_primary'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Caregiver copyWith({
    int? id,
    int? patientId,
    CaregiverType? caregiverType,
    String? idType,
    String? idNumber,
    String? firstName,
    String? secondName,
    String? lastName,
    String? secondLastName,
    String? relationship,
    String? email,
    String? landline,
    String? cellphone,
    RegimenAfiliacion? affiliationRegime,
    PertenenciaEtnica? ethnicity,
    bool? displaced,
    bool? isPrimary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Caregiver(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      caregiverType: caregiverType ?? this.caregiverType,
      idType: idType ?? this.idType,
      idNumber: idNumber ?? this.idNumber,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      secondLastName: secondLastName ?? this.secondLastName,
      relationship: relationship ?? this.relationship,
      email: email ?? this.email,
      landline: landline ?? this.landline,
      cellphone: cellphone ?? this.cellphone,
      affiliationRegime: affiliationRegime ?? this.affiliationRegime,
      ethnicity: ethnicity ?? this.ethnicity,
      displaced: displaced ?? this.displaced,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
