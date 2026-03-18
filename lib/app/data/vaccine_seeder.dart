import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Seeder para pre-cargar todas las vacunas y sus opciones configurables
class VaccineSeeder {
  static const _uuid = Uuid();

  /// Ejecutar todos los seeders
  static Future<void> seedAll(Database db) async {
    print('🌱 Iniciando seeder de vacunas...');

    await _seedCovid19(db);
    await _seedBCG(db);
    await _seedHepatitisB(db);
    await _seedPolioInactivado(db);
    await _seedPolioOral(db);
    await _seedPentavalente(db);
    await _seedHexavalente(db);
    await _seedDPT(db);
    await _seedDTPaPediatrico(db);
    await _seedTDPediatrico(db);
    await _seedRotavirus(db);
    await _seedNeumococo(db);
    await _seedTripleViral(db);
    await _seedSarampionRubeola(db);
    await _seedFiebreAmarilla(db);
    await _seedHepatitisAPediatrica(db);
    await _seedVaricela(db);
    await _seedToxoideTetanicoDiftericoAdulto(db);
    await _seedDTPaAdulto(db);
    await _seedInfluenza(db);
    await _seedVPH(db);
    await _seedAntirrabicaVacuna(db);
    await _seedAntirrabicoSuero(db);
    await _seedHepatitisBInmunoglobulina(db);
    await _seedInmunoglobulinaAntitetanica(db);
    await _seedAntitoxinaTetanica(db);
    await _seedMeningococo(db);

    print('✅ Seeder completado: 27 vacunas cargadas');
  }

  // Helper para obtener el siguiente vaccine_sequence
  static Future<int> _nextSequence(Database db) async {
    final res = await db.rawQuery('SELECT MAX(vaccine_sequence) as maxSeq FROM vaccines');
    final maxSeq = res.first['maxSeq'];
    final seq = (maxSeq is int ? maxSeq : (maxSeq == null ? 0 : int.tryParse(maxSeq.toString()) ?? 0));
    return seq + 1;
  }

