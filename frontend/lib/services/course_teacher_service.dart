import 'dart:convert';
import 'dart:async';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/course_teacher_model.dart' as c;
import 'package:excel/excel.dart';

class CourseTeacherService {
  final String baseUrl = "http://localhost:5050/api/courseTeacher";

  Future<List<c.CourseTeacher>> getAllTeachers(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('payload')) {
        final dynamic payloadData = jsonResponse['payload'];
        Iterable data = jsonDecode(payloadData);
        List<c.CourseTeacher> teachers =
            data.map((teacher) => c.CourseTeacher.fromJson(teacher)).toList();
        return teachers;
      }
      return [];
    } else {
      throw Exception('Failed to load teachers');
    }
  }

  Future<c.CourseTeacher?> getTeacherByEmail(String email, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get?email=$email'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return c.CourseTeacher.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<c.CourseTeacher?> getTeacherById(int id, String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/getById?id=$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('payload')) {
        final dynamic payloadData = jsonResponse['payload'];
        return c.CourseTeacher.fromJson(payloadData);
      }
    } else {
      return null;
    }
    return null;
  }

  bool validateFile(PlatformFile file) {
    if (file.extension != 'xlsx') {
      return false;
    }

    var bytes = file.bytes!;
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first]!;
    List<String> columns =
        sheet.rows.first.map((data) => data?.value.toString() ?? '').toList();

    List<String> requiredColumns = [
      "Numar matricol",
      "Nume",
      "Prenume",
      "An",
      "Grupa",
      "Email",
      "Numar de telefon"
    ];

    if (!requiredColumns.every((column) => columns.contains(column))) {
      return false;
    }

    return true;
  }

  List<String> generateGroups(PlatformFile file) {
    var bytes = file.bytes!;
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first]!;

    var columnNames =
        sheet.rows.first.map((data) => data?.value.toString() ?? '').toList();
    var groupNameIndex = columnNames.indexOf('Grupa');

    var groupNames = sheet.rows
        .skip(1)
        .map((row) => row[groupNameIndex]?.value.toString().trim() ?? '')
        .toList();

    return groupNames.toSet().toList();
  }

  Future<String?> createCourseEntities(
      String token,
      int id,
      Map<String, dynamic> data,
      PlatformFile file,
      List<String> spreadsheetTemplateColumns) async {
    c.CourseTeacher? courseTeacher = await getTeacherById(id, token);
    if (courseTeacher != null) {
      if (courseTeacher.courses
          .map((e) => e.courseName)
          .contains(data['courseName'])) {
        return 'Course already exists!';
      }
    }

    String url =
        'http://localhost:5050/api/courseTeacher/createCourseEntities?id=$id';
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      Map<String, List<String>> convertedData = await convertXlsxToMap(file);

      String jsonData = jsonEncode({
        ...data,
        'studentsData': convertedData,
        'spreadsheetTemplateColumns': spreadsheetTemplateColumns,
      });

      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonData,
      );

      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse.containsKey("message")) {
        return jsonResponse["message"];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
      return 'Failed to connect to the server';
    }
    return 'Something went wrong. Try later.';
  }

  Future<Map<String, List<String>>> convertXlsxToMap(PlatformFile file) async {
    var bytes = file.bytes!;
    var excel = Excel.decodeBytes(bytes);
    var sheet = excel.tables[excel.tables.keys.first]!;

    Map<String, List<String>> resultMap = {};

    if (sheet.rows.isNotEmpty) {
      var columnNames =
          sheet.rows.first.map((data) => data?.value.toString() ?? '').toList();
      for (var columnName in columnNames) {
        resultMap[columnName] = [];
      }

      for (var row in sheet.rows.skip(1)) {
        for (int i = 0; i < columnNames.length; i++) {
          resultMap[columnNames[i]]!.add(row[i]?.value?.toString() ?? '');
        }
      }
    }
    return resultMap;
  }

  Future<void> deleteCourseEntities(String token, int id) async {
    String url =
        'http://localhost:5050/api/courseTeacher/deleteCourseEntities?id=$id';
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      var response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Success!');
        }
      } else {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey("message")) {
          if (kDebugMode) {
            print('Exception: ${jsonResponse["message"]}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception: $e');
      }
    }
  }

  Future<String> getPrivateFile(String token, int courseId) async {
    String url =
        'http://localhost:5050/api/course/getPrivateFile?courseId=$courseId';
    try {
      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
      };

      http.Response response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          List<dynamic> dataMap = jsonResponse['payload'];

          List<List<dynamic>> csvData = [];
          for (List<dynamic> data in dataMap) {
            csvData.add(data.map((e) => e.toString()).toList());
          }

          String csv = const ListToCsvConverter().convert(csvData);

          return csv;
        } else {
          return 'Failed to get private file';
        }
      } else {
        return 'Failed to get private file';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
      return 'Something went wrong. Try later.';
    }
  }
}
