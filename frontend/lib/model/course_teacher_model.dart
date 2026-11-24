import 'course_model.dart';
import 'group_model.dart';

class CourseTeacher {
  final List<Course> courses;
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final List<Group> groups;

  CourseTeacher({
    required this.courses,
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.groups,});

  factory CourseTeacher.fromJson(Map<String, dynamic> json) {
    List<Course> courses = [];
    List<Group> groups = [];

    if (json['courses'] != null) {
      json['courses'].forEach((course) {
        courses.add(Course.fromJson(course));
      });
    }

    if (json['groups'] != null) {
      json['groups'].forEach((group) {
        groups.add(Group.fromJson(group));
      });
    }

    return CourseTeacher(
      courses: courses,
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      groups: groups);
  }
}
