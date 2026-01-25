/// Tipos de vacunas disponibles en el catálogo
enum VaccineType {
  covid19('COVID', 'COVID-19'),
  bcg('BCG', 'BCG - Tuberculosis'),
  hepatitisB('HepB', 'Hepatitis B'),
  polioInactivado('IPV', 'Polio Inactivado (Inyectable)'),
  polioOral('VOP', 'Polio Oral'),
  pentavalente('PENTA', 'Pentavalente'),
  hexavalente('HEXA', 'Hexavalente'),
  dpt('DPT', 'Difteria, Tos ferina y Tétanos - DPT'),
  dtpaPediatrico('DTPa-P', 'DTPa Pediátrico'),
  tdPediatrico('TD-P', 'TD Pediátrico'),
  rotavirus('ROTA', 'Rotavirus (Oral)'),
  neumococo('NEUM', 'Neumococo'),
  tripleViral('SRP', 'Triple Viral - SRP'),
  sarampionRubeola('SR', 'Sarampión-Rubéola SR'),
  fiebreAmarilla('FA', 'Fiebre Amarilla'),
  hepatitisAPediatrica('HepA-P', 'Hepatitis A Pediátrica'),
  varicela('VAR', 'Varicela'),
  tdAdulto('TD-A', 'Toxoide Tetánico y Diftérico de Adulto'),
  dtpaAdulto('DTPa-A', 'dTpa Adulto'),
  influenza('FLU', 'Influenza'),
  vph('VPH', 'VPH - Virus Papiloma Humano'),
  antirrabicaHumana('RAB-V', 'Antirrábica Humana (Vacuna)'),
  antirrabicoSuero('RAB-S', 'Antirrábico Humano (Suero)'),
  hepatitisBInmunoglobulina('HepB-IG', 'Hepatitis B (Inmunoglobulina)'),
  inmunoglobulinaAntiTetanica('TET-IG', 'Inmunoglobulina Anti Tetánica'),
  antiToxinaTetanica('TET-AT', 'Anti Toxina Tetánica (Suero Heterólogo)'),
  meningococo('MENING', 'Meningococo A, C, W-135, Y');

  final String code;
  final String fullName;

  const VaccineType(this.code, this.fullName);
}