  // ==================== COVID-19 ====================
  static Future<void> _seedCovid19(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'COVID-19',
      'code': 'covid19',
      'category': 'todas',
      'max_doses': 6,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 1,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Unica',
      'Refuerzo',
      '2do refuerzo - Res419',
      '2do refuerzo',
      'Dosis Adicional'
    ]);

    // Laboratorios
    await _insertOptions(db, vaccineId, 'laboratory', [
      'PFIZER',
      'ASTRAZENECA',
      'MODERNA 0,25',
      'MODERNA 0,5',
      'SINOVAC',
      'JANSSEN',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa23G1_convencional_covid19',
      'Jeringa22G1_media_pulg_convencional_covid19',
    ]);
  }

  // ==================== BCG ====================
  static Future<void> _seedBCG(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'BCG',
      'code': 'bcg',
      'category': 'infantil',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 6,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Unica']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_AD',
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_Convencional',
      'Jeringa_Desechable_27G_Tres_Octavos_Pulg',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'POBLACION INDIGENA Y RURAL DISPERSA',
      'CONTACTOS DE HANSEN',
    ]);
  }

  // ==================== HEPATITIS B ====================
  static Future<void> _seedHepatitisB(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Hepatitis B',
      'code': 'hepatitis_b',
      'category': 'infantil',
      'max_doses': 4,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 216, // 18 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'RECIEN NACIDO',
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Adiccional',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'ANTES DE 12 HORAS',
      'DESPÚES DE 12 HORAS',
      '(ICBF)',
      'RESOLUCION. 0459/2012 y Circular 031/14',
      'HOMBRES QUE TIENEN SEXO CON HOMBRES. PRIO',
      'PERSONAS QUE EJERCEN ACTIVIDADES SEXUALES PAGAS. PRIO',
      'MUJERES TRANSGENERO. PRIO',
      'PERSONAS QUE SE INYECTAN DROGAS. PRIO',
      'HABITANTES DE CALLE. PRIO',
      'INDIGENAS. PRIO',
    ]);
  }

  // ==================== POLIO INACTIVADO ====================
  static Future<void> _seedPolioInactivado(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Polio Inactivado (IPV)',
      'code': 'polio_ipv',
      'category': 'infantil',
      'max_doses': 5,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 60, // 5 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
    ]);

    // Jeringas (usar las genéricas de 23G)
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'AUTORIZADAS POR EL MINISTERIO',
    ]);
  }

  // ==================== POLIO ORAL ====================
  static Future<void> _seedPolioOral(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Polio Oral (OPV)',
      'code': 'polio_oral',
      'category': 'infantil',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 60, // 5 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 0,
      'has_syringe_lot': 0,
      'has_diluent': 0,
      'has_dropper': 1,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Segundo Refuerzo']);

    // Gotero
    await _insertOptions(db, vaccineId, 'dropper', ['Desechado']);
  }

  // ==================== PENTAVALENTE ====================
  static Future<void> _seedPentavalente(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Pentavalente (DPT+HB+Hib)',
      'code': 'pentavalente',
      'category': 'infantil',
      'max_doses': 5,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 24, // 2 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'AUTORIZADAS POR EL MINISTERIO',
    ]);
  }

  // ==================== HEXAVALENTE ====================
  static Future<void> _seedHexavalente(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Hexavalente',
      'code': 'hexavalente',
      'category': 'infantil',
      'max_doses': 3,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 24,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== DPT ====================
  static Future<void> _seedDPT(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'DPT (Difteria, Tos ferina, Tétanos)',
      'code': 'dpt',
      'category': 'infantil',
      'max_doses': 5,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 84, // 7 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== DTPa PEDIÁTRICO ====================
  static Future<void> _seedDTPaPediatrico(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'DTPa Pediátrico',
      'code': 'dtpa_pediatrico',
      'category': 'infantil',
      'max_doses': 5,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 84,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== TD PEDIÁTRICO ====================
  static Future<void> _seedTDPediatrico(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'TD Pediátrico',
      'code': 'td_pediatrico',
      'category': 'infantil',
      'max_doses': 5,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 84,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== ROTAVIRUS ====================
  static Future<void> _seedRotavirus(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Rotavirus',
      'code': 'rotavirus',
      'category': 'infantil',
      'max_doses': 2,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 6,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 0,
      'has_syringe_lot': 0,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Solo Dosis y Lote
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
    ]);
  }

  // ==================== NEUMOCOCO ====================
  static Future<void> _seedNeumococo(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Neumococo Conjugada',
      'code': 'neumococo',
      'category': 'infantil',
      'max_doses': 4,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 60,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 1,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Tipo Neumococo
    await _insertOptions(db, vaccineId, 'pneumococcalType', [
      'DECAVALENTE',
      'TRECEVALENTE',
    ]);

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Primer Refuerzo',
      'Unica',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== TRIPLE VIRAL ====================
  static Future<void> _seedTripleViral(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Triple Viral (SRP)',
      'code': 'srp',
      'category': 'infantil',
      'max_doses': 2,
      'vaccine_sequence': sequence,
      'min_months': 12,
      'max_months': 60,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Primera dosis', 'Refuerzo']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
    ]);
  }

  // ==================== SARAMPIÓN RUBEOLA ====================
  static Future<void> _seedSarampionRubeola(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Sarampión Rubeola (SR) Multidosis',
      'code': 'sr_multidosis',
      'category': 'infantil',
      'max_doses': 2,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Unica', 'Cero']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
    ]);
  }

  // ==================== FIEBRE AMARILLA ====================
  static Future<void> _seedFiebreAmarilla(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Fiebre Amarilla',
      'code': 'fiebre_amarilla',
      'category': 'todas',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': 12,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Unica']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
    ]);
  }

  // ==================== HEPATITIS A PEDIÁTRICA ====================
  static Future<void> _seedHepatitisAPediatrica(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Hepatitis A Pediátrica',
      'code': 'hepatitis_a_pediatrica',
      'category': 'infantil',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': 0,
      'max_months': 144, // 12 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Unica']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== VARICELA ====================
  static Future<void> _seedVaricela(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Varicela',
      'code': 'varicela',
      'category': 'infantil',
      'max_doses': 2,
      'vaccine_sequence': sequence,
      'min_months': 12, // 1 año
      'max_months': 120, // 10 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', ['Primera dosis', 'Refuerzo']);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
    ]);
  }

  // ==================== TOXOIDE TETÁNICO DIFTÉRICO ADULTO ====================
  static Future<void> _seedToxoideTetanicoDiftericoAdulto(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Toxoide Tetánico Diftérico (TD) Adulto',
      'code': 'td_adulto',
      'category': 'adulto',
      'max_doses': 9,
      'vaccine_sequence': sequence,
      'min_months': 84, // 7 años en adelante
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Cuarta dosis',
      'Quinta dosis',
      'Primer Refuerzo',
      'Segundo Refuerzo',
      'Tercer Refuerzo',
      'Cuarto Refuerzo',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
    ]);
  }

  // ==================== DTPa ADULTO ====================
  static Future<void> _seedDTPaAdulto(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'dTpa Adulto',
      'code': 'dtpa_adulto',
      'category': 'adulto',
      'max_doses': 6,
      'vaccine_sequence': sequence,
      'min_months': 84,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Cuarta dosis',
      'Quinta dosis',
      'Unica',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
    ]);
  }

  // ==================== INFLUENZA ====================
  static Future<void> _seedInfluenza(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Influenza',
      'code': 'influenza',
      'category': 'todas',
      'max_doses': 99, // Anual
      'vaccine_sequence': sequence,
      'min_months': 6,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Unica 0,25',
      'Unica 0,5',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'DIAGNÓSTICO DE RIESGO',
      'Poblaciones autorizadas MSPS',
      'TALENTO HUMANO EN SALUD',
    ]);
  }

  // ==================== VPH ====================
  static Future<void> _seedVPH(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'VPH (Virus del Papiloma Humano)',
      'code': 'vph',
      'category': 'adolescente',
      'max_doses': 3,
      'vaccine_sequence': sequence,
      'min_months': 108, // 9 años
      'max_months': 204, // 17 años
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Dosis Unica',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== ANTIRRÁBICA VACUNA ====================
  static Future<void> _seedAntirrabicaVacuna(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Antirrábica Humana (Vacuna)',
      'code': 'antirrabica_vacuna',
      'category': 'especial',
      'max_doses': 6,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Cuarta dosis',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
    ]);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'PRE EXPOSICIÓN OPCION 1 (I.D.)',
      'PRE EXPOSICIÓN OPCION 2 (I.M.)',
      'POS EXPOSICIÓN NORMAL',
    ]);
  }

  // ==================== ANTIRRÁBICO SUERO ====================
  static Future<void> _seedAntirrabicoSuero(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Antirrábico Humano (Suero)',
      'code': 'antirrabico_suero',
      'category': 'especial',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 0,
      'has_syringe_lot': 0,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 1,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis única por defecto
    await _insertOptions(db, vaccineId, 'dose', ['Única']);
  }

  // ==================== HEPATITIS B INMUNOGLOBULINA ====================
  static Future<void> _seedHepatitisBInmunoglobulina(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Hepatitis B (Inmunoglobulina)',
      'code': 'hepatitis_b_inmunoglobulina',
      'category': 'especial',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 1,
      'has_observation': 1,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);

    // Dosis única por defecto
    await _insertOptions(db, vaccineId, 'dose', ['Única']);

    // Observaciones
    await _insertOptions(db, vaccineId, 'observation', [
      'ANTES DE 12 HORAS',
      'DESPÚES DE 12 HORAS',
      'RESOLUCION 0459/2012- circular 031/14',
    ]);
  }

  // ==================== INMUNOGLOBULINA ANTITETÁNICA ====================
  static Future<void> _seedInmunoglobulinaAntitetanica(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Inmunoglobulina Antitetánica (Suero Homólogo)',
      'code': 'inmunoglobulina_antitetanica',
      'category': 'especial',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 1,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis única por defecto
    await _insertOptions(db, vaccineId, 'dose', ['Única']);

    // Jeringas (todas las disponibles)
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_AD',
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_Convencional',
      'Jeringa_Desechable_27G_Tres_Octavos_Pulg',
    ]);
  }

  // ==================== ANTITOXINA TETÁNICA ====================
  static Future<void> _seedAntitoxinaTetanica(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Antitoxina Tetánica (Suero Heterólogo)',
      'code': 'antitoxina_tetanica',
      'category': 'especial',
      'max_doses': 1,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 0,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 1,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis única por defecto
    await _insertOptions(db, vaccineId, 'dose', ['Única']);

    // Jeringas (todas las disponibles)
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_22G1_Media_Pulg_AD',
      'Jeringa_Desechable_22G1_Media_Pulg_Convencional',
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_AD',
      'Jeringa_Desechable_25G_Cinco_Octavos_Pulg_Convencional',
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_AD',
      'Jeringa_Desechable_26G_Tres_Octavos_Pulg_Convencional',
      'Jeringa_Desechable_27G_Tres_Octavos_Pulg',
    ]);
  }

  // ==================== MENINGOCOCO ====================
  static Future<void> _seedMeningococo(Database db) async {
    final vaccineId = _uuid.v4();
    final sequence = await _nextSequence(db);
    await db.insert('vaccines', {
      'id': vaccineId,
      'name': 'Meningococo (Serogrupos A, C, W-135, Y)',
      'code': 'meningococo',
      'category': 'todas',
      'max_doses': 4,
      'vaccine_sequence': sequence,
      'min_months': null,
      'max_months': null,
      'has_laboratory': 0,
      'has_lot': 1,
      'has_syringe': 1,
      'has_syringe_lot': 1,
      'has_diluent': 1,
      'has_dropper': 0,
      'has_pneumococcal_type': 0,
      'has_vial_count': 0,
      'has_observation': 0,
      'is_active': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    // Dosis
    await _insertOptions(db, vaccineId, 'dose', [
      'Primera dosis',
      'Segunda dosis',
      'Tercera dosis',
      'Unica',
    ]);

    // Jeringas
    await _insertOptions(db, vaccineId, 'syringe', [
      'Jeringa_Desechable_23G1_Pulg_AD',
      'Jeringa_Desechable_23G1_Pulg_Convencional',
    ]);
  }

  // ==================== HELPER METHODS ====================

  /// Insertar múltiples opciones de configuración
  static Future<void> _insertOptions(
    Database db,
    String vaccineId,
    String fieldType,
    List<String> options,
  ) async {
    for (int i = 0; i < options.length; i++) {
      await db.insert('vaccine_config_options', {
        'id': _uuid.v4(),
        'vaccine_id': vaccineId,
        'field_type': fieldType,
        'value': _sanitizeValue(options[i]),
        'display_name': options[i],
        'sort_order': i,
        'is_default': 1,
        'is_active': 1,
      });
    }
  }

  /// Sanitizar valor para usar como identificador
  static String _sanitizeValue(String text) {
    return text
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll(',', '')
        .replaceAll('.', '')
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n');
  }
}
