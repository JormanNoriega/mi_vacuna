import 'package:get/get.dart';
import '../models/vaccine.dart';
import '../services/vaccine_service.dart';
import '../data/database_helper.dart';

class VaccineManagementController extends GetxController {
  final VaccineService _vaccineService = VaccineService();

  // Estado
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final searchQuery = ''.obs;

  // Listas
  final vaccines = <Vaccine>[].obs;
  final filteredVaccines = <Vaccine>[].obs;

  // Estadísticas
  final totalVaccinesCount = 0.obs;
  final vaccinesByCategory = <String, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadVaccines();

    // Listener para filtrado en tiempo real
    ever(searchQuery, (_) => _filterVaccines());
  }

  /// Carga todas las vacunas
  Future<void> loadVaccines() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      vaccines.value = await _vaccineService.getAllVaccines();
      filteredVaccines.value = vaccines;

      await _loadStatistics();
    } catch (e) {
      errorMessage.value = 'Error al cargar vacunas: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Carga estadísticas
  Future<void> _loadStatistics() async {
    try {
      totalVaccinesCount.value = await _vaccineService.countActiveVaccines();
      vaccinesByCategory.value = await _vaccineService.countByCategory();
    } catch (e) {
      print('Error cargando estadísticas: $e');
    }
  }

  /// Filtra vacunas por búsqueda
  void _filterVaccines() {
    if (searchQuery.value.isEmpty) {
      filteredVaccines.value = vaccines;
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredVaccines.value = vaccines.where((vaccine) {
      return vaccine.name.toLowerCase().contains(query) ||
          vaccine.code.toLowerCase().contains(query) ||
          vaccine.category.toLowerCase().contains(query);
    }).toList();
  }

  /// Refresca la lista
  Future<void> refresh() async {
    await loadVaccines();
  }

  /// Activa/desactiva una vacuna
  Future<bool> toggleVaccineStatus(Vaccine vaccine) async {
    try {
      final db = await DatabaseHelper.instance.database;
      final updatedVaccine = Vaccine(
        id: vaccine.id,
        name: vaccine.name,
        code: vaccine.code,
        category: vaccine.category,
        maxDoses: vaccine.maxDoses,
        minMonths: vaccine.minMonths,
        maxMonths: vaccine.maxMonths,
        hasLaboratory: vaccine.hasLaboratory,
        hasLot: vaccine.hasLot,
        hasSyringe: vaccine.hasSyringe,
        hasSyringeLot: vaccine.hasSyringeLot,
        hasDiluent: vaccine.hasDiluent,
        hasDropper: vaccine.hasDropper,
        hasPneumococcalType: vaccine.hasPneumococcalType,
        hasVialCount: vaccine.hasVialCount,
        hasObservation: vaccine.hasObservation,
        isActive: !vaccine.isActive,
        createdAt: vaccine.createdAt,
        updatedAt: DateTime.now(),
      );

      await db.update(
        'vaccines',
        updatedVaccine.toMap(),
        where: 'id = ?',
        whereArgs: [vaccine.id],
      );

      await refresh();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar el estado: $e');
      return false;
    }
  }

  /// Elimina una vacuna
  Future<bool> deleteVaccine(int vaccineId) async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Verificar si tiene dosis aplicadas
      final dosesCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM applied_doses WHERE vaccine_id = ?',
        [vaccineId],
      );

      final count = dosesCount.first['count'] as int;
      if (count > 0) {
        Get.snackbar(
          'No se puede eliminar',
          'Esta vacuna tiene $count dosis aplicadas registradas',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }

      await db.delete('vaccines', where: 'id = ?', whereArgs: [vaccineId]);
      await refresh();
      return true;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo eliminar: $e');
      return false;
    }
  }

  /// Limpia filtros
  void clearFilters() {
    searchQuery.value = '';
  }
}
