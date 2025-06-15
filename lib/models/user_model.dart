// File: lib/models/user_model.dart
// Model class for user data
class User {
  int? id;
  String name;
  String email;
  String password;
  String role;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  // Convert a User into a map for inserting into the database
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Create a User object from a map retrieved from the database
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: map['role'],
    );
  }
}
