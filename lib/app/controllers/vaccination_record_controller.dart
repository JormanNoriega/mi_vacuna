import 'package:get/get.dart';
import '../models/vaccination_record_model.dart';
import '../services/vaccination_record_service.dart';
import 'auth_controller.dart';

class VaccinationRecordController extends GetxController {
  final VaccinationRecordService _recordService = VaccinationRecordService();
  final AuthController _authController = Get.find<AuthController>();

  // Estado reactivo
  final RxList<VaccinationRecordModel> allRecords =
      <VaccinationRecordModel>[].obs;
  final RxList<VaccinationRecordModel> filteredRecords =
      <VaccinationRecordModel>[].obs;
  final Rx<VaccinationRecordModel?> currentRecord = Rx<VaccinationRecordModel?>(
    null,
  );

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  // Filtros
  final RxString searchQuery = ''.obs;
  final Rx<DateTime?> filterStartDate = Rx<DateTime?>(null);
  final Rx<DateTime?> filterEndDate = Rx<DateTime?>(null);
  final RxBool showOnlyMyRecords = false.obs;

  // Estadísticas
  final RxMap<String, int> vaccineStats = <String, int>{}.obs;
  final RxInt totalRecordsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // No cargar datos automáticamente - se cargará cuando se navegue a la página de registros

