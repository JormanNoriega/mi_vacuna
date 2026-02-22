import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/controllers/auth_controller.dart';
import 'app/modules/auth/login.dart';
import 'app/modules/export/export_page.dart';
import 'app/modules/license/license_screen.dart';
import 'app/services/license_service.dart';
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
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mi Vacuna',
      debugShowCheckedModeBanner: false,
      // ✅ Configuración correcta de localizaciones
      locale: const Locale('es', 'ES'),
      fallbackLocale: const Locale('es', 'ES'),
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LicenseWrapper(),
      getPages: [GetPage(name: '/export', page: () => const ExportPage())],
    );
  }
}

/// Widget que verifica si la app está desbloqueada
class LicenseWrapper extends StatefulWidget {
  const LicenseWrapper({super.key});

  @override
  State<LicenseWrapper> createState() => _LicenseWrapperState();
}

class _LicenseWrapperState extends State<LicenseWrapper> {
  late Future<bool> _unlockFuture;
  final _licenseService = LicenseService();

  @override
  void initState() {
    super.initState();
    // Crear el Future una sola vez para evitar múltiples llamadas
    _unlockFuture = _licenseService.isUnlocked();
  }

  void _onLicenseVerified() {
    // Después de desbloquear, actualizar el estado
    setState(() {
      _unlockFuture = Future.value(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _unlockFuture,
      builder: (context, snapshot) {
        // Mientras se verifica el estado
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF135BEC),
              ),
            ),
          );
        }

        // Si hay error, mostrar error loading
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final isUnlocked = snapshot.data ?? false;

        // Si no está desbloqueado, mostrar pantalla de desbloqueo
        if (!isUnlocked) {
          return LicenseScreen(onLicenseVerified: _onLicenseVerified);
        }

        // Si está desbloqueado, mostrar la app normalmente
        return const LoginPage();
      },
    );
  }
}
