import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/export_controller.dart';
import '../../theme/colors.dart';
import '../../widgets/stat_card.dart';

/// Página para exportar registros de vacunación
class ExportPage extends StatelessWidget {
  const ExportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExportController());

    // Cargar estadísticas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.updateStatistics();
    });

    return Scaffold(
      backgroundColor: backgroundMedium,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Exportar Registros',
          style: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Información
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Exporta los registros de vacunación en formato CSV para análisis o respaldo',
                      style: TextStyle(color: textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Selección de rango de fechas
            Text(
              'Rango de Fechas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Fecha inicio
            _buildDateField(
              label: 'Fecha de inicio',
              date: controller.startDate,
              onTap: () => _selectDate(context, controller, true),
            ),
            const SizedBox(height: 12),

            // Fecha fin
            _buildDateField(
              label: 'Fecha de fin',
              date: controller.endDate,
              onTap: () => _selectDate(context, controller, false),
            ),
            const SizedBox(height: 24),

            // Estadísticas
            Obx(() {
              if (controller.isLoadingStats.value) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                );
              }

              final startDateStr = controller.startDate.value != null
                  ? DateFormat('dd/MM/yyyy').format(controller.startDate.value!)
                  : 'No seleccionada';
              final endDateStr = controller.endDate.value != null
                  ? DateFormat('dd/MM/yyyy').format(controller.endDate.value!)
                  : 'No seleccionada';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$startDateStr - $endDateStr',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  StatCard(
                    title: 'PACIENTES EN EL RANGO',
                    value: controller.totalPatients.value.toString(),
                    icon: Icons.people,
                    iconColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    title: 'DOSIS APLICADAS',
                    value: controller.totalDoses.value.toString(),
                    icon: Icons.vaccines,
                    iconColor: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 12),
                  StatCard(
                    title: 'TIPOS DE VACUNAS USADAS',
                    value: controller.totalVaccines.value.toString(),
                    icon: Icons.medical_services,
                    iconColor: const Color(0xFFFF9800),
                  ),
                ],
              );
            }),
            const SizedBox(height: 24),

            // Botón exportar
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    controller.isExporting.value ||
                        controller.totalDoses.value == 0
                    ? null
                    : () => controller.exportAndShare(),
                icon: controller.isExporting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.ios_share, size: 20),
                label: Text(
                  controller.isExporting.value
                      ? 'Exportando...'
                      : 'Exportar y Compartir CSV',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.help_outline, size: 18, color: textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El archivo se generará en formato CSV compatible con Excel y otras aplicaciones',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required Rx<DateTime?> date,
    required VoidCallback onTap,
  }) {
    return Obx(
      () => InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date.value != null
                        ? DateFormat('dd/MM/yyyy').format(date.value!)
                        : 'Seleccionar',
                    style: const TextStyle(
                      color: textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.calendar_today, color: primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    ExportController controller,
    bool isStartDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (controller.startDate.value ?? DateTime.now())
          : (controller.endDate.value ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              surface: cardBackground,
              onSurface: textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStartDate) {
        controller.setStartDate(picked);
      } else {
        controller.setEndDate(picked);
      }
    }
  }
}
