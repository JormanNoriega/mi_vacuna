import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/patient_model.dart';

/// Servicio para gestionar pacientes
///
/// Proporciona métodos CRUD completos:
/// - Crear, leer, actualizar y eliminar pacientes
/// - Búsquedas por documento, nombre, enfermera
/// - Consultas con información de dosis aplicadas
class PatientService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CRUD BÁSICO ====================

  /// Crea un nuevo paciente
  /// Retorna el ID del paciente creado
  Future<int> createPatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.insert('patients', patient.toMap());
  }

  /// Obtiene un paciente por su ID
  Future<Patient?> getPatientById(int id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Patient.fromMap(result.first);
  }

  /// Obtiene todos los pacientes
  Future<List<Patient>> getAllPatients({int? limit, int? offset}) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      orderBy: 'attention_date DESC, last_name ASC, first_name ASC',
      limit: limit,
      offset: offset,
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Actualiza un paciente existente
  /// Retorna el número de filas afectadas (1 si fue exitoso)
  Future<int> updatePatient(Patient patient) async {
    final db = await _dbHelper.database;
    return await db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  /// Elimina un paciente por su ID
  /// NOTA: Esto también eliminará todas las dosis aplicadas (CASCADE)
  Future<int> deletePatient(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== BÚSQUEDA ====================

  /// Busca un paciente por su número de documento
  Future<Patient?> getPatientByIdNumber(String idNumber) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'id_number = ?',
      whereArgs: [idNumber],
      limit: 1,
      orderBy: 'attention_date DESC',
    );

    if (result.isEmpty) return null;
    return Patient.fromMap(result.first);
  }

  /// Busca pacientes por nombre (búsqueda parcial en nombres y apellidos)
  Future<List<Patient>> searchPatients(String searchTerm) async {
    final db = await _dbHelper.database;
    final term = '%$searchTerm%';
    final result = await db.query(
      'patients',
      where: '''
        first_name LIKE ? OR 
        second_name LIKE ? OR 
        last_name LIKE ? OR 
        second_last_name LIKE ? OR
        id_number LIKE ?
      ''',
      whereArgs: [term, term, term, term, term],
      orderBy: 'last_name ASC, first_name ASC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Obtiene pacientes por enfermera
  Future<List<Patient>> getPatientsByNurse(int nurseId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'nurse_id = ?',
      whereArgs: [nurseId],
      orderBy: 'attention_date DESC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Busca pacientes por rango de fechas de atención
  Future<List<Patient>> getPatientsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'attention_date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'attention_date DESC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Busca pacientes por edad en meses (rango)
  Future<List<Patient>> getPatientsByAgeRange(
    int minMonths,
    int maxMonths,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'total_months BETWEEN ? AND ?',
      whereArgs: [minMonths, maxMonths],
      orderBy: 'total_months ASC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // ==================== FILTROS AVANZADOS ====================

  /// Filtra pacientes por múltiples criterios
  Future<List<Patient>> filterPatients({
    String? sex,
    String? affiliationRegime,
    String? ethnicity,
    bool? displaced,
    bool? disabled,
    bool? deceased,
    String? userCondition,
    int? nurseId,
  }) async {
    final db = await _dbHelper.database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (sex != null) {
      conditions.add('sex = ?');
      args.add(sex);
    }

    if (affiliationRegime != null) {
      conditions.add('affiliation_regime = ?');
      args.add(affiliationRegime);
    }

    if (ethnicity != null) {
      conditions.add('ethnicity = ?');
      args.add(ethnicity);
    }

    if (displaced != null) {
      conditions.add('displaced = ?');
      args.add(displaced ? 1 : 0);
    }

    if (disabled != null) {
      conditions.add('disabled = ?');
      args.add(disabled ? 1 : 0);
    }

    if (deceased != null) {
      conditions.add('deceased = ?');
      args.add(deceased ? 1 : 0);
    }

    if (userCondition != null) {
      conditions.add('user_condition = ?');
      args.add(userCondition);
    }

    if (nurseId != null) {
      conditions.add('nurse_id = ?');
      args.add(nurseId);
    }

    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');

    final result = await db.query(
      'patients',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'attention_date DESC',
    );

    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Obtiene pacientes con esquema completo
  Future<List<Patient>> getPatientsWithCompleteScheme() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'complete_scheme = ?',
      whereArgs: [1],
      orderBy: 'attention_date DESC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Obtiene pacientes con contraindicación de vacunación
  Future<List<Patient>> getPatientsWithContraindication() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'has_contraindication = ?',
      whereArgs: [1],
      orderBy: 'attention_date DESC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  /// Obtiene pacientes con reacciones previas a biológicos
  Future<List<Patient>> getPatientsWithPreviousReactions() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      where: 'has_previous_reaction = ?',
      whereArgs: [1],
      orderBy: 'attention_date DESC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // ==================== RELACIONES CON DOSIS ====================

  /// Obtiene un paciente con sus dosis aplicadas
  /// Retorna un Map con los datos del paciente y una lista de dosis
  Future<Map<String, dynamic>?> getPatientWithDoses(int patientId) async {
    final db = await _dbHelper.database;

    // Obtener paciente
    final patientResult = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (patientResult.isEmpty) return null;

    // Obtener dosis aplicadas con información de vacuna
    final dosesResult = await db.rawQuery(
      '''
      SELECT 
        ad.*,
        v.name as vaccine_name,
        v.code as vaccine_code,
        v.category as vaccine_category
      FROM applied_doses ad
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      WHERE ad.patient_id = ?
      ORDER BY ad.application_date DESC
    ''',
      [patientId],
    );

    return {
      'patient': Patient.fromMap(patientResult.first),
      'doses': dosesResult,
    };
  }

  /// Obtiene pacientes con el conteo de dosis aplicadas
  Future<List<Map<String, dynamic>>> getPatientsWithDoseCount({
    int? nurseId,
    int? limit,
  }) async {
    final db = await _dbHelper.database;

    String query = '''
      SELECT 
        p.*,
        COUNT(ad.id) as dose_count
      FROM patients p
      LEFT JOIN applied_doses ad ON p.id = ad.patient_id
    ''';

    List<dynamic> args = [];

    if (nurseId != null) {
      query += ' WHERE p.nurse_id = ?';
      args.add(nurseId);
    }

    query += '''
      GROUP BY p.id
      ORDER BY p.attention_date DESC
    ''';

    if (limit != null) {
      query += ' LIMIT ?';
      args.add(limit);
    }

    final result = await db.rawQuery(query, args.isEmpty ? null : args);

    return result.map((row) {
      final patient = Patient.fromMap(row);
      return {'patient': patient, 'dose_count': row['dose_count'] as int};
    }).toList();
  }

  // ==================== ESTADÍSTICAS ====================

  /// Cuenta el total de pacientes
  Future<int> countAllPatients() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM patients');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Cuenta pacientes por enfermera
  Future<int> countPatientsByNurse(int nurseId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM patients WHERE nurse_id = ?',
      [nurseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Obtiene estadísticas de pacientes por sexo
  Future<Map<String, int>> countBySex() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT sex, COUNT(*) as count 
      FROM patients 
      GROUP BY sex
    ''');

    return Map.fromEntries(
      result.map((row) => MapEntry(row['sex'] as String, row['count'] as int)),
    );
  }

  /// Obtiene estadísticas de pacientes por régimen de afiliación
  Future<Map<String, int>> countByAffiliationRegime() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT affiliation_regime, COUNT(*) as count 
      FROM patients 
      WHERE affiliation_regime IS NOT NULL
      GROUP BY affiliation_regime
    ''');

    return Map.fromEntries(
      result.map(
        (row) =>
            MapEntry(row['affiliation_regime'] as String, row['count'] as int),
      ),
    );
  }

  /// Obtiene el último paciente registrado
  Future<Patient?> getLastRegisteredPatient() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'patients',
      orderBy: 'created_at DESC',
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Patient.fromMap(result.first);
  }

  // ==================== VALIDACIONES ====================

  /// Verifica si existe un paciente con ese número de documento
  Future<bool> existsByIdNumber(String idNumber) async {
    final patient = await getPatientByIdNumber(idNumber);
    return patient != null;
  }

  /// Verifica si un paciente tiene dosis aplicadas
  Future<bool> hasDoses(int patientId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses WHERE patient_id = ?',
      [patientId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
