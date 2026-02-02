import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/applied_dose.dart';

/// Servicio para gestionar dosis aplicadas
///
/// Proporciona métodos para:
/// - CRUD completo de registros de vacunación
/// - Consultas por paciente, vacuna, enfermera y fechas
/// - Información enriquecida con datos de paciente, vacuna y enfermera
/// - Control de sincronización offline
class AppliedDoseService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CRUD BÁSICO ====================

  /// Registra una nueva dosis aplicada
  /// Retorna el ID de la dosis creada
  Future<int> createDose(AppliedDose dose) async {
    final db = await _dbHelper.database;
    return await db.insert('applied_doses', dose.toMap());
  }

  /// Obtiene una dosis por su ID
  Future<AppliedDose?> getDoseById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AppliedDose.fromMap(result.first);
  }

  /// Obtiene una dosis por su UUID
  Future<AppliedDose?> getDoseByUuid(String uuid) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'uuid = ?',
      whereArgs: [uuid],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AppliedDose.fromMap(result.first);
  }

  /// Obtiene todas las dosis aplicadas
  Future<List<AppliedDose>> getAllDoses({int? limit, int? offset}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      orderBy: 'application_date DESC',
      limit: limit,
      offset: offset,
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Actualiza una dosis existente
  /// Retorna el número de filas afectadas (1 si fue exitoso)
  Future<int> updateDose(AppliedDose dose) async {
    final db = await _dbHelper.database;
    return await db.update(
      'applied_doses',
      dose.toMap(),
      where: 'id = ?',
      whereArgs: [dose.id],
    );
  }

  /// Elimina una dosis por su ID
  Future<int> deleteDose(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('applied_doses', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== CONSULTAS POR RELACIONES ====================

  /// Obtiene todas las dosis aplicadas a un paciente
  Future<List<AppliedDose>> getDosesByPatient(String patientId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'application_date DESC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Obtiene todas las dosis de una vacuna específica
  Future<List<AppliedDose>> getDosesByVaccine(int vaccineId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'vaccine_id = ?',
      whereArgs: [vaccineId],
      orderBy: 'application_date DESC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Obtiene todas las dosis aplicadas por una enfermera
  Future<List<AppliedDose>> getDosesByNurse(int nurseId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'nurse_id = ?',
      whereArgs: [nurseId],
      orderBy: 'application_date DESC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Obtiene dosis por rango de fechas
  Future<List<AppliedDose>> getDosesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'application_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'application_date DESC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Obtiene dosis de un paciente para una vacuna específica
  Future<List<AppliedDose>> getDosesByPatientAndVaccine(
    String patientId,
    int vaccineId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'patient_id = ? AND vaccine_id = ?',
      whereArgs: [patientId, vaccineId],
      orderBy: 'application_date ASC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  // ==================== CONSULTAS CON INFORMACIÓN ENRIQUECIDA ====================

  /// Obtiene dosis con información de paciente, vacuna y enfermera
  Future<List<Map<String, dynamic>>> getDosesWithVaccineInfo({
    String? patientId,
    String? nurseId,
    int? limit,
  }) async {
    final db = await _dbHelper.database;

    String query = '''
      SELECT 
        ad.*,
        v.name as vaccine_name,
        v.code as vaccine_code,
        v.category as vaccine_category,
        p.first_name as patient_first_name,
        p.last_name as patient_last_name,
        p.id_number as patient_id_number,
        n.firstName as nurse_first_name,
        n.lastName as nurse_last_name
      FROM applied_doses ad
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      INNER JOIN patients p ON ad.patient_id = p.id
      INNER JOIN nurses n ON ad.nurse_id = n.id
    ''';

    List<dynamic> args = [];
    List<String> conditions = [];

    if (patientId != null) {
      conditions.add('ad.patient_id = ?');
      args.add(patientId);
    }

    if (nurseId != null) {
      conditions.add('ad.nurse_id = ?');
      args.add(nurseId);
    }

    if (conditions.isNotEmpty) {
      query += ' WHERE ' + conditions.join(' AND ');
    }

    query += ' ORDER BY ad.application_date DESC';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    return await db.rawQuery(query, args.isEmpty ? null : args);
  }

  /// Obtiene el detalle completo de una dosis aplicada
  Future<Map<String, dynamic>?> getDoseDetail(int doseId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        ad.*,
        v.name as vaccine_name,
        v.code as vaccine_code,
        v.category as vaccine_category,
        v.max_doses as vaccine_max_doses,
        p.first_name as patient_first_name,
        p.second_name as patient_second_name,
        p.last_name as patient_last_name,
        p.second_last_name as patient_second_last_name,
        p.id_type as patient_id_type,
        p.id_number as patient_id_number,
        p.birth_date as patient_birth_date,
        p.sex as patient_sex,
        n.firstName as nurse_first_name,
        n.lastName as nurse_last_name,
        n.institution as nurse_institution
      FROM applied_doses ad
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      INNER JOIN patients p ON ad.patient_id = p.id
      INNER JOIN nurses n ON ad.nurse_id = n.id
      WHERE ad.id = ?
    ''',
      [doseId],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  // ==================== FILTROS Y BÚSQUEDA ====================

  /// Filtra dosis por múltiples criterios
  Future<List<AppliedDose>> filterDoses({
    String? patientId,
    int? vaccineId,
    String? nurseId,
    DateTime? startDate,
    DateTime? endDate,
    String? syncStatus,
  }) async {
    final db = await _dbHelper.database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (patientId != null) {
      conditions.add('patient_id = ?');
      args.add(patientId);
    }

    if (vaccineId != null) {
      conditions.add('vaccine_id = ?');
      args.add(vaccineId);
    }

    if (nurseId != null) {
      conditions.add('nurse_id = ?');
      args.add(nurseId);
    }

    if (startDate != null) {
      conditions.add('application_date >= ?');
      args.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      conditions.add('application_date <= ?');
      args.add(endDate.toIso8601String());
    }

    if (syncStatus != null) {
      conditions.add('sync_status = ?');
      args.add(syncStatus);
    }

    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');

    final result = await db.query(
      'applied_doses',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'application_date DESC',
    );

    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Busca dosis por número de lote
  Future<List<AppliedDose>> getDosesByLotNumber(String lotNumber) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'lot_number = ?',
      whereArgs: [lotNumber],
      orderBy: 'application_date DESC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  // ==================== SINCRONIZACIÓN ====================

  /// Obtiene dosis pendientes de sincronización
  Future<List<AppliedDose>> getDosesNeedingSync() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'sync_status = ?',
      whereArgs: ['local'],
      orderBy: 'created_at ASC',
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  /// Marca una dosis como sincronizada
  Future<int> markAsSynced(int doseId) async {
    final db = await _dbHelper.database;
    return await db.update(
      'applied_doses',
      {'sync_status': 'synced', 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [doseId],
    );
  }

  /// Marca múltiples dosis como sincronizadas
  Future<int> markMultipleAsSynced(List<int> doseIds) async {
    final db = await _dbHelper.database;
    final ids = doseIds.join(',');
    return await db.rawUpdate(
      '''
      UPDATE applied_doses 
      SET sync_status = 'synced', updated_at = ?
      WHERE id IN ($ids)
    ''',
      [DateTime.now().toIso8601String()],
    );
  }

  /// Cuenta dosis pendientes de sincronización
  Future<int> countDosesNeedingSync() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE sync_status = ?',
      ['local'],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ==================== ESTADÍSTICAS ====================

  /// Cuenta el total de dosis aplicadas
  Future<int> countAllDoses() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Cuenta dosis por enfermera
  Future<int> countDosesByNurse(int nurseId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE nurse_id = ?',
      [nurseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Cuenta dosis por vacuna
  Future<Map<String, int>> countDosesByVaccine() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        v.name as vaccine_name,
        COUNT(ad.id) as count
      FROM applied_doses ad
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      GROUP BY v.name
      ORDER BY count DESC
    ''');

    return Map.fromEntries(
      result.map(
        (row) => MapEntry(row['vaccine_name'] as String, row['count'] as int),
      ),
    );
  }

  /// Cuenta dosis aplicadas en un rango de fechas
  Future<int> countDosesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE application_date BETWEEN ? AND ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtiene las últimas dosis aplicadas
  Future<List<AppliedDose>> getLatestDoses(int limit) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      orderBy: 'application_date DESC',
      limit: limit,
    );
    return result.map((json) => AppliedDose.fromMap(json)).toList();
  }

  // ==================== VALIDACIONES Y CONTROL ====================

  /// Verifica si un paciente ya recibió todas las dosis de una vacuna
  Future<bool> hasCompletedVaccineScheme(
    String patientId,
    int vaccineId,
  ) async {
    final db = await _dbHelper.database;

    // Obtener la cantidad máxima de dosis de la vacuna
    final vaccineResult = await db.query(
      'vaccines',
      columns: ['max_doses'],
      where: 'id = ?',
      whereArgs: [vaccineId],
      limit: 1,
    );

    if (vaccineResult.isEmpty) return false;
    final maxDoses = vaccineResult.first['max_doses'] as int;

    // Contar cuántas dosis ha recibido el paciente
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE patient_id = ? AND vaccine_id = ?',
      [patientId, vaccineId],
    );

    final appliedDoses = Sqflite.firstIntValue(countResult) ?? 0;
    return appliedDoses >= maxDoses;
  }

  /// Obtiene el número de dosis aplicadas de una vacuna a un paciente
  Future<int> countDosesForPatientVaccine(
    String patientId,
    int vaccineId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE patient_id = ? AND vaccine_id = ?',
      [patientId, vaccineId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtiene la última dosis aplicada de una vacuna a un paciente
  Future<AppliedDose?> getLastDoseForPatientVaccine(
    String patientId,
    int vaccineId,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'applied_doses',
      where: 'patient_id = ? AND vaccine_id = ?',
      whereArgs: [patientId, vaccineId],
      orderBy: 'application_date DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return AppliedDose.fromMap(result.first);
  }
}
