import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../models/nurse_model.dart';
import '../services/nurse_service.dart';

class AuthController extends GetxController {
  final NurseService _nurseService = NurseService();

  final Rx<NurseModel?> currentNurse = Rx<NurseModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoggedIn => currentNurse.value != null;

  // Hash de contraseña simple
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrar nueva enfermera
  Future<bool> register({
    required String idType,
    required String idNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String institution,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      // Verificar si el email ya existe
      if (await _nurseService.emailExists(email)) {
        errorMessage.value = 'El correo electrónico ya está registrado';
        return false;
      }

      // Verificar si el número de ID ya existe
      if (await _nurseService.idNumberExists(idNumber)) {
        errorMessage.value = 'El número de identificación ya está registrado';
        return false;
      }

      // Crear nueva enfermera
      final nurse = NurseModel(
        idType: idType,
        idNumber: idNumber,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        institution: institution,
        password: _hashPassword(password),
      );

      await _nurseService.createNurse(nurse);
      // Obtener la enfermera creada por email
      final createdNurse = await _nurseService.getNurseByEmail(email);
      currentNurse.value = createdNurse;

      return true;
    } catch (e) {
      errorMessage.value = 'Error al registrar: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Iniciar sesión
  Future<bool> login({
    required String emailOrId,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      NurseModel? nurse;

      // Intentar buscar por email
      if (emailOrId.contains('@')) {
        nurse = await _nurseService.getNurseByEmail(emailOrId);
      } else {
        // Buscar por número de ID
        nurse = await _nurseService.getNurseByIdNumber(emailOrId);
      }

      if (nurse == null) {
        errorMessage.value = 'Usuario no encontrado';
        return false;
      }

      // Verificar contraseña
      if (nurse.password != _hashPassword(password)) {
        errorMessage.value = 'Contraseña incorrecta';
        return false;
      }

      currentNurse.value = nurse;
      return true;
    } catch (e) {
      errorMessage.value = 'Error al iniciar sesión: ${e.toString()}';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Cerrar sesión
  void logout() {
    currentNurse.value = null;
  }

  // Limpiar mensaje de error
  void clearError() {
    errorMessage.value = '';
  }
}
