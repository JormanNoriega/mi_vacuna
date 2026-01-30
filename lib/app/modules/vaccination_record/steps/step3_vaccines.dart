import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../widgets/form_fields.dart';

class Step3Vaccines extends StatelessWidget {
  const Step3Vaccines({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PatientFormController>();

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
                    'Información de Vacunas',
                    style: TextStyle(
                      color: Color(0xFF111318),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Registre las vacunas administradas.',
                    style: TextStyle(color: Color(0xFF616F89), fontSize: 14),
                  ),
                ],
              ),
            ),

            // Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF135BEC).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF135BEC),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Complete solo la información de las vacunas que desea registrar. Los campos vacíos se guardarán como no aplicables.',
                      style: TextStyle(color: Color(0xFF616F89), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineSection({
    required IconData icon,
    required String title,
    required TextEditingController dosis,
    required TextEditingController laboratorio,
    required TextEditingController lote,
    required TextEditingController jeringa,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBDFE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF135BEC).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF135BEC), size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF111318),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fields
          FormFields.buildTextField(
            label: 'Dosis',
            controller: dosis,
            placeholder: 'Ej: Primera',
            required: false,
          ),
          const SizedBox(height: 8),
          FormFields.buildTextField(
            label: 'Laboratorio',
            controller: laboratorio,
            placeholder: 'Ej: Pfizer',
            required: false,
          ),
          const SizedBox(height: 8),
          FormFields.buildTextField(
            label: 'Lote',
            controller: lote,
            placeholder: 'Ej: LOT123456',
            required: false,
          ),
          const SizedBox(height: 8),
          FormFields.buildTextField(
            label: 'Jeringa',
            controller: jeringa,
            placeholder: 'Ej: 12345',
            required: false,
          ),
        ],
      ),
    );
  }
}
