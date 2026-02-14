import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/patient_form_controller.dart';
import '../../../models/patient_model.dart';
import '../../../widgets/form_fields.dart';
import '../../../widgets/colombia_location_selector.dart';
import '../../../theme/colors.dart';

class Step2AdditionalData extends StatefulWidget {
  const Step2AdditionalData({Key? key}) : super(key: key);

  @override
  State<Step2AdditionalData> createState() => _Step2AdditionalDataState();
}

class _Step2AdditionalDataState extends State<Step2AdditionalData>
    with AutomaticKeepAliveClientMixin {
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  @override
  bool get wantKeepAlive => true;

  // Getter para exponer el formKey desde Step2
  GlobalKey<FormState> get formKey => _formKey;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = Get.find<PatientFormController>();

    // ✅ Registrar formKey en el siguiente frame para que el wrapper pueda acceder
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.registerStep2FormKey(_formKey);
    });

    return Form(
      key: _formKey,
      child: Container(
        color: backgroundMedium,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ===== SECCIÓN 1: DATOS DEMOGRÁFICOS =====
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Datos Demográficos',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

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
                      // Sexo - Con botones
                      const Text(
                        'Sexo *',
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
                              child: _buildSexButton(
                                controller: controller,
                                label: 'Mujer',
                                icon: Icons.female,
                                value: 'Mujer',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSexButton(
                                controller: controller,
                                label: 'Hombre',
                                icon: Icons.male,
                                value: 'Hombre',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildSexButton(
                                controller: controller,
                                label: 'Indeterminado',
                                icon: Icons.question_mark,
                                value: 'Indeterminado',
                              ),
                            ),
                          ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Género - Dropdown
                    FormFields.buildDropdownField(
                      label: 'Género',
                      value: controller.selectedGender.value?.name ?? 'N/A',
                      items: const [
                        'N/A',
                        'masculino',
                        'femenino',
                        'transgenero',
                        'indeterminado',
                      ],
                      onChanged: (value) {
                        if (value == 'N/A') {
                          controller.selectedGender.value = null;
                        } else {
                          controller.selectedGender.value = Genero.values
                              .firstWhere((e) => e.name == value);
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Orientación Sexual
                    FormFields.buildDropdownField(
                      label: 'Orientación Sexual',
                      value:
                          controller.selectedSexualOrientation.value?.name ??
                          'N/A',
                      items: const [
                        'N/A',
                        'heterosexual',
                        'homosexual',
                        'bisexual',
                        'noSabeNoAplica',
                      ],
                      onChanged: (value) {
                        if (value == 'N/A') {
                          controller.selectedSexualOrientation.value = null;
                        } else {
                          controller.selectedSexualOrientation.value =
                              OrientacionSexual.values.firstWhere(
                                (e) => e.name == value,
                              );
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Edad Gestacional
                    FormFields.buildTextField(
                      label: 'Edad Gestacional (semanas)',
                      controller: controller.gestationalAgeController,
                      placeholder: 'Ej: 12',
                      keyboardType: TextInputType.number,
                      required: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== SECCIÓN 2: ORIGEN Y MIGRACIÓN =====
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Origen y Migración',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

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
                    // País de Nacimiento
                    FormFields.buildTextField(
                      label: 'País de Nacimiento',
                      controller: controller.birthCountryController,
                      placeholder: 'Ej: Colombia',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Estatus Migratorio - Segmented Control
                    const Text(
                      'Estatus Migratorio *',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: backgroundMedium,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildSegmentButton(
                                controller: controller,
                                label: 'Regular',
                                value: 'regular',
                                groupValue:
                                    controller
                                        .selectedMigratoryStatus
                                        .value
                                        ?.name ??
                                    'N/A',
                                onTap: () =>
                                    controller.selectedMigratoryStatus.value =
                                        EstatusMigratorio.regular,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _buildSegmentButton(
                                controller: controller,
                                label: 'Irregular',
                                value: 'irregular',
                                groupValue:
                                    controller
                                        .selectedMigratoryStatus
                                        .value
                                        ?.name ??
                                    'N/A',
                                onTap: () =>
                                    controller.selectedMigratoryStatus.value =
                                        EstatusMigratorio.irregular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== SECCIÓN 3: ATENCIÓN Y SEGURIDAD SOCIAL =====
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Atención y Seguridad Social',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

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
                    // Lugar de Atención del Parto
                    FormFields.buildTextField(
                      label: 'Lugar de Atención del Parto',
                      controller: controller.birthPlaceController,
                      placeholder: 'Ej: Hospital San Vicente',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Régimen de Afiliación
                    FormFields.buildDropdownField(
                      label: 'Régimen de Afiliación',
                      value:
                          controller.selectedHealthRegime.value?.name ?? 'N/A',
                      items: const [
                        'N/A',
                        'contributivo',
                        'subsidiado',
                        'poblacionPobreNoAsegurada',
                        'especial',
                        'excepcion',
                        'noAsegurado',
                      ],
                      onChanged: (value) {
                        if (value == 'N/A') {
                          controller.selectedHealthRegime.value = null;
                        } else {
                          controller.selectedHealthRegime.value =
                              RegimenAfiliacion.values.firstWhere(
                                (e) => e.name == value,
                              );
                        }
                      },
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Aseguradora
                    FormFields.buildTextField(
                      label: 'Aseguradora (EPS)',
                      controller: controller.insurerController,
                      placeholder: 'Ej: Sura EPS',
                      required: true,
                    ),
                    const SizedBox(height: 16),

                    // Pertenencia Étnica
                    FormFields.buildDropdownField(
                      label: 'Pertenencia Étnica',
                      value: controller.selectedEthnicity.value.name,
                      items: const [
                        'ninguno',
                        'indigena',
                        'rom',
                        'raizal',
                        'palenquero',
                        'negroAfrocolombiano',
                      ],
                      onChanged: (value) {
                        controller.selectedEthnicity.value = PertenenciaEtnica
                            .values
                            .firstWhere((e) => e.name == value);
                      },
                      required: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ===== SECCIÓN 4: INFORMACIÓN DE CONTACTO Y RESIDENCIA =====
              _buildContactAndResidenceSection(controller),

              const SizedBox(height: 24),

              // ===== SECCIÓN 5: CONDICIONES ESPECIALES =====
              _buildSpecialConditionsSection(controller),

              const SizedBox(height: 24),

              // ===== SECCIÓN 6: ANTECEDENTES MÉDICOS =====
              _buildMedicalHistorySection(controller),

              const SizedBox(height: 24),

              // ===== SECCIÓN 7: CONDICIÓN USUARIA (solo mujeres) =====
              _buildUserConditionSection(controller),

              const SizedBox(height: 24),

              // ===== SECCIÓN 8: DATOS DE LA MADRE =====
              _buildMotherSection(controller),

              const SizedBox(height: 24),

              // ===== SECCIÓN 9: DATOS DEL CUIDADOR =====
              _buildCaregiverSection(controller),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      ),
    );
  }

  // Sección de información de contacto y residencia
  Widget _buildContactAndResidenceSection(PatientFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Información de Contacto y Residencia',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              // País fijo: Colombia (solo lectura)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'País de Residencia *',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextFormField(
                      controller: controller.residenceCountryController,
                      readOnly: true,
                      style: const TextStyle(color: textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Colombia',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: borderColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Selector de Departamento y Municipio
              ColombiaLocationSelector(
                departamentoController:
                    controller.residenceDepartmentController,
                municipioController: controller.residenceMunicipalityController,
                departamentoInicial:
                    controller.residenceDepartmentController.text,
                municipioInicial:
                    controller.residenceMunicipalityController.text,
              ),
              const SizedBox(height: 16),

              // Comuna / Localidad
              FormFields.buildTextField(
                label: 'Comuna / Localidad',
                controller: controller.communeController,
                placeholder: 'Ej: Comuna 10',
                required: false,
              ),
              const SizedBox(height: 16),

              // Área
              const Text(
                'Área *',
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
                      child: _buildAreaButton(
                        controller: controller,
                        label: 'Urbana',
                        icon: Icons.location_city,
                        value: Area.urbana,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAreaButton(
                        controller: controller,
                        label: 'Rural',
                        icon: Icons.nature,
                        value: Area.rural,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dirección
              FormFields.buildTextField(
                label: 'Dirección con Nomenclatura',
                controller: controller.addressController,
                placeholder: 'Ej: Calle 50 # 45-32',
                required: false,
              ),
              const SizedBox(height: 16),

              // Teléfono fijo
              FormFields.buildTextField(
                label: 'Teléfono Fijo (Indicativo + Número)',
                controller: controller.landlineController,
                placeholder: 'Ej: 6012345678',
                keyboardType: TextInputType.phone,
                required: false,
              ),
              const SizedBox(height: 16),

              // Celular
              FormFields.buildTextField(
                label: 'Celular',
                controller: controller.cellphoneController,
                placeholder: 'Ej: 3001234567',
                keyboardType: TextInputType.phone,
                required: false,
              ),
              const SizedBox(height: 16),

              // Email
              FormFields.buildTextField(
                label: 'Email',
                controller: controller.emailController,
                placeholder: 'Ej: correo@example.com',
                keyboardType: TextInputType.emailAddress,
                required: false,
              ),
              const SizedBox(height: 16),

              // Autorizaciones
              const Text(
                'Autorizaciones',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Autoriza llamadas telefónicas',
                    style: TextStyle(color: textPrimary, fontSize: 16),
                  ),
                  value: controller.authorizeCalls.value,
                  onChanged: (value) =>
                      controller.authorizeCalls.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Autoriza envío de correo electrónico',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.authorizeEmail.value,
                  onChanged: (value) =>
                      controller.authorizeEmail.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sección de condiciones especiales
  Widget _buildSpecialConditionsSection(PatientFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Condiciones Especiales',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              const Text(
                'Seleccione las condiciones que apliquen:',
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Desplazado',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.displaced.value,
                  onChanged: (value) =>
                      controller.displaced.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Discapacitado',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.disabled.value,
                  onChanged: (value) =>
                      controller.disabled.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Fallecido',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.deceased.value,
                  onChanged: (value) =>
                      controller.deceased.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Víctima del conflicto armado',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.armedConflictVictim.value,
                  onChanged: (value) =>
                      controller.armedConflictVictim.value = value ?? false,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
              Obx(
                () => CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Estudia actualmente',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  value: controller.currentlyStudying.value ?? false,
                  onChanged: (value) =>
                      controller.currentlyStudying.value = value,
                  activeColor: primaryColor,
                  controlAffinity: ListTileControlAffinity.leading,
                  tristate: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sección de antecedentes médicos
  Widget _buildMedicalHistorySection(PatientFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Antecedentes Médicos',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              // Contraindicaciones
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Sufre o ha sufrido enfermedad que contraindique la vacunación?',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: controller.hasContraindication.value,
                  onChanged: (value) {
                    controller.hasContraindication.value = value;
                    // Establecer valor por defecto cuando se activa
                    if (value &&
                        controller
                            .contraindicationDetailsController
                            .text
                            .isEmpty) {
                      controller.contraindicationDetailsController.text =
                          'Adultos';
                    }
                  },
                  activeColor: primaryColor,
                ),
              ),
              Obx(
                () => controller.hasContraindication.value
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          FormFields.buildDropdownField(
                            label: '¿Cuál?',
                            value:
                                controller
                                    .contraindicationDetailsController
                                    .text
                                    .isEmpty
                                ? 'Adultos'
                                : controller
                                      .contraindicationDetailsController
                                      .text,
                            items: const [
                              'Adultos',
                              'Anafilaxia o hipersensibilidad al huevo',
                              'Cancer',
                              'Encefalopatía',
                              'Enfermedad Autoinmune',
                              'Enfermedad congénita Inmunológica',
                              'Enfermedad neurológica degenerativa',
                              'Gestante',
                              'Hipersensibilidad a los Aminoglucósidos',
                              'Inmunocomprometido',
                              'Inmunodeficiencia Primaria o secundaria',
                              'Malformación del aparato gastrointestinal',
                              'Menor de 6 meses',
                              'Neoplasias',
                              'Reacción alergica a estreptomicina',
                              'Reacción alérgica a neomicina',
                              'Reacción alérgica polimixina B',
                              'Transfusiones de derivados sanguíneos o inmunoglobulina',
                              'Tratamiento inmunosupresor',
                              'Varicela',
                            ],
                            onChanged: (value) {
                              controller
                                      .contraindicationDetailsController
                                      .text =
                                  value ?? '';
                            },
                            required: false,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Reacciones previas
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Ha presentado reacción moderada o severa a biológicos anteriores?',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: controller.hasPreviousReaction.value,
                  onChanged: (value) {
                    controller.hasPreviousReaction.value = value;
                    // Establecer valor por defecto cuando se activa
                    if (value &&
                        controller.reactionDetailsController.text.isEmpty) {
                      controller.reactionDetailsController.text =
                          'Convulsiones';
                    }
                  },
                  activeColor: primaryColor,
                ),
              ),
              Obx(
                () => controller.hasPreviousReaction.value
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          FormFields.buildDropdownField(
                            label: '¿Cuál?',
                            value:
                                controller
                                    .reactionDetailsController
                                    .text
                                    .isEmpty
                                ? 'Convulsiones'
                                : controller.reactionDetailsController.text,
                            items: const [
                              'Convulsiones',
                              'Diarrea',
                              'Dificultad respiratoria',
                              'Dolor de cabeza',
                              'Dolor local',
                              'Dolor muscular',
                              'Edema',
                              'Encefalitis',
                              'Enfermedad viscerotrópica',
                              'Enrrojecimiento',
                              'Eritema',
                              'Escalofrios',
                              'Hipotonia',
                              'Induración',
                              'Irritabilidad',
                              'Linfadenitis',
                              'Llanto persistente',
                              'Parálisis flácida',
                              'Perdida de apetito',
                              'Shock anafiláctico',
                              'Sindróme de Guillain Barré',
                              'Temperatura mayor 40° C',
                              'Trombocitopenia',
                              'Urticaria',
                              'Varicela',
                              'Vómito',
                            ],
                            onChanged: (value) {
                              controller.reactionDetailsController.text =
                                  value ?? '';
                            },
                            required: false,
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Registro de antecedente
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Registro de Antecedente',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Fecha de registro
              Obx(
                () => FormFields.buildDatePickerField(
                  label: 'Fecha de Registro del Antecedente',
                  value: controller.historyRecordDate.value,
                  icon: Icons.calendar_today,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: Get.context!,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      locale: const Locale('es'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF135BEC),
                              secondary: Color(0xFF135BEC),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (date != null) {
                      controller.historyRecordDate.value = date;
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Tipo
              FormFields.buildTextField(
                label: 'Tipo',
                controller: controller.historyTypeController,
                placeholder: 'Ej: Alergia, Enfermedad crónica',
                required: false,
              ),
              const SizedBox(height: 16),

              // Descripción
              FormFields.buildTextField(
                label: 'Descripción',
                controller: controller.historyDescriptionController,
                placeholder: 'Describa el antecedente',
                required: false,
              ),
              const SizedBox(height: 16),

              // Observaciones especiales
              FormFields.buildTextField(
                label: 'Observaciones Especiales',
                controller: controller.specialObservationsController,
                placeholder: 'Observaciones adicionales',
                required: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sección de condición usuaria (solo mujeres >= 9 años)
  Widget _buildUserConditionSection(PatientFormController controller) {
    return Obx(() {
      // Solo mostrar si el sexo es mujer
      if (controller.selectedSex.value != Sexo.mujer) {
        return const SizedBox.shrink();
      }

      // Validar edad >= 9 años
      final birthDate = controller.birthDate.value;
      if (birthDate == null) {
        return const SizedBox.shrink();
      }

      final int age = DateTime.now().difference(birthDate).inDays ~/ 365;
      if (age < 9) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Condición de la Usuaria',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
                // Condición usuaria
                FormFields.buildDropdownField(
                  label: 'Condición de la Usuaria',
                  value: _getUserConditionLabel(
                    controller.selectedUserCondition.value,
                  ),
                  items: const [
                    'No Aplica',
                    'Mujer en Edad Fértil',
                    'Gestante',
                    'Mujer Mayor de 50 Años',
                  ],
                  onChanged: (value) {
                    // Mapear etiqueta a valor del enum
                    final conditionMap = {
                      'No Aplica': CondicionUsuaria.noAplica,
                      'Mujer en Edad Fértil': CondicionUsuaria.mujerEdadFertil,
                      'Gestante': CondicionUsuaria.gestante,
                      'Mujer Mayor de 50 Años': CondicionUsuaria.mujerMayor50,
                    };

                    controller.selectedUserCondition.value =
                        conditionMap[value]!;

                    // Si cambia de gestante a otro valor, limpiar campos
                    if (value != 'Gestante') {
                      controller.lastMenstrualDate.value = null;
                      controller.probableDeliveryDate.value = null;
                      controller.gestationWeeksController.clear();
                      controller.previousPregnanciesController.clear();
                    }
                  },
                  required: false,
                ),
                const SizedBox(height: 16),

                // Si es gestante, mostrar campos adicionales
                Obx(
                  () =>
                      controller.selectedUserCondition.value ==
                          CondicionUsuaria.gestante
                      ? Column(
                          children: [
                            // Fecha de última menstruación
                            FormFields.buildDatePickerField(
                              label: 'Fecha de Última Menstruación *',
                              value: controller.lastMenstrualDate.value,
                              icon: Icons.calendar_today,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: Get.context!,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now().subtract(
                                    const Duration(days: 280),
                                  ),
                                  lastDate: DateTime.now(),
                                  locale: const Locale('es'),
                                );
                                if (date != null) {
                                  controller.lastMenstrualDate.value = date;

                                  // Calcular automáticamente semanas de gestación
                                  final int daysDiff = DateTime.now()
                                      .difference(date)
                                      .inDays;
                                  final int weeks = daysDiff ~/ 7;
                                  final int remainingDays = daysDiff % 7;
                                  controller.gestationWeeksController.text =
                                      '$weeks semanas${remainingDays > 0 ? ' y $remainingDays días' : ''}';

                                  // Calcular fecha probable de parto (280 días después)
                                  controller.probableDeliveryDate.value = date
                                      .add(const Duration(days: 280));
                                }
                              },
                            ),
                            const SizedBox(height: 16),

                            // Semanas de gestación (calculado automáticamente - solo lectura)
                            FormFields.buildReadOnlyTextField(
                              label: 'Semanas de Gestación',
                              controller: controller.gestationWeeksController,
                              placeholder: 'Se calcula automáticamente',
                            ),
                            const SizedBox(height: 16),

                            // Fecha probable de parto (calculada automáticamente - solo lectura)
                            Obx(
                              () => FormFields.buildReadOnlyDateField(
                                label: 'Fecha Probable de Parto',
                                value:
                                    controller.probableDeliveryDate.value !=
                                        null
                                    ? DateFormat('dd/MM/yyyy').format(
                                        controller.probableDeliveryDate.value!,
                                      )
                                    : 'No calculada',
                                icon: Icons.calendar_today,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Embarazos previos
                            FormFields.buildTextField(
                              label: 'Cantidad de Embarazos Previos',
                              controller:
                                  controller.previousPregnanciesController,
                              placeholder: 'Ej: 2',
                              keyboardType: TextInputType.number,
                              required: false,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // Widget helper para botón de área
  Widget _buildAreaButton({
    required PatientFormController controller,
    required String label,
    required IconData icon,
    required Area value,
  }) {
    final isSelected = controller.selectedArea.value == value;

    return InkWell(
      onTap: () => controller.selectedArea.value = value,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Sección de datos de la madre
  Widget _buildMotherSection(PatientFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Datos de la Madre',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              // Pregunta: ¿Desea agregar datos de la madre?
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Desea agregar datos de la madre?',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Para pacientes menores de edad',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  value: controller.showMotherData.value,
                  onChanged: (value) => controller.showMotherData.value = value,
                  activeColor: primaryColor,
                ),
              ),

              // Campos de la madre (se muestran solo si showMotherData es true)
              Obx(
                () => controller.showMotherData.value
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Tipo y número de documento
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: FormFields.buildDropdownField(
                                  label: 'Tipo de Documento',
                                  value:
                                      controller.selectedMotherIdType.value ??
                                      'CC - Cédula de Ciudadanía',
                                  items: const [
                                    'CC - Cédula de Ciudadanía',
                                    'CE - Cédula de Extranjería',
                                    'PA - Pasaporte',
                                    'RC - Registro Civil',
                                    'TI - Tarjeta de Identidad',
                                  ],
                                  onChanged: (value) =>
                                      controller.selectedMotherIdType.value =
                                          value,
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: FormFields.buildTextField(
                                  label: 'Número de Documento',
                                  controller:
                                      controller.motherIdNumberController,
                                  placeholder: 'Ej: 1234567890',
                                  keyboardType: TextInputType.number,
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nombres
                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Primer Nombre',
                                  controller:
                                      controller.motherFirstNameController,
                                  placeholder: 'Ej: María',
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Segundo Nombre',
                                  controller:
                                      controller.motherSecondNameController,
                                  placeholder: 'Ej: Elena',
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Apellidos
                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Primer Apellido',
                                  controller:
                                      controller.motherLastNameController,
                                  placeholder: 'Ej: García',
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Segundo Apellido',
                                  controller:
                                      controller.motherSecondLastNameController,
                                  placeholder: 'Ej: López',
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Contacto
                          FormFields.buildTextField(
                            label: 'Email',
                            controller: controller.motherEmailController,
                            placeholder: 'Ej: maria@example.com',
                            keyboardType: TextInputType.emailAddress,
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Teléfono Fijo',
                                  controller:
                                      controller.motherLandlineController,
                                  placeholder: 'Ej: 6012345678',
                                  keyboardType: TextInputType.phone,
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Celular',
                                  controller:
                                      controller.motherCellphoneController,
                                  placeholder: 'Ej: 3001234567',
                                  keyboardType: TextInputType.phone,
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Régimen de Afiliación
                          FormFields.buildDropdownField(
                            label: 'Régimen de Afiliación',
                            value:
                                controller
                                    .selectedMotherAffiliationRegime
                                    .value
                                    ?.name ??
                                'N/A',
                            items: const [
                              'N/A',
                              'contributivo',
                              'subsidiado',
                              'poblacionPobreNoAsegurada',
                              'especial',
                              'excepcion',
                              'noAsegurado',
                            ],
                            onChanged: (value) {
                              if (value == 'N/A') {
                                controller
                                        .selectedMotherAffiliationRegime
                                        .value =
                                    null;
                              } else {
                                controller
                                    .selectedMotherAffiliationRegime
                                    .value = RegimenAfiliacion.values
                                    .firstWhere((e) => e.name == value);
                              }
                            },
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          // Pertenencia Étnica
                          FormFields.buildDropdownField(
                            label: 'Pertenencia Étnica',
                            value:
                                controller
                                    .selectedMotherEthnicity
                                    .value
                                    ?.name ??
                                'ninguno',
                            items: const [
                              'ninguno',
                              'indigena',
                              'rom',
                              'raizal',
                              'palenquero',
                              'negroAfrocolombiano',
                            ],
                            onChanged: (value) {
                              controller.selectedMotherEthnicity.value =
                                  PertenenciaEtnica.values.firstWhere(
                                    (e) => e.name == value,
                                  );
                            },
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          // Desplazada
                          Obx(
                            () => CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text(
                                '¿Es persona desplazada?',
                                style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              value: controller.motherDisplaced.value ?? false,
                              onChanged: (value) =>
                                  controller.motherDisplaced.value = value,
                              activeColor: primaryColor,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Sección de datos del cuidador
  Widget _buildCaregiverSection(PatientFormController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Datos del Cuidador',
            style: TextStyle(
              color: textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
              // Pregunta: ¿Desea agregar datos del cuidador?
              Obx(
                () => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Desea agregar datos del cuidador?',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: const Text(
                    'Tutor o responsable del paciente',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  value: controller.showCaregiverData.value,
                  onChanged: (value) =>
                      controller.showCaregiverData.value = value,
                  activeColor: primaryColor,
                ),
              ),

              // Campos del cuidador (se muestran solo si showCaregiverData es true)
              Obx(
                () => controller.showCaregiverData.value
                    ? Column(
                        children: [
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 16),

                          // Tipo y número de documento
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: FormFields.buildDropdownField(
                                  label: 'Tipo de Documento',
                                  value:
                                      controller
                                          .selectedCaregiverIdType
                                          .value ??
                                      'CC - Cédula de Ciudadanía',
                                  items: const [
                                    'CC - Cédula de Ciudadanía',
                                    'CE - Cédula de Extranjería',
                                    'PA - Pasaporte',
                                    'RC - Registro Civil',
                                    'TI - Tarjeta de Identidad',
                                  ],
                                  onChanged: (value) =>
                                      controller.selectedCaregiverIdType.value =
                                          value,
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: FormFields.buildTextField(
                                  label: 'Número de Documento',
                                  controller:
                                      controller.caregiverIdNumberController,
                                  placeholder: 'Ej: 1234567890',
                                  keyboardType: TextInputType.number,
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Nombres
                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Primer Nombre',
                                  controller:
                                      controller.caregiverFirstNameController,
                                  placeholder: 'Ej: Juan',
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Segundo Nombre',
                                  controller:
                                      controller.caregiverSecondNameController,
                                  placeholder: 'Ej: Carlos',
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Apellidos
                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Primer Apellido',
                                  controller:
                                      controller.caregiverLastNameController,
                                  placeholder: 'Ej: Pérez',
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Segundo Apellido',
                                  controller: controller
                                      .caregiverSecondLastNameController,
                                  placeholder: 'Ej: Ramírez',
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Parentesco
                          FormFields.buildTextField(
                            label: 'Parentesco',
                            controller:
                                controller.caregiverRelationshipController,
                            placeholder: 'Ej: Padre, Tío, Abuelo',
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          // Contacto
                          FormFields.buildTextField(
                            label: 'Email',
                            controller: controller.caregiverEmailController,
                            placeholder: 'Ej: juan@example.com',
                            keyboardType: TextInputType.emailAddress,
                            required: false,
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Teléfono Fijo',
                                  controller:
                                      controller.caregiverLandlineController,
                                  placeholder: 'Ej: 6012345678',
                                  keyboardType: TextInputType.phone,
                                  required: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FormFields.buildTextField(
                                  label: 'Celular',
                                  controller:
                                      controller.caregiverCellphoneController,
                                  placeholder: 'Ej: 3001234567',
                                  keyboardType: TextInputType.phone,
                                  required: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Botón de Sexo con icono
  Widget _buildSexButton({
    required PatientFormController controller,
    required String label,
    required IconData icon,
    required String value,
  }) {
    final sexoMap = {
      'Mujer': Sexo.mujer,
      'Hombre': Sexo.hombre,
      'Indeterminado': Sexo.indeterminado,
    };
    final valueLabel = {
      'mujer': 'Mujer',
      'hombre': 'Hombre',
      'indeterminado': 'Indeterminado',
    };
    final isSelected = valueLabel[controller.selectedSex.value.name] == value;

    return InkWell(
      onTap: () => controller.selectedSex.value = sexoMap[value]!,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Botón de segmento (para Estatus Migratorio)
  Widget _buildSegmentButton({
    required PatientFormController controller,
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == groupValue;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : textSecondary,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // Helper para obtener etiqueta legible de condición usuaria
  String _getUserConditionLabel(CondicionUsuaria? condition) {
    if (condition == null) return 'No Aplica';

    switch (condition) {
      case CondicionUsuaria.noAplica:
        return 'No Aplica';
      case CondicionUsuaria.mujerEdadFertil:
        return 'Mujer en Edad Fértil';
      case CondicionUsuaria.gestante:
        return 'Gestante';
      case CondicionUsuaria.mujerMayor50:
        return 'Mujer Mayor de 50 Años';
    }
  }
}
