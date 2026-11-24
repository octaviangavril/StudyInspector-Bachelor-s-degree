import 'student_model.dart';

class Group {
  final int id;
  final String groupName;
  final List<Student> students;
  final int labTeacherId;
  final int courseId;

  Group({
    required this.id,
    required this.groupName,
    required this.students,
    required this.labTeacherId,
    required this.courseId,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    List<Student> students = [];
    if (json['students'] != null) {
      json['students'].forEach((student) {
        students.add(Student.fromJson(student));
      });
    }

    return Group(
      id: json['id'],
      groupName: json['groupName'],
      students: students,
      labTeacherId: json['labTeacherId'],
      courseId: json['courseId'],
    );
  }
}
