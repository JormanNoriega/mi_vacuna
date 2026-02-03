import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../data/database_helper.dart';
import 'package:intl/intl.dart';

/// Servicio para exportar datos de vacunación a formato CSV
class ExportService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Genera CSV de vacunación por rango de fechas
  /// Una fila por cada dosis aplicada con todos los datos del paciente
  Future<File> generateVaccinationReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    print('📊 Generando reporte de vacunación...');
    print(
      '📅 Rango: ${DateFormat('yyyy-MM-dd').format(startDate)} a ${DateFormat('yyyy-MM-dd').format(endDate)}',
    );

    // 1. Obtener datos de la BD filtrados por fecha
    final data = await _getVaccinationData(startDate, endDate);

    print('📋 Total de dosis aplicadas: ${data.length}');

    // 2. Crear estructura CSV con dos filas de encabezados
    List<List<dynamic>> csvData = [
      // Fila 1: Categorías
      _getCategoryHeaders(),
      // Fila 2: Campos específicos
      _getFieldHeaders(),
      // Datos: Una fila por cada dosis aplicada
      ...data,
    ];

    // 3. Convertir a CSV
    String csv = const ListToCsvConverter().convert(csvData);

    // 4. Guardar en archivo temporal
    final directory = await getTemporaryDirectory();
    final fileName =
        'vacunacion_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final file = File('${directory.path}/$fileName');

    await file.writeAsString(csv, encoding: utf8);

    print('✅ Archivo CSV generado: ${file.path}');

    return file;
  }

  /// Genera la fila de categorías (primera fila de encabezados)
  List<String> _getCategoryHeaders() {
    return [
      // DATOS BÁSICOS (18 campos) - Solo la primera celda con el título
      'DATOS BÁSICOS',
      '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
      // DATOS COMPLEMENTARIOS (22 campos)
      'DATOS COMPLEMENTARIOS',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      // ANTECEDENTES MÉDICOS (4 campos)
      'ANTECEDENTES MÉDICOS',
      '', '', '',
      // CONDICIÓN USUARIA (5 campos)
      'CONDICIÓN USUARIA',
      '', '', '', '',
      // HISTÓRICO DE ANTECEDENTES (4 campos)
      'HISTÓRICO DE ANTECEDENTES',
      '', '', '',
      // DATOS DE LA MADRE (12 campos)
      'DATOS DE LA MADRE',
      '', '', '', '', '', '', '', '', '', '', '',
      // DATOS DEL CUIDADOR (10 campos)
      'DATOS DEL CUIDADOR',
      '', '', '', '', '', '', '', '', '',
      // DATOS ENFERMERA (5 campos)
      'DATOS ENFERMERA',
      '', '', '', '',
      // VACUNAS (16 campos)
      'VACUNAS',
      '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',
    ];
  }

  /// Genera la fila de campos específicos (segunda fila de encabezados)
  List<String> _getFieldHeaders() {
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

      // DATOS COMPLEMENTARIOS (24 campos)
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

      // DATOS DOSIS APLICADA (16 campos)
      'Nombre Vacuna',
      'Código Vacuna',
      'Categoría Vacuna',
      'ID Dosis',
      'Dosis Seleccionada',
      'Fecha Aplicación',
      'Lote Vacuna',
      'Laboratorio',
      'Jeringa',
      'Lote Jeringa',
      'Lote Diluyente',
      'Gotero',
      'Tipo Neumococo',
      'Cantidad Frascos',
      'Observación',
      'Observación Personalizada',
    ];
  }

  /// Obtiene datos de vacunación por rango de fechas
  /// Retorna una fila por cada dosis aplicada con todos los datos del paciente
  Future<List<List<dynamic>>> _getVaccinationData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await _db.database;

    // Consulta que une applied_doses + patients + vaccines + nurses
    // Una fila por cada dosis aplicada
    final List<Map<String, dynamic>> results = await db.rawQuery(
      '''
      SELECT 
        -- DATOS PACIENTE (todos los campos)
        p.consecutivo,
        p.attention_date,
        p.id_type,
        p.id_number,
        p.first_name,
        p.second_name,
        p.last_name,
        p.second_last_name,
        p.birth_date,
        p.years,
        p.months,
        p.days,
        p.total_months,
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
        
        -- DATOS VACUNA
        v.name as vaccine_name,
        v.code as vaccine_code,
        v.category as vaccine_category,
        
        -- DATOS DOSIS APLICADA
        ad.id as dose_id,
        ad.selected_dose,
        ad.application_date,
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
        
        -- DATOS ENFERMERA
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
      ORDER BY ad.application_date DESC, p.last_name ASC, p.first_name ASC
    ''',
      [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
    );

    print('🔍 Dosis aplicadas encontradas: ${results.length}');

    // Convertir cada registro a una fila del CSV
    return results.map((row) {
      return [
        // DATOS BÁSICOS (18 campos)
        row['consecutivo']?.toString() ?? '',
        row['attention_date']?.toString() ?? '',
        row['id_type']?.toString() ?? '',
        row['id_number']?.toString() ?? '',
        row['first_name']?.toString() ?? '',
        row['second_name']?.toString() ?? '',
        row['last_name']?.toString() ?? '',
        row['second_last_name']?.toString() ?? '',
        row['birth_date']?.toString() ?? '',
        row['years']?.toString() ?? '',
        row['months']?.toString() ?? '',
        row['days']?.toString() ?? '',
        row['total_months']?.toString() ?? '',
        row['complete_scheme'] == 1 ? 'Sí' : 'No',
        row['sex']?.toString() ?? '',
        row['gender']?.toString() ?? '',
        row['sexual_orientation']?.toString() ?? '',
        row['gestational_age']?.toString() ?? '',

        // DATOS COMPLEMENTARIOS (24 campos)
        row['birth_country']?.toString() ?? '',
        row['migration_status']?.toString() ?? '',
        row['birth_place']?.toString() ?? '',
        row['affiliation_regime']?.toString() ?? '',
        row['insurer']?.toString() ?? '',
        row['ethnicity']?.toString() ?? '',
        row['displaced'] == 1 ? 'Sí' : 'No',
        row['disabled'] == 1 ? 'Sí' : 'No',
        row['deceased'] == 1 ? 'Sí' : 'No',
        row['armed_conflict_victim'] == 1 ? 'Sí' : 'No',
        row['currently_studying'] == 1 ? 'Sí' : 'No',
        row['residence_country']?.toString() ?? '',
        row['residence_department']?.toString() ?? '',
        row['residence_municipality']?.toString() ?? '',
        row['commune']?.toString() ?? '',
        row['area']?.toString() ?? '',
        row['address']?.toString() ?? '',
        row['landline']?.toString() ?? '',
        row['cellphone']?.toString() ?? '',
        row['email']?.toString() ?? '',
        row['authorize_calls'] == 1 ? 'Sí' : 'No',
        row['authorize_email'] == 1 ? 'Sí' : 'No',

        // ANTECEDENTES MÉDICOS (4 campos)
        row['has_contraindication'] == 1 ? 'Sí' : 'No',
        row['contraindication_details']?.toString() ?? '',
        row['has_previous_reaction'] == 1 ? 'Sí' : 'No',
        row['reaction_details']?.toString() ?? '',

        // CONDICIÓN USUARIA (5 campos)
        row['user_condition']?.toString() ?? '',
        row['last_menstrual_date']?.toString() ?? '',
        row['gestation_weeks']?.toString() ?? '',
        row['probable_delivery_date']?.toString() ?? '',
        row['previous_pregnancies']?.toString() ?? '',

        // HISTÓRICO DE ANTECEDENTES (4 campos)
        row['history_record_date']?.toString() ?? '',
        row['history_type']?.toString() ?? '',
        row['history_description']?.toString() ?? '',
        row['special_observations']?.toString() ?? '',

        // DATOS DE LA MADRE (12 campos)
        row['mother_id_type']?.toString() ?? '',
        row['mother_id_number']?.toString() ?? '',
        row['mother_first_name']?.toString() ?? '',
        row['mother_second_name']?.toString() ?? '',
        row['mother_last_name']?.toString() ?? '',
        row['mother_second_last_name']?.toString() ?? '',
        row['mother_email']?.toString() ?? '',
        row['mother_landline']?.toString() ?? '',
        row['mother_cellphone']?.toString() ?? '',
        row['mother_affiliation_regime']?.toString() ?? '',
        row['mother_ethnicity']?.toString() ?? '',
        row['mother_displaced'] == 1 ? 'Sí' : 'No',

        // DATOS DEL CUIDADOR (10 campos)
        row['caregiver_id_type']?.toString() ?? '',
        row['caregiver_id_number']?.toString() ?? '',
        row['caregiver_first_name']?.toString() ?? '',
        row['caregiver_second_name']?.toString() ?? '',
        row['caregiver_last_name']?.toString() ?? '',
        row['caregiver_second_last_name']?.toString() ?? '',
        row['caregiver_relationship']?.toString() ?? '',
        row['caregiver_email']?.toString() ?? '',
        row['caregiver_landline']?.toString() ?? '',
        row['caregiver_cellphone']?.toString() ?? '',

        // DATOS ENFERMERA (5 campos)
        row['nurse_name']?.toString() ?? '',
        row['nurse_document']?.toString() ?? '',
        row['nurse_email']?.toString() ?? '',
        row['nurse_phone']?.toString() ?? '',
        row['nurse_institution']?.toString() ?? '',

        // DATOS DOSIS APLICADA (16 campos)
        row['vaccine_name']?.toString() ?? '',
        row['vaccine_code']?.toString() ?? '',
        row['vaccine_category']?.toString() ?? '',
        row['dose_id']?.toString() ?? '',
        row['selected_dose']?.toString() ?? '',
        row['application_date']?.toString() ?? '',
        row['lot_number']?.toString() ?? '',
        row['selected_laboratory']?.toString() ?? '',
        row['selected_syringe']?.toString() ?? '',
        row['syringe_lot']?.toString() ?? '',
        row['diluent_lot']?.toString() ?? '',
        row['selected_dropper']?.toString() ?? '',
        row['selected_pneumococcal_type']?.toString() ?? '',
        row['vial_count']?.toString() ?? '',
        row['selected_observation']?.toString() ?? '',
        row['custom_observation']?.toString() ?? '',
      ];
    }).toList();
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
      INNER JOIN nurses n ON ad.nurse_id = n.id
      WHERE date(ad.application_date) BETWEEN date(?) AND date(?)
    ''',
      [
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      ],
    );

    return {
      'total_patients': result.first['total_patients'] ?? 0,
      'total_doses': result.first['total_doses'] ?? 0,
      'total_vaccines': result.first['total_vaccines'] ?? 0,
    };
  }
}
