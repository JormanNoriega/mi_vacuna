class NurseModel {
  String? id; // UUID
  String idType;
  String idNumber;
  String firstName;
  String lastName;
  String email;
  String phone;
  String institution;
  String password;
  DateTime createdAt;

  NurseModel({
    this.id,
    required this.idType,
    required this.idNumber,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.institution,
    required this.password,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convertir a Map para SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idType': idType,
      'idNumber': idNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'institution': institution,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Crear desde Map de SQLite
  factory NurseModel.fromMap(Map<String, dynamic> map) {
    return NurseModel(
      id: map['id'],
      idType: map['idType'],
      idNumber: map['idNumber'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      phone: map['phone'],
      institution: map['institution'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Obtener nombre completo
  String get fullName => '$firstName $lastName';

  @override
  String toString() {
    return 'NurseModel{id: $id, name: $fullName, email: $email}';
  }
}
