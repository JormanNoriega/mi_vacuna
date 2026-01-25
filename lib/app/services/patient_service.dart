import '../data/database_helper.dart';
import '../models/patient_model.dart';

/// Servicio para operaciones CRUD de pacientes
class PatientService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Crear un nuevo paciente
  Future<int> createPatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.insert('patients', patient.toMap());
  }

  /// Obtener paciente por ID
  Future<Patient?> getPatientById(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('patients', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  /// Obtener paciente por número de identificación
  Future<Patient?> getPatientByIdNumber(String idNumber) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where: 'id_number = ?',
      whereArgs: [idNumber],
    );

    if (maps.isEmpty) return null;
    return Patient.fromMap(maps.first);
  }

  /// Verificar si existe un paciente con ese número de identificación
  Future<bool> idNumberExists(String idNumber) async {
    final patient = await getPatientByIdNumber(idNumber);
    return patient != null;
  }

  /// Obtener todos los pacientes
  Future<List<Patient>> getAllPatients() async {
    final db = await _dbHelper.database;
    final maps = await db.query('patients', orderBy: 'created_at DESC');
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Buscar pacientes por nombre
  Future<List<Patient>> searchPatientsByName(String searchTerm) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where:
          'first_name LIKE ? OR last_name LIKE ? OR second_name LIKE ? OR second_last_name LIKE ?',
      whereArgs: [
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
      ],
      orderBy: 'first_name ASC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Obtener pacientes por edad en meses (para filtrar vacunas aplicables)
  Future<List<Patient>> getPatientsByAgeRange(
    int minMonths,
    int? maxMonths,
  ) async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    // Calcular fechas de nacimiento correspondientes
    final maxBirthDate = DateTime(now.year, now.month - minMonths, now.day);
    final minBirthDate = maxMonths != null
        ? DateTime(now.year, now.month - maxMonths, now.day)
        : null;

    String whereClause = 'birth_date <= ?';
    List<dynamic> whereArgs = [maxBirthDate.toIso8601String()];

    if (minBirthDate != null) {
      whereClause += ' AND birth_date >= ?';
      whereArgs.add(minBirthDate.toIso8601String());
    }

    final maps = await db.query(
      'patients',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'birth_date DESC',
    );

    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Obtener pacientes con esquema incompleto
  Future<List<Patient>> getPatientsWithIncompleteScheme() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where: 'complete_scheme = ?',
      whereArgs: [0],
      orderBy: 'birth_date DESC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Actualizar paciente
  Future<int> updatePatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.update(
      'patients',
      patient.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  /// Eliminar paciente
  Future<int> deletePatient(int id) async {
    final db = await _dbHelper.database;
    // Los cuidadores y antecedentes se eliminan automáticamente por CASCADE
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  /// Obtener pacientes fallecidos
  Future<List<Patient>> getDeceasedPatients() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where: 'deceased = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Obtener pacientes por condición de usuaria
  Future<List<Patient>> getPatientsByUserCondition(
    CondicionUsuaria condition,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'patients',
      where: 'user_condition = ?',
      whereArgs: [condition.name],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Patient.fromMap(map)).toList();
  }

  /// Contar pacientes registrados
  Future<int> countPatients() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM patients');
    return result.first['count'] as int;
  }
}
