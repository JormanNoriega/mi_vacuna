import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/vaccine.dart';
import '../../models/vaccine_config_option.dart';
import '../../services/vaccine_service.dart';
import '../../data/database_helper.dart';
import '../../widgets/form_fields.dart';
import '../../theme/colors.dart';

class VaccineFormPage extends StatefulWidget {
  final Vaccine? vaccine; // null = crear nueva, con datos = editar

  const VaccineFormPage({Key? key, this.vaccine}) : super(key: key);

  @override
  State<VaccineFormPage> createState() => _VaccineFormPageState();
}

class _VaccineFormPageState extends State<VaccineFormPage> {
  final _formKey = GlobalKey<FormState>();
  final VaccineService _vaccineService = VaccineService();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _maxDosesController;
  late TextEditingController _minMonthsController;
  late TextEditingController _maxMonthsController;

  // Valores
  String _selectedCategory = 'Programa Ampliado de Inmunización (PAI)';
  bool _hasLaboratory = false;
  bool _hasLot = true;
  bool _hasSyringe = false;
  bool _hasSyringeLot = false;
  bool _hasDiluent = false;
  bool _hasDropper = false;
  bool _hasPneumococcalType = false;
  bool _hasVialCount = false;
  bool _hasObservation = false;
  bool _isActive = true;

