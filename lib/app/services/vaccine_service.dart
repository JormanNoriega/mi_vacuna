import 'package:sqflite/sqflite.dart';
import '../data/database_helper.dart';
import '../models/vaccine.dart';
import '../models/vaccine_config_option.dart';

/// Servicio para gestionar vacunas del catálogo
///
/// Proporciona métodos para:
/// - Consultar vacunas activas, por categoría y por rango de edad
/// - Obtener configuraciones dinámicas (dosis, laboratorios, jeringas, etc.)
/// - Validar disponibilidad de vacunas
class VaccineService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ==================== CONSULTAS DE VACUNAS ====================

  /// Obtiene todas las vacunas activas
  Future<List<Vaccine>> getAllActiveVaccines() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'name ASC',
    );
    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  /// Obtiene todas las vacunas (incluidas las inactivas)
  Future<List<Vaccine>> getAllVaccines() async {
    final db = await _dbHelper.database;
    final result = await db.query('vaccines', orderBy: 'name ASC');
    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  /// Obtiene vacunas por categoría
  ///
  /// Categorías disponibles:
  /// - "Programa Ampliado de Inmunización (PAI)"
  /// - "Especial"
  /// - "Programa Ampliado de Inmunización (PAI) - Especial"
  Future<List<Vaccine>> getVaccinesByCategory(String category) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: 'category = ? AND is_active = ?',
      whereArgs: [category, 1],
      orderBy: 'name ASC',
    );
    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  /// Obtiene vacunas aplicables para una edad específica (en meses)
  ///
  /// Devuelve solo vacunas que tengan rango de edad definido Y la edad esté dentro del rango
  Future<List<Vaccine>> getVaccinesForAge(int ageInMonths) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: '''
        is_active = 1 
        AND min_months IS NOT NULL 
        AND max_months IS NOT NULL
        AND ? BETWEEN min_months AND max_months
      ''',
      whereArgs: [ageInMonths],
      orderBy: 'min_months ASC, name ASC',
    );
    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  /// Obtiene vacunas que recomienden un rango de edad (sin ser obligatorio)
  Future<List<Vaccine>> getVaccinesRecommendedForAge(int ageInMonths) async {
    final allVaccines = await getAllActiveVaccines();
    return allVaccines.where((v) => v.isInRecommendedAge(ageInMonths)).toList();
  }

  /// Obtiene una vacuna por su ID
  Future<Vaccine?> getVaccineById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Vaccine.fromMap(result.first);
  }

  /// Obtiene una vacuna por su código único
  Future<Vaccine?> getVaccineByCode(String code) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: 'code = ?',
      whereArgs: [code],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return Vaccine.fromMap(result.first);
  }

  /// Verifica si existe una vacuna con un código específico
  Future<bool> existsByCode(String code) async {
    final vaccine = await getVaccineByCode(code);
    return vaccine != null;
  }

  // ==================== CONFIGURACIONES DINÁMICAS ====================

  /// Obtiene todas las opciones de configuración de una vacuna
  Future<List<VaccineConfigOption>> getOptions(
    String vaccineId, {
    ConfigFieldType? fieldType,
  }) async {
    final db = await _dbHelper.database;

    String where = 'vaccine_id = ? AND is_active = ?';
    List<dynamic> whereArgs = [vaccineId, 1];

    if (fieldType != null) {
      where += ' AND field_type = ?';
      whereArgs.add(fieldType.name);
    }

    final result = await db.query(
      'vaccine_config_options',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'sort_order ASC, display_name ASC',
    );

    return result.map((json) => VaccineConfigOption.fromMap(json)).toList();
  }

  /// Obtiene las dosis disponibles de una vacuna
  Future<List<VaccineConfigOption>> getDoses(String vaccineId) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.dose);
  }

  /// Obtiene los laboratorios disponibles de una vacuna
  Future<List<VaccineConfigOption>> getLaboratories(String vaccineId) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.laboratory);
  }

  /// Obtiene las jeringas disponibles de una vacuna
  Future<List<VaccineConfigOption>> getSyringes(String vaccineId) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.syringe);
  }

  /// Obtiene los goteros disponibles de una vacuna
  Future<List<VaccineConfigOption>> getDroppers(String vaccineId) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.dropper);
  }

  /// Obtiene los tipos de neumococo disponibles
  Future<List<VaccineConfigOption>> getPneumococcalTypes(
    String vaccineId,
  ) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.pneumococcalType);
  }

  /// Obtiene las observaciones predefinidas de una vacuna
  Future<List<VaccineConfigOption>> getObservations(String vaccineId) async {
    return getOptions(vaccineId, fieldType: ConfigFieldType.observation);
  }

  /// Obtiene la opción marcada como predeterminada para un campo específico
  Future<VaccineConfigOption?> getDefaultOption(
    String vaccineId,
    ConfigFieldType fieldType,
  ) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccine_config_options',
      where:
          'vaccine_id = ? AND field_type = ? AND is_default = ? AND is_active = ?',
      whereArgs: [vaccineId, fieldType.name, 1, 1],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return VaccineConfigOption.fromMap(result.first);
  }

  // ==================== BÚSQUEDA Y FILTRADO ====================

  /// Busca vacunas por nombre (búsqueda parcial, case-insensitive)
  Future<List<Vaccine>> searchByName(String searchTerm) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'vaccines',
      where: 'name LIKE ? AND is_active = ?',
      whereArgs: ['%$searchTerm%', 1],
      orderBy: 'name ASC',
    );
    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  /// Filtra vacunas por múltiples criterios
  Future<List<Vaccine>> filterVaccines({
    String? category,
    int? minAgeMonths,
    int? maxAgeMonths,
    bool? hasLaboratory,
    bool? hasSyringe,
    bool? onlyActive = true,
  }) async {
    final db = await _dbHelper.database;

    List<String> conditions = [];
    List<dynamic> args = [];

    if (onlyActive == true) {
      conditions.add('is_active = ?');
      args.add(1);
    }

    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }

    if (minAgeMonths != null) {
      conditions.add('(max_months IS NULL OR max_months >= ?)');
      args.add(minAgeMonths);
    }

    if (maxAgeMonths != null) {
      conditions.add('(min_months IS NULL OR min_months <= ?)');
      args.add(maxAgeMonths);
    }

    if (hasLaboratory != null) {
      conditions.add('has_laboratory = ?');
      args.add(hasLaboratory ? 1 : 0);
    }

    if (hasSyringe != null) {
      conditions.add('has_syringe = ?');
      args.add(hasSyringe ? 1 : 0);
    }

    final whereClause = conditions.isEmpty ? null : conditions.join(' AND ');

    final result = await db.query(
      'vaccines',
      where: whereClause,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );

    return result.map((json) => Vaccine.fromMap(json)).toList();
  }

  // ==================== ESTADÍSTICAS ====================

  /// Cuenta el total de vacunas activas
  Future<int> countActiveVaccines() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vaccines WHERE is_active = 1',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Cuenta vacunas por categoría
  Future<Map<String, int>> countByCategory() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM vaccines 
      WHERE is_active = 1
      GROUP BY category
    ''');

    return Map.fromEntries(
      result.map(
        (row) => MapEntry(row['category'] as String, row['count'] as int),
      ),
    );
  }

  // ==================== UTILIDADES ====================

  /// Obtiene una lista de todas las categorías únicas
  Future<List<String>> getAllCategories() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT DISTINCT category 
      FROM vaccines 
      WHERE is_active = 1 
      ORDER BY category
    ''');
    return result.map((row) => row['category'] as String).toList();
  }

  /// Verifica si una vacuna tiene configuraciones dinámicas
  Future<bool> hasConfigOptions(String vaccineId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vaccine_config_options WHERE vaccine_id = ? AND is_active = 1',
      [vaccineId],
    );
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }
}
