class Departamento {
  final int id;
  final String nombre;
  final List<String> ciudades;

  Departamento({
    required this.id,
    required this.nombre,
    required this.ciudades,
  });

  factory Departamento.fromJson(Map<String, dynamic> json) {
    return Departamento(
      id: json['id'] as int,
      nombre: json['departamento'] as String,
      ciudades: (json['ciudades'] as List<dynamic>)
          .map((ciudad) => ciudad as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'departamento': nombre, 'ciudades': ciudades};
  }
}
