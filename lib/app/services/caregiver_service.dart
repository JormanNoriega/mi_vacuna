import '../data/database_helper.dart';
import '../models/caregiver_model.dart';

/// Servicio para operaciones CRUD de cuidadores
class CaregiverService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crear un nuevo cuidador
  Future<int> createCaregiver(Caregiver caregiver) async {
    final db = await _dbHelper.database;
    return await db.insert('caregivers', caregiver.toMap());
  }

  /// Obtener cuidador por ID
  Future<Caregiver?> getCaregiverById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('caregivers', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Caregiver.fromMap(maps.first);
  }

  /// Obtener todos los cuidadores de un paciente
  Future<List<Caregiver>> getCaregiversByPatientId(int patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'caregivers',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'is_primary DESC, created_at ASC',
    );
    return maps.map((map) => Caregiver.fromMap(map)).toList();
  }

  /// Obtener el cuidador principal de un paciente
  Future<Caregiver?> getPrimaryCaregiver(int patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'caregivers',
      where: 'patient_id = ? AND is_primary = ?',
      whereArgs: [patientId, 1],
    );

    if (maps.isEmpty) return null;
    return Caregiver.fromMap(maps.first);
  }

  /// Establecer un cuidador como principal (y quitar el flag de los demás)
  Future<void> setPrimaryCaregiver(int caregiverId, int patientId) async {
    final db = await _dbHelper.database;

    // Primero, quitar el flag de todos los cuidadores de este paciente
    await db.update(
      'caregivers',
      {'is_primary': 0},
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    // Luego, establecer este como principal
    await db.update(
      'caregivers',
      {'is_primary': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [caregiverId],
    );
  }

  /// Obtener cuidadores por tipo
  Future<List<Caregiver>> getCaregiversByType(
    int patientId,
    CaregiverType type,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'caregivers',
      where: 'patient_id = ? AND caregiver_type = ?',
      whereArgs: [patientId, type.name],
      orderBy: 'created_at ASC',
    );
    return maps.map((map) => Caregiver.fromMap(map)).toList();
  }

  /// Verificar si un paciente tiene cuidador principal
  Future<bool> hasPrimaryCaregiver(int patientId) async {
    final primary = await getPrimaryCaregiver(patientId);
    return primary != null;
  }

  /// Actualizar cuidador
  Future<int> updateCaregiver(Caregiver caregiver) async {
    final db = await _dbHelper.database;
    return await db.update(
      'caregivers',
      caregiver.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [caregiver.id],
    );
  }

  /// Eliminar cuidador
  Future<int> deleteCaregiver(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('caregivers', where: 'id = ?', whereArgs: [id]);
  }

  /// Eliminar todos los cuidadores de un paciente
  Future<int> deleteAllCaregiversByPatientId(int patientId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'caregivers',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  /// Buscar cuidadores por nombre
  Future<List<Caregiver>> searchCaregiversByName(String searchTerm) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'caregivers',
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$searchTerm%', '%$searchTerm%'],
      orderBy: 'first_name ASC',
    );
    return maps.map((map) => Caregiver.fromMap(map)).toList();
  }

  /// Contar cuidadores de un paciente
  Future<int> countCaregiversByPatientId(int patientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM caregivers WHERE patient_id = ?',
      [patientId],
    );
    return result.first['count'] as int;
  }
}
