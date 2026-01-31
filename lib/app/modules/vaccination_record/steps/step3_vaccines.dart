import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../controllers/vaccine_selection_controller.dart';
import '../../../models/vaccine.dart';
import '../../../theme/colors.dart';
import '../../../widgets/form_fields.dart';

class Step3Vaccines extends StatelessWidget {
  const Step3Vaccines({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final patientController = Get.find<PatientFormController>();
    final vaccineController = Get.put(VaccineSelectionController());

    // Cargar vacunas disponibles según la edad del paciente
    vaccineController.loadAvailableVaccines(patientController.birthDate.value);

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
        // Dosis (siempre se muestra)
        _buildDoseDropdown(vaccine, controller),

        const SizedBox(height: 12),

        // Fecha de aplicación
        _buildDateField(vaccine, controller),

        const SizedBox(height: 12),

        // Laboratorio (si aplica)
        if (vaccine.hasLaboratory) ...[
          _buildLaboratoryDropdown(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Lote (siempre se muestra)
        _buildLotField(vaccine, controller),

        const SizedBox(height: 12),

        // Jeringa (si aplica)
        if (vaccine.hasSyringe) ...[
          _buildSyringeDropdown(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Lote de jeringa (si aplica)
        if (vaccine.hasSyringeLot) ...[
          _buildSyringeLotField(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Diluyente (si aplica)
        if (vaccine.hasDiluent) ...[
          _buildDiluentField(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Gotero (si aplica)
        if (vaccine.hasDropper) ...[
          _buildDropperDropdown(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Tipo neumococo (si aplica)
        if (vaccine.hasPneumococcalType) ...[
          _buildPneumococcalTypeDropdown(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Cantidad de frascos (si aplica)
        if (vaccine.hasVialCount) ...[
          _buildVialCountField(vaccine, controller),
          const SizedBox(height: 12),
        ],

        // Observaciones (si aplica)
        if (vaccine.hasObservation) ...[
          _buildObservationDropdown(vaccine, controller),
        ],
      ],
    );
  }

  Widget _buildDoseDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getDoseOptions(vaccine.id!);
      final selectedValue = controller.getSelectedDose(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Dosis',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedDose(vaccine.id!, option.id!);
          }
        },
        required: true,
      );
    });
  }

  Widget _buildLaboratoryDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getLaboratoryOptions(vaccine.id!);
      final selectedValue = controller.getSelectedLaboratory(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Laboratorio',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedLaboratory(vaccine.id!, option.id!);
          }
        },
      );
    });
  }

  Widget _buildSyringeDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getSyringeOptions(vaccine.id!);
      final selectedValue = controller.getSelectedSyringe(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Jeringa',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedSyringe(vaccine.id!, option.id!);
          }
        },
      );
    });
  }

  Widget _buildDropperDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getDropperOptions(vaccine.id!);
      final selectedValue = controller.getSelectedDropper(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Gotero',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedDropper(vaccine.id!, option.id!);
          }
        },
      );
    });
  }

  Widget _buildPneumococcalTypeDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getPneumococcalTypeOptions(vaccine.id!);
      final selectedValue = controller.getSelectedPneumococcalType(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Tipo de Neumococo',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedPneumococcalType(vaccine.id!, option.id!);
          }
        },
      );
    });
  }

  Widget _buildObservationDropdown(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final options = controller.getObservationOptions(vaccine.id!);
      final selectedValue = controller.getSelectedObservation(vaccine.id!);
      final items = options.map((opt) => opt.displayName).toList();

      return FormFields.buildDropdownField(
        label: 'Observaciones',
        value: selectedValue ?? (items.isNotEmpty ? items.first : ''),
        items: items,
        onChanged: (value) {
          if (value != null) {
            final option = options.firstWhere(
              (opt) => opt.displayName == value,
            );
            controller.setSelectedObservation(vaccine.id!, option.id!);
          }
        },
      );
    });
  }

  Widget _buildLotField(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    final textController = controller.getLotController(vaccine.id!);

    return FormFields.buildTextField(
      label: 'Lote',
      controller: textController,
      placeholder: 'Ej: LOT123456',
    );
  }

  Widget _buildSyringeLotField(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    final textController = controller.getSyringeLotController(vaccine.id!);

    return FormFields.buildTextField(
      label: 'Lote de Jeringa',
      controller: textController,
      placeholder: 'Ej: SYR789',
    );
  }

  Widget _buildDiluentField(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    final textController = controller.getDiluentController(vaccine.id!);

    return FormFields.buildTextField(
      label: 'Diluyente',
      controller: textController,
      placeholder: 'Ej: DIL456',
    );
  }

  Widget _buildVialCountField(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    final textController = controller.getVialCountController(vaccine.id!);

    return FormFields.buildTextField(
      label: 'Cantidad de Frascos',
      controller: textController,
      placeholder: 'Ej: 2',
      keyboardType: TextInputType.number,
    );
  }

  Widget _buildDateField(
    Vaccine vaccine,
    VaccineSelectionController controller,
  ) {
    return Obx(() {
      final selectedDate = controller.getApplicationDate(vaccine.id!);

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              onTap: () async {
                final date = await Get.dialog<DateTime>(
                  DatePickerDialog(
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  ),
                );
                if (date != null) {
                  controller.setApplicationDate(vaccine.id!, date);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: inputBackground,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: primaryColor,
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
}
