import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../theme/colors.dart';
import '../../models/patient_model.dart';
import '../../controllers/patient_form_controller.dart';
import '../vaccination_record/vaccination_form_wrapper.dart';
import '../../controllers/patient_history_controller.dart';

class PatientHistoryPage extends StatelessWidget {
  const PatientHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientHistoryController());

    return Scaffold(
      backgroundColor: backgroundMedium,
      body: Column(
        children: [
          // Barra de búsqueda
          Container(
            color: cardBackground,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o ID...',
                hintStyle: const TextStyle(color: textHint),
                prefixIcon: const Icon(Icons.search, color: textSecondary),
                filled: true,
                fillColor: inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: inputFocusBorder,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, color: textSecondary),
                      onPressed: () => controller.updateSearchQuery(''),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ),
              onChanged: (value) => controller.updateSearchQuery(value),
            ),
          ),

          const Divider(height: 1, color: borderColor),

          // Lista de pacientes
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                );
              }

              final filteredPatients = controller.filteredPatients;

              if (filteredPatients.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: backgroundLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Icon(
                            controller.searchQuery.value.isEmpty
                                ? Icons.people_outline
                                : Icons.search_off,
                            size: 64,
                            color: textSecondary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'No hay pacientes'
                              : 'No se encontraron pacientes',
                          style: const TextStyle(
                            fontSize: 18,
                            color: textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.searchQuery.value.isEmpty
                              ? 'Registra tu primer paciente'
                              : 'No se encontraron coincidencias',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  return _buildPatientCard(patient, context, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(
    Patient patient,
    BuildContext context,
    PatientHistoryController controller,
  ) {
    // Generar color para el avatar basado en el nombre
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Green
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFEF4444), // Red
    ];
    final colorIndex = patient.firstName.hashCode % colors.length;
    final avatarColor = colors[colorIndex.abs()];

    // Obtener iniciales
    final initials = '${patient.firstName[0]}${patient.lastName[0]}'
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar con iniciales
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: avatarColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: avatarColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Información del paciente
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre
                      Text(
                        '${patient.firstName} ${patient.secondName ?? ''} ${patient.lastName} ${patient.secondLastName ?? ''}'
                            .trim()
                            .replaceAll(RegExp(r'\s+'), ' '),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Documento
                      Text(
                        'ID: ${patient.idNumber}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menú de acciones
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: textSecondary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20, color: primaryColor),
                          const SizedBox(width: 12),
                          const Text('Editar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: Colors.red),
                          const SizedBox(width: 12),
                          const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        _editPatient(patient);
                        break;
                      case 'delete':
                        _confirmDelete(context, patient);
                        break;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: borderColor),
            const SizedBox(height: 12),

            // Fecha de atención y vacunas aplicadas
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Chip de fecha
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat(
                          'dd MMM yyyy',
                          'es',
                        ).format(patient.attentionDate),
                        style: const TextStyle(
                          fontSize: 12,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Chips de vacunas aplicadas
                ...?controller.patientVaccines[patient.id]?.map((vaccineName) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.vaccines,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          vaccineName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Navega al formulario de edición del paciente
  void _editPatient(Patient patient) {
    // Verificar si hay datos sin guardar
    if (Get.isRegistered<PatientFormController>()) {
      final currentFormController = Get.find<PatientFormController>();
      if (currentFormController.hasUnsavedData()) {
        // Mostrar diálogo de advertencia
        Get.dialog(
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 28,
                ),
                SizedBox(width: 12),
                Text('Datos sin guardar'),
              ],
            ),
            content: const Text(
              '¿Deseas descartar el registro actual y editar este paciente?\n\nSe perderán todos los datos no guardados.',
              style: TextStyle(fontSize: 15),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back(); // Cerrar diálogo
                  _proceedWithEdit(patient); // Continuar con edición
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Descartar y editar'),
              ),
            ],
          ),
        );
        return;
      }
    }

    // Si no hay datos sin guardar, proceder directamente
    _proceedWithEdit(patient);
  }

  void _proceedWithEdit(Patient patient) {
    // Obtener el controlador existente
    final formController = Get.find<PatientFormController>();

    // Cargar los datos del paciente EN MODO MODAL
    formController.loadPatientData(patient, isModal: true);

    // Abrir en modo edición como modal
    Get.to(() => const VaccinationFormWrapper(showPopScope: true))?.then((_) {
      // Recargar la lista al regresar
      final historyController = Get.find<PatientHistoryController>();
      historyController.loadPatients();
    });
  }

  /// Muestra diálogo de confirmación para eliminar paciente
  void _confirmDelete(BuildContext context, Patient patient) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text(
              'Confirmar eliminación',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Está seguro de eliminar este paciente?',
              style: TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Text(
                '"${patient.firstName} ${patient.lastName}"',
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta acción no se puede deshacer y eliminará todos los registros asociados.',
              style: TextStyle(color: textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'CANCELAR',
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Get.back();
              final controller = Get.find<PatientHistoryController>();
              controller.deletePatient(patient.id!);
            },
            child: const Text(
              'ELIMINAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
