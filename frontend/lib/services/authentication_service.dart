import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AuthenticationService {
  static const String host = "http://localhost:5050/api/auth";

  Future<String> registerCourseTeacher(String email, String password, String firstName, String lastName, String phoneNumber) async {
    final url = Uri.parse('$host/register/courseTeacher');
    final body = jsonEncode({
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    });
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      }
      return jsonDecode(response.body).toString();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return 'Something went wrong';
    }
  }

  Future<String> registerLabTeacher(String email, String password, String firstName, String lastName, String phoneNumber) async {
    final url = Uri.parse('$host/register/labTeacher');
    final body = jsonEncode({
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
    });
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      }
      return jsonDecode(response.body).toString();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return 'Something went wrong';
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$host/login');
    final body = jsonEncode({'email': email, 'password': password});
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'message': 'Login successful',
          'token': responseData['accessToken'],
        };
      }
      return {'message': 'Invalid email or password!'};
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return {'message': 'Something went wrong'};
    }
  }

  Future<int?> loginStudent(String matriculationNumber) async {
    final url = Uri.parse('$host/students/getByMatriculationNumber?matriculationNumber=$matriculationNumber');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['id'];
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }
}
