import '../data/database_helper.dart';
import '../models/patient_model.dart';

/// Servicio para gestionar antecedentes médicos de pacientes
class MedicalHistoryService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crear un nuevo antecedente médico
  Future<int> createHistory(MedicalHistory history) async {
    final db = await _dbHelper.database;
    return await db.insert('medical_history', history.toMap());
  }

  /// Obtener antecedente por ID
  Future<MedicalHistory?> getHistoryById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'medical_history',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return MedicalHistory.fromMap(maps.first);
  }

  /// Obtener todos los antecedentes de un paciente
  Future<List<MedicalHistory>> getHistoriesByPatient(int patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'medical_history',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'registration_date DESC',
    );
    return maps.map((map) => MedicalHistory.fromMap(map)).toList();
  }

  /// Obtener antecedentes por tipo
  Future<List<MedicalHistory>> getHistoriesByType(
    int patientId,
    String type,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'medical_history',
      where: 'patient_id = ? AND type = ?',
      whereArgs: [patientId, type],
      orderBy: 'registration_date DESC',
    );
    return maps.map((map) => MedicalHistory.fromMap(map)).toList();
  }

  /// Buscar antecedentes por descripción
  Future<List<MedicalHistory>> searchHistories(
    int patientId,
    String searchTerm,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'medical_history',
      where: 'patient_id = ? AND (description LIKE ? OR type LIKE ?)',
      whereArgs: [patientId, '%$searchTerm%', '%$searchTerm%'],
      orderBy: 'registration_date DESC',
    );
    return maps.map((map) => MedicalHistory.fromMap(map)).toList();
  }

  /// Verificar si un paciente tiene antecedentes de un tipo específico
  Future<bool> hasHistoryType(int patientId, String type) async {
    final histories = await getHistoriesByType(patientId, type);
    return histories.isNotEmpty;
  }

  /// Actualizar antecedente médico
  Future<int> updateHistory(MedicalHistory history) async {
    final db = await _dbHelper.database;
    return await db.update(
      'medical_history',
      history.toMap(),
      where: 'id = ?',
      whereArgs: [history.id],
    );
  }

  /// Eliminar antecedente médico
  Future<int> deleteHistory(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('medical_history', where: 'id = ?', whereArgs: [id]);
  }

  /// Eliminar todos los antecedentes de un paciente
  Future<int> deleteAllHistoriesByPatient(int patientId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'medical_history',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  /// Contar antecedentes de un paciente
  Future<int> countHistoriesByPatient(int patientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM medical_history WHERE patient_id = ?',
      [patientId],
    );
    return result.first['count'] as int;
  }

  /// Obtener tipos de antecedentes únicos de un paciente
  Future<List<String>> getUniqueHistoryTypes(int patientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT type FROM medical_history WHERE patient_id = ? ORDER BY type',
      [patientId],
    );
    return result.map((row) => row['type'] as String).toList();
  }

  /// Obtener antecedentes recientes (últimos N días)
  Future<List<MedicalHistory>> getRecentHistories(
    int patientId,
    int days,
  ) async {
    final db = await _dbHelper.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final maps = await db.query(
      'medical_history',
      where: 'patient_id = ? AND registration_date >= ?',
      whereArgs: [patientId, cutoffDate.toIso8601String()],
      orderBy: 'registration_date DESC',
    );
    return maps.map((map) => MedicalHistory.fromMap(map)).toList();
  }

  /// Verificar contraindicaciones para vacunación
  Future<List<MedicalHistory>> getContraindicationsForVaccination(
    int patientId,
  ) async {
    final contraindicationTypes = [
      'ALERGIA',
      'REACCION_ADVERSA',
      'INMUNODEFICIENCIA',
      'EMBARAZO',
      'ENFERMEDAD_AGUDA',
    ];

    final db = await _dbHelper.database;
    final placeholders = List.filled(
      contraindicationTypes.length,
      '?',
    ).join(',');

    final maps = await db.query(
      'medical_history',
      where: 'patient_id = ? AND type IN ($placeholders)',
      whereArgs: [patientId, ...contraindicationTypes],
      orderBy: 'registration_date DESC',
    );
    return maps.map((map) => MedicalHistory.fromMap(map)).toList();
  }
}
