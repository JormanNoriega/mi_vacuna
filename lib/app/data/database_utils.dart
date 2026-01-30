import 'package:flutter/material.dart';
import 'database_helper.dart';

/// Utilidad para resetear la base de datos durante desarrollo
/// ADVERTENCIA: Esto eliminará TODOS los datos
class DatabaseUtils {
  static Future<void> resetDatabase() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Eliminar todas las tablas
      await db.execute('DROP TABLE IF EXISTS vaccination_records');
      await db.execute('DROP TABLE IF EXISTS nurses');

      // Cerrar la base de datos actual
      await db.close();

      // Nota: La base de datos se recreará automáticamente en la próxima inicialización
      debugPrint('✅ Base de datos reseteada correctamente');
      debugPrint('⚠️ Reinicie la aplicación para recrear las tablas');
    } catch (e) {
      debugPrint('❌ Error al resetear base de datos: $e');
    }
  }

  static Future<void> clearAllData() async {
    try {
      final db = await DatabaseHelper.instance.database;

      await db.delete('vaccination_records');
      await db.delete('nurses');

      debugPrint('✅ Todos los datos han sido eliminados');
    } catch (e) {
      debugPrint('❌ Error al limpiar datos: $e');
    }
  }

  static Future<Map<String, int>> getDatabaseStats() async {
    try {
      final db = await DatabaseHelper.instance.database;

      final nursesCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM nurses',
      );
      final recordsCount = await db.rawQuery(
        'SELECT COUNT(*) as count FROM vaccination_records',
      );

      return {
        'nurses': nursesCount.first['count'] as int,
        'vaccination_records': recordsCount.first['count'] as int,
      };
    } catch (e) {
      debugPrint('❌ Error al obtener estadísticas: $e');
      return {};
    }
  }

  static Future<void> printDatabaseInfo() async {
    final stats = await getDatabaseStats();
    debugPrint('📊 Estadísticas de la Base de Datos:');
    debugPrint('   - Enfermeras: ${stats['nurses']}');
    debugPrint('   - Registros de Vacunación: ${stats['vaccination_records']}');
  }
}
