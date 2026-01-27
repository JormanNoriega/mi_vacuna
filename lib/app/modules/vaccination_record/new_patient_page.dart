import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NewPatientPage extends StatefulWidget {
  const NewPatientPage({super.key});

  @override
  State<NewPatientPage> createState() => _NewPatientPageState();
}

class _NewPatientPageState extends State<NewPatientPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _idNumberController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _secondNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _secondLastNameController = TextEditingController();

  // Variables
  String _selectedIdType = 'CC - Cédula de Ciudadanía';
  final DateTime _attentionDate = DateTime.now();
  DateTime? _birthDate;
  bool _completeScheme = false;

  // Tipos de identificación
  final List<String> _idTypes = [
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
  ];

  // Calcular edad
  Map<String, int> _calculateAge() {
    if (_birthDate == null) {
      return {'years': 0, 'months': 0, 'days': 0, 'totalMonths': 0};
    }

    final now = DateTime.now();
    int years = now.year - _birthDate!.year;
    int months = now.month - _birthDate!.month;
    int days = now.day - _birthDate!.day;

    if (days < 0) {
      months--;
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final totalMonths =
        (now.year - _birthDate!.year) * 12 + (now.month - _birthDate!.month);
    final totalDays = now.difference(_birthDate!).inDays;

    return {
      'years': years,
      'months': months,
      'days': totalDays,
      'totalMonths': totalMonths.abs(),
    };
  }

  @override
  void dispose() {
    _idNumberController.dispose();
    _firstNameController.dispose();
    _secondNameController.dispose();
    _lastNameController.dispose();
    _secondLastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final age = _calculateAge();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111318)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Datos Básicos',
          style: TextStyle(
            color: Color(0xFF111318),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.cloud_done, color: Colors.green.shade600, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Offline Ready',
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFDBDFE6), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Registro de Paciente',
                      style: TextStyle(
                        color: Color(0xFF111318),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Paso 1 de 4',
                      style: TextStyle(
                        color: const Color(0xFF616F89),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: 0.25,
                    backgroundColor: const Color(0xFFDBDFE6),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF135BEC),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
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
                            'Nuevo Paciente',
                            style: TextStyle(
                              color: Color(0xFF111318),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete la información inicial para el registro de vacunación.',
                            style: TextStyle(
                              color: Color(0xFF616F89),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Fecha de Atención (Read Only)
                          _buildReadOnlyDateField(
                            label: 'Fecha de Atención',
                            value: DateFormat(
                              'dd MMMM, yyyy',
                              'es',
                            ).format(_attentionDate),
                            icon: Icons.calendar_today,
                          ),

                          // Tipo de Documento
                          _buildDropdownField(
                            label: 'Tipo de Documento',
                            value: _selectedIdType,
                            items: _idTypes,
                            onChanged: (value) {
                              setState(() {
                                _selectedIdType = value!;
                              });
                            },
                          ),

                          // Número de Identificación
                          _buildTextField(
                            label: 'Número de Identificación',
                            controller: _idNumberController,
                            placeholder: 'Ej: 1020304050',
                            keyboardType: TextInputType.number,
                            required: true,
                          ),

                          // Primer Nombre
                          _buildTextField(
                            label: 'Primer Nombre',
                            controller: _firstNameController,
                            placeholder: 'Ingrese el primer nombre',
                            required: true,
                          ),

                          // Segundo Nombre
                          _buildTextField(
                            label: 'Segundo Nombre',
                            controller: _secondNameController,
                            placeholder: 'Ingrese el segundo nombre (opcional)',
                            required: false,
                          ),

                          // Primer Apellido
                          _buildTextField(
                            label: 'Primer Apellido',
                            controller: _lastNameController,
                            placeholder: 'Ingrese el primer apellido',
                            required: true,
                          ),

                          // Segundo Apellido
                          _buildTextField(
                            label: 'Segundo Apellido',
                            controller: _secondLastNameController,
                            placeholder:
                                'Ingrese el segundo apellido (opcional)',
                            required: false,
                          ),

                          // Fecha de Nacimiento
                          _buildDatePickerField(
                            label: 'Fecha de Nacimiento',
                            value: _birthDate,
                            icon: Icons.cake,
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(
                                  const Duration(days: 365 * 25),
                                ),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                locale: const Locale('es', 'ES'),
                              );
                              if (date != null) {
                                setState(() {
                                  _birthDate = date;
                                });
                              }
                            },
                          ),

                          // Age Summary Card
                          if (_birthDate != null)
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF135BEC,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(
                                    0xFF135BEC,
                                  ).withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF135BEC,
                                      ).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.info,
                                      color: Color(0xFF135BEC),
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
                                            color: Color(0xFF135BEC),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${age['years']} años, ${age['months']} meses, ${age['days']} días',
                                          style: const TextStyle(
                                            color: Color(0xFF111318),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Total: ${age['totalMonths']} meses',
                                          style: const TextStyle(
                                            color: Color(0xFF616F89),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Esquema Completo
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
                                    'Esquema Completo',
                                    style: TextStyle(
                                      color: Color(0xFF111318),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFFDBDFE6),
                                    ),
                                  ),
                                  child: SwitchListTile(
                                    value: _completeScheme,
                                    onChanged: (value) {
                                      setState(() {
                                        _completeScheme = value;
                                      });
                                    },
                                    title: Text(
                                      _completeScheme ? 'Sí' : 'No',
                                      style: const TextStyle(
                                        color: Color(0xFF111318),
                                        fontSize: 16,
                                      ),
                                    ),
                                    activeThumbColor: const Color(0xFF135BEC),
                                    activeTrackColor: const Color(
                                      0xFF135BEC,
                                    ).withValues(alpha: 0.5),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
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
          ),
        ],
      ),

      // Sticky Footer
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFDBDFE6), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navegar al siguiente paso
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF135BEC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
                shadowColor: const Color(0xFF135BEC).withValues(alpha: 0.25),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Siguiente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget para campo de texto de solo lectura con fecha
  Widget _buildReadOnlyDateField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF111318),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBDFE6)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      value,
                      style: const TextStyle(
                        color: Color(0xFF616F89),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(icon, color: const Color(0xFF616F89), size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget para dropdown
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF111318),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFDBDFE6)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                icon: const Icon(Icons.expand_more, color: Color(0xFF616F89)),
                style: const TextStyle(color: Color(0xFF111318), fontSize: 16),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget para campo de texto
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              '$label${required ? ' *' : ''}',
              style: const TextStyle(
                color: Color(0xFF111318),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Color(0xFF111318), fontSize: 16),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(
                color: const Color(0xFF616F89).withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBDFE6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFDBDFE6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF135BEC),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            validator: required
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es requerido';
                    }
                    return null;
                  }
                : null,
          ),
        ],
      ),
    );
  }

  // Widget para selector de fecha
  Widget _buildDatePickerField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              '$label *',
              style: const TextStyle(
                color: Color(0xFF111318),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          InkWell(
            onTap: onTap,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDBDFE6)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        value != null
                            ? DateFormat('dd/MM/yyyy').format(value)
                            : 'Seleccione una fecha',
                        style: TextStyle(
                          color: value != null
                              ? const Color(0xFF111318)
                              : const Color(0xFF616F89).withValues(alpha: 0.5),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(icon, color: const Color(0xFF616F89), size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
