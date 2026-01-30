// Modelo de Dosis Aplicada - Registro de cada vacuna aplicada a un paciente

class AppliedDose {
  int? id;
  String uuid; // Identificador global único (para sincronización)
  int patientId; // FK -> patients
  int nurseId; // FK -> nurses
  int vaccineId; // FK -> vaccines
  DateTime applicationDate; // Fecha de aplicación (OBLIGATORIO)

  // Campos genéricos (se llenan según configuración de vaccine)
  String? selectedDose; // Ej: "Primera dosis", "Refuerzo"
  String? selectedLaboratory; // Ej: "PFIZER", "MODERNA"
  String lotNumber; // Lote de la vacuna (OBLIGATORIO)
  String? selectedSyringe; // Ej: "Jeringa_23G1_Pulg_AD"
  String? syringeLot; // Lote de la jeringa
  String? diluentLot; // Lote del diluyente
  String? selectedDropper; // Ej: "Desechado" (para vacunas orales)
  String? selectedPneumococcalType; // Ej: "DECAVALENTE", "TRECEVALENTE"
  int? vialCount; // Número de frascos (para sueros)
  String? selectedObservation; // Observación predefinida
  String? customObservation; // Observación libre adicional

  // Seguimiento
  DateTime? nextDoseDate; // Próxima dosis programada

  // Sincronización
  String syncStatus; // 'local', 'synced', 'conflict'

  // Metadatos
  DateTime createdAt;
  DateTime? updatedAt;

  AppliedDose({
    this.id,
    String? uuid,
    required this.patientId,
    required this.nurseId,
    required this.vaccineId,
    required this.applicationDate,
    this.selectedDose,
    this.selectedLaboratory,
    required this.lotNumber,
    this.selectedSyringe,
    this.syringeLot,
    this.diluentLot,
    this.selectedDropper,
    this.selectedPneumococcalType,
    this.vialCount,
    this.selectedObservation,
    this.customObservation,
    this.nextDoseDate,
    this.syncStatus = 'local',
    DateTime? createdAt,
    this.updatedAt,
  }) : uuid = uuid ?? _generateUuid(),
       createdAt = createdAt ?? DateTime.now();

  // Generar UUID simple (en producción usa package:uuid)
  static String _generateUuid() {
    final now = DateTime.now();
    final random = now.microsecondsSinceEpoch.toString();
    return 'dose_$random';
  }

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'patient_id': patientId,
      'nurse_id': nurseId,
      'vaccine_id': vaccineId,
      'application_date': applicationDate.toIso8601String(),
      'selected_dose': selectedDose,
      'selected_laboratory': selectedLaboratory,
      'lot_number': lotNumber,
      'selected_syringe': selectedSyringe,
      'syringe_lot': syringeLot,
      'diluent_lot': diluentLot,
      'selected_dropper': selectedDropper,
      'selected_pneumococcal_type': selectedPneumococcalType,
      'vial_count': vialCount,
      'selected_observation': selectedObservation,
      'custom_observation': customObservation,
      'next_dose_date': nextDoseDate?.toIso8601String(),
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory AppliedDose.fromMap(Map<String, dynamic> map) {
    return AppliedDose(
      id: map['id'],
      uuid: map['uuid'],
      patientId: map['patient_id'],
      nurseId: map['nurse_id'],
      vaccineId: map['vaccine_id'],
      applicationDate: DateTime.parse(map['application_date']),
      selectedDose: map['selected_dose'],
      selectedLaboratory: map['selected_laboratory'],
      lotNumber: map['lot_number'],
      selectedSyringe: map['selected_syringe'],
      syringeLot: map['syringe_lot'],
      diluentLot: map['diluent_lot'],
      selectedDropper: map['selected_dropper'],
      selectedPneumococcalType: map['selected_pneumococcal_type'],
      vialCount: map['vial_count'],
      selectedObservation: map['selected_observation'],
      customObservation: map['custom_observation'],
      nextDoseDate: map['next_dose_date'] != null
          ? DateTime.parse(map['next_dose_date'])
          : null,
      syncStatus: map['sync_status'] ?? 'local',
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  // Marcar como sincronizado
  AppliedDose markAsSynced() {
    return AppliedDose(
      id: id,
      uuid: uuid,
      patientId: patientId,
      nurseId: nurseId,
      vaccineId: vaccineId,
      applicationDate: applicationDate,
      selectedDose: selectedDose,
      selectedLaboratory: selectedLaboratory,
      lotNumber: lotNumber,
      selectedSyringe: selectedSyringe,
      syringeLot: syringeLot,
      diluentLot: diluentLot,
      selectedDropper: selectedDropper,
      selectedPneumococcalType: selectedPneumococcalType,
      vialCount: vialCount,
      selectedObservation: selectedObservation,
      customObservation: customObservation,
      nextDoseDate: nextDoseDate,
      syncStatus: 'synced',
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  // Verificar si necesita sincronización
  bool get needsSync => syncStatus == 'local' || syncStatus == 'conflict';

  @override
  String toString() =>
      'AppliedDose{id: $id, uuid: $uuid, vaccineId: $vaccineId, date: $applicationDate}';
}
