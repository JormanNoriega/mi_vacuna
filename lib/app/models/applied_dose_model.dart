import '../domain/vaccine_type.dart';
import '../domain/dose_config.dart';

/// Modelo de dosis aplicada a un paciente
class AppliedDose {
  final int? id;
  final int patientId; // FK a patients
  final int nurseId; // FK a nurses (enfermera que aplicó)
  final VaccineType vaccineType; // Tipo de vacuna del catálogo
  final int doseNumber; // Número de dosis (1, 2, 3...)

  // Datos de aplicación
  final DateTime applicationDate;
  final String lotNumber;
  final String? syringeLot;
  final String? diluentLot;
  final ApplicationDevice device;
  final String? laboratory; // Para vacunas que lo requieren (COVID, etc)
  final String? observation; // Observación predefinida o personalizada
  final String? adverseReaction; // Reacción adversa si la hubo

  // Campos opcionales según tipo de vacuna
  final String? pneumococcalType; // Para Neumococo (PCV13, PPSV23)
  final int? vialCount; // Para sueros e inmunoglobulinas

  // Fecha calculada de próxima dosis
  final DateTime? nextDoseDate;

  final DateTime createdAt;
  final DateTime? updatedAt;

  AppliedDose({
    this.id,
    required this.patientId,
    required this.nurseId,
    required this.vaccineType,
    required this.doseNumber,
    required this.applicationDate,
    required this.lotNumber,
    this.syringeLot,
    this.diluentLot,
    required this.device,
    this.laboratory,
    this.observation,
    this.adverseReaction,
    this.pneumococcalType,
    this.vialCount,
    this.nextDoseDate,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'nurse_id': nurseId,
      'vaccine_type': vaccineType.name,
      'dose_number': doseNumber,
      'application_date': applicationDate.toIso8601String(),
      'lot_number': lotNumber,
      'syringe_lot': syringeLot,
      'diluent_lot': diluentLot,
      'device': device.name,
      'laboratory': laboratory,
      'observation': observation,
      'adverse_reaction': adverseReaction,
      'pneumococcal_type': pneumococcalType,
      'vial_count': vialCount,
      'next_dose_date': nextDoseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AppliedDose.fromMap(Map<String, dynamic> map) {
    return AppliedDose(
      id: map['id'],
      patientId: map['patient_id'],
      nurseId: map['nurse_id'],
      vaccineType: VaccineType.values.firstWhere(
        (e) => e.name == map['vaccine_type'],
      ),
      doseNumber: map['dose_number'],
      applicationDate: DateTime.parse(map['application_date']),
      lotNumber: map['lot_number'],
      syringeLot: map['syringe_lot'],
      diluentLot: map['diluent_lot'],
      device: ApplicationDevice.values.firstWhere(
        (e) => e.name == map['device'],
      ),
      laboratory: map['laboratory'],
      observation: map['observation'],
      adverseReaction: map['adverse_reaction'],
      pneumococcalType: map['pneumococcal_type'],
      vialCount: map['vial_count'],
      nextDoseDate: map['next_dose_date'] != null
          ? DateTime.parse(map['next_dose_date'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  AppliedDose copyWith({
    int? id,
    int? patientId,
    int? nurseId,
    VaccineType? vaccineType,
    int? doseNumber,
    DateTime? applicationDate,
    String? lotNumber,
    String? syringeLot,
    String? diluentLot,
    ApplicationDevice? device,
    String? laboratory,
    String? observation,
    String? adverseReaction,
    String? pneumococcalType,
    int? vialCount,
    DateTime? nextDoseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppliedDose(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      nurseId: nurseId ?? this.nurseId,
      vaccineType: vaccineType ?? this.vaccineType,
      doseNumber: doseNumber ?? this.doseNumber,
      applicationDate: applicationDate ?? this.applicationDate,
      lotNumber: lotNumber ?? this.lotNumber,
      syringeLot: syringeLot ?? this.syringeLot,
      diluentLot: diluentLot ?? this.diluentLot,
      device: device ?? this.device,
      laboratory: laboratory ?? this.laboratory,
      observation: observation ?? this.observation,
      adverseReaction: adverseReaction ?? this.adverseReaction,
      pneumococcalType: pneumococcalType ?? this.pneumococcalType,
      vialCount: vialCount ?? this.vialCount,
      nextDoseDate: nextDoseDate ?? this.nextDoseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
