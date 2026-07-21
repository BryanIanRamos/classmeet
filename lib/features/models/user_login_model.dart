class UserLoginModel {
  final int id;
  final String name;
  final String email;

  UserLoginModel({required this.id, required this.name, required this.email});

  factory UserLoginModel.fromJson(Map<String, dynamic> json) {
    return UserLoginModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}
