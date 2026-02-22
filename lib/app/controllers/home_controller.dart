import 'package:get/get.dart';
import '../services/patient_service.dart';
import '../services/applied_dose_service.dart';
import '../services/vaccine_service.dart';

class HomeController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppliedDoseService _doseService = AppliedDoseService();
  final VaccineService _vaccineService = VaccineService();

  // Estadísticas observables
  final patientsToday = 0.obs;
  final dosesToday = 0.obs;
  final totalVaccines = 0.obs;
  final isLoading = true.obs;

  // Últimos registros
  final recentDoses = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadStatistics();
  }

  @override
  void onReady() {
    super.onReady();
    loadStatistics();
  }

  /// Carga todas las estadísticas del dashboard
  Future<void> loadStatistics() async {
    try {
      isLoading.value = true;

      // Obtener fecha de hoy (inicio y fin del día)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Cargar estadísticas en paralelo
      final results = await Future.wait([
        _countPatientsToday(startOfDay, endOfDay),
        _countDosesToday(startOfDay, endOfDay),
        _vaccineService.getAllActiveVaccines(),
        _doseService.getDosesWithVaccineInfo(limit: 5),
      ]);

      patientsToday.value = results[0] as int;
      dosesToday.value = results[1] as int;
      totalVaccines.value = (results[2] as List).length;
      recentDoses.value = results[3] as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Cuenta pacientes únicos atendidos hoy (solo pacientes que existen en BD)
  Future<int> _countPatientsToday(DateTime start, DateTime end) async {
    try {
      final db = await _patientService.getAllPatients();
      final patientsToday = db.where((patient) {
        final date = patient.attentionDate;
        return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            date.isBefore(end.add(const Duration(seconds: 1)));
      }).length;
      return patientsToday;
    } catch (e) {
      print('Error counting patients today: $e');
      return 0;
    }
  }

  /// Cuenta dosis aplicadas hoy (solo dosis con pacientes válidos)
  Future<int> _countDosesToday(DateTime start, DateTime end) async {
    try {
      // Usar el mismo método que el export para consistencia
      return await _doseService.countDosesByDateRange(start, end);
    } catch (e) {
      print('Error counting doses today: $e');
      return 0;
    }
  }

  /// Refresca las estadísticas
  @override
  Future<void> refresh() async {
    await loadStatistics();
  }
}
