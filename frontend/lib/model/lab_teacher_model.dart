import 'group_model.dart';

class LabTeacher {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<Group> groups;

  LabTeacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.groups,
  });

  factory LabTeacher.fromJson(Map<String, dynamic> json) {
    List<Group> groups = [];
    if (json['groups'] != null) {
      json['groups'].forEach((group) {
        groups.add(Group.fromJson(group));
      });
    }

    return LabTeacher(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      groups: groups,
    );
  }
}