    // Escuchar cambios en la búsqueda
    debounce(
      searchQuery,
      (_) => applyFilters(),
      time: const Duration(milliseconds: 500),
    );
  }

  // ==================== CRUD ====================

  /// Cargar todos los registros
  Future<void> loadAllRecords() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      allRecords.value = await _recordService.getAllRecords();
      filteredRecords.value = allRecords;
      totalRecordsCount.value = allRecords.length;

      await loadStatistics();
    } catch (e) {
      errorMessage.value = 'Error al cargar registros: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Crear nuevo registro
  Future<bool> createRecord(VaccinationRecordModel record) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      // Asignar el ID de la enfermera actual
      if (_authController.currentNurse.value != null) {
        record.nurseId = _authController.currentNurse.value!.id;
      }

      final createdRecord = await _recordService.createRecord(record);

      // Actualizar listas
      allRecords.insert(0, createdRecord);
      await applyFilters();

      totalRecordsCount.value++;
      successMessage.value = 'Registro creado exitosamente';

      return true;
    } catch (e) {
      errorMessage.value = 'Error al crear registro: ${e.toString()}';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Actualizar registro existente
  Future<bool> updateRecord(VaccinationRecordModel record) async {
    try {
      isSaving.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      await _recordService.updateRecord(record);

      // Actualizar en la lista
      final index = allRecords.indexWhere((r) => r.id == record.id);
      if (index != -1) {
        allRecords[index] = record;
      }

      await applyFilters();
      successMessage.value = 'Registro actualizado exitosamente';

      return true;
    } catch (e) {
      errorMessage.value = 'Error al actualizar registro: ${e.toString()}';
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  /// Eliminar registro
  Future<bool> deleteRecord(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _recordService.deleteRecord(id);

      allRecords.removeWhere((r) => r.id == id);
      await applyFilters();

      totalRecordsCount.value--;
      successMessage.value = 'Registro eliminado exitosamente';

      return true;
    } catch (e) {
      errorMessage.value = 'Error al eliminar registro: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Obtener registro por ID
  Future<VaccinationRecordModel?> getRecordById(int id) async {
    try {
      isLoading.value = true;
      currentRecord.value = await _recordService.getRecordById(id);
      return currentRecord.value;
    } catch (e) {
      errorMessage.value = 'Error al obtener registro: ${e.toString()}';
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== BÚSQUEDA Y FILTROS ====================

  /// Buscar registros por número de identificación
  Future<List<VaccinationRecordModel>> searchByIdNumber(String idNumber) async {
    try {
      isLoading.value = true;
      return await _recordService.getRecordsByIdNumber(idNumber);
    } catch (e) {
      errorMessage.value = 'Error en la búsqueda: ${e.toString()}';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Buscar por nombre
  Future<void> searchByName(String name) async {
    searchQuery.value = name;
  }

  /// Aplicar todos los filtros activos
  Future<void> applyFilters() async {
    List<VaccinationRecordModel> results = List.from(allRecords);

    // Filtro por enfermera (solo mis registros)
    if (showOnlyMyRecords.value && _authController.currentNurse.value != null) {
      final nurseId = _authController.currentNurse.value!.id;
      results = results.where((r) => r.nurseId == nurseId).toList();
    }

    // Filtro por búsqueda (nombre o ID)
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      results = results.where((r) {
        final fullName = r.nombreCompleto.toLowerCase();
        final idNumber = r.numeroIdentificacion.toLowerCase();
        return fullName.contains(query) || idNumber.contains(query);
      }).toList();
    }

    // Filtro por rango de fechas
    if (filterStartDate.value != null && filterEndDate.value != null) {
      results = results.where((r) {
        if (r.fechaAtencion == null) return false;
        return r.fechaAtencion!.isAfter(filterStartDate.value!) &&
            r.fechaAtencion!.isBefore(
              filterEndDate.value!.add(const Duration(days: 1)),
            );
      }).toList();
    }

    filteredRecords.value = results;
  }

  /// Establecer filtro de fechas
  void setDateFilter(DateTime? startDate, DateTime? endDate) {
    filterStartDate.value = startDate;
    filterEndDate.value = endDate;
    applyFilters();
  }

  /// Limpiar todos los filtros
  void clearFilters() {
    searchQuery.value = '';
    filterStartDate.value = null;
    filterEndDate.value = null;
    showOnlyMyRecords.value = false;
    filteredRecords.value = allRecords;
  }

  /// Alternar filtro "Solo mis registros"
  void toggleMyRecordsFilter() {
    showOnlyMyRecords.value = !showOnlyMyRecords.value;
    applyFilters();
  }

  // ==================== ESTADÍSTICAS ====================

  /// Cargar estadísticas de vacunación
  Future<void> loadStatistics() async {
    try {
      vaccineStats.value = await _recordService.getVaccineStatistics();
    } catch (e) {
      errorMessage.value = 'Error al cargar estadísticas: ${e.toString()}';
    }
  }

  /// Obtener conteo de registros por enfermera actual
  Future<int> getMyRecordsCount() async {
    if (_authController.currentNurse.value == null) return 0;

    try {
      return await _recordService.getRecordsCountByNurse(
        _authController.currentNurse.value!.id!,
      );
    } catch (e) {
      return 0;
    }
  }

  /// Obtener registros de hoy
  Future<List<VaccinationRecordModel>> getTodayRecords() async {
    try {
      return await _recordService.getRecordsByDate(DateTime.now());
    } catch (e) {
      errorMessage.value = 'Error al obtener registros de hoy: ${e.toString()}';
      return [];
    }
  }

  /// Obtener registros de esta semana
  Future<List<VaccinationRecordModel>> getWeekRecords() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      return await _recordService.getRecordsByDateRange(startOfWeek, endOfWeek);
    } catch (e) {
      errorMessage.value =
          'Error al obtener registros de la semana: ${e.toString()}';
      return [];
    }
  }

  /// Obtener registros de este mes
  Future<List<VaccinationRecordModel>> getMonthRecords() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      return await _recordService.getRecordsByDateRange(
        startOfMonth,
        endOfMonth,
      );
    } catch (e) {
      errorMessage.value =
          'Error al obtener registros del mes: ${e.toString()}';
      return [];
    }
  }

  // ==================== VALIDACIÓN ====================

  /// Validar datos básicos del paciente
  String? validateBasicData({
    required String tipoIdentificacion,
    required String numeroIdentificacion,
    required String primerNombre,
    required String primerApellido,
    required DateTime? fechaNacimiento,
    required String sexo,
    required String paisNacimiento,
  }) {
    if (tipoIdentificacion.isEmpty) {
      return 'Debe seleccionar un tipo de identificación';
    }
    if (numeroIdentificacion.isEmpty) {
      return 'El número de identificación es obligatorio';
    }
    if (primerNombre.isEmpty) {
      return 'El primer nombre es obligatorio';
    }
    if (primerApellido.isEmpty) {
      return 'El primer apellido es obligatorio';
    }
    if (fechaNacimiento == null) {
      return 'La fecha de nacimiento es obligatoria';
    }
    if (sexo.isEmpty) {
      return 'Debe seleccionar el sexo';
    }
    if (paisNacimiento.isEmpty) {
      return 'El país de nacimiento es obligatorio';
    }
    return null;
  }

  /// Calcular edad en años, meses y días
  Map<String, int> calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months--;
      days += DateTime(now.year, now.month, 0).day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final totalMonths = (years * 12) + months;

    return {
      'anos': years,
      'meses': months,
      'dias': days,
      'totalMeses': totalMonths,
    };
  }

  // ==================== UTILIDADES ====================

  /// Limpiar mensajes
  void clearMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  /// Establecer registro actual para edición
  void setCurrentRecord(VaccinationRecordModel? record) {
    currentRecord.value = record;
  }

  /// Verificar si existe historial para un paciente
  Future<bool> hasPatientHistory(String numeroIdentificacion) async {
    try {
      return await _recordService.hasRecords(numeroIdentificacion);
    } catch (e) {
      return false;
    }
  }

  /// Obtener historial completo de un paciente
  Future<List<VaccinationRecordModel>> getPatientHistory(
    String numeroIdentificacion,
  ) async {
    try {
      isLoading.value = true;
      return await _recordService.getRecordsByIdNumber(numeroIdentificacion);
    } catch (e) {
      errorMessage.value = 'Error al obtener historial: ${e.toString()}';
      return [];
    } finally {
      isLoading.value = false;
    }
  }

  /// Refrescar datos
  Future<void> refresh() async {
    await loadAllRecords();
    await loadStatistics();
  }
}
