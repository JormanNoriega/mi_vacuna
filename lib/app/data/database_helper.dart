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

    // Aquí se pueden agregar más tablas (patients, vaccines, etc.)
  }

  // Cerrar base de datos
  Future close() async {
    final db = await database;
    db.close();
  }
}
