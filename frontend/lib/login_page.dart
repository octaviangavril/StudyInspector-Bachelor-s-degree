import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/lab_teacher_page.dart';
import 'package:frontend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import 'package:frontend/services/authentication_service.dart';
import 'course_teacher_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController studentIdController = TextEditingController();

  Future<void> _login() async {
    Map<String, dynamic> requestBody = {
      "email": emailController.text,
      "password": passwordController.text,
    };

    try {
      Map<String, dynamic> response = await AuthenticationService()
          .login(requestBody['email'], requestBody['password']);
      if (response.containsKey('token')) {
        sp.SharedPreferences prefs = await sp.SharedPreferences.getInstance();
        await prefs.setString('token', response['token']);
        await prefs.setInt(
            'userId',
            await UserService()
                    .getUserId(response['token'], requestBody['email']) ??
                -1);

        List<String> roles = (await UserService()
                .getUserById(response['token'], prefs.getInt('userId')!))
            .roles
            .map((role) => role.name)
            .toList();

        if (roles.contains('COURSE TEACHER')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CourseTeacherPage()),
          );
        } else if (roles.contains('LAB TEACHER')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LabTeacherPage()),
          );
        }
      } else {
        final snackBar = SnackBar(
          content: Text('Error: ${response['message']}'),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        if (kDebugMode) {
          print('Error: ${response['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          title: const Row(
            children: [
              Text(
                'Study',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0,
                ),
              ),
              SizedBox(width: 8.0),
              Text(
                'Inspector',
                style: TextStyle(
                  fontSize: 25.0,
                ),
              ),
            ],
          ),
        ),
        body: Center(
          child: SizedBox(
            width: 200,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const SizedBox(height: 36.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(height: 36.0),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
            ]),
          ),
        ));
  }
}
