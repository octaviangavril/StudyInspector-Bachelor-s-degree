class Student {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String matriculationNumber;
  final int groupId;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.matriculationNumber,
    required this.groupId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      matriculationNumber: json['matriculationNumber'],
      groupId: json['groupId'],
    );
  }
}
