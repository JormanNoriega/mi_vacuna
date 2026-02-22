import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
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
    
    // Escuchar cambios en las fechas
    ever(startDate, (_) => updateStatistics());
    ever(endDate, (_) => updateStatistics());
  }

  @override
  void onReady() {
    super.onReady();
    // Cargar estadísticas después de inicializar
    updateStatistics();
  }

  /// Valida que el rango de fechas sea coherente
  bool _isValidDateRange() {
    if (startDate.value == null || endDate.value == null) {
      CustomSnackbar.showError('Selecciona un rango de fechas válido');
      return false;
    }

    if (startDate.value!.isAfter(endDate.value!)) {
      CustomSnackbar.showError(
        'La fecha de inicio no puede ser posterior a la fecha de fin',
      );
      return false;
    }

    // Validar que no sea demasiado antiguo (más de 2 años)
    final twoyearsAgo = DateTime.now().subtract(const Duration(days: 730));
    if (startDate.value!.isBefore(twoyearsAgo)) {
      CustomSnackbar.showWarning(
        'La fecha de inicio es muy antigua. Se recomiendan rangos menores a 2 años',
      );
    }

    return true;
  }

  /// Actualiza las estadísticas cuando cambian las fechas
  Future<void> updateStatistics() async {
    if (!_isValidDateRange()) {
      // Resetear estadísticas si el rango no es válido
      totalPatients.value = 0;
      totalDoses.value = 0;
      totalVaccines.value = 0;
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
      totalPatients.value = 0;
      totalDoses.value = 0;
      totalVaccines.value = 0;
      CustomSnackbar.showError('Error al cargar estadísticas');
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Exportar y compartir Excel
  Future<void> exportAndShare() async {
    if (!_isValidDateRange()) {
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
      print('📤 Iniciando exportación a Excel...');

      // Generar Excel
      final file = await _exportService.generateVaccinationReport(
        startDate: startDate.value!,
        endDate: endDate.value!,
      );

      print('📂 Archivo generado: ${file.path}');

      // Compartir archivo
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Reporte de vacunación - ${totalDoses.value} dosis aplicadas del ${_formatDateRange()}',
        subject: 'Reporte de Vacunación - ${totalDoses.value} Dosis',
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
    // Validar que no sea una fecha futura
    if (date.isAfter(DateTime.now())) {
      CustomSnackbar.showError(
        'La fecha de inicio no puede ser posterior a hoy',
      );
      return;
    }

    // Validar que no sea superior a la fecha de fin si ya existe
    if (endDate.value != null && date.isAfter(endDate.value!)) {
      CustomSnackbar.showError(
        'La fecha de inicio no puede ser posterior a la fecha de fin',
      );
      return;
    }

    startDate.value = date;
    print('📅 Fecha de inicio establecida: ${DateFormat('dd/MM/yyyy').format(date)}');
  }

  /// Actualiza la fecha de fin
  void setEndDate(DateTime date) {
    // Validar que no sea una fecha futura
    if (date.isAfter(DateTime.now())) {
      CustomSnackbar.showError(
        'La fecha de fin no puede ser posterior a hoy',
      );
      return;
    }

    // Validar que no sea anterior a la fecha de inicio si ya existe
    if (startDate.value != null && date.isBefore(startDate.value!)) {
      CustomSnackbar.showError(
        'La fecha de fin no puede ser anterior a la fecha de inicio',
      );
      return;
    }

    endDate.value = date;
    print('📅 Fecha de fin establecida: ${DateFormat('dd/MM/yyyy').format(date)}');
  }

  /// Formatea el rango de fechas para mostrar
  String _formatDateRange() {
    if (startDate.value == null || endDate.value == null) {
      return 'Fecha no seleccionada';
    }
    
    final formatter = DateFormat('dd/MM/yyyy');
    return '${formatter.format(startDate.value!)} - ${formatter.format(endDate.value!)}';
  }
}
