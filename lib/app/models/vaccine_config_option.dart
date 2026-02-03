// Opciones de configuración para vacunas

enum ConfigFieldType {
  dose, // Opciones de dosis
  laboratory, // Laboratorios disponibles
  syringe, // Tipos de jeringa
  dropper, // Tipos de gotero
  pneumococcalType, // Tipos de neumococo
  observation, // Observaciones predefinidas
}

class VaccineConfigOption {
  String? id; // UUID
  String vaccineId; // FK -> vaccines (UUID)
  ConfigFieldType fieldType; // Tipo de campo
  String value; // Valor de la opción (para guardar en BD)
  String displayName; // Nombre para mostrar en UI
  int sortOrder; // Orden de aparición en dropdowns
  bool isDefault; // Si es valor por defecto/precargado
  bool isActive;

  VaccineConfigOption({
    this.id,
    required this.vaccineId,
    required this.fieldType,
    required this.value,
    required this.displayName,
    this.sortOrder = 0,
    this.isDefault = false,
    this.isActive = true,
  });

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vaccine_id': vaccineId,
      'field_type': fieldType.name,
      'value': value,
      'display_name': displayName,
      'sort_order': sortOrder,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }

  // Crear desde Map de SQLite
  factory VaccineConfigOption.fromMap(Map<String, dynamic> map) {
    return VaccineConfigOption(
      id: map['id'],
      vaccineId: map['vaccine_id'],
      fieldType: ConfigFieldType.values.byName(map['field_type']),
      value: map['value'],
      displayName: map['display_name'],
      sortOrder: map['sort_order'],
      isDefault: map['is_default'] == 1,
      isActive: map['is_active'] == 1,
    );
  }

  @override
  String toString() =>
      'VaccineConfigOption{vaccineId: $vaccineId, type: ${fieldType.name}, value: $value}';
}
