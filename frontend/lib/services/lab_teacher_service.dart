import 'dart:convert';
import 'package:http/http.dart' as http;

import '../model/lab_teacher_model.dart';

class LabTeacherService {
  final String baseUrl = 'http://localhost:5050/api/labTeacher';

  Future<List<LabTeacher>> getAllTeachers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          List<LabTeacher> list = [];
          for (var item in payloadData) {
            list.add(LabTeacher.fromJson(item));
          }
          return list;
        }
        throw Exception('Failed to load teachers');
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<LabTeacher?> getTeacherByEmail(String email, String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get?email=$email'),
        headers : {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return LabTeacher.fromJson(responseData);
      } else {
        throw Exception('Teacher not found');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  Future<LabTeacher?> getTeacherById(int id, String token) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getById?id=$id'),
          headers : {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return LabTeacher.fromJson(responseData['payload']);
      } else {
        throw Exception('Teacher not found');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }
}