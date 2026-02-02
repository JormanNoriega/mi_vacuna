import '../data/database_helper.dart';
import '../models/nurse_model.dart';
import 'package:uuid/uuid.dart';

class NurseService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  // Crear enfermera
  Future<String> createNurse(NurseModel nurse) async {
    final db = await _db.database;
    final nurseId = nurse.id ?? _uuid.v4();

    final nurseMap = nurse.toMap();
    nurseMap['id'] = nurseId;

    await db.insert('nurses', nurseMap);
    return nurseId;
  }

  // Obtener enfermera por email
  Future<NurseModel?> getNurseByEmail(String email) async {
    final db = await _db.database;
    final maps = await db.query(
      'nurses',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return NurseModel.fromMap(maps.first);
    }
    return null;
  }

  // Obtener enfermera por ID number
  Future<NurseModel?> getNurseByIdNumber(String idNumber) async {
    final db = await _db.database;
    final maps = await db.query(
      'nurses',
      where: 'idNumber = ?',
      whereArgs: [idNumber],
    );

    if (maps.isNotEmpty) {
      return NurseModel.fromMap(maps.first);
    }
    return null;
  }

  // Obtener todas las enfermeras
  Future<List<NurseModel>> getAllNurses() async {
    final db = await _db.database;
    final result = await db.query('nurses', orderBy: 'createdAt DESC');
    return result.map((map) => NurseModel.fromMap(map)).toList();
  }

  // Actualizar enfermera
  Future<int> updateNurse(NurseModel nurse) async {
    final db = await _db.database;
    return db.update(
      'nurses',
      nurse.toMap(),
      where: 'id = ?',
      whereArgs: [nurse.id],
    );
  }

  // Eliminar enfermera
  Future<int> deleteNurse(String id) async {
    final db = await _db.database;
    return await db.delete('nurses', where: 'id = ?', whereArgs: [id]);
  }

  // Verificar si existe email
  Future<bool> emailExists(String email) async {
    final nurse = await getNurseByEmail(email);
    return nurse != null;
  }

  // Verificar si existe número de ID
  Future<bool> idNumberExists(String idNumber) async {
    final nurse = await getNurseByIdNumber(idNumber);
    return nurse != null;
  }
}
