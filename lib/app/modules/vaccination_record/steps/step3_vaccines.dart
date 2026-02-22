import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../controllers/vaccine_selection_controller.dart';
import '../../../models/vaccine.dart';
import '../../../theme/colors.dart';
import '../../../widgets/form_fields.dart';

class Step3Vaccines extends StatefulWidget {
  const Step3Vaccines({super.key});

  @override
  State<Step3Vaccines> createState() => _Step3VaccinesState();
}

class _Step3VaccinesState extends State<Step3Vaccines>
    with AutomaticKeepAliveClientMixin {
  bool _hasLoadedEditData = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Cargar datos después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final patientController = Get.find<PatientFormController>();

    // Usar find si ya existe, put si no
    final vaccineController = Get.isRegistered<VaccineSelectionController>()
        ? Get.find<VaccineSelectionController>()
        : Get.put(VaccineSelectionController());

    // Cargar vacunas disponibles según la edad del paciente
    await vaccineController.loadAvailableVaccines(
      patientController.birthDate.value,
    );

    // Si está en modo edición y aún no se han cargado las vacunas
    if (patientController.isEditMode.value &&
        patientController.editingPatientId != null &&
        !_hasLoadedEditData) {
      _hasLoadedEditData = true;
      await patientController.loadPatientVaccinesForEdit(
        patientController.editingPatientId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Usar find si ya existe, put si no
    final vaccineController = Get.isRegistered<VaccineSelectionController>()
        ? Get.find<VaccineSelectionController>()
        : Get.put(VaccineSelectionController());

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100),
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
                    'Selecciona las Vacunas',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Marca las vacunas que deseas aplicar y completa su información',
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Solo marca las vacunas que aplicarás hoy. Al seleccionar una vacuna, se mostrarán los campos necesarios.',
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Lista de vacunas disponibles
            Obx(() {
              if (vaccineController.isLoading.value) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (vaccineController.availableVaccines.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.vaccines_outlined,
                          size: 64,
                          color: textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No hay vacunas disponibles',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Configura vacunas en el catálogo',
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: vaccineController.availableVaccines
                    .map(
                      (vaccine) =>
                          _buildVaccineCard(vaccine, vaccineController),
                    )
                    .toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineCard(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final selected = controller.isVaccineSelected(vaccine.id!);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : borderColor,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            // Header con checkbox
            InkWell(
              onTap: () => controller.toggleVaccineSelection(vaccine.id!),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Checkbox
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: selected ? primaryColor : Colors.transparent,
                        border: Border.all(
                          color: selected ? primaryColor : borderColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    // Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          vaccine.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vaccine.name,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${vaccine.code} • ${vaccine.maxDoses} dosis',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vaccine.ageRangeDescription,
                            style: TextStyle(
                              color: primaryColor.withOpacity(0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Indicador de expansión
                    if (selected)
                      const Icon(
                        Icons.expand_more,
                        color: primaryColor,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),

            // Campos expandibles con animación
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: selected
                  ? Column(
                      children: [
                        const Divider(height: 1, color: borderColor),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildVaccineFields(vaccine, controller),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildVaccineFields(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Botones de dosis
        _buildDoseButtons(vaccine, controller),

        const SizedBox(height: 16),

        // Formularios de las dosis activas
        _buildActiveDoseForms(vaccine, controller),
      ],
    );
  }

  /// Construye los botones de selección de dosis
  Widget _buildDoseButtons(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final doseOptions = controller.getDoseOptions(vaccine.id!);

      if (doseOptions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dosis Disponibles',
            style: TextStyle(
              color: textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doseOptions.map((doseOption) {
              final isLocked = controller.isDoseLocked(
                vaccine.id!,
                doseOption.id!,
              );
              final isActive = controller.isDoseActive(
                vaccine.id!,
                doseOption.id!,
              );
              final hasDoseData = controller.hasDoseData(
                vaccine.id!,
                doseOption.id!,
              );

              Color buttonColor;
              Color textColor;
              IconData? icon;

              if (isLocked) {
                // Dosis ya registrada (bloqueada)
                buttonColor = textSecondary.withOpacity(0.2);
                textColor = textSecondary;
                icon = Icons.lock;
              } else if (isActive) {
                // Dosis activa (siendo editada)
                buttonColor = primaryColor;
                textColor = Colors.white;
                icon = Icons.edit;
              } else if (hasDoseData) {
                // Dosis completada pero inactiva
                buttonColor = Colors.green.withOpacity(0.1);
                textColor = Colors.green;
                icon = Icons.check_circle;
              } else {
                // Dosis disponible (sin datos)
                buttonColor = inputBackground;
                textColor = textSecondary;
                icon = null;
              }

              return InkWell(
                onTap: isLocked
                    ? null
                    : () => controller.toggleDoseSelection(
                        vaccine.id!,
                        doseOption.id!,
                      ),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: buttonColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isActive ? primaryColor : borderColor,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 16, color: textColor),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        doseOption.displayName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Leyenda
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              _buildLegendItem(Icons.edit, 'Activa', primaryColor),
              _buildLegendItem(Icons.lock, 'Registrada', textSecondary),
              _buildLegendItem(Icons.check_circle, 'Completada', Colors.green),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildLegendItem(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: textSecondary, fontSize: 11)),
      ],
    );
  }

  /// Construye los formularios de las dosis activas
  Widget _buildActiveDoseForms(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final activeDoses = controller.getActiveDoses(vaccine.id!);

      if (activeDoses.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Selecciona una dosis para completar su información',
            style: TextStyle(
              color: textSecondary,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        );
      }

      final doseOptions = controller.getDoseOptions(vaccine.id!);

      return Column(
        children: activeDoses.map((doseOptionId) {
          final doseOption = doseOptions.firstWhereOrNull(
            (opt) => opt.id == doseOptionId,
          );

          if (doseOption == null) return const SizedBox.shrink();

          final isLocked = controller.isDoseLocked(vaccine.id!, doseOptionId);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isLocked
                  ? textSecondary.withOpacity(0.05)
                  : primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLocked ? borderColor : primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header del formulario de dosis
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isLocked
                            ? textSecondary.withOpacity(0.1)
                            : primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.vaccines,
                        size: 16,
                        color: isLocked ? textSecondary : primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doseOption.displayName,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isLocked) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Ya registrada',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Campos del formulario
                _buildDoseForm(vaccine, controller, doseOptionId, isLocked),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  /// Construye el formulario de una dosis específica
  Widget _buildDoseForm(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fecha de aplicación
        _buildDateFieldForDose(vaccine, controller, doseOptionId, isLocked),

        const SizedBox(height: 12),

        // Laboratorio (si aplica)
        if (vaccine.hasLaboratory) ...[
          _buildLaboratoryDropdownForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Lote (siempre se muestra)
        _buildLotFieldForDose(vaccine, controller, doseOptionId, isLocked),

        const SizedBox(height: 12),

        // Jeringa (si aplica)
        if (vaccine.hasSyringe) ...[
          _buildSyringeDropdownForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Lote de jeringa (si aplica)
        if (vaccine.hasSyringeLot) ...[
          _buildSyringeLotFieldForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Diluyente (si aplica)
        if (vaccine.hasDiluent) ...[
          _buildDiluentFieldForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Gotero (si aplica)
        if (vaccine.hasDropper) ...[
          _buildDropperDropdownForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Tipo neumococo (si aplica)
        if (vaccine.hasPneumococcalType) ...[
          _buildPneumococcalTypeDropdownForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Cantidad de frascos (si aplica)
        if (vaccine.hasVialCount) ...[
          _buildVialCountFieldForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Observaciones (si aplica)
        if (vaccine.hasObservation) ...[
          _buildObservationDropdownForDose(
            vaccine,
            controller,
            doseOptionId,
            isLocked,
          ),
          const SizedBox(height: 12),
        ],

        // Observación personalizada (opcional, siempre disponible)
        _buildCustomObservationFieldForDose(
          vaccine,
          controller,
          doseOptionId,
          isLocked,
        ),
      ],
    );
  }

  // ==================== CAMPOS ESPECÍFICOS POR DOSIS ====================

  Widget _buildLaboratoryDropdownForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final options = controller.getLaboratoryOptions(vaccine.id!);
      final selectedValue = controller.getSelectedLaboratory(
        vaccine.id!,
        doseOptionId,
      );
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Laboratorio',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: isLocked
            ? null
            : (value) {
                if (value != null) {
                  final option = options.firstWhere(
                    (opt) => opt.displayName == value,
                  );
                  controller.setSelectedLaboratory(
                    vaccine.id!,
                    doseOptionId,
                    option.id!,
                  );
                }
              },
      );
    });
  }

  Widget _buildSyringeDropdownForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final options = controller.getSyringeOptions(vaccine.id!);
      final selectedValue = controller.getSelectedSyringe(
        vaccine.id!,
        doseOptionId,
      );
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Jeringa',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: isLocked
            ? null
            : (value) {
                if (value != null) {
                  final option = options.firstWhere(
                    (opt) => opt.displayName == value,
                  );
                  controller.setSelectedSyringe(
                    vaccine.id!,
                    doseOptionId,
                    option.id!,
                  );
                }
              },
      );
    });
  }

  Widget _buildDropperDropdownForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final options = controller.getDropperOptions(vaccine.id!);
      final selectedValue = controller.getSelectedDropper(
        vaccine.id!,
        doseOptionId,
      );
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Gotero',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: isLocked
            ? null
            : (value) {
                if (value != null) {
                  final option = options.firstWhere(
                    (opt) => opt.displayName == value,
                  );
                  controller.setSelectedDropper(
                    vaccine.id!,
                    doseOptionId,
                    option.id!,
                  );
                }
              },
      );
    });
  }

  Widget _buildPneumococcalTypeDropdownForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final options = controller.getPneumococcalTypeOptions(vaccine.id!);
      final selectedValue = controller.getSelectedPneumococcalType(
        vaccine.id!,
        doseOptionId,
      );
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Tipo de Neumococo',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: isLocked
            ? null
            : (value) {
                if (value != null) {
                  final option = options.firstWhere(
                    (opt) => opt.displayName == value,
                  );
                  controller.setSelectedPneumococcalType(
                    vaccine.id!,
                    doseOptionId,
                    option.id!,
                  );
                }
              },
      );
    });
  }

  Widget _buildObservationDropdownForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final options = controller.getObservationOptions(vaccine.id!);
      final selectedValue = controller.getSelectedObservation(
        vaccine.id!,
        doseOptionId,
      );
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Observaciones',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: isLocked
            ? null
            : (value) {
                if (value != null) {
                  final option = options.firstWhere(
                    (opt) => opt.displayName == value,
                  );
                  controller.setSelectedObservation(
                    vaccine.id!,
                    doseOptionId,
                    option.id!,
                  );
                }
              },
      );
    });
  }

  Widget _buildLotFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    final textController = controller.getLotController(
      vaccine.id!,
      doseOptionId,
    );
    if (textController == null) return const SizedBox.shrink();

    return FormFields.buildTextField(
      label: 'Lote',
      controller: textController,
      placeholder: 'Ej: LOT123456',
      enabled: !isLocked,
    );
  }

  Widget _buildSyringeLotFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    final textController = controller.getSyringeLotController(
      vaccine.id!,
      doseOptionId,
    );
    if (textController == null) return const SizedBox.shrink();

    return FormFields.buildTextField(
      label: 'Lote de Jeringa',
      controller: textController,
      placeholder: 'Ej: SYR789',
      enabled: !isLocked,
    );
  }

  Widget _buildDiluentFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    final textController = controller.getDiluentController(
      vaccine.id!,
      doseOptionId,
    );
    if (textController == null) return const SizedBox.shrink();

    return FormFields.buildTextField(
      label: 'Diluyente',
      controller: textController,
      placeholder: 'Ej: DIL456',
      enabled: !isLocked,
    );
  }

  Widget _buildVialCountFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    final textController = controller.getVialCountController(
      vaccine.id!,
      doseOptionId,
    );
    if (textController == null) return const SizedBox.shrink();

    return FormFields.buildTextField(
      label: 'Cantidad de Frascos',
      controller: textController,
      placeholder: 'Ej: 2',
      keyboardType: TextInputType.number,
      enabled: !isLocked,
    );
  }

  Widget _buildDateFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    return Obx(() {
      final selectedDate = controller.getApplicationDate(
        vaccine.id!,
        doseOptionId,
      );

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 6),
              child: Text(
                'Fecha de Aplicación *',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            InkWell(
              onTap: isLocked
                  ? null
                  : () async {
                      final date = await Get.dialog<DateTime>(
                        DatePickerDialog(
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        ),
                      );
                      if (date != null) {
                        controller.setApplicationDate(
                          vaccine.id!,
                          doseOptionId,
                          date,
                        );
                      }
                    },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isLocked
                      ? textSecondary.withOpacity(0.05)
                      : inputBackground,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: isLocked ? textSecondary : primaryColor,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedDate != null
                          ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
                          : 'Selecciona la fecha',
                      style: TextStyle(
                        color: selectedDate != null ? textPrimary : textHint,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCustomObservationFieldForDose(
    Vaccine vaccine,
    VaccineSelectionController controller,
    String doseOptionId,
    bool isLocked,
  ) {
    final textController = controller.getCustomObservationController(
      vaccine.id!,
      doseOptionId,
    );
    if (textController == null) return const SizedBox.shrink();

    return FormFields.buildTextField(
      label: 'Observaciones Adicionales (Opcional)',
      controller: textController,
      placeholder: 'Ingresa observaciones adicionales si es necesario...',
      enabled: !isLocked,
      maxLines: 3,
      minLines: 2,
    );
  }
}
