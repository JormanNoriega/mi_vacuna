import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/location_models.dart';

class ColombiaLocationService {
  static ColombiaLocationService? _instance;
  List<Departamento>? _departamentos;

  ColombiaLocationService._();

  static ColombiaLocationService get instance {
    _instance ??= ColombiaLocationService._();
    return _instance!;
  }

  Future<List<Departamento>> getDepartamentos() async {
    if (_departamentos != null) {
      return _departamentos!;
    }

    try {
      final String jsonString = await rootBundle.loadString(
        'lib/app/data/colombia.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);

      _departamentos = jsonData
          .map((json) => Departamento.fromJson(json))
          .toList();

      return _departamentos!;
    } catch (e) {
      print('Error cargando datos de Colombia: $e');
      return [];
    }
  }

  List<String> getCiudadesByDepartamento(String departamentoNombre) {
    if (_departamentos == null) {
      return [];
    }

    final departamento = _departamentos!.firstWhere(
      (dept) => dept.nombre == departamentoNombre,
      orElse: () => Departamento(id: -1, nombre: '', ciudades: []),
    );

    return departamento.ciudades;
  }

  void clearCache() {
    _departamentos = null;
  }
}
