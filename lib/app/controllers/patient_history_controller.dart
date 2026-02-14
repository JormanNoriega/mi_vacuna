import 'package:get/get.dart';
import '../models/patient_model.dart';
import '../services/patient_service.dart';
import '../services/applied_dose_service.dart';
import '../data/database_helper.dart';
import '../widgets/custom_snackbar.dart';

class PatientHistoryController extends GetxController {
  final PatientService _patientService = PatientService();
  final AppliedDoseService _appliedDoseService = AppliedDoseService();

  // Estado
  final isLoading = false.obs;
  final patients = <Patient>[].obs;
  final searchQuery = ''.obs;

  // Mapa de paciente ID -> lista de nombres de vacunas (UUID -> List<String>)
  final patientVaccines = <String, List<String>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadPatients();
  }

  /// Carga todos los pacientes ordenados por fecha de atención
  Future<void> loadPatients() async {
    try {
      isLoading.value = true;
      final result = await _patientService.getAllPatients();
      
      // Ordenar por attentionDate (más reciente primero)
      result.sort((a, b) => b.attentionDate.compareTo(a.attentionDate));
      
      patients.value = result;

      // Cargar vacunas para cada paciente
      for (var patient in result) {
        if (patient.id != null) {
          await _loadVaccinesForPatient(patient.id!);
        }
      }
    } catch (e) {
      print('Error cargando pacientes: $e');
      CustomSnackbar.showError('Error al cargar pacientes');
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga las vacunas aplicadas para un paciente específico
  Future<void> _loadVaccinesForPatient(String patientId) async {
    try {
      // Usar el mismo método que funciona en modo edición
      final doses = await _appliedDoseService.getDosesByPatient(patientId);

      print('📋 Dosis encontradas para paciente $patientId: ${doses.length}');

      // Obtener nombres únicos de vacunas de las dosis
      final vaccineIds = doses.map((dose) => dose.vaccineId).toSet();

      // Buscar los nombres de las vacunas
      final db = await DatabaseHelper.instance.database;
      if (vaccineIds.isEmpty) {
        patientVaccines[patientId] = [];
        return;
      }

      final vaccineNames = <String>[];
      for (var vaccineId in vaccineIds) {
        final result = await db.query(
          'vaccines',
          columns: ['name'],
          where: 'id = ?',
          whereArgs: [vaccineId],
          limit: 1,
        );
        if (result.isNotEmpty) {
          vaccineNames.add(result.first['name'] as String);
        }
      }

      print('💉 Vacunas únicas: $vaccineNames');
      patientVaccines[patientId] = vaccineNames;
    } catch (e) {
      print('❌ Error cargando vacunas para paciente $patientId: $e');
      patientVaccines[patientId] = [];
    }
  }

  /// Filtra pacientes por búsqueda
  List<Patient> get filteredPatients {
    if (searchQuery.value.isEmpty) {
      return patients;
    }

    final query = searchQuery.value.toLowerCase();
    return patients.where((patient) {
      final fullName =
          '${patient.firstName} ${patient.secondName ?? ''} ${patient.lastName} ${patient.secondLastName ?? ''}'
              .toLowerCase();
      final idNumber = patient.idNumber.toLowerCase();
      return fullName.contains(query) || idNumber.contains(query);
    }).toList();
  }

  /// Actualiza el término de búsqueda
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Refresca la lista de pacientes
  Future<void> refreshPatients() async {
    await loadPatients();
  }

  /// Elimina un paciente
  Future<void> deletePatient(String patientId) async {
    try {
      await _patientService.deletePatient(patientId);
      patients.removeWhere((p) => p.id == patientId);
      CustomSnackbar.showSuccess('Paciente eliminado correctamente');
    } catch (e) {
      print('Error eliminando paciente: $e');
      CustomSnackbar.showError('Error al eliminar paciente');
    }
  }
}
