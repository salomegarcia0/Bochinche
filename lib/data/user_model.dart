class UserModel {
  final String uid;
  final String email;
  final String nombre;
  final String cedula; //documento
  final String telefono;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.cedula,
    required this.telefono,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nombre: map['nombre'] ?? '',
      cedula: map['cedula'] ?? '',
      telefono: map['telefono'] ?? '',
      profileImageUrl: map['profileImageUrl'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nombre': nombre,
      'cedula': cedula,
      'telefono': telefono,
      'profileImageUrl': profileImageUrl,
    };
  }
}
