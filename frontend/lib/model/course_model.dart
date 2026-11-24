import 'group_model.dart';

class Course {
  final int id;
  final String courseName;
  final List<Group> groups;
  final int courseTeacherId;
  final String urlFileAllStudents;
  final String privateUrlFileAllStudents;

  Course({
    required this.id,
    required this.courseName,
    required this.groups,
    required this.courseTeacherId,
    required this.urlFileAllStudents,
    required this.privateUrlFileAllStudents
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    List<Group> groups = [];
    if (json['groups'] != null) {
      json['groups'].forEach((group) {
        groups.add(Group.fromJson(group));
      });
    }
    return Course(
      id: json['id'],
      courseName: json['courseName'],
      groups: groups,
      courseTeacherId: json['courseTeacherId'],
      urlFileAllStudents: json['urlFileAllStudents'],
      privateUrlFileAllStudents: json['privateUrlFileAllStudents']
    );
  }
}