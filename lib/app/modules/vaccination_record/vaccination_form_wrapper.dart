import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_form_controller.dart';
import '../../controllers/vaccine_selection_controller.dart';
import '../../theme/colors.dart';
import '../../widgets/custom_snackbar.dart';
import 'steps/step1_basic_data.dart';
import 'steps/step2_additional_data.dart';
import 'steps/step3_vaccines.dart';
import 'steps/step4_review.dart';

class VaccinationFormWrapper extends StatefulWidget {
  final bool showPopScope;

  const VaccinationFormWrapper({super.key, this.showPopScope = false});

  @override
  State<VaccinationFormWrapper> createState() => _VaccinationFormWrapperState();
}

class _VaccinationFormWrapperState extends State<VaccinationFormWrapper> 
    with WidgetsBindingObserver {
  PageController? _localPageController;
  bool _hasInitialized = false; // Flag para evitar múltiples inicializaciones
  
  // ✅ Key única para forzar reconstrucción completa del formulario
  final RxString _formKey = DateTime.now().millisecondsSinceEpoch.toString().obs;

  @override
  void initState() {
    super.initState();
    // SIEMPRE crear un PageController local para este wrapper
    // Esto evita conflictos si el wrapper se abre/cierra múltiples veces
    _localPageController = PageController();
    
    // Agregar observer para detectar cambios de visibilidad
    WidgetsBinding.instance.addObserver(this);
    
    // ✅ Inicializar estado inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormState();
      _hasInitialized = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Cuando la app vuelve a estar activa, verificar si necesitamos limpiar
    if (state == AppLifecycleState.resumed && _hasInitialized) {
      _checkAndCleanFormIfNeeded();
    }
  }

  /// Verifica si el formulario necesita ser limpiado
  void _checkAndCleanFormIfNeeded() {
    if (!mounted || widget.showPopScope) return;
    
    final controller = Get.isRegistered<PatientFormController>()
        ? Get.find<PatientFormController>()
        : null;
    
    if (controller == null) return;
    
    // Si estamos en tab mode y hay datos de edición, limpiar
    if (controller.isEditMode.value || controller.isModalMode.value) {
      print('🧹 Limpiando formulario - detectado estado modal/edición en tab');
      controller.clearForm();
      controller.isModalMode.value = false;
      controller.isEditMode.value = false;
      controller.editingPatientId = null;
      _regenerateFormKey();
    }
  }

  /// Inicializa el estado del formulario según el modo
  void _initializeFormState() {
    if (!mounted) return;
    
    final controller = Get.isRegistered<PatientFormController>()
        ? Get.find<PatientFormController>()
        : null;
    
    if (controller == null) return;

    // Si está abierto como tab (no es modal), asegurar que el formulario esté limpio
    if (!widget.showPopScope) {
      print('🔄 Inicializando formulario en modo tab - limpiando datos');
      controller.clearForm();
      controller.isModalMode.value = false;
      controller.isEditMode.value = false;
      controller.editingPatientId = null;
    }
    
    // Regenerar key para asegurar reconstrucción
    _regenerateFormKey();
  }

  @override
  void dispose() {
    // Quitar observer y liberar PageController local si existe
    WidgetsBinding.instance.removeObserver(this);
    _localPageController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VaccinationFormWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Detectar cambio de modo (modal ↔ tab)
    if (oldWidget.showPopScope != widget.showPopScope) {
      final controller = Get.isRegistered<PatientFormController>()
          ? Get.find<PatientFormController>()
          : null;
      
      // ✅ Si cambiamos de modal a tab, limpiar INSTANTÁNEAMENTE
      if (oldWidget.showPopScope && !widget.showPopScope && controller != null) {
        controller.clearForm(); // Limpiar datos inmediatamente
      }
      
      // ✅ Recrear PageController para asegurar estado limpio
      _localPageController?.dispose();
      _localPageController = PageController();
      
      _initializeFormState();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener controlador existente o crear uno nuevo
    final controller = Get.isRegistered<PatientFormController>()
        ? Get.find<PatientFormController>()
        : Get.put(PatientFormController());

    // ✅ VERIFICAR EN CADA BUILD: Si estamos en tab mode, asegurar que esté limpio
    if (!widget.showPopScope && _hasInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndCleanFormIfNeeded();
      });
    }

    // SIEMPRE usar el PageController local creado en initState
    // Esto asegura que cada instancia del wrapper tenga su propio controller
    final pageController = _localPageController!;

    final scaffold = Scaffold(
      backgroundColor: backgroundLight,
      appBar: widget.showPopScope
          ? AppBar(
              backgroundColor: cardBackground,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
                onPressed: () => _handleBackButton(context, controller),
              ),
              title: Obx(
                () => Text(
                  controller.isEditMode.value
                      ? 'Editar Paciente'
                      : 'Nuevo Registro',
                  style: const TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: borderColor),
              ),
            )
          : null,
      body: Column(
        children: [
          // Progress Indicator (optimizado para no reconstruir todo)
          _ProgressIndicator(controller: controller),

          // PageView con los pasos (key reactiva para reconstrucción completa)
          Expanded(
            child: Obx(() => PageView(
              key: ValueKey(_formKey.value), // ✅ Key cambia = reconstrucción TOTAL
              controller: pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                Step1BasicData(),
                Step2AdditionalData(),
                Step3Vaccines(),
                Step4Review(),
              ],
            )),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNavigationButtons(
        controller: controller,
        pageController: pageController,
        onNext: _handleNextButton,
      ),
    );

    // Envolver con PopScope si es modal para interceptar gestos de retroceso
    if (widget.showPopScope) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _showCancelDialog(context, controller);
        },
        child: scaffold,
      );
    }

    return scaffold;
  }

  /// ✅ Método para forzar reconstrucción completa del formulario
  void _regenerateFormKey() {
    _formKey.value = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _handleNextButton(
    PatientFormController controller,
    PageController pageController,
  ) async {
    final step = controller.currentStep.value;
    if (step == 0) {
      // ✅ Validar el FORM (para mostrar errores en rojo en los campos)
      // Si el formKey está registrado, validar el Form
      // Si no, confiar en la validación del controller
      bool formIsValid = true;
      final step1FormKey = controller.step1FormKey.value;
      
      if (step1FormKey != null) {
        formIsValid = step1FormKey.currentState?.validate() ?? true;
      }
      
      if (formIsValid) {
        // El Form es válido, ahora validar lógica de negocio del controller
        if (controller.validateStep1()) {
          controller.nextStep(customPageController: pageController);
        }
      }
      // Si hay errores en el Form, se muestran automáticamente en rojo
    } else if (step == 1) {
      // ✅ Validar el FORM (para mostrar errores en rojo en los campos)
      // Si el formKey está registrado, validar el Form
      // Si no, confiar en la validación del controller
      bool formIsValid = true;
      final step2FormKey = controller.step2FormKey.value;
      
      if (step2FormKey != null) {
        formIsValid = step2FormKey.currentState?.validate() ?? true;
      }
      
      if (formIsValid) {
        // El Form es válido, ahora validar lógica de negocio del controller
        if (controller.validateStep2()) {
          controller.nextStep(customPageController: pageController);
        }
      }
      // Si hay errores en el Form, se muestran automáticamente en rojo
    } else if (step == 2) {
      bool formIsValid = true;
      final step3FormKey = controller.step3FormKey.value;
      
      if (step3FormKey != null) {
        formIsValid = step3FormKey.currentState?.validate() ?? true;
      }
      
      if (formIsValid) {
        final vaccineController = Get.find<VaccineSelectionController>();
        if (vaccineController.validate()) {
          controller.nextStep(customPageController: pageController);
        }
      }
    } else if (step == 3) {
      // Guardar el modo ANTES de ejecutar submitForm
      final wasEditMode = controller.isEditMode.value;
      final isCurrentlyModal = widget.showPopScope; // Flag actual del widget

      // ✅ Ejecutar guardado (sin lógica de navegación desde el controller)
      await controller.submitForm();

      // ✅ Manejar UI y navegación SOLO desde el wrapper
      if (isCurrentlyModal) {
        // Modal: cerrar PRIMERO y luego mostrar snackbar
        Navigator.of(context).pop(); // Usar Navigator en lugar de Get.back()
        
        // Mostrar snackbar después de cerrar
        Future.delayed(const Duration(milliseconds: 300), () {
          CustomSnackbar.showSuccess(
            wasEditMode
                ? 'Paciente actualizado correctamente'
                : 'Paciente y vacunas registrados correctamente',
          );
        });
      } else {
        // Tab: mostrar snackbar, limpiar y navegar al inicio
        CustomSnackbar.showSuccess(
          wasEditMode
              ? 'Paciente actualizado correctamente'
              : 'Paciente y vacunas registrados correctamente',
        );
        
        // Breve delay para permitir que se complete el snackbar
        await Future.delayed(const Duration(milliseconds: 300));
        
        // ✅ PRIMERO: Limpiar formulario completamente
        controller.clearForm();
        
        // ✅ SEGUNDO: Regenerar key para FORZAR reconstrucción total de widgets
        _regenerateFormKey();
        
        // ✅ TERCERO: Resetear flag para forzar siguiente inicialización
        _hasInitialized = false;
        
        // ✅ CUARTO: Breve delay para que los widgets se reconstruyan
        await Future.delayed(const Duration(milliseconds: 150));
        
        // ✅ QUINTO: Navegar al primer paso
        if (pageController.hasClients) {
          pageController.jumpToPage(0);
        }
        
        // ✅ SEXTO: Marcar como inicializado nuevamente
        _hasInitialized = true;
      }
    }
  }

  void _handleBackButton(
    BuildContext context,
    PatientFormController controller,
  ) {
    _showCancelDialog(context, controller);
  }

  void _showCancelDialog(
    BuildContext context,
    PatientFormController controller,
  ) {
    final bool isEditMode = controller.isEditMode.value;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            isEditMode ? '¿Cancelar edición?' : '¿Cancelar registro?',
            style: const TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            isEditMode
                ? 'Si sales ahora, perderás todos los cambios realizados. ¿Estás seguro de que deseas cancelar la edición?'
                : 'Si sales ahora, perderás todos los datos ingresados. ¿Estás seguro de que deseas cancelar?',
            style: const TextStyle(color: textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isEditMode ? 'Continuar editando' : 'Continuar registrando',
                style: const TextStyle(color: textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Cerrar diálogo
                Navigator.of(context).pop();

                // ✅ PRIMERO: Limpiar formulario antes de cerrar
                controller.clearForm();
                
                // ✅ SEGUNDO: Regenerar key para FORZAR reconstrucción total
                _regenerateFormKey();
                
                // ✅ TERCERO: Limpiar flags de modo
                controller.isModalMode.value = false;
                controller.isEditMode.value = false;

                // ✅ CUARTO: Cerrar el modal
                Navigator.of(context).pop();
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

// Widget optimizado para el indicador de progreso
class _ProgressIndicator extends StatelessWidget {
  final PatientFormController controller;

  const _ProgressIndicator({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: cardBackground,
      padding: const EdgeInsets.all(16),
      child: Obx(() {
        final step = controller.currentStep.value;
        final progress = controller.progress;
        return Column(
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
                  'Paso ${step + 1} de ${controller.totalSteps}',
                  style: const TextStyle(color: textSecondary, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: borderColor,
                valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 6,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// Widget optimizado para los botones de navegación
class _BottomNavigationButtons extends StatelessWidget {
  final PatientFormController controller;
  final PageController pageController;
  final Function(PatientFormController, PageController) onNext;

  const _BottomNavigationButtons({
    required this.controller,
    required this.pageController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: cardBackground,
        border: Border(top: BorderSide(color: borderColor, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Obx(() {
            final currentStep = controller.currentStep.value;
            final isLastStep = currentStep == controller.totalSteps - 1;
            final showBackButton = currentStep > 0;

            return Row(
              children: [
                if (showBackButton) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.previousStep(
                        customPageController: pageController,
                      ),
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
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onNext(controller, pageController),
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
                          isLastStep ? 'Guardar' : 'Siguiente',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep ? Icons.check : Icons.arrow_forward,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