  // Opciones de configuración
  final Map<ConfigFieldType, List<VaccineConfigOption>> _configOptions = {};
  bool _isLoading = false;
  int? _vaccineId;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.vaccine != null) {
      // Modo edición
      final vaccine = widget.vaccine!;
      _vaccineId = vaccine.id;
      _nameController = TextEditingController(text: vaccine.name);
      _codeController = TextEditingController(text: vaccine.code);
      _maxDosesController = TextEditingController(
        text: vaccine.maxDoses.toString(),
      );
      _minMonthsController = TextEditingController(
        text: vaccine.minMonths?.toString() ?? '',
      );
      _maxMonthsController = TextEditingController(
        text: vaccine.maxMonths?.toString() ?? '',
      );

      // Asegurar que la categoría sea válida
      final validCategories = [
        'Programa Ampliado de Inmunización (PAI)',
        'Especial',
        'Programa Ampliado de Inmunización (PAI) - Especial',
      ];
      _selectedCategory = validCategories.contains(vaccine.category)
          ? vaccine.category
          : 'Programa Ampliado de Inmunización (PAI)';

      _hasLaboratory = vaccine.hasLaboratory;
      _hasLot = vaccine.hasLot;
      _hasSyringe = vaccine.hasSyringe;
      _hasSyringeLot = vaccine.hasSyringeLot;
      _hasDiluent = vaccine.hasDiluent;
      _hasDropper = vaccine.hasDropper;
      _hasPneumococcalType = vaccine.hasPneumococcalType;
      _hasVialCount = vaccine.hasVialCount;
      _hasObservation = vaccine.hasObservation;
      _isActive = vaccine.isActive;

      _loadConfigOptions();
    } else {
      // Modo creación
      _nameController = TextEditingController();
      _codeController = TextEditingController();
      _maxDosesController = TextEditingController(text: '1');
      _minMonthsController = TextEditingController();
      _maxMonthsController = TextEditingController();
    }
  }

  Future<void> _loadConfigOptions() async {
    if (_vaccineId == null) return;

    setState(() => _isLoading = true);

    try {
      for (var fieldType in ConfigFieldType.values) {
        final options = await _vaccineService.getOptions(
          _vaccineId!,
          fieldType: fieldType,
        );
        _configOptions[fieldType] = options;
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar las opciones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundMedium,
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.vaccine == null ? 'Nueva Vacuna' : 'Editar Vacuna',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: _saveVaccine,
              icon: const Icon(Icons.save, color: primaryColor),
              label: const Text(
                'GUARDAR',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  _buildBasicInfoSection(),
                  const SizedBox(height: 16),
                  _buildAgeRangeSection(),
                  const SizedBox(height: 16),
                  _buildFeaturesSection(),
                  const SizedBox(height: 16),
                  if (_vaccineId != null) ...[
                    _buildConfigOptionsSection(),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
            'Información Básica',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Datos generales de la vacuna',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FormFields.buildTextField(
            label: 'Nombre de la Vacuna',
            controller: _nameController,
            placeholder: 'Ej: COVID-19, BCG, Hepatitis B',
            required: true,
          ),
          const SizedBox(height: 16),
          FormFields.buildTextField(
            label: widget.vaccine == null
                ? 'Código Único'
                : 'Código Único (No editable)',
            controller: _codeController,
            placeholder: 'Ej: covid19, bcg, hepatitis_b',
            required: true,
          ),
          if (widget.vaccine != null)
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 4),
              child: Text(
                'El código no puede modificarse después de crear la vacuna',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
            ),
          const SizedBox(height: 16),
          FormFields.buildDropdownField(
            label: 'Categoría',
            value: _selectedCategory,
            items: const [
              'Programa Ampliado de Inmunización (PAI)',
              'Especial',
              'Programa Ampliado de Inmunización (PAI) - Especial',
            ],
            onChanged: (value) => setState(() => _selectedCategory = value!),
            required: true,
          ),
          const SizedBox(height: 16),
          FormFields.buildTextField(
            label: 'Número Máximo de Dosis',
            controller: _maxDosesController,
            placeholder: 'Ej: 1, 2, 3',
            keyboardType: TextInputType.number,
            required: true,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Vacuna Activa',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Mostrar en la lista de vacunas disponibles',
                style: TextStyle(color: textSecondary, fontSize: 12),
              ),
              value: _isActive,
              activeColor: primaryColor,
              onChanged: (value) => setState(() => _isActive = value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeSection() {
    return Container(
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
            'Rango de Edad (Opcional)',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Especifica la edad recomendada en meses',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          FormFields.buildTextField(
            label: 'Edad Mínima (meses)',
            controller: _minMonthsController,
            placeholder: '0',
            keyboardType: TextInputType.number,
            required: false,
          ),
          const SizedBox(height: 16),
          FormFields.buildTextField(
            label: 'Edad Máxima (meses)',
            controller: _maxMonthsController,
            placeholder: '12',
            keyboardType: TextInputType.number,
            required: false,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
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
            'Características de la Vacuna',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona los campos que esta vacuna necesita',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          _buildFeatureSwitch(
            'Tiene Laboratorio',
            'Fabricante o marca del biológico',
            _hasLaboratory,
            (value) => setState(() => _hasLaboratory = value),
          ),
          _buildFeatureSwitch(
            'Tiene Lote',
            'Número de lote del biológico',
            _hasLot,
            (value) => setState(() => _hasLot = value),
          ),
          _buildFeatureSwitch(
            'Tiene Jeringa',
            'Tipo de jeringa utilizada',
            _hasSyringe,
            (value) => setState(() => _hasSyringe = value),
          ),
          _buildFeatureSwitch(
            'Tiene Lote de Jeringa',
            'Número de lote de la jeringa',
            _hasSyringeLot,
            (value) => setState(() => _hasSyringeLot = value),
          ),
          _buildFeatureSwitch(
            'Tiene Diluyente',
            'Requiere diluyente para preparación',
            _hasDiluent,
            (value) => setState(() => _hasDiluent = value),
          ),
          _buildFeatureSwitch(
            'Tiene Gotero',
            'Se aplica con gotero oral',
            _hasDropper,
            (value) => setState(() => _hasDropper = value),
          ),
          _buildFeatureSwitch(
            'Tiene Tipo Neumococo',
            'Especificar tipo de vacuna neumocócica',
            _hasPneumococcalType,
            (value) => setState(() => _hasPneumococcalType = value),
          ),
          _buildFeatureSwitch(
            'Tiene Conteo de Frascos',
            'Registrar cantidad de frascos usados',
            _hasVialCount,
            (value) => setState(() => _hasVialCount = value),
          ),
          _buildFeatureSwitch(
            'Tiene Observaciones',
            'Campo de texto para notas adicionales',
            _hasObservation,
            (value) => setState(() => _hasObservation = value),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? primaryColor.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: value ? primaryColor.withOpacity(0.3) : Colors.transparent,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(
          title,
          style: TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: value ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: textSecondary, fontSize: 12),
        ),
        value: value,
        activeColor: primaryColor,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildConfigOptionsSection() {
    return Container(
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
            'Opciones de Configuración',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Define las opciones disponibles para cada campo',
            style: TextStyle(color: textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 16),
          if (_hasLaboratory)
            _buildConfigOptionList('Laboratorios', ConfigFieldType.laboratory),
          if (_hasSyringe)
            _buildConfigOptionList('Jeringas', ConfigFieldType.syringe),
          if (_hasDropper)
            _buildConfigOptionList('Goteros', ConfigFieldType.dropper),
          if (_hasPneumococcalType)
            _buildConfigOptionList(
              'Tipos de Neumococo',
              ConfigFieldType.pneumococcalType,
            ),
          if (_hasObservation)
            _buildConfigOptionList(
              'Observaciones',
              ConfigFieldType.observation,
            ),
          _buildConfigOptionList('Dosis', ConfigFieldType.dose),
        ],
      ),
    );
  }

  Widget _buildConfigOptionList(String title, ConfigFieldType fieldType) {
    final options = _configOptions[fieldType] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        title: Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${options.length} opciones configuradas',
          style: const TextStyle(color: textSecondary, fontSize: 12),
        ),
        children: [
          ...options.map(
            (option) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: option.isDefault
                      ? primaryColor.withOpacity(0.3)
                      : borderColor,
                ),
              ),
              child: ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                title: Text(
                  option.displayName,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 13,
                    fontWeight: option.isDefault
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'Valor: ${option.value}',
                  style: const TextStyle(color: textSecondary, fontSize: 11),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (option.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Por Defecto',
                          style: TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: primaryColor,
                      ),
                      onPressed: () => _editConfigOption(option, fieldType),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () => _deleteConfigOption(option.id!),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: Icon(Icons.add_circle, color: primaryColor, size: 20),
              title: Text(
                'Agregar $title',
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () => _addConfigOption(fieldType),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVaccine() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final db = await DatabaseHelper.instance.database;

      final vaccine = Vaccine(
        id: _vaccineId,
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toLowerCase(),
        category: _selectedCategory,
        maxDoses: int.parse(_maxDosesController.text),
        minMonths: _minMonthsController.text.isEmpty
            ? null
            : int.parse(_minMonthsController.text),
        maxMonths: _maxMonthsController.text.isEmpty
            ? null
            : int.parse(_maxMonthsController.text),
        hasLaboratory: _hasLaboratory,
        hasLot: _hasLot,
        hasSyringe: _hasSyringe,
        hasSyringeLot: _hasSyringeLot,
        hasDiluent: _hasDiluent,
        hasDropper: _hasDropper,
        hasPneumococcalType: _hasPneumococcalType,
        hasVialCount: _hasVialCount,
        hasObservation: _hasObservation,
        isActive: _isActive,
        createdAt: widget.vaccine?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (_vaccineId == null) {
        // Crear nueva
        _vaccineId = await db.insert('vaccines', vaccine.toMap());
        Get.snackbar(
          'Éxito',
          'Vacuna creada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Cambiar a modo edición para poder agregar opciones
        setState(() {});
      } else {
        // Actualizar existente
        await db.update(
          'vaccines',
          vaccine.toMap(),
          where: 'id = ?',
          whereArgs: [_vaccineId],
        );
        Get.snackbar(
          'Éxito',
          'Vacuna actualizada correctamente',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }

      Get.back(result: true);
    } catch (e) {
      Get.snackbar('Error', 'No se pudo guardar: $e');
    }
  }

  Future<void> _addConfigOption(ConfigFieldType fieldType) async {
    final nameController = TextEditingController();
    bool isDefault = false;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Agregar ${_getFieldTypeName(fieldType)}',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFields.buildTextField(
                label: 'Nombre',
                controller: nameController,
                placeholder: 'Ej: Sanofi, Pfizer, 1ml, 2ml',
                required: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Seleccionar por defecto',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Se autoseleccionará al aplicar la vacuna',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  value: isDefault,
                  activeColor: primaryColor,
                  onChanged: (value) =>
                      setDialogState(() => isDefault = value!),
                ),
              ),
            ],
          ),
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
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Ingresa el nombre',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              try {
                final db = await DatabaseHelper.instance.database;
                final name = nameController.text.trim();
                final option = VaccineConfigOption(
                  vaccineId: _vaccineId!,
                  fieldType: fieldType,
                  value: name,
                  displayName: name,
                  sortOrder: (_configOptions[fieldType]?.length ?? 0),
                  isDefault: isDefault,
                );

                await db.insert('vaccine_config_options', option.toMap());
                await _loadConfigOptions();
                Get.back();
                Get.snackbar(
                  'Éxito',
                  'Opción agregada correctamente',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo agregar: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'AGREGAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _editConfigOption(
    VaccineConfigOption option,
    ConfigFieldType fieldType,
  ) async {
    final nameController = TextEditingController(text: option.displayName);
    bool isDefault = option.isDefault;

    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Editar ${_getFieldTypeName(fieldType)}',
          style: const TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FormFields.buildTextField(
                label: 'Nombre',
                controller: nameController,
                placeholder: 'Ej: Sanofi, Pfizer, 1ml, 2ml',
                required: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: borderColor),
                ),
                child: CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Seleccionar por defecto',
                    style: TextStyle(color: textPrimary, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Se autoseleccionará al aplicar la vacuna',
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  value: isDefault,
                  activeColor: primaryColor,
                  onChanged: (value) =>
                      setDialogState(() => isDefault = value!),
                ),
              ),
            ],
          ),
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
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Ingresa el nombre',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              try {
                final db = await DatabaseHelper.instance.database;
                final name = nameController.text.trim();
                await db.update(
                  'vaccine_config_options',
                  {
                    'value': name,
                    'display_name': name,
                    'is_default': isDefault ? 1 : 0,
                  },
                  where: 'id = ?',
                  whereArgs: [option.id],
                );
                await _loadConfigOptions();
                Get.back();
                Get.snackbar(
                  'Éxito',
                  'Opción actualizada correctamente',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'No se pudo actualizar: $e',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text(
              'GUARDAR',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteConfigOption(int optionId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('¿Eliminar esta opción?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Get.back(result: true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final db = await DatabaseHelper.instance.database;
        await db.delete(
          'vaccine_config_options',
          where: 'id = ?',
          whereArgs: [optionId],
        );
        await _loadConfigOptions();
        Get.snackbar(
          'Éxito',
          'Opción eliminada',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar('Error', 'No se pudo eliminar: $e');
      }
    }
  }

  String _getFieldTypeName(ConfigFieldType fieldType) {
    switch (fieldType) {
      case ConfigFieldType.dose:
        return 'Dosis';
      case ConfigFieldType.laboratory:
        return 'Laboratorio';
      case ConfigFieldType.syringe:
        return 'Jeringa';
      case ConfigFieldType.dropper:
        return 'Gotero';
      case ConfigFieldType.pneumococcalType:
        return 'Tipo de Neumococo';
      case ConfigFieldType.observation:
        return 'Observación';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _maxDosesController.dispose();
    _minMonthsController.dispose();
    _maxMonthsController.dispose();
    super.dispose();
  }
}
