import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LicenseService {
  static final LicenseService _instance = LicenseService._internal();
  
  final _secureStorage = const FlutterSecureStorage();
  
  static const String _unlockedKey = 'app_unlocked';
  static const String _correctPassword = 'T!i5?@gYQ11@60t(C[NuVD8Xk/PHn(*?c>1`a82NCfi>4J(-%%'; // Contraseña maestra

  factory LicenseService() {
    return _instance;
  }

  LicenseService._internal();

  /// Verifica si la app está desbloqueada
  Future<bool> isUnlocked() async {
    try {
      final unlocked = await _secureStorage.read(key: _unlockedKey);
      return unlocked == 'true';
    } catch (e) {
      print('Error al verificar desbloqueo: $e');
      return false;
    }
  }

  /// Verifica si la contraseña ingresada es correcta
  bool verifyPassword(String password) {
    return password == _correctPassword;
  }

  /// Desbloquea la app (guarda que fue desbloqueada)
  Future<void> unlock() async {
    try {
      await _secureStorage.write(key: _unlockedKey, value: 'true');
    } catch (e) {
      print('Error al desbloquear: $e');
    }
  }

  /// Reinicia el desbloqueo (para testing)
  Future<void> resetUnlock() async {
    try {
      await _secureStorage.delete(key: _unlockedKey);
    } catch (e) {
      print('Error al reiniciar: $e');
    }
  }
}
