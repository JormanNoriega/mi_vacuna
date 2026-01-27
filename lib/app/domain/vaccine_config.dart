import 'vaccine_type.dart';
import 'dose_config.dart';

/// Configuración estática de una vacuna del catálogo
class VaccineConfig {
  final VaccineType type;
  final String name;
  final String code;
  final List<DoseConfig> doses;

  // Campos opcionales según tipo de vacuna
  final bool hasLaboratory;
  final List<String>?
  laboratories; // Laboratorios específicos (para COVID, etc)
  final bool hasLot;
  final bool hasSyringeLot;
  final bool hasDiluentLot;
  final bool hasObservation;
  final List<String>? observations; // Observaciones predefinidas
  final bool hasPneumococcalType;
  final bool usesVialCount; // Número de frascos utilizados

  // Dispositivos permitidos para aplicación
  final List<ApplicationDevice> allowedDevices;

  const VaccineConfig({
    required this.type,
    required this.name,
    required this.code,
    required this.doses,
    required this.allowedDevices,
    this.hasLaboratory = false,
    this.laboratories,
    this.hasLot = true,
    this.hasSyringeLot = false,
    this.hasDiluentLot = false,
    this.hasObservation = false,
    this.observations,
    this.hasPneumococcalType = false,
    this.usesVialCount = false,
  });

  // Getter calculado automáticamente
  int get totalDoses => doses.length;

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'name': name,
      'code': code,
      'totalDoses': totalDoses,
      'doses': doses.map((d) => d.toJson()).toList(),
      'hasLaboratory': hasLaboratory,
      'laboratories': laboratories,
      'hasLot': hasLot,
      'hasSyringeLot': hasSyringeLot,
      'hasDiluentLot': hasDiluentLot,
      'hasObservation': hasObservation,
      'observations': observations,
      'hasPneumococcalType': hasPneumococcalType,
      'usesVialCount': usesVialCount,
      'allowedDevices': allowedDevices.map((d) => d.name).toList(),
    };
  }
}
