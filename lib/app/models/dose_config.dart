/// Dispositivos de aplicación permitidos para vacunas
enum ApplicationDevice {
  // Jeringas COVID-19
  jeringa23G1ConvencionalCovid19(
    'Jeringa 23G 1" Convencional COVID-19',
    'J23G1-C-COVID',
  ),
  jeringa22G1MediaPulgConvencionalCovid19(
    'Jeringa 22G 1" Media Pulg Convencional COVID-19',
    'J22G1-MC-COVID',
  ),

  // Jeringas BCG
  jeringaDesechable26GTresOctavosAD(
    'Jeringa Desechable 26G 3/8" AD',
    'J26G-3/8-AD',
  ),
  jeringaDesechable26GTresOctavosConvencional(
    'Jeringa Desechable 26G 3/8" Convencional',
    'J26G-3/8-C',
  ),
  jeringaDesechable27GTresOctavos('Jeringa Desechable 27G 3/8"', 'J27G-3/8'),

  // Jeringas 22G 1" Media Pulg
  jeringaDesechable22G1MediaPulgAD(
    'Jeringa Desechable 22G 1" Media Pulg AD',
    'J22G1-AD',
  ),
  jeringaDesechable22G1MediaPulgConvencional(
    'Jeringa Desechable 22G 1" Media Pulg Convencional',
    'J22G1-C',
  ),

  // Jeringas 23G 1"
  jeringaDesechable23G1PulgAD('Jeringa Desechable 23G 1" AD', 'J23G1-AD'),
  jeringaDesechable23G1PulgConvencional(
    'Jeringa Desechable 23G 1" Convencional',
    'J23G1-C',
  ),

  // Jeringas 25G 5/8"
  jeringaDesechable25GCincoOctavosAD(
    'Jeringa Desechable 25G 5/8" AD',
    'J25G-5/8-AD',
  ),
  jeringaDesechable25GCincoOctavosConvencional(
    'Jeringa Desechable 25G 5/8" Convencional',
    'J25G-5/8-C',
  ),

  // Goteros
  goteroDesechado('Gotero Desechado', 'GOTERO');

  final String displayName;
  final String shortName;

  const ApplicationDevice(this.displayName, this.shortName);
}

/// Configuración de una dosis específica
class DoseConfig {
  final int doseNumber;
  final String doseName;
  final int ageMonthsMin;
  final int? ageMonthsMax;
  final int? daysFromPrevious;

  const DoseConfig({
    required this.doseNumber,
    required this.doseName,
    required this.ageMonthsMin,
    this.ageMonthsMax,
    this.daysFromPrevious,
  });

  Map<String, dynamic> toJson() {
    return {
      'doseNumber': doseNumber,
      'doseName': doseName,
      'ageMonthsMin': ageMonthsMin,
      'ageMonthsMax': ageMonthsMax,
      'daysFromPrevious': daysFromPrevious,
    };
  }

  factory DoseConfig.fromJson(Map<String, dynamic> json) {
    return DoseConfig(
      doseNumber: json['doseNumber'],
      doseName: json['doseName'],
      ageMonthsMin: json['ageMonthsMin'],
      ageMonthsMax: json['ageMonthsMax'],
      daysFromPrevious: json['daysFromPrevious'],
    );
  }
}
