import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'vaccine_seeder.dart';

/// DatabaseHelper - Singleton para gestión de base de datos SQLite
///
/// Tablas:
/// - nurses: Enfermeras/usuarios del sistema
/// - patients: Pacientes con toda su información
/// - vaccines: Catálogo de vacunas disponibles
/// - vaccine_config_options: Opciones configurables por vacuna (dosis, jeringas, etc.)
/// - applied_doses: Registro de cada vacuna aplicada
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

    return await openDatabase(
      path,
      version: 3, // Versión actualizada para UUID en patients
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    print('🔨 Creando base de datos versión $version...');

    // ==================== TABLA: NURSES ====================
    await db.execute('''
      CREATE TABLE nurses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idType TEXT NOT NULL,
        idNumber TEXT NOT NULL,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        institution TEXT NOT NULL,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        UNIQUE(email),
        UNIQUE(idNumber)
      )
    ''');

    // ==================== TABLA: VACCINES ====================
    await db.execute('''
      CREATE TABLE vaccines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        code TEXT NOT NULL UNIQUE,
        category TEXT NOT NULL,
        max_doses INTEGER NOT NULL,
        min_months INTEGER,
        max_months INTEGER,
        has_laboratory INTEGER DEFAULT 0,
        has_lot INTEGER DEFAULT 1,
        has_syringe INTEGER DEFAULT 0,
        has_syringe_lot INTEGER DEFAULT 0,
        has_diluent INTEGER DEFAULT 0,
        has_dropper INTEGER DEFAULT 0,
        has_pneumococcal_type INTEGER DEFAULT 0,
        has_vial_count INTEGER DEFAULT 0,
        has_observation INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // ==================== TABLA: VACCINE_CONFIG_OPTIONS ====================
    await db.execute('''
      CREATE TABLE vaccine_config_options (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vaccine_id INTEGER NOT NULL,
        field_type TEXT NOT NULL,
        value TEXT NOT NULL,
        display_name TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0,
        is_default INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        FOREIGN KEY (vaccine_id) REFERENCES vaccines (id) ON DELETE CASCADE
      )
    ''');

    // Índices para vaccine_config_options
    await db.execute('''
      CREATE INDEX idx_config_vaccine 
      ON vaccine_config_options(vaccine_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_config_type 
      ON vaccine_config_options(field_type)
    ''');
    await db.execute('''
      CREATE INDEX idx_config_active 
      ON vaccine_config_options(is_active)
    ''');

    // ==================== TABLA: APPLIED_DOSES ====================
    await db.execute('''
      CREATE TABLE applied_doses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uuid TEXT NOT NULL UNIQUE,
        patient_id TEXT NOT NULL, -- Cambiado a TEXT para UUID
        nurse_id TEXT NOT NULL,
        vaccine_id INTEGER NOT NULL,
        application_date TEXT NOT NULL,
        selected_dose TEXT,
        selected_laboratory TEXT,
        lot_number TEXT NOT NULL,
        selected_syringe TEXT,
        syringe_lot TEXT,
        diluent_lot TEXT,
        selected_dropper TEXT,
        selected_pneumococcal_type TEXT,
        vial_count INTEGER,
        selected_observation TEXT,
        custom_observation TEXT,
        next_dose_date TEXT,
        sync_status TEXT DEFAULT 'local',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
        FOREIGN KEY (nurse_id) REFERENCES nurses (id),
        FOREIGN KEY (vaccine_id) REFERENCES vaccines (id)
      )
    ''');

    // Índices para applied_doses
    await db.execute('''
      CREATE INDEX idx_dose_patient 
      ON applied_doses(patient_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_dose_vaccine 
      ON applied_doses(vaccine_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_dose_nurse 
      ON applied_doses(nurse_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_dose_date 
      ON applied_doses(application_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_dose_sync 
      ON applied_doses(sync_status)
    ''');

    // ==================== TABLA: PATIENTS ====================
    await db.execute('''
      CREATE TABLE patients (
        id TEXT PRIMARY KEY NOT NULL, -- UUID como String
        nurse_id TEXT NOT NULL,
        
        -- DATOS BÁSICOS
        consecutivo TEXT,
        attention_date TEXT NOT NULL,
        id_type TEXT NOT NULL,
        id_number TEXT NOT NULL,
        first_name TEXT NOT NULL,
        second_name TEXT,
        last_name TEXT NOT NULL,
        second_last_name TEXT,
        birth_date TEXT NOT NULL,
        years INTEGER,
        months INTEGER,
        days INTEGER,
        total_months INTEGER,
        complete_scheme INTEGER DEFAULT 0,
        sex TEXT NOT NULL,
        gender TEXT,
        sexual_orientation TEXT,
        gestational_age INTEGER,
        
        -- DATOS COMPLEMENTARIOS
        birth_country TEXT NOT NULL,
        migration_status TEXT,
        birth_place TEXT,
        affiliation_regime TEXT,
        insurer TEXT,
        ethnicity TEXT,
        displaced INTEGER DEFAULT 0,
        disabled INTEGER DEFAULT 0,
        deceased INTEGER DEFAULT 0,
        armed_conflict_victim INTEGER DEFAULT 0,
        currently_studying INTEGER,
        residence_country TEXT,
        residence_department TEXT,
        residence_municipality TEXT,
        commune TEXT,
        area TEXT,
        address TEXT,
        landline TEXT,
        cellphone TEXT,
        email TEXT,
        authorize_calls INTEGER DEFAULT 0,
        authorize_email INTEGER DEFAULT 0,
        
        -- ANTECEDENTES MÉDICOS
        has_contraindication INTEGER DEFAULT 0,
        contraindication_details TEXT,
        has_previous_reaction INTEGER DEFAULT 0,
        reaction_details TEXT,
        
        -- HISTÓRICO
        history_record_date TEXT,
        history_type TEXT,
        history_description TEXT,
        special_observations TEXT,
        
        -- CONDICIÓN USUARIA
        user_condition TEXT,
        last_menstrual_date TEXT,
        gestation_weeks INTEGER,
        probable_delivery_date TEXT,
        previous_pregnancies INTEGER,
        
        -- DATOS DE LA MADRE
        mother_id_type TEXT,
        mother_id_number TEXT,
        mother_first_name TEXT,
        mother_second_name TEXT,
        mother_last_name TEXT,
        mother_second_last_name TEXT,
        mother_email TEXT,
        mother_landline TEXT,
        mother_cellphone TEXT,
        mother_affiliation_regime TEXT,
        mother_ethnicity TEXT,
        mother_displaced INTEGER,
        
        -- DATOS DEL CUIDADOR
        caregiver_id_type TEXT,
        caregiver_id_number TEXT,
        caregiver_first_name TEXT,
        caregiver_second_name TEXT,
        caregiver_last_name TEXT,
        caregiver_second_last_name TEXT,
        caregiver_relationship TEXT,
        caregiver_email TEXT,
        caregiver_landline TEXT,
        caregiver_cellphone TEXT,
        
        -- METADATOS
        created_at TEXT NOT NULL,
        updated_at TEXT,
        
        FOREIGN KEY (nurse_id) REFERENCES nurses (id)
      )
    ''');

    // Índices para patients
    await db.execute('''
      CREATE INDEX idx_patient_id_number 
      ON patients(id_number)
    ''');
    await db.execute('''
      CREATE INDEX idx_patient_nurse 
      ON patients(nurse_id)
    ''');
    await db.execute('''
      CREATE INDEX idx_patient_attention_date 
      ON patients(attention_date)
    ''');
    await db.execute('''
      CREATE INDEX idx_patient_name 
      ON patients(first_name, last_name)
    ''');

    print('✅ Tablas creadas exitosamente');

    // ==================== EJECUTAR SEEDER ====================
    print('🌱 Ejecutando seeder de vacunas...');
    await VaccineSeeder.seedAll(db);
    print('✅ Base de datos inicializada completamente');
  }

  /// Manejo de migraciones de versiones
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    print('⚠️ Migración de v$oldVersion a v$newVersion');

    if (oldVersion < 2) {
      // Migración de v1 a v2: Agregar nuevas tablas
      print('📦 Creando nuevas tablas...');

      // Crear solo las tablas nuevas (vaccines, vaccine_config_options, applied_doses, patients)
      // La tabla nurses ya existe desde v1

      await db.execute('''
        CREATE TABLE IF NOT EXISTS vaccines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          code TEXT NOT NULL UNIQUE,
          category TEXT NOT NULL,
          max_doses INTEGER NOT NULL,
          min_months INTEGER,
          max_months INTEGER,
          has_laboratory INTEGER DEFAULT 0,
          has_lot INTEGER DEFAULT 1,
          has_syringe INTEGER DEFAULT 0,
          has_syringe_lot INTEGER DEFAULT 0,
          has_diluent INTEGER DEFAULT 0,
          has_dropper INTEGER DEFAULT 0,
          has_pneumococcal_type INTEGER DEFAULT 0,
          has_vial_count INTEGER DEFAULT 0,
          has_observation INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS vaccine_config_options (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          vaccine_id INTEGER NOT NULL,
          field_type TEXT NOT NULL,
          value TEXT NOT NULL,
          display_name TEXT NOT NULL,
          sort_order INTEGER DEFAULT 0,
          is_default INTEGER DEFAULT 0,
          is_active INTEGER DEFAULT 1,
          FOREIGN KEY (vaccine_id) REFERENCES vaccines (id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS applied_doses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          patient_id INTEGER NOT NULL,
          nurse_id INTEGER NOT NULL,
          vaccine_id INTEGER NOT NULL,
          application_date TEXT NOT NULL,
          selected_dose TEXT,
          selected_laboratory TEXT,
          lot_number TEXT NOT NULL,
          selected_syringe TEXT,
          syringe_lot TEXT,
          diluent_lot TEXT,
          selected_dropper TEXT,
          selected_pneumococcal_type TEXT,
          vial_count INTEGER,
          selected_observation TEXT,
          custom_observation TEXT,
          next_dose_date TEXT,
          sync_status TEXT DEFAULT 'local',
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
          FOREIGN KEY (nurse_id) REFERENCES nurses (id),
          FOREIGN KEY (vaccine_id) REFERENCES vaccines (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS patients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nurse_id INTEGER NOT NULL,
          consecutivo TEXT,
          attention_date TEXT NOT NULL,
          id_type TEXT NOT NULL,
          id_number TEXT NOT NULL,
          first_name TEXT NOT NULL,
          second_name TEXT,
          last_name TEXT NOT NULL,
          second_last_name TEXT,
          birth_date TEXT NOT NULL,
          years INTEGER,
          months INTEGER,
          days INTEGER,
          total_months INTEGER,
          complete_scheme INTEGER DEFAULT 0,
          sex TEXT NOT NULL,
          gender TEXT,
          sexual_orientation TEXT,
          gestational_age INTEGER,
          birth_country TEXT NOT NULL,
          migration_status TEXT,
          birth_place TEXT,
          affiliation_regime TEXT,
          insurer TEXT,
          ethnicity TEXT,
          displaced INTEGER DEFAULT 0,
          disabled INTEGER DEFAULT 0,
          deceased INTEGER DEFAULT 0,
          armed_conflict_victim INTEGER DEFAULT 0,
          currently_studying INTEGER,
          residence_country TEXT,
          residence_department TEXT,
          residence_municipality TEXT,
          commune TEXT,
          area TEXT,
          address TEXT,
          landline TEXT,
          cellphone TEXT,
          email TEXT,
          authorize_calls INTEGER DEFAULT 0,
          authorize_email INTEGER DEFAULT 0,
          has_contraindication INTEGER DEFAULT 0,
          contraindication_details TEXT,
          has_previous_reaction INTEGER DEFAULT 0,
          reaction_details TEXT,
          history_record_date TEXT,
          history_type TEXT,
          history_description TEXT,
          special_observations TEXT,
          user_condition TEXT,
          last_menstrual_date TEXT,
          gestation_weeks INTEGER,
          probable_delivery_date TEXT,
          previous_pregnancies INTEGER,
          mother_id_type TEXT,
          mother_id_number TEXT,
          mother_first_name TEXT,
          mother_second_name TEXT,
          mother_last_name TEXT,
          mother_second_last_name TEXT,
          mother_email TEXT,
          mother_landline TEXT,
          mother_cellphone TEXT,
          mother_affiliation_regime TEXT,
          mother_ethnicity TEXT,
          mother_displaced INTEGER,
          caregiver_id_type TEXT,
          caregiver_id_number TEXT,
          caregiver_first_name TEXT,
          caregiver_second_name TEXT,
          caregiver_last_name TEXT,
          caregiver_second_last_name TEXT,
          caregiver_relationship TEXT,
          caregiver_email TEXT,
          caregiver_landline TEXT,
          caregiver_cellphone TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (nurse_id) REFERENCES nurses (id)
        )
      ''');

      // Crear índices
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_config_vaccine ON vaccine_config_options(vaccine_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_dose_patient ON applied_doses(patient_id)',
      );
      await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_patient_id_number ON patients(id_number)',
      );

      // Ejecutar seeder
      print('🌱 Cargando catálogo de vacunas...');
      await VaccineSeeder.seedAll(db);

      print('✅ Migración completada');
    }

    if (oldVersion < 3) {
      // Migración de v2 a v3: Cambiar IDs a UUID (patients y nurses)
      print('🔄 Migrando a UUID (se borrarán todos los datos)...');

      // Borrar tablas existentes
      await db.execute('DROP TABLE IF EXISTS applied_doses');
      await db.execute('DROP TABLE IF EXISTS patients');
      await db.execute('DROP TABLE IF EXISTS nurses');

      // Recrear nurses con UUID
      await db.execute('''
        CREATE TABLE nurses (
          id TEXT PRIMARY KEY NOT NULL,
          idType TEXT NOT NULL,
          idNumber TEXT NOT NULL,
          firstName TEXT NOT NULL,
          lastName TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT NOT NULL,
          institution TEXT NOT NULL,
          password TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');

      // Recrear patients con UUID
      await db.execute('''
        CREATE TABLE patients (
          id TEXT PRIMARY KEY NOT NULL,
          nurse_id TEXT NOT NULL,
          consecutivo TEXT,
          attention_date TEXT NOT NULL,
          id_type TEXT NOT NULL,
          id_number TEXT NOT NULL,
          first_name TEXT NOT NULL,
          second_name TEXT,
          last_name TEXT NOT NULL,
          second_last_name TEXT,
          birth_date TEXT NOT NULL,
          years INTEGER,
          months INTEGER,
          days INTEGER,
          total_months INTEGER,
          complete_scheme INTEGER DEFAULT 0,
          sex TEXT NOT NULL,
          gender TEXT,
          sexual_orientation TEXT,
          gestational_age INTEGER,
          birth_country TEXT NOT NULL,
          migration_status TEXT,
          birth_place TEXT,
          affiliation_regime TEXT,
          insurer TEXT,
          ethnicity TEXT,
          displaced INTEGER DEFAULT 0,
          disabled INTEGER DEFAULT 0,
          deceased INTEGER DEFAULT 0,
          armed_conflict_victim INTEGER DEFAULT 0,
          currently_studying INTEGER,
          residence_country TEXT,
          residence_department TEXT,
          residence_municipality TEXT,
          commune TEXT,
          area TEXT,
          address TEXT,
          landline TEXT,
          cellphone TEXT,
          email TEXT,
          authorize_calls INTEGER DEFAULT 0,
          authorize_email INTEGER DEFAULT 0,
          has_contraindication INTEGER DEFAULT 0,
          contraindication_details TEXT,
          has_previous_reaction INTEGER DEFAULT 0,
          reaction_details TEXT,
          history_record_date TEXT,
          history_type TEXT,
          history_description TEXT,
          special_observations TEXT,
          user_condition TEXT,
          last_menstrual_date TEXT,
          gestation_weeks INTEGER,
          probable_delivery_date TEXT,
          previous_pregnancies INTEGER,
          mother_id_type TEXT,
          mother_id_number TEXT,
          mother_first_name TEXT,
          mother_second_name TEXT,
          mother_last_name TEXT,
          mother_second_last_name TEXT,
          mother_email TEXT,
          mother_landline TEXT,
          mother_cellphone TEXT,
          mother_affiliation_regime TEXT,
          mother_ethnicity TEXT,
          mother_displaced INTEGER,
          caregiver_id_type TEXT,
          caregiver_id_number TEXT,
          caregiver_first_name TEXT,
          caregiver_second_name TEXT,
          caregiver_last_name TEXT,
          caregiver_second_last_name TEXT,
          caregiver_relationship TEXT,
          caregiver_email TEXT,
          caregiver_landline TEXT,
          caregiver_cellphone TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (nurse_id) REFERENCES nurses (id)
        )
      ''');

      // Recrear applied_doses con UUIDs
      await db.execute('''
        CREATE TABLE applied_doses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          uuid TEXT NOT NULL UNIQUE,
          patient_id TEXT NOT NULL,
          nurse_id TEXT NOT NULL,
          vaccine_id INTEGER NOT NULL,
          application_date TEXT NOT NULL,
          selected_dose TEXT,
          selected_laboratory TEXT,
          lot_number TEXT NOT NULL,
          selected_syringe TEXT,
          syringe_lot TEXT,
          diluent_lot TEXT,
          selected_dropper TEXT,
          selected_pneumococcal_type TEXT,
          vial_count INTEGER,
          selected_observation TEXT,
          custom_observation TEXT,
          next_dose_date TEXT,
          sync_status TEXT DEFAULT 'local',
          created_at TEXT NOT NULL,
          updated_at TEXT,
          FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
          FOREIGN KEY (nurse_id) REFERENCES nurses (id),
          FOREIGN KEY (vaccine_id) REFERENCES vaccines (id)
        )
      ''');

      // Recrear índices
      await db.execute(
        'CREATE INDEX idx_patient_id_number ON patients(id_number)',
      );
      await db.execute(
        'CREATE INDEX idx_dose_patient ON applied_doses(patient_id)',
      );
      await db.execute(
        'CREATE INDEX idx_dose_nurse ON applied_doses(nurse_id)',
      );

      print('✅ Migración a UUID completada (datos eliminados)');
    }
  }

  /// Cerrar base de datos
  Future close() async {
    final db = await database;
    db.close();
  }
}
