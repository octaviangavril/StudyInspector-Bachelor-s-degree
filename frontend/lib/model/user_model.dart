class User {
  int id;
  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String password;
  final List<Role> roles;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    var rolesList = json['roles'] as List;
    List<Role> roles =
    rolesList.map((roleJson) => Role.fromJson(roleJson)).toList();

    return User(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      password: json['password'],
      roles: roles,
    );
  }
}

class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
}
