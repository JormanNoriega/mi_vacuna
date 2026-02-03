// Modelo de Vacuna - Catálogo configurable

class Vaccine {
  String? id; // UUID
  String name; // "COVID-19", "BCG", "Hepatitis B"
  String code; // "covid19", "bcg", "hepatitis_b"
  String category; // "infantil", "adulto", "especial", "todas"
  int maxDoses; // Número máximo de dosis

  // Rango de edad (en meses)
  int? minMonths; // Edad mínima en meses (null = sin límite)
  int? maxMonths; // Edad máxima en meses (null = sin límite)

  // Configuración de campos disponibles
  bool hasLaboratory; // COVID-19: true, BCG: false
  bool hasLot; // Siempre true
  bool hasSyringe; // true para inyectables
  bool hasSyringeLot; // true si tiene jeringa
  bool hasDiluent; // true para vacunas con diluyente
  bool hasDropper; // true para orales (Polio, Rotavirus)
  bool hasPneumococcalType; // Solo Neumococo
  bool hasVialCount; // Solo sueros/inmunoglobulinas
  bool hasObservation; // Algunas vacunas específicas

  bool isActive;
  DateTime createdAt;
  DateTime? updatedAt;

  Vaccine({
    this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.maxDoses,
    this.minMonths,
    this.maxMonths,
    this.hasLaboratory = false,
    this.hasLot = true,
    this.hasSyringe = false,
    this.hasSyringeLot = false,
    this.hasDiluent = false,
    this.hasDropper = false,
    this.hasPneumococcalType = false,
    this.hasVialCount = false,
    this.hasObservation = false,
    this.isActive = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'category': category,
      'max_doses': maxDoses,
      'min_months': minMonths,
      'max_months': maxMonths,
      'has_laboratory': hasLaboratory ? 1 : 0,
      'has_lot': hasLot ? 1 : 0,
      'has_syringe': hasSyringe ? 1 : 0,
      'has_syringe_lot': hasSyringeLot ? 1 : 0,
      'has_diluent': hasDiluent ? 1 : 0,
      'has_dropper': hasDropper ? 1 : 0,
      'has_pneumococcal_type': hasPneumococcalType ? 1 : 0,
      'has_vial_count': hasVialCount ? 1 : 0,
      'has_observation': hasObservation ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory Vaccine.fromMap(Map<String, dynamic> map) {
    return Vaccine(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      category: map['category'],
      maxDoses: map['max_doses'],
      minMonths: map['min_months'],
      maxMonths: map['max_months'],
      hasLaboratory: map['has_laboratory'] == 1,
      hasLot: map['has_lot'] == 1,
      hasSyringe: map['has_syringe'] == 1,
      hasSyringeLot: map['has_syringe_lot'] == 1,
      hasDiluent: map['has_diluent'] == 1,
      hasDropper: map['has_dropper'] == 1,
      hasPneumococcalType: map['has_pneumococcal_type'] == 1,
      hasVialCount: map['has_vial_count'] == 1,
      hasObservation: map['has_observation'] == 1,
      isActive: map['is_active'] == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  // Verificar si la vacuna es aplicable a una edad (en meses)
  // NOTA: Por ahora esto es solo informativo, no bloquea la aplicación
  bool isApplicableForAge(int ageInMonths) {
    if (!isActive) return false;
    // Validación de rango de edad (opcional por ahora)
    // if (minMonths != null && ageInMonths < minMonths!) return false;
    // if (maxMonths != null && ageInMonths > maxMonths!) return false;
    return true; // Por ahora todas las vacunas activas son aplicables
  }

  // Verificar si está dentro del rango recomendado (no bloquea)
  bool isInRecommendedAge(int ageInMonths) {
    if (minMonths != null && ageInMonths < minMonths!) return false;
    if (maxMonths != null && ageInMonths > maxMonths!) return false;
    return true;
  }

  // Helper para obtener descripción de rango de edad
  String get ageRangeDescription {
    if (minMonths == null && maxMonths == null) {
      return 'Todas las edades';
    } else if (minMonths == null) {
      return 'Hasta ${_monthsToReadable(maxMonths!)}';
    } else if (maxMonths == null) {
      return 'Desde ${_monthsToReadable(minMonths!)}';
    } else {
      return '${_monthsToReadable(minMonths!)} - ${_monthsToReadable(maxMonths!)}';
    }
  }

  String _monthsToReadable(int months) {
    if (months < 12) {
      return '$months ${months == 1 ? "mes" : "meses"}';
    } else if (months % 12 == 0) {
      final years = months ~/ 12;
      return '$years ${years == 1 ? "año" : "años"}';
    } else {
      final years = months ~/ 12;
      final remainingMonths = months % 12;
      return '$years ${years == 1 ? "año" : "años"} y $remainingMonths ${remainingMonths == 1 ? "mes" : "meses"}';
    }
  }

  @override
  String toString() => 'Vaccine{id: $id, name: $name, code: $code}';
}
