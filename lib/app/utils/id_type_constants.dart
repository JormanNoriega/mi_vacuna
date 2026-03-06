class IdTypeConstants {
  // Lista completa de tipos de identificación con sus descripciones
  static const List<String> allIdTypes = [
    'CN - Certificado de Nacido Vivo',
    'RC - Registro Civil',
    'TI - Tarjeta de Identidad',
    'CC - Cédula de Ciudadanía',
    'AS - Adulto sin Identificación',
    'MS - Menor sin Identificación',
    'CE - Cédula de Extranjería',
    'PA - Pasaporte',
    'CD - Carné Diplomático',
    'SC - Salvoconducto',
    'PE - Permiso Especial de Permanencia',
    'PPT - Permiso por Protección Temporal',
    'DE - Documento Extranjero',
  ];

  // Mapa de conversión: descripción completa → abreviatura
  static const Map<String, String> idTypeToAbbr = {
    'CN - Certificado de Nacido Vivo': 'CN',
    'RC - Registro Civil': 'RC',
    'TI - Tarjeta de Identidad': 'TI',
    'CC - Cédula de Ciudadanía': 'CC',
    'AS - Adulto sin Identificación': 'AS',
    'MS - Menor sin Identificación': 'MS',
    'CE - Cédula de Extranjería': 'CE',
    'PA - Pasaporte': 'PA',
    'CD - Carné Diplomático': 'CD',
    'SC - Salvoconducto': 'SC',
    'PE - Permiso Especial de Permanencia': 'PE',
    'PPT - Permiso por Protección Temporal': 'PPT',
    'DE - Documento Extranjero': 'DE',
  };

  /// Convierte tipo de ID completo a abreviatura
  static String toAbbreviation(String? idType) {
    if (idType == null || idType.isEmpty) return '';
    return idTypeToAbbr[idType] ?? idType;
  }
}
