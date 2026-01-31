import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_form_controller.dart';
import '../../controllers/vaccine_selection_controller.dart';
import '../../theme/colors.dart';
import 'steps/step1_basic_data.dart';
import 'steps/step2_additional_data.dart';
import 'steps/step3_vaccines.dart';
import 'steps/step4_review.dart';

class VaccinationFormWrapper extends StatelessWidget {
  const VaccinationFormWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatientFormController());

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () => _showCancelDialog(context, controller),
        ),
        title: Obx(
          () => Text(
            _getStepTitle(controller.currentStep.value),
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            color: cardBackground,
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Registro de Vacunación',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Paso ${controller.currentStep.value + 1} de ${controller.totalSteps}',
                        style: const TextStyle(
                          color: textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      backgroundColor: borderColor,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // PageView con los pasos
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return PageView(
                  controller: controller.pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      controller.currentStep.value = index,
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Step1BasicData(),
                    ),
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Step2AdditionalData(),
                    ),
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Step3Vaccines(),
                    ),
                    SizedBox(
                      height: constraints.maxHeight,
                      child: const Step4Review(),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: cardBackground,
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => Row(
                children: [
                  if (controller.currentStep.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Anterior'),
                      ),
                    ),
                  if (controller.currentStep.value > 0)
                    const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.currentStep.value == 0) {
                          // Validar paso 1 y avanzar
                          if (controller.validateStep1()) {
                            controller.nextStep();
                          }
                        } else if (controller.currentStep.value == 1) {
                          // Paso 2 -> Paso 3 (sin validación obligatoria)
                          controller.nextStep();
                        } else if (controller.currentStep.value == 2) {
                          // Paso 3 (vacunas) -> Paso 4 (revisión)
                          // Validar vacunas antes de avanzar
                          final vaccineController =
                              Get.find<VaccineSelectionController>();
                          if (vaccineController.validate()) {
                            controller.nextStep();
                          }
                        } else if (controller.currentStep.value == 3) {
                          // Paso 4 (último) -> Guardar
                          print('🚀 Botón Guardar presionado en paso 4');
                          controller.submitForm();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: primaryColor.withValues(alpha: 0.25),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            controller.currentStep.value ==
                                    controller.totalSteps - 1
                                ? 'Guardar'
                                : 'Siguiente',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            controller.currentStep.value ==
                                    controller.totalSteps - 1
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Datos Básicos';
      case 1:
        return 'Datos Adicionales';
      case 2:
        return 'Vacunas';
      case 3:
        return 'Revisión';
      default:
        return 'Registro';
    }
  }

  void _showCancelDialog(
    BuildContext context,
    PatientFormController controller,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            '¿Cancelar registro?',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Si sales ahora, perderás todos los datos ingresados. ¿Estás seguro de que deseas cancelar?',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Continuar editando',
                style: TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.back();
                Get.delete<PatientFormController>();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sí, cancelar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
