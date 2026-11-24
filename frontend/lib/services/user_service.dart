import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/user_model.dart';

class UserService {
  final String baseUrl = 'http://localhost:5050/api/user';

  Future<int?> getUserId(String token, String email) async {
    final url = Uri.parse('$baseUrl/get?email=$email');
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('payload')) {
          final dynamic payloadData = jsonResponse['payload'];
          return payloadData['id'];
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<User> getUserById(String token, int userId) async {
    final url = Uri.parse('$baseUrl/getById?id=$userId');

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        int id = jsonResponse['payload']['id'];
        String firstName = jsonResponse['payload']['firstName'];
        String lastName = jsonResponse['payload']['lastName'];
        String email = jsonResponse['payload']['email'];
        String phoneNumber = jsonResponse['payload']['phoneNumber'];
        String password = jsonResponse['payload']['password'];

        List<dynamic> rolesJson = jsonResponse['payload']['roles'];
        List<Role> roles = rolesJson.map((roleJson) => Role.fromJson(roleJson)).toList();

        return User(
          id: id,
          firstName: firstName,
          lastName: lastName,
          email: email,
          phoneNumber: phoneNumber,
          password: password,
          roles: roles,
        );
      } else {
        throw Exception('Failed to load user details');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      throw Exception('Failed to load user details');
    }
  }

  Future<String> deleteUser(String token, int id) async {
    try {
      final response = await http.delete(
          Uri.parse('$baseUrl/delete?id=$id'),
          headers : {'Authorization': 'Bearer $token'}
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['message'];
      }
      return jsonDecode(response.body)['message'];
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return 'Something went wrong';
    }
  }

  Future<String> updateUser(String token, int id, String firstName, String lastName, String email, String password, String phoneNumber) async {
    final url = Uri.parse('$baseUrl/update?id=$id');
    final body = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
    });
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.put(url, body: body, headers: headers);
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
}