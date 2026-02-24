import 'dart:convert';
import 'package:flutter/services.dart';

class Country {
  final String nameES;
  final String nameEN;
  final String iso2;
  final String iso3;
  final String phoneCode;

  Country({
    required this.nameES,
    required this.nameEN,
    required this.iso2,
    required this.iso3,
    required this.phoneCode,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      nameES: json['nameES'] ?? '',
      nameEN: json['nameEN'] ?? '',
      iso2: json['iso2'] ?? '',
      iso3: json['iso3'] ?? '',
      phoneCode: json['phoneCode'] ?? '',
    );
  }
}

class CountriesLoader {
  static Future<List<Country>> loadCountries() async {
    try {
      final String jsonString = await rootBundle.loadString('lib/app/data/countries.json');
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => Country.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error cargando países: $e');
      rethrow;
    }
  }
}
