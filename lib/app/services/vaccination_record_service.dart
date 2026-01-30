import '../data/database_helper.dart';
import '../models/vaccination_record_model.dart';

class VaccinationRecordService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Crear registro de vacunación
  Future<VaccinationRecordModel> createRecord(
    VaccinationRecordModel record,
  ) async {
    final db = await _db.database;
    final id = await db.insert('vaccination_records', record.toMap());
    return record..id = id;
  }

  // Obtener registro por ID
  Future<VaccinationRecordModel?> getRecordById(int id) async {
    final db = await _db.database;
    final maps = await db.query(
      'vaccination_records',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return VaccinationRecordModel.fromMap(maps.first);
    }
    return null;
  }

  // Obtener registros por número de identificación del paciente
  Future<List<VaccinationRecordModel>> getRecordsByIdNumber(
    String numeroIdentificacion,
  ) async {
    final db = await _db.database;
    final result = await db.query(
      'vaccination_records',
      where: 'numeroIdentificacion = ?',
      whereArgs: [numeroIdentificacion],
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Obtener todos los registros
  Future<List<VaccinationRecordModel>> getAllRecords() async {
    final db = await _db.database;
    final result = await db.query(
      'vaccination_records',
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Obtener registros por enfermera
  Future<List<VaccinationRecordModel>> getRecordsByNurse(int nurseId) async {
    final db = await _db.database;
    final result = await db.query(
      'vaccination_records',
      where: 'nurseId = ?',
      whereArgs: [nurseId],
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Obtener registros por fecha
  Future<List<VaccinationRecordModel>> getRecordsByDate(DateTime fecha) async {
    final db = await _db.database;
    final fechaStr = fecha.toIso8601String().split('T')[0]; // Solo la fecha
    final result = await db.query(
      'vaccination_records',
      where: 'fechaAtencion LIKE ?',
      whereArgs: ['$fechaStr%'],
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Obtener registros por rango de fechas
  Future<List<VaccinationRecordModel>> getRecordsByDateRange(
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    final db = await _db.database;
    final result = await db.query(
      'vaccination_records',
      where: 'fechaAtencion BETWEEN ? AND ?',
      whereArgs: [fechaInicio.toIso8601String(), fechaFin.toIso8601String()],
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Buscar registros por nombre del paciente
  Future<List<VaccinationRecordModel>> searchByName(String nombre) async {
    final db = await _db.database;
    final result = await db.query(
      'vaccination_records',
      where: 'primerNombre LIKE ? OR primerApellido LIKE ?',
      whereArgs: ['%$nombre%', '%$nombre%'],
      orderBy: 'fechaAtencion DESC',
    );
    return result.map((map) => VaccinationRecordModel.fromMap(map)).toList();
  }

  // Actualizar registro
  Future<int> updateRecord(VaccinationRecordModel record) async {
    final db = await _db.database;
    record.updatedAt = DateTime.now();
    return db.update(
      'vaccination_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // Eliminar registro
  Future<int> deleteRecord(int id) async {
    final db = await _db.database;
    return await db.delete(
      'vaccination_records',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Contar registros totales
  Future<int> getTotalRecordsCount() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vaccination_records',
    );
    return result.first['count'] as int;
  }

  // Contar registros por enfermera
  Future<int> getRecordsCountByNurse(int nurseId) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM vaccination_records WHERE nurseId = ?',
      [nurseId],
    );
    return result.first['count'] as int;
  }

  // Obtener estadísticas por vacuna
  Future<Map<String, int>> getVaccineStatistics() async {
    final records = await getAllRecords();

    final Map<String, int> stats = {};

    for (var record in records) {
      if (record.covidDosis != null && record.covidDosis!.isNotEmpty) {
        stats['COVID-19'] = (stats['COVID-19'] ?? 0) + 1;
      }
      if (record.bcgDosis != null && record.bcgDosis!.isNotEmpty) {
        stats['BCG'] = (stats['BCG'] ?? 0) + 1;
      }
      if (record.hepatitisBDosis != null &&
          record.hepatitisBDosis!.isNotEmpty) {
        stats['Hepatitis B'] = (stats['Hepatitis B'] ?? 0) + 1;
      }
      if (record.influenzaDosis != null && record.influenzaDosis!.isNotEmpty) {
        stats['Influenza'] = (stats['Influenza'] ?? 0) + 1;
      }
      if (record.srptDosis != null && record.srptDosis!.isNotEmpty) {
        stats['Triple Viral'] = (stats['Triple Viral'] ?? 0) + 1;
      }
      // Agregar más vacunas según necesidad
    }

    return stats;
  }

  // Verificar si existe registro para un paciente
  Future<bool> hasRecords(String numeroIdentificacion) async {
    final records = await getRecordsByIdNumber(numeroIdentificacion);
    return records.isNotEmpty;
  }
}
