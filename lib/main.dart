import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/controllers/auth_controller.dart';
import 'app/modules/auth/login.dart';
import 'app/data/database_helper.dart';

void main() async {
  // Asegurar que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar locale en español para formateo de fechas
  await initializeDateFormatting('es', null);

  // Inicializar la base de datos
  await DatabaseHelper.instance.database;

  // Inicializar controladores globales
  Get.put(AuthController());
  // PatientFormController se creará cuando se necesite, no es global

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mi Vacuna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
