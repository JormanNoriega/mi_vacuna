import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import '../data/database_helper.dart';
import 'package:intl/intl.dart';
import '../utils/age_calculator.dart';

/// Servicio para exportar datos de vacunación a formato Excel
class ExportService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  // Paleta de colores profesionales por categoría (formato RGB en hex)
  static const Map<String, String> categoryColors = {
    'DATOS BÁSICOS': 'FF4472C4', // Azul
    'DATOS COMPLEMENTARIOS': 'FF70AD47', // Verde
    'ANTECEDENTES MÉDICOS': 'FFFFC000', // Naranja
    'CONDICIÓN USUARIA': 'FFF4B084', // Naranja claro
    'HISTÓRICO DE ANTECEDENTES': 'FF92D050', // Verde claro
    'DATOS DE LA MADRE': 'FFE74C3C', // Rojo
    'DATOS DEL CUIDADOR': 'FF9B59B6', // Púrpura
    'DATOS ENFERMERA': 'FF3498DB', // Azul claro
    'VACUNAS': 'FF1ABC9C', // Turquesa
  };

  /// Genera Excel de vacunación por rango de fechas
  Future<File> generateVaccinationReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Crear workbook
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    // 1. Cargar estructura de vacunas dinámicamente
    final vaccineStructure = await _loadVaccineStructure();

    // 2. Obtener datos de la BD (con estructura dinámica)
    final data = await _getVaccinationData(startDate, endDate, vaccineStructure);

    // 3. Crear encabezados merged (dinámicos)
    _createMergedHeaders(sheet, vaccineStructure);

    // 4. Agregar datos
    _addDataRows(sheet, data);

    // 5. Generar nombre del archivo según el rango de fechas
    final isSameDay = startDate.year == endDate.year && 
                      startDate.month == endDate.month && 
                      startDate.day == endDate.day;

    final fileName = isSameDay
        ? 'reporte_${DateFormat('yyyyMMdd').format(startDate)}.xlsx'
        : 'reporte_${DateFormat('yyyyMMdd').format(startDate)}_${DateFormat('yyyyMMdd').format(endDate)}.xlsx';

    // 6. Guardar archivo
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');

    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  /// Carga la estructura dinámica de vacunas desde la BD
  /// Retorna mapa con info de cada vacuna y sus campos habilitados
  Future<Map<String, Map<String, dynamic>>> _loadVaccineStructure() async {
    final db = await _db.database;
    final Map<String, Map<String, dynamic>> structure = {};

    // Obtener todas las vacunas ordenadas por sequence
    final vaccines = await db.query(
      'vaccines',
      orderBy: 'vaccine_sequence ASC',
    );

    // Los 12 campos que el usuario quiere mostrar
    const vaccineFields = [
      'dose',
      'application_date',
      'lot_number',
      'laboratory',
      'syringe',
      'syringe_lot',
      'diluent_lot',
      'dropper',
      'pneumococcal_type',
      'vial_count',
      'observation',
      'custom_observation',
    ];

    for (final vaccine in vaccines) {
      final vaccineId = vaccine['id'] as String;

      // Mapeo de campos BD a flags has_*
      final fieldMapping = {
        'dose': true, // siempre mostrar dosis
        'application_date': true, // siempre mostrar fecha
        'lot_number': vaccine['has_lot'] == 1,
        'laboratory': vaccine['has_laboratory'] == 1,
        'syringe': vaccine['has_syringe'] == 1,
        'syringe_lot': vaccine['has_syringe_lot'] == 1,
        'diluent_lot': vaccine['has_diluent'] == 1,
        'dropper': vaccine['has_dropper'] == 1,
        'pneumococcal_type': vaccine['has_pneumococcal_type'] == 1,
        'vial_count': vaccine['has_vial_count'] == 1,
        'observation': vaccine['has_observation'] == 1,
        'custom_observation': true, // siempre mostrar observación personalizada
      };

      // Contar campos habilitados
      final enabledFields = vaccineFields
          .where((field) => fieldMapping[field] == true)
          .toList();

      structure[vaccineId] = {
        'name': vaccine['name'],
        'code': vaccine['code'],
        'sequence': vaccine['vaccine_sequence'],
        'fieldMapping': fieldMapping,
        'enabledFields': enabledFields,
        'totalFields': enabledFields.length,
      };
    }

    return structure;
  }

  /// Crea los encabezados merged con colores (dinámico)
  void _createMergedHeaders(
    Sheet sheet,
    Map<String, Map<String, dynamic>> vaccineStructure,
  ) {
    // 1. Categorías fijas antes de vacunas
    final categories = [
      MapEntry('DATOS BÁSICOS', 18),
      MapEntry('DATOS COMPLEMENTARIOS', 22),
      MapEntry('ANTECEDENTES MÉDICOS', 4),
      MapEntry('CONDICIÓN USUARIA', 5),
      MapEntry('HISTÓRICO DE ANTECEDENTES', 4),
      MapEntry('DATOS DE LA MADRE', 12),
      MapEntry('DATOS DEL CUIDADOR', 10),
      MapEntry('DATOS ENFERMERA', 5),
    ];

    int columnIndex = 0;
    // Encabezados fijos
    for (final entry in categories) {
      final category = entry.key;
      final fieldCount = entry.value;
      final cellColorHex = categoryColors[category] ?? 'FFFFFFFF';
      for (int i = 0; i < fieldCount; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: columnIndex + i,
          rowIndex: 0,
        ));
        if (i == 0) cell.value = category;
        final cellStyle = CellStyle(
          backgroundColorHex: cellColorHex,
          fontColorHex: 'FFFFFFFF',
          bold: true,
        );
        cell.cellStyle = cellStyle;
      }
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: columnIndex + fieldCount - 1,
          rowIndex: 0,
        ),
      );
      columnIndex += fieldCount;
    }

    // 2. Encabezados agrupados por vacuna (ordenadas por sequence)
    final sortedVaccines = vaccineStructure.entries.toList()
      ..sort((a, b) {
        final seqA = a.value['sequence'];
        final seqB = b.value['sequence'];
        final intSeqA = seqA is int ? seqA : (seqA == null ? 0 : int.tryParse(seqA.toString()) ?? 0);
        final intSeqB = seqB is int ? seqB : (seqB == null ? 0 : int.tryParse(seqB.toString()) ?? 0);
        return intSeqA.compareTo(intSeqB);
      });

    int vaccineIndex = 0;
    for (final entry in sortedVaccines) {
      final vaccineName = entry.value['name'] as String;
      final enabledFields = entry.value['enabledFields'] as List<String>;
      
      // Alternar entre turquesa oscuro y claro para diferenciar vacunas
      final isDarkVaccine = vaccineIndex % 2 == 0;
      final cellColorHex = isDarkVaccine ? 'FF1ABC9C' : 'FF5FD8D1'; // Oscuro y claro
      
      for (int i = 0; i < enabledFields.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: columnIndex + i,
          rowIndex: 0,
        ));
        if (i == 0) cell.value = vaccineName;
        
        // CellStyle con bordes negros
        final cellStyle = CellStyle(
          backgroundColorHex: cellColorHex,
          fontColorHex: 'FFFFFFFF',
          bold: true,
        );
        cell.cellStyle = cellStyle;
      }
      // Merge para la vacuna
      sheet.merge(
        CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0),
        CellIndex.indexByColumnRow(
          columnIndex: columnIndex + enabledFields.length - 1,
          rowIndex: 0,
        ),
      );
      columnIndex += enabledFields.length;
      vaccineIndex++;
    }

    // Fila 1: solo los nombres de los campos (sin prefijo de vacuna)
    final fixedFields = _getFixedFieldHeaders();
    int col = 0;
    for (final field in fixedFields) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: col,
        rowIndex: 1,
      ));
      cell.value = field;
      final cellStyle = CellStyle(
        backgroundColorHex: 'FFE7E6E6',
        bold: true,
      );
      cell.cellStyle = cellStyle;
      col++;
    }
    // Campos de vacunas (solo nombre del campo)
    final Map<String, String> fieldLabels = {
      'dose': 'Dosis',
      'application_date': 'Fecha Aplicación',
      'lot_number': 'Lote',
      'laboratory': 'Laboratorio',
      'syringe': 'Jeringa',
      'syringe_lot': 'Lote Jeringa',
      'diluent_lot': 'Diluyente',
      'dropper': 'Gotero',
      'pneumococcal_type': 'Tipo Neumococo',
      'vial_count': 'Cantidad Frascos',
      'observation': 'Observación',
      'custom_observation': 'Observación Personalizada',
    };
    int vaccineFieldIndex = 0;
    for (final entry in sortedVaccines) {
      final enabledFields = entry.value['enabledFields'] as List<String>;
      final isDarkVaccine = vaccineFieldIndex % 2 == 0;
      final cellColorHex = isDarkVaccine ? 'FFB8E7E1' : 'FFDAF5F2'; // Versiones más claras del turquesa
      
      for (final field in enabledFields) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 1,
        ));
        cell.value = fieldLabels[field] ?? field;
        final cellStyle = CellStyle(
          backgroundColorHex: cellColorHex,
          bold: true,
        );
        cell.cellStyle = cellStyle;
        col++;
      }
      vaccineFieldIndex++;
    }
  }

  /// Añade las filas de datos
  void _addDataRows(Sheet sheet, List<List<dynamic>> data) {
    for (int rowIndex = 0; rowIndex < data.length; rowIndex++) {
      final row = data[rowIndex];
      for (int colIndex = 0; colIndex < row.length; colIndex++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(
          columnIndex: colIndex,
          rowIndex: rowIndex + 2, // +2 por las filas de encabezado
        ));

        cell.value = row[colIndex]?.toString() ?? '';

        // Alternar colores de fila para mejor legibilidad
        final backgroundColor = rowIndex % 2 == 0 ? 'FFFFFFFF' : 'FFF2F2F2';

        final cellStyle = CellStyle(
          backgroundColorHex: backgroundColor,
        );
        cell.cellStyle = cellStyle;
      }
    }
  }

  /// Lista de campos (encabezados de segunda fila) - DINÁMICO


  List<String> _getFixedFieldHeaders() {
    return [
      // DATOS BÁSICOS (18 campos)
      'Consecutivo',
      'Fecha de atención',
      'Tipo de identificación',
      'Número de identificación',
      'Primer nombre',
      'Segundo nombre',
      'Primer apellido',
      'Segundo apellido',
      'Fecha de nacimiento',
      'AÑOS',
      'MESES',
      'DÍAS',
      'Total meses',
      'Esquema completo',
      'Sexo',
      'Género',
      'Orientación sexual',
      'Edad gestacional (semanas)',

      // DATOS COMPLEMENTARIOS (22 campos)
      'País de nacimiento',
      'Estatus Migratorio',
      'Lugar de atención del parto',
      'Régimen de afiliación',
      'Aseguradora',
      'Pertenencia étnica',
      'Desplazado',
      'Discapacitado',
      'Fallecido',
      'Víctima del conflicto armado',
      'Estudia actualmente',
      'País de residencia',
      'Departamento de residencia',
      'Municipio de residencia',
      'Comuna/Localidad',
      'Área',
      'Dirección con nomenclatura',
      'Teléfono fijo',
      'Celular',
      'Email',
      '¿Autoriza llamadas telefónicas?',
      '¿Autoriza envío de correo?',

      // ANTECEDENTES MÉDICOS (4 campos)
      '¿Sufre o ha sufrido algún evento o enfermedad que contraindique la vacunación?',
      'Cuál contraindicación',
      '¿Ha presentado reacción moderada o severa a biológicos anteriores?',
      'Cuál reacción',

      // CONDICIÓN USUARIA (5 campos)
      'Condición de la usuaria',
      'Fecha de última menstruación',
      'Semanas de gestación',
      'Fecha probable de parto',
      'Cantidad de embarazos previos',

      // HISTÓRICO DE ANTECEDENTES (4 campos)
      'Fecha de registro del antecedente',
      'Tipo',
      'Descripción',
      'Observaciones especiales',

      // DATOS DE LA MADRE (12 campos)
      'Tipo de identificación madre',
      'Número de identificación madre',
      'Primer nombre madre',
      'Segundo nombre madre',
      'Primer apellido madre',
      'Segundo apellido madre',
      'Correo electrónico madre',
      'Teléfono fijo madre',
      'Celular madre',
      'Régimen de afiliación madre',
      'Pertenencia étnica madre',
      'Desplazado madre',

      // DATOS DEL CUIDADOR (10 campos)
      'Tipo de identificación cuidador',
      'Número de identificación cuidador',
      'Primer nombre cuidador',
      'Segundo nombre cuidador',
      'Primer apellido cuidador',
      'Segundo apellido cuidador',
      'Parentesco',
      'Correo electrónico cuidador',
      'Teléfono fijo cuidador',
      'Celular cuidador',

      // DATOS ENFERMERA (5 campos)
      'Nombre Enfermera',
      'Documento Enfermera',
      'Correo electrónico Enfermera',
      'Teléfono Enfermera',
      'Institución Enfermera',
    ];
  }

  /// Obtiene datos de vacunación por rango de fechas - REESCRITO PARA AGRUPACIÓN DINÁMICA
  Future<List<List<dynamic>>> _getVaccinationData(
    DateTime startDate,
    DateTime endDate,
    Map<String, Map<String, dynamic>> vaccineStructure,
  ) async {
    final db = await _db.database;

    // Query: Obtener todas las dosis en el rango con datos de paciente y vacuna
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT 
        ad.id as dose_id,
        ad.patient_id,
        ad.vaccine_id,
        ad.application_date,
        ad.selected_dose,
        ad.lot_number,
        ad.selected_laboratory,
        ad.selected_syringe,
        ad.syringe_lot,
        ad.diluent_lot,
        ad.selected_dropper,
        ad.selected_pneumococcal_type,
        ad.vial_count,
        ad.selected_observation,
        ad.custom_observation,
        
        p.consecutivo,
        p.attention_date,
        p.id_type,
        p.id_number,
        p.first_name,
        p.second_name,
        p.last_name,
        p.second_last_name,
        p.birth_date,
        p.complete_scheme,
        p.sex,
        p.gender,
        p.sexual_orientation,
        p.gestational_age,
        p.birth_country,
        p.migration_status,
        p.birth_place,
        p.affiliation_regime,
        p.insurer,
        p.ethnicity,
        p.displaced,
        p.disabled,
        p.deceased,
        p.armed_conflict_victim,
        p.currently_studying,
        p.residence_country,
        p.residence_department,
        p.residence_municipality,
        p.commune,
        p.area,
        p.address,
        p.landline,
        p.cellphone,
        p.email,
        p.authorize_calls,
        p.authorize_email,
        p.has_contraindication,
        p.contraindication_details,
        p.has_previous_reaction,
        p.reaction_details,
        p.user_condition,
        p.last_menstrual_date,
        p.gestation_weeks,
        p.probable_delivery_date,
        p.previous_pregnancies,
        p.history_record_date,
        p.history_type,
        p.history_description,
        p.special_observations,
        p.mother_id_type,
        p.mother_id_number,
        p.mother_first_name,
        p.mother_second_name,
        p.mother_last_name,
        p.mother_second_last_name,
        p.mother_email,
        p.mother_landline,
        p.mother_cellphone,
        p.mother_affiliation_regime,
        p.mother_ethnicity,
        p.mother_displaced,
        p.caregiver_id_type,
        p.caregiver_id_number,
        p.caregiver_first_name,
        p.caregiver_second_name,
        p.caregiver_last_name,
        p.caregiver_second_last_name,
        p.caregiver_relationship,
        p.caregiver_email,
        p.caregiver_landline,
        p.caregiver_cellphone,
        
        v.id as vaccine_id_db,
        v.name as vaccine_name,
        v.code as vaccine_code,
        v.category as vaccine_category,
        
        n.firstName || ' ' || n.lastName as nurse_name,
        n.idNumber as nurse_document,
        n.email as nurse_email,
        n.phone as nurse_phone,
        n.institution as nurse_institution
        
      FROM applied_doses ad
      INNER JOIN patients p ON ad.patient_id = p.id
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      LEFT JOIN nurses n ON ad.nurse_id = n.id
      WHERE date(ad.application_date) BETWEEN date(?) AND date(?)
      ORDER BY ad.application_date DESC, p.last_name ASC, p.first_name ASC, v.vaccine_sequence ASC
    ''',
      [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
    );

    // AGRUPACIÓN: (patient_id + application_date) → detectar duplicados de misma vacuna
    // Normalizar la fecha usando solo DATE, sin hora/timestamp
    final Map<String, List<Map<String, dynamic>>> groupedByPatientDate = {};

    for (final dose in results) {
      final patientId = dose['patient_id'] as String;
      final appDate = dose['application_date'] as String;
      // Extraer solo la fecha (YYYY-MM-DD) sin la hora/timestamp
      // Formato ISO 8601: "2026-03-03T23:11:18.331393" → "2026-03-03"
      final normalizedDate = appDate.split('T')[0];
      final key = '$patientId|$normalizedDate';

      groupedByPatientDate.putIfAbsent(key, () => []);
      groupedByPatientDate[key]!.add(dose);
    }

    // Procesar cada grupo para generar filas
    final List<List<dynamic>> reportRows = [];

    for (final groupEntry in groupedByPatientDate.entries) {
      final doses = groupEntry.value;
      final firstDose = doses.first;

      // Contar dosis por vacuna
      final vaccineDoesesMap = <String, List<Map<String, dynamic>>>{};
      for (final dose in doses) {
        final vaccId = dose['vaccine_id'] as String;
        vaccineDoesesMap.putIfAbsent(vaccId, () => []);
        vaccineDoesesMap[vaccId]!.add(dose);
      }

      // Encontrar el máximo número de dosis de cualquier vacuna ese día
      int maxDosesPerDay = 0;
      for (final dosesList in vaccineDoesesMap.values) {
        if (dosesList.length > maxDosesPerDay) {
          maxDosesPerDay = dosesList.length;
        }
      }

      // Crear N filas (donde N = maxDosesPerDay)
      for (int doseIndex = 0; doseIndex < maxDosesPerDay; doseIndex++) {
        final row = _buildPatientRowWithDoseIndex(
          firstDose,
          vaccineDoesesMap,
          doseIndex,
          vaccineStructure,
        );
        reportRows.add(row);
      }
    }

    return reportRows;
  }

  /// Extrae datos básicos del paciente
  List<dynamic> _getBasicPatientData(Map<String, dynamic> patientData) {
    final birthDate = DateTime.parse(patientData['birth_date'].toString());
    final ageData = AgeCalculator.calculate(birthDate);

    // Función auxiliar para formatear fechas a "día mes año"
    String formatDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        return DateFormat('d MMMM yyyy', 'es_ES').format(date);
      } catch (e) {
        return dateStr;
      }
    }

    return [
      // DATOS BÁSICOS (18 campos)
      patientData['consecutivo']?.toString() ?? '',
      formatDate(patientData['attention_date']?.toString()),
      patientData['id_type']?.toString() ?? '',
      patientData['id_number']?.toString() ?? '',
      patientData['first_name']?.toString() ?? '',
      patientData['second_name']?.toString() ?? '',
      patientData['last_name']?.toString() ?? '',
      patientData['second_last_name']?.toString() ?? '',
      formatDate(patientData['birth_date']?.toString()),
      ageData['years'].toString(),
      ageData['months'].toString(),
      ageData['days'].toString(),
      ageData['totalMonths'].toString(),
      patientData['complete_scheme'] == 1 ? 'Sí' : 'No',
      patientData['sex']?.toString() ?? '',
      patientData['gender']?.toString() ?? '',
      patientData['sexual_orientation']?.toString() ?? '',
      patientData['gestational_age']?.toString() ?? '',

      // DATOS COMPLEMENTARIOS (22 campos)
      patientData['birth_country']?.toString() ?? '',
      patientData['migration_status']?.toString() ?? '',
      patientData['birth_place']?.toString() ?? '',
      patientData['affiliation_regime']?.toString() ?? '',
      patientData['insurer']?.toString() ?? '',
      patientData['ethnicity']?.toString() ?? '',
      patientData['displaced'] == 1 ? 'Sí' : 'No',
      patientData['disabled'] == 1 ? 'Sí' : 'No',
      patientData['deceased'] == 1 ? 'Sí' : 'No',
      patientData['armed_conflict_victim'] == 1 ? 'Sí' : 'No',
      patientData['currently_studying'] == 1 ? 'Sí' : 'No',
      patientData['residence_country']?.toString() ?? '',
      patientData['residence_department']?.toString() ?? '',
      patientData['residence_municipality']?.toString() ?? '',
      patientData['commune']?.toString() ?? '',
      patientData['area']?.toString() ?? '',
      patientData['address']?.toString() ?? '',
      patientData['landline']?.toString() ?? '',
      patientData['cellphone']?.toString() ?? '',
      patientData['email']?.toString() ?? '',
      patientData['authorize_calls'] == 1 ? 'Sí' : 'No',
      patientData['authorize_email'] == 1 ? 'Sí' : 'No',

      // ANTECEDENTES MÉDICOS (4 campos)
      patientData['has_contraindication'] == 1 ? 'Sí' : 'No',
      patientData['contraindication_details']?.toString() ?? '',
      patientData['has_previous_reaction'] == 1 ? 'Sí' : 'No',
      patientData['reaction_details']?.toString() ?? '',

      // CONDICIÓN USUARIA (5 campos)
      patientData['user_condition']?.toString() ?? '',
      patientData['last_menstrual_date']?.toString() ?? '',
      patientData['gestation_weeks']?.toString() ?? '',
      patientData['probable_delivery_date']?.toString() ?? '',
      patientData['previous_pregnancies']?.toString() ?? '',

      // HISTÓRICO DE ANTECEDENTES (4 campos)
      patientData['history_record_date']?.toString() ?? '',
      patientData['history_type']?.toString() ?? '',
      patientData['history_description']?.toString() ?? '',
      patientData['special_observations']?.toString() ?? '',

      // DATOS DE LA MADRE (12 campos)
      patientData['mother_id_type']?.toString() ?? '',
      patientData['mother_id_number']?.toString() ?? '',
      patientData['mother_first_name']?.toString() ?? '',
      patientData['mother_second_name']?.toString() ?? '',
      patientData['mother_last_name']?.toString() ?? '',
      patientData['mother_second_last_name']?.toString() ?? '',
      patientData['mother_email']?.toString() ?? '',
      patientData['mother_landline']?.toString() ?? '',
      patientData['mother_cellphone']?.toString() ?? '',
      patientData['mother_affiliation_regime']?.toString() ?? '',
      patientData['mother_ethnicity']?.toString() ?? '',
      patientData['mother_displaced'] == 1 ? 'Sí' : 'No',

      // DATOS DEL CUIDADOR (10 campos)
      patientData['caregiver_id_type']?.toString() ?? '',
      patientData['caregiver_id_number']?.toString() ?? '',
      patientData['caregiver_first_name']?.toString() ?? '',
      patientData['caregiver_second_name']?.toString() ?? '',
      patientData['caregiver_last_name']?.toString() ?? '',
      patientData['caregiver_second_last_name']?.toString() ?? '',
      patientData['caregiver_relationship']?.toString() ?? '',
      patientData['caregiver_email']?.toString() ?? '',
      patientData['caregiver_landline']?.toString() ?? '',
      patientData['caregiver_cellphone']?.toString() ?? '',

      // DATOS ENFERMERA (5 campos)
      patientData['nurse_name']?.toString() ?? '',
      patientData['nurse_document']?.toString() ?? '',
      patientData['nurse_email']?.toString() ?? '',
      patientData['nurse_phone']?.toString() ?? '',
      patientData['nurse_institution']?.toString() ?? '',
    ];
  }

  /// Extrae el valor de un campo específico de una dosis de vacuna
  dynamic _getVaccineFieldValue(Map<String, dynamic> dose, String field) {
    switch (field) {
      case 'dose':
        return dose['selected_dose']?.toString() ?? '';
      case 'application_date':
        return dose['application_date']?.toString() ?? '';
      case 'lot_number':
        return dose['lot_number']?.toString() ?? '';
      case 'laboratory':
        return dose['selected_laboratory']?.toString() ?? '';
      case 'syringe':
        return dose['selected_syringe']?.toString() ?? '';
      case 'syringe_lot':
        return dose['syringe_lot']?.toString() ?? '';
      case 'diluent_lot':
        return dose['diluent_lot']?.toString() ?? '';
      case 'dropper':
        return dose['selected_dropper']?.toString() ?? '';
      case 'pneumococcal_type':
        return dose['selected_pneumococcal_type']?.toString() ?? '';
      case 'vial_count':
        return dose['vial_count']?.toString() ?? '';
      case 'observation':
        return dose['selected_observation']?.toString() ?? '';
      case 'custom_observation':
        return dose['custom_observation']?.toString() ?? '';
      default:
        return '';
    }
  }

  /// Construye una fila basada en el índice de dosis para ese día
  /// Si una vacuna tiene múltiples dosis ese día, crea una fila por cada índice
  List<dynamic> _buildPatientRowWithDoseIndex(
    Map<String, dynamic> patientData,
    Map<String, List<Map<String, dynamic>>> vaccineDoesesMap,
    int doseIndex,
    Map<String, Map<String, dynamic>> vaccineStructure,
  ) {
    final row = _getBasicPatientData(patientData);

    // Ordenar vacunas por sequence
    final sortedVaccines = vaccineStructure.entries.toList()
      ..sort((a, b) {
        final seqA = a.value['sequence'];
        final seqB = b.value['sequence'];
        final intSeqA = seqA is int ? seqA : (seqA == null ? 0 : int.tryParse(seqA.toString()) ?? 0);
        final intSeqB = seqB is int ? seqB : (seqB == null ? 0 : int.tryParse(seqB.toString()) ?? 0);
        return intSeqA.compareTo(intSeqB);
      });

    // Llenar columnas de vacunas según el índice de dosis
    for (final vaccineEntry in sortedVaccines) {
      final vaccineId = vaccineEntry.key;
      final vaccineConfig = vaccineEntry.value;
      final enabledFields = vaccineConfig['enabledFields'] as List<String>;

      // Obtener las dosis de esta vacuna
      final dosesList = vaccineDoesesMap[vaccineId] ?? [];

      for (final field in enabledFields) {
        if (doseIndex < dosesList.length) {
          // Esta vacuna tiene una dosis en este índice
          row.add(_getVaccineFieldValue(dosesList[doseIndex], field));
        } else {
          // No hay dosis para este índice - dejar vacío
          row.add('');
        }
      }
    }

    return row;
  }


  /// Obtiene estadísticas del reporte
  Future<Map<String, dynamic>> getReportStatistics({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _db.database;

    final result = await db.rawQuery(
      '''
      SELECT 
        COUNT(DISTINCT ad.patient_id) as total_patients,
        COUNT(ad.id) as total_doses,
        COUNT(DISTINCT ad.vaccine_id) as total_vaccines
      FROM applied_doses ad
      INNER JOIN patients p ON ad.patient_id = p.id
      INNER JOIN vaccines v ON ad.vaccine_id = v.id
      LEFT JOIN nurses n ON ad.nurse_id = n.id
      WHERE date(ad.application_date) BETWEEN date(?) AND date(?)
    ''',
      [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
    );

    return {
      'total_patients': result.isNotEmpty ? result.first['total_patients'] ?? 0 : 0,
      'total_doses': result.isNotEmpty ? result.first['total_doses'] ?? 0 : 0,
      'total_vaccines': result.isNotEmpty ? result.first['total_vaccines'] ?? 0 : 0,
    };
  }
}
