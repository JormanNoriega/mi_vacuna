import '../data/database_helper.dart';
import '../models/applied_dose_model.dart';
import '../models/patient_model.dart';
import '../domain/vaccine_catalog.dart';
import '../domain/vaccine_config.dart';
import '../domain/vaccine_type.dart';
import '../domain/dose_config.dart';

/// Servicio para gestionar la aplicación de vacunas
class VaccineService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Aplicar una dosis de vacuna a un paciente
  Future<int> applyDose(AppliedDose dose) async {
    final db = await _dbHelper.database;
    return await db.insert('applied_doses', dose.toMap());
  }

  /// Obtener todas las dosis aplicadas a un paciente
  Future<List<AppliedDose>> getDosesByPatient(int patientId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'applied_doses',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'application_date DESC',
    );
    return maps.map((map) => AppliedDose.fromMap(map)).toList();
  }

  /// Obtener dosis de una vacuna específica para un paciente
  Future<List<AppliedDose>> getDosesByVaccineType(
    int patientId,
    VaccineType vaccineType,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'applied_doses',
      where: 'patient_id = ? AND vaccine_type = ?',
      whereArgs: [patientId, vaccineType.name],
      orderBy: 'application_date ASC',
    );
    return maps.map((map) => AppliedDose.fromMap(map)).toList();
  }

  /// Obtener la última dosis aplicada de una vacuna específica
  Future<AppliedDose?> getLastDoseByVaccine(
    int patientId,
    VaccineType vaccineType,
  ) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'applied_doses',
      where: 'patient_id = ? AND vaccine_type = ?',
      whereArgs: [patientId, vaccineType.name],
      orderBy: 'application_date DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return AppliedDose.fromMap(maps.first);
  }

  /// Verificar si se puede aplicar una dosis específica
  Future<bool> canApplyDose(
    Patient patient,
    VaccineType vaccineType,
    int doseNumber,
  ) async {
    final vaccineConfig = VaccineCatalog.getByType(vaccineType);
    if (vaccineConfig == null) return false;

    // Verificar que la dosis existe en la configuración
    if (doseNumber > vaccineConfig.totalDoses) return false;

    final doseConfig = vaccineConfig.doses.firstWhere(
      (d) => d.doseNumber == doseNumber,
      orElse: () => vaccineConfig.doses.first,
    );

    // Verificar edad del paciente
    final ageMonths = patient.ageMonths;
    if (ageMonths < doseConfig.ageMonthsMin) return false;
    if (doseConfig.ageMonthsMax != null &&
        ageMonths > doseConfig.ageMonthsMax!) {
      return false;
    }

    // Verificar que no esté duplicada
    final appliedDoses = await getDosesByVaccineType(patient.id!, vaccineType);
    if (appliedDoses.any((d) => d.doseNumber == doseNumber)) {
      return false;
    }

    // Verificar intervalo mínimo si es dosis subsecuente
    if (doseConfig.daysFromPrevious != null && doseNumber > 1) {
      final lastDose = await getLastDoseByVaccine(patient.id!, vaccineType);
      if (lastDose != null) {
        final daysSinceLastDose = DateTime.now()
            .difference(lastDose.applicationDate)
            .inDays;
        if (daysSinceLastDose < doseConfig.daysFromPrevious!) {
          return false;
        }
      } else {
        // Si requiere dosis previa y no existe, no se puede aplicar
        return false;
      }
    }

    return true;
  }

  /// Calcular fecha de próxima dosis
  Future<DateTime?> calculateNextDoseDate(
    int patientId,
    VaccineType vaccineType,
    int currentDoseNumber,
  ) async {
    final vaccineConfig = VaccineCatalog.getByType(vaccineType);
    if (vaccineConfig == null) return null;

    // Si es la última dosis, no hay siguiente
    if (currentDoseNumber >= vaccineConfig.totalDoses) return null;

    // Buscar la siguiente dosis en la configuración
    final nextDose = vaccineConfig.doses.firstWhere(
      (d) => d.doseNumber == currentDoseNumber + 1,
      orElse: () => vaccineConfig.doses.first,
    );

    if (nextDose.daysFromPrevious != null) {
      // Calcular desde la última aplicación
      return DateTime.now().add(Duration(days: nextDose.daysFromPrevious!));
    }

    return null;
  }

  /// Obtener vacunas disponibles para un paciente según su edad
  Future<List<VaccineConfig>> getAvailableVaccines(Patient patient) async {
    final ageMonths = patient.ageMonths;
    return VaccineCatalog.getByAgeMonths(ageMonths);
  }

  /// Obtener dosis pendientes para un paciente
  Future<Map<VaccineType, List<DoseConfig>>> getPendingDoses(
    Patient patient,
  ) async {
    final availableVaccines = await getAvailableVaccines(patient);
    final pendingDoses = <VaccineType, List<DoseConfig>>{};

    for (final vaccine in availableVaccines) {
      final appliedDoses = await getDosesByVaccineType(
        patient.id!,
        vaccine.type,
      );
      final appliedDoseNumbers = appliedDoses.map((d) => d.doseNumber).toSet();

      final pending = vaccine.doses.where((dose) {
        // Verificar si no está aplicada
        if (appliedDoseNumbers.contains(dose.doseNumber)) return false;

        // Verificar edad
        final ageMonths = patient.ageMonths;
        if (ageMonths < dose.ageMonthsMin) return false;
        if (dose.ageMonthsMax != null && ageMonths > dose.ageMonthsMax!) {
          return false;
        }

        return true;
      }).toList();

      if (pending.isNotEmpty) {
        pendingDoses[vaccine.type] = pending;
      }
    }

    return pendingDoses;
  }

  /// Calcular porcentaje de completitud del esquema de vacunación
  Future<double> getVaccinationCompletionPercentage(int patientId) async {
    final appliedDoses = await getDosesByPatient(patientId);

    // Total de dosis del PAI (aproximado para menores de 5 años)
    // Este número puede ajustarse según las políticas del PAI
    const totalExpectedDoses = 25;

    if (appliedDoses.isEmpty) return 0.0;

    final percentage = (appliedDoses.length / totalExpectedDoses) * 100;
    return percentage > 100 ? 100.0 : percentage;
  }

  /// Obtener conteo de dosis por vacuna para un paciente
  Future<Map<VaccineType, int>> getVaccineCountByPatient(int patientId) async {
    final doses = await getDosesByPatient(patientId);
    final counts = <VaccineType, int>{};

    for (final dose in doses) {
      counts[dose.vaccineType] = (counts[dose.vaccineType] ?? 0) + 1;
    }

    return counts;
  }

  /// Actualizar dosis aplicada
  Future<int> updateDose(AppliedDose dose) async {
    final db = await _dbHelper.database;
    return await db.update(
      'applied_doses',
      dose.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [dose.id],
    );
  }

  /// Eliminar dosis aplicada
  Future<int> deleteDose(int doseId) async {
    final db = await _dbHelper.database;
    return await db.delete(
      'applied_doses',
      where: 'id = ?',
      whereArgs: [doseId],
    );
  }

  /// Obtener dosis aplicadas por una enfermera
  Future<List<AppliedDose>> getDosesByNurse(int nurseId) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'applied_doses',
      where: 'nurse_id = ?',
      whereArgs: [nurseId],
      orderBy: 'application_date DESC',
    );
    return maps.map((map) => AppliedDose.fromMap(map)).toList();
  }

  /// Contar dosis aplicadas totales
  Future<int> countAppliedDoses() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM applied_doses',
    );
    return result.first['count'] as int;
  }

  /// Buscar dosis por número de lote (para trazabilidad)
  Future<List<AppliedDose>> getDosesByLotNumber(String lotNumber) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'applied_doses',
      where: 'lot_number = ?',
      whereArgs: [lotNumber],
      orderBy: 'application_date DESC',
    );
    return maps.map((map) => AppliedDose.fromMap(map)).toList();
  }
}
