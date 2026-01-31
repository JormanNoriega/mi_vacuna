import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../controllers/vaccine_selection_controller.dart';
import '../../../theme/colors.dart';

class Step4Review extends StatelessWidget {
  const Step4Review({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientFormController>();
    final vaccineController = Get.find<VaccineSelectionController>();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Revisar y Confirmar',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Verifique la información antes de guardar.',
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Datos Básicos Section
            _buildSection(
              title: 'Datos Básicos',
              icon: Icons.person,
              children: [
                Obx(
                  () => _buildInfoRow(
                    'Tipo de Documento',
                    controller.selectedIdType.value,
                  ),
                ),
                _buildInfoRow(
                  'Número de Identificación',
                  controller.idNumberController.text,
                ),
                _buildInfoRow(
                  'Nombre Completo',
                  '${controller.firstNameController.text} ${controller.secondNameController.text} ${controller.lastNameController.text} ${controller.secondLastNameController.text}'
                      .trim()
                      .replaceAll(RegExp(r'\s+'), ' '),
                ),
                Obx(
                  () => _buildInfoRow(
                    'Fecha de Nacimiento',
                    controller.birthDate.value != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(controller.birthDate.value!)
                        : 'No especificada',
                  ),
                ),
                Obx(() {
                  if (controller.birthDate.value == null) {
                    return const SizedBox();
                  }
                  final age = controller.calculateAge();
                  return _buildInfoRow(
                    'Edad',
                    '${age['years']} años, ${age['months']} meses, ${age['days']} días',
                  );
                }),
                Obx(
                  () => _buildInfoRow(
                    'Esquema Completo',
                    controller.completeScheme.value ? 'Sí' : 'No',
                  ),
                ),
              ],
            ),

            // Datos Adicionales Section
            _buildSection(
              title: 'Datos Adicionales',
              icon: Icons.info_outline,
              children: [
                Obx(
                  () => _buildInfoRow(
                    'Sexo',
                    controller.selectedSex.value.name.toUpperCase(),
                  ),
                ),
                _buildInfoRow(
                  'País de Nacimiento',
                  controller.birthCountryController.text.isEmpty
                      ? 'No especificado'
                      : controller.birthCountryController.text,
                ),
                _buildInfoRow(
                  'Lugar de Nacimiento',
                  controller.birthPlaceController.text.isEmpty
                      ? 'No especificado'
                      : controller.birthPlaceController.text,
                ),
                _buildInfoRow(
                  'Departamento',
                  controller.residenceDepartmentController.text.isEmpty
                      ? 'No especificado'
                      : controller.residenceDepartmentController.text,
                ),
                _buildInfoRow(
                  'Municipio',
                  controller.residenceMunicipalityController.text.isEmpty
                      ? 'No especificado'
                      : controller.residenceMunicipalityController.text,
                ),
                _buildInfoRow(
                  'Dirección',
                  controller.addressController.text.isEmpty
                      ? 'No especificada'
                      : controller.addressController.text,
                ),
                _buildInfoRow(
                  'Teléfono',
                  controller.landlineController.text.isEmpty
                      ? 'No especificado'
                      : controller.landlineController.text,
                ),
                _buildInfoRow(
                  'Celular',
                  controller.cellphoneController.text.isEmpty
                      ? 'No especificado'
                      : controller.cellphoneController.text,
                ),
                _buildInfoRow(
                  'Email',
                  controller.emailController.text.isEmpty
                      ? 'No especificado'
                      : controller.emailController.text,
                ),
              ],
            ),

            // Vacunas Registradas
            _buildVaccinesSection(vaccineController),

            const SizedBox(height: 16),

            // Warning Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Verifique que todos los datos sean correctos antes de guardar.',
                      style: TextStyle(color: textPrimary, fontSize: 13),
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

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinesSection(VaccineSelectionController vaccineController) {
    if (vaccineController.selectedVaccines.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: textSecondary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No se registraron vacunas',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return _buildSection(
      title:
          'Vacunas Registradas (${vaccineController.selectedVaccines.length})',
      icon: Icons.vaccines,
      children: vaccineController.selectedVaccines.entries.map((entry) {
        final vaccineId = entry.key;
        final data = entry.value;
        final vaccine = vaccineController.availableVaccines.firstWhereOrNull(
          (v) => v.id == vaccineId,
        );

        if (vaccine == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: primaryColor.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre de la vacuna
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        vaccine.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vaccine.name,
                      style: const TextStyle(
                        color: textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: borderColor),
              const SizedBox(height: 8),

              // Información de la vacuna
              _buildVaccineDetail(
                'Dosis',
                vaccineController.getSelectedDose(vaccineId) ??
                    'No especificada',
              ),
              _buildVaccineDetail(
                'Fecha de Aplicación',
                data.applicationDate != null
                    ? DateFormat('dd/MM/yyyy').format(data.applicationDate!)
                    : 'No especificada',
              ),
              if (vaccine.hasLaboratory)
                _buildVaccineDetail(
                  'Laboratorio',
                  vaccineController.getSelectedLaboratory(vaccineId) ??
                      'No especificado',
                ),
              if (data.lotController.text.isNotEmpty)
                _buildVaccineDetail('Lote', data.lotController.text),
              if (vaccine.hasSyringe)
                _buildVaccineDetail(
                  'Jeringa',
                  vaccineController.getSelectedSyringe(vaccineId) ??
                      'No especificada',
                ),
              if (vaccine.hasSyringeLot &&
                  data.syringeLotController.text.isNotEmpty)
                _buildVaccineDetail(
                  'Lote Jeringa',
                  data.syringeLotController.text,
                ),
              if (vaccine.hasDiluent && data.diluentController.text.isNotEmpty)
                _buildVaccineDetail('Diluyente', data.diluentController.text),
              if (vaccine.hasDropper)
                _buildVaccineDetail(
                  'Gotero',
                  vaccineController.getSelectedDropper(vaccineId) ??
                      'No especificado',
                ),
              if (vaccine.hasPneumococcalType)
                _buildVaccineDetail(
                  'Tipo Neumococo',
                  vaccineController.getSelectedPneumococcalType(vaccineId) ??
                      'No especificado',
                ),
              if (vaccine.hasVialCount &&
                  data.vialCountController.text.isNotEmpty)
                _buildVaccineDetail(
                  'Cant. Frascos',
                  data.vialCountController.text,
                ),
              if (vaccine.hasObservation)
                _buildVaccineDetail(
                  'Observaciones',
                  vaccineController.getSelectedObservation(vaccineId) ??
                      'No especificadas',
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVaccineDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: textSecondary.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
