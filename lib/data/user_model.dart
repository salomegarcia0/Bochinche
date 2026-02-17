class UserModel {
  final String uid;
  final String email;
  final String name;
  final String identification; //documento
  final String phone;
  final String? profileImageUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.identification,
    required this.phone,
    this.profileImageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      identification: map['cedula'] ?? '',
      phone: map['phone'] ?? '',
      profileImageUrl: map['profileImageUrl'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'cedula': identification,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
    };
  }

}