import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// DatabaseHelper - Maneja solo la conexión y creación de tablas
/// No contiene lógica de negocio - usa Services para operaciones CRUD
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mi_vacuna.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNull = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const intTypeNull = 'INTEGER';

    // Tabla de enfermeras
    await db.execute('''
      CREATE TABLE nurses (
        id $idType,
        idType $textType,
        idNumber $textType,
        firstName $textType,
        lastName $textType,
        email $textType,
        phone $textType,
        institution $textType,
        password $textType,
        createdAt $textType,
        UNIQUE(email),
        UNIQUE(idNumber)
      )
    ''');

    // Tabla de pacientes
    await db.execute('''
      CREATE TABLE patients (
        id $idType,
        nurse_id $intType,
        attention_date $textType,
        id_type $textType,
        id_number $textType,
        first_name $textType,
        second_name $textTypeNull,
        last_name $textType,
        second_last_name $textTypeNull,
        birth_date $textType,
        complete_scheme $intType,
        sex $textType,
        gender $textType,
        sexual_orientation $textType,
        gestational_weeks $intTypeNull,
        birth_country $textType,
        migration_status $textType,
        birth_place $textType,
        affiliation_regime $textType,
        insurer $textType,
        ethnicity $textType,
        displaced $intType,
        disabled $intType,
        deceased $intType,
        armed_conflict_victim $intType,
        currently_studying $intType,
        residence_country $textType,
        residence_department $textType,
        residence_municipality $textType,
        commune $textTypeNull,
        area $textType,
        address $textTypeNull,
        landline $textTypeNull,
        cellphone $textTypeNull,
        email $textTypeNull,
        authorize_calls $intType,
        authorize_email $intType,
        has_contraindication $intType,
        contraindication_details $textTypeNull,
        has_previous_reaction $intType,
        reaction_details $textTypeNull,
        user_condition $textType,
        last_menstrual_date $textTypeNull,
        previous_pregnancies $intTypeNull,
        created_at $textType,
        updated_at $textTypeNull,
        UNIQUE(id_number),
        FOREIGN KEY (nurse_id) REFERENCES nurses (id) ON DELETE RESTRICT
      )
    ''');

    // Tabla de cuidadores
    await db.execute('''
      CREATE TABLE caregivers (
        id $idType,
        patient_id $intType,
        caregiver_type $textType,
        id_type $textType,
        id_number $textType,
        first_name $textType,
        second_name $textTypeNull,
        last_name $textType,
        second_last_name $textTypeNull,
        relationship $textType,
        email $textType,
        landline $textTypeNull,
        cellphone $textTypeNull,
        affiliation_regime $textType,
        ethnicity $textType,
        displaced $intType,
        is_primary $intType,
        created_at $textType,
        updated_at $textTypeNull,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de antecedentes médicos
    await db.execute('''
      CREATE TABLE medical_history (
        id $idType,
        patient_id $intType,
        registration_date $textType,
        type $textType,
        description $textType,
        special_observations $textTypeNull,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
      )
    ''');

    // Tabla de dosis aplicadas
    await db.execute('''
      CREATE TABLE applied_doses (
        id $idType,
        patient_id $intType,
        nurse_id $intType,
        vaccine_type $textType,
        dose_number $intType,
        application_date $textType,
        lot_number $textType,
        syringe_lot $textTypeNull,
        diluent_lot $textTypeNull,
        device $textType,
        laboratory $textTypeNull,
        observation $textTypeNull,
        adverse_reaction $textTypeNull,
        pneumococcal_type $textTypeNull,
        vial_count $intTypeNull,
        next_dose_date $textTypeNull,
        created_at $textType,
        updated_at $textTypeNull,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
        FOREIGN KEY (nurse_id) REFERENCES nurses (id) ON DELETE RESTRICT
      )
    ''');
  }

  // Cerrar base de datos
  Future close() async {
    final db = await database;
    db.close();
  }
}
