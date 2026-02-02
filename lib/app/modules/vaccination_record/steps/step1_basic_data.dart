import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../widgets/form_fields.dart';
import '../../../widgets/custom_snackbar.dart';
import '../../../theme/colors.dart';

class Step1BasicData extends StatefulWidget {
  const Step1BasicData({Key? key}) : super(key: key);

  @override
  State<Step1BasicData> createState() => _Step1BasicDataState();
}

class _Step1BasicDataState extends State<Step1BasicData> {
  String? _lastCheckedId;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientFormController>();

    return Container(
      color: backgroundMedium,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Header
              const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos Básicos del Paciente',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Complete la información básica del paciente.',
                      style: TextStyle(color: textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),

              // CARD ÚNICA CON TODO EL CONTENIDO
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Fecha de Atención
                    FormFields.buildReadOnlyDateField(
                      label: 'Fecha de Atención',
                      value: DateFormat(
                        'dd/MM/yyyy',
                      ).format(controller.attentionDate.value),
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),

                    // Tipo de Documento
                    Obx(
                      () => FormFields.buildDropdownField(
                        label: 'Tipo de Documento',
                        value: controller.selectedIdType.value,
                        items: const [
                          'CN - Certificado de Nacido Vivo',
                          'RC - Registro Civil',
                          'TI - Tarjeta de Identidad',
                          'CC - Cédula de Ciudadanía',
                          'AS - Adulto sin Identificación',
                          'MS - Menor sin Identificación',
                          'CE - Cédula de Extranjería',
                          'PA - Pasaporte',
                          'CD - Carné Diplomático',
                          'SC - Salvoconducto',
                          'PE - Permiso Especial de Permanencia',
                          'PPT - Permiso por Protección Temporal',
                          'DE - Documento Extranjero',
                        ],
                        onChanged: (value) =>
                            controller.selectedIdType.value = value!,
                        required: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Número de Identificación
                    Obx(
                      () => FormFields.buildTextField(
                        label: 'Número de Identificación',
                        controller: controller.idNumberController,
                        placeholder: 'Ej: 1020304050',
                        keyboardType: TextInputType.number,
                        required: true,
                        enabled: !controller
                            .isEditMode
                            .value, // Bloquear en modo edición
                        onChanged: (value) =>
                            _checkExistingPatient(value, controller),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Primer Nombre
                    FormFields.buildTextField(
                      label: 'Primer Nombre',
                      controller: controller.firstNameController,
                      placeholder: 'Ingrese el primer nombre',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Segundo Nombre
                    FormFields.buildTextField(
                      label: 'Segundo Nombre',
                      controller: controller.secondNameController,
                      placeholder: 'Ingrese el segundo nombre (opcional)',
                      required: false,
                    ),
                    const SizedBox(height: 16),

                    // Primer Apellido
                    FormFields.buildTextField(
                      label: 'Primer Apellido',
                      controller: controller.lastNameController,
                      placeholder: 'Ingrese el primer apellido',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Segundo Apellido
                    FormFields.buildTextField(
                      label: 'Segundo Apellido',
                      controller: controller.secondLastNameController,
                      placeholder: 'Ingrese el segundo apellido (opcional)',
                      required: false,
                    ),
                    const SizedBox(height: 16),

                    // Fecha de Nacimiento
                    Obx(
                      () => FormFields.buildDatePickerField(
                        label: 'Fecha de Nacimiento',
                        value: controller.birthDate.value,
                        icon: Icons.cake,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(
                              const Duration(days: 365 * 25),
                            ),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            controller.birthDate.value = date;
                          }
                        },
                      ),
                    ),

                    // Age Summary Card
                    Obx(() {
                      if (controller.birthDate.value == null)
                        return const SizedBox();
                      final age = controller.calculateAge();

                      return Column(
                        children: [
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.info,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'EDAD CALCULADA',
                                        style: TextStyle(
                                          color: primaryColor,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${age['years']} años, ${age['months']} meses, ${age['days']} días',
                                        style: const TextStyle(
                                          color: textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Total: ${age['totalMonths']} meses',
                                        style: const TextStyle(
                                          color: textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(height: 16),

                    // Esquema Completo
                    const Text(
                      '¿Esquema Completo? *',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildSchemeButton(
                              controller: controller,
                              label: 'Sí',
                              icon: Icons.check_circle,
                              value: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSchemeButton(
                              controller: controller,
                              label: 'No',
                              icon: Icons.cancel,
                              value: false,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Verifica si existe un paciente con el ID ingresado
  void _checkExistingPatient(
    String value,
    PatientFormController controller,
  ) async {
    print('🔍 Verificando ID: $value (Longitud: ${value.length})');

    // Solo verificar si el valor tiene al menos 4 dígitos y no está en modo edición
    if (value.length < 4) {
      print('❌ ID muy corto');
      return;
    }

    if (controller.isEditMode.value) {
      print('❌ Modo edición activo');
      return;
    }

    // Evitar verificar el mismo ID múltiples veces
    if (_lastCheckedId == value) {
      print('⏭️  ID ya verificado');
      return;
    }

    _lastCheckedId = value;
    print('🔎 Buscando paciente con ID: $value');

    // Buscar paciente
    final patient = await controller.findPatientByIdNumber(value);

    if (patient != null) {
      print('✅ Paciente encontrado: ${patient.firstName} ${patient.lastName}');
      if (mounted) {
        _showLoadPatientDialog(patient, controller);
      }
    } else {
      print('❌ Paciente no encontrado');
    }
  }

  /// Muestra diálogo para cargar datos del paciente existente
  void _showLoadPatientDialog(
    dynamic patient,
    PatientFormController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Paciente Encontrado',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ya existe un paciente registrado con este número de identificación:',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: backgroundMedium,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${patient.firstName} ${patient.lastName}',
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${patient.idType} • ${patient.idNumber}',
                    style: const TextStyle(color: textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Deseas cargar los datos de este paciente para editarlos?',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Solo resetear el flag para permitir nueva búsqueda
              _lastCheckedId = null;
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.loadPatientData(patient);
              CustomSnackbar.showSuccess(
                'Datos del paciente cargados correctamente',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sí, cargar datos',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSchemeButton({
    required PatientFormController controller,
    required String label,
    required IconData icon,
    required bool value,
  }) {
    final isSelected = controller.completeScheme.value == value;

    return InkWell(
      onTap: () => controller.completeScheme.value = value,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textSecondary,
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
