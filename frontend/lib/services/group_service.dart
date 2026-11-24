import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../model/group_model.dart';
import 'package:http/http.dart' as http;

class GroupService {
  String baseUrl = 'http://localhost:5050/api/group';

  Future<List<Group>?> getAllGroupsByLabTeacherId(int id, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getAllByLabTeacher?id=$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          List<Group> list = [];
          for (var item in payloadData) {
            list.add(Group.fromJson(item));
          }
          return list;
        }
        if (kDebugMode) {
          print('Failed to load groups');
        }
      } else {
        if (kDebugMode) {
          print('Failed to load groups');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return null;
  }

  Future<List<String>> getLabNamesWithoutGrade(String token, int id, int studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getLabNamesWithoutGrade?id=$id&studentId=$studentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          List<String> list = [];
          for (var item in payloadData) {
            list.add(item);
          }
          return list;
        }
        if (kDebugMode) {
          print('Failed to load lab names ${jsonResponse['message']}');
        }
      }
      else {
        if (kDebugMode) {
          print('Failed to load lab names ${response.body}');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return [];
  }

  Future<String> updateLabGrade(int courseId, String labName, double grade, String token, String matriculationNumber) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateLabGrade?courseId=$courseId&matriculationNumber=$matriculationNumber&labName=$labName&grade=$grade'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse['message'];
      }
      else {
        if (kDebugMode) {
          print('Failed to update lab grade with status code: ${response.body}');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return 'Failed to update lab grade';
  }

  Future<Group?> updateSpreadSheets(String token, int groupToGoId, int groupFromToId, int studentId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/updateSpreadsheets?groupToGoId=$groupToGoId&groupFromToId=$groupFromToId&studentId=$studentId'),
        headers: {'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final List<dynamic> groupJsonList = jsonResponse['payload'];
          final List<Group> groups = groupJsonList.map((json) => Group.fromJson(json)).toList();
          return groups[1];
        }
        if (kDebugMode) {
          print('Failed to update lab grade: ${jsonResponse['message']}');
        }
      }
      else {
        if (kDebugMode) {
          print('Failed to update lab grade with status code: ${response.body}');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return null;
  }

  Future<String> updateStudentGroup(String token, int groupId, int studentId) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:5050/api/student/update?id=$studentId'),
        headers: {'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': '',
          'lastName': '',
          'email': '',
          'password': '',
          'phoneNumber': '',
          'matriculationNumber': '',
          'groupId': groupId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('message')) {
          return jsonResponse['message'];
        }
        if (kDebugMode) {
          print('Failed to update student group: ${jsonResponse['message']}');
        }
      }
      else {
        if (kDebugMode) {
          print('Failed to update student group with status code: ${response.body}');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }

    return 'Failed to update student group';
  }

  Future<List<Group>> getAllGroupsByCourseId(String token, int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getAllByCourse?id=$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          List<Group> list = [];
          for (var item in payloadData) {
            list.add(Group.fromJson(item));
          }
          return list;
        }
        if (kDebugMode) {
          print('Failed to load groups');
        }
      } else {
        if (kDebugMode) {
          print('Failed to load groups');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return [];
  }

  Future<String> removeStudentFromGroup(String token, int studentId, int groupId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/removeStudent?groupId=$groupId&studentId=$studentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('message')) {
          return jsonResponse['message'];
        }
        if (kDebugMode) {
          print('Failed to remove student from group: ${jsonResponse['message']}');
        }
      }
      else {
        if (kDebugMode) {
          print('Failed to remove student from group with status code: ${response.body}');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return 'Failed to remove student from group';
  }

  Future<Map<String, List<String>>> getStudentsTable(String token, int courseId, List<String> studentsMatriculationNumbers) async {
    try{
      String listParam = studentsMatriculationNumbers.join(',');
      final response = await http.get(
        Uri.parse('$baseUrl/getStudentsTable?courseId=$courseId&studentsMatriculationNumbers=$listParam'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          Map<String, List<String>> map = {};
          for (var item in payloadData.keys) {
            map[item] = List<String>.from(payloadData[item]);
          }
          return map;
        }
        if (kDebugMode) {
          print('Failed to load students table');
        }
      } else {
        if (kDebugMode) {
          print('Failed to load students table');
        }
      }
    }
    catch (e) {
      if (kDebugMode) {
        print('Failed to connect to the server: $e');
      }
    }
    return {};
  }
}