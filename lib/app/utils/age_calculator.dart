/// Utilidad para calcular edad de forma consistente
/// - Calcula años, meses y días correctamente
/// - Los 'días' son los restantes del mes, NO el total de días
/// - Se usa en toda la aplicación para mantener consistencia
class AgeCalculator {
  /// Calcula la edad completa a partir de una fecha de nacimiento
  ///
  /// Retorna un mapa con:
  /// - 'years': años completos
  /// - 'months': meses completos (0-11)
  /// - 'days': días restantes del mes (0-31)
  /// - 'totalMonths': total de meses desde el nacimiento
  /// - 'totalDays': total de días desde el nacimiento
  ///
  /// Ejemplo:
  /// - Nace: 15/03/2020
  /// - Hoy: 22/02/2026
  /// Resultado: {years: 5, months: 11, days: 7, totalMonths: 71, totalDays: 2130}
  static Map<String, int> calculate(DateTime birthDate) {
    final now = DateTime.now();

    // Validar que la fecha de nacimiento no sea en el futuro
    if (birthDate.isAfter(now)) {
      return {'years': 0, 'months': 0, 'days': 0, 'totalMonths': 0, 'totalDays': 0};
    }

    // Calcular años
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    // Ajustar si los días son negativos
    if (days < 0) {
      months--;
      // Obtener el último día del mes anterior
      final previousMonth = DateTime(now.year, now.month, 0);
      days += previousMonth.day;
    }

    // Ajustar si los meses son negativos
    if (months < 0) {
      years--;
      months += 12;
    }

    // Calcular totales
    final totalMonths = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    final totalDays = now.difference(birthDate).inDays;

    return {
      'years': years,
      'months': months,
      'days': days,
      'totalMonths': totalMonths.abs(),
      'totalDays': totalDays,
    };
  }

  /// Formatea la edad de forma legible
  /// Ejemplo: "5 años, 11 meses, 7 días"
  static String format(Map<String, int> age) {
    return '${age['years']} años, ${age['months']} meses, ${age['days']} días';
  }

  /// Formatea solo años y meses (compacto)
  /// Ejemplo: "5 años, 11 meses"
  static String formatCompact(Map<String, int> age) {
    return '${age['years']} años, ${age['months']} meses';
  }

  /// Retorna solo los meses totales (útil para búsqueda de vacunas)
  static int getTotalMonths(DateTime birthDate) {
    final now = DateTime.now();
    final totalMonths = (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
    return totalMonths.abs();
  }

  /// Retorna solo los días totales
  static int getTotalDays(DateTime birthDate) {
    return DateTime.now().difference(birthDate).inDays;
  }
}
