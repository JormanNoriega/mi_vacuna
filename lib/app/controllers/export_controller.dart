import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../services/export_service.dart';
import '../widgets/custom_snackbar.dart';

/// Controlador para la exportación de datos
class ExportController extends GetxController {
  final ExportService _exportService = ExportService();

  // Estado
  final isExporting = false.obs;
  final isLoadingStats = false.obs;

  // Fechas seleccionadas
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  // Estadísticas
  final totalPatients = 0.obs;
  final totalDoses = 0.obs;
  final totalVaccines = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Inicializar con el último mes
    final now = DateTime.now();
    endDate.value = now;
    startDate.value = DateTime(now.year, now.month - 1, now.day);
  }

  @override
  void onReady() {
    super.onReady();
    // Cargar estadísticas solo aquí, no en onInit
    updateStatistics();
  }

  /// Actualiza las estadísticas cuando cambian las fechas
  Future<void> updateStatistics() async {
    if (startDate.value == null || endDate.value == null) {
      return;
    }

    // Validar que la fecha de inicio no sea mayor que la fecha de fin
    if (startDate.value!.isAfter(endDate.value!)) {
      CustomSnackbar.showError(
        'La fecha de inicio no puede ser posterior a la fecha de fin',
      );
      return;
    }

    try {
      isLoadingStats.value = true;

      final stats = await _exportService.getReportStatistics(
        startDate: startDate.value!,
        endDate: endDate.value!,
      );

      totalPatients.value = stats['total_patients'] as int;
      totalDoses.value = stats['total_doses'] as int;
      totalVaccines.value = stats['total_vaccines'] as int;

      print('📊 Estadísticas actualizadas:');
      print('   Pacientes: ${totalPatients.value}');
      print('   Dosis: ${totalDoses.value}');
      print('   Vacunas: ${totalVaccines.value}');
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      CustomSnackbar.showError('Error al cargar estadísticas');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Exportar y compartir CSV
  Future<void> exportAndShare() async {
    if (startDate.value == null || endDate.value == null) {
      CustomSnackbar.showError('Selecciona un rango de fechas válido');
      return;
    }

    // Validar que la fecha de inicio no sea mayor que la fecha de fin
    if (startDate.value!.isAfter(endDate.value!)) {
      CustomSnackbar.showError(
        'La fecha de inicio no puede ser posterior a la fecha de fin',
      );
      return;
    }

    // Validar que haya datos para exportar
    if (totalDoses.value == 0) {
      CustomSnackbar.showError(
        'No hay datos para exportar en el rango seleccionado',
      );
      return;
    }

    try {
      isExporting.value = true;
      print('📤 Iniciando exportación...');

      // Generar CSV
      final file = await _exportService.generateVaccinationReport(
        startDate: startDate.value!,
        endDate: endDate.value!,
      );

      print('📂 Archivo generado: ${file.path}');

      // Compartir archivo
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte de vacunación - ${totalDoses.value} dosis aplicadas',
        subject: 'Registro de dosis aplicadas',
      );

      if (result.status == ShareResultStatus.success) {
        CustomSnackbar.showSuccess('Archivo compartido exitosamente');
      }

      print('✅ Exportación completada');
    } catch (e) {
      print('❌ Error al exportar: $e');
      CustomSnackbar.showError('No se pudo exportar: ${e.toString()}');
    } finally {
      isExporting.value = false;
    }
  }

  /// Actualiza la fecha de inicio
  void setStartDate(DateTime date) {
    startDate.value = date;
    updateStatistics();
  }

  /// Actualiza la fecha de fin
  void setEndDate(DateTime date) {
    endDate.value = date;
    updateStatistics();
  }
}
