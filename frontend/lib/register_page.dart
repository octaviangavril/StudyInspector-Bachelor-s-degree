import 'package:flutter/material.dart';
import 'package:frontend/services/authentication_service.dart';

import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  String selectedRole = 'Course Teacher';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == 'Course Teacher') {
        await AuthenticationService().registerCourseTeacher(
          emailController.text,
          passwordController.text,
          firstNameController.text,
          lastNameController.text,
          phoneNumberController.text,
        );
      } else if (selectedRole == 'Lab Teacher') {
        await AuthenticationService().registerLabTeacher(
          emailController.text,
          passwordController.text,
          firstNameController.text,
          lastNameController.text,
          phoneNumberController.text,
        );
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
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
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        MediaQuery.of(context).size.width < 600
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Register as',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  DropdownButton<String>(
                                    value: selectedRole,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedRole = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Course Teacher',
                                      'Lab Teacher'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                fontSize: 18.0)),
                                      );
                                    }).toList(),
                                    underline: Container(),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Register as',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  DropdownButton<String>(
                                    value: selectedRole,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedRole = newValue!;
                                      });
                                    },
                                    items: <String>[
                                      'Course Teacher',
                                      'Lab Teacher'
                                    ].map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: const TextStyle(
                                                fontSize: 18.0)),
                                      );
                                    }).toList(),
                                    underline: Container(),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 36.0),
                        MediaQuery.of(context).size.width > 600 ?
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: firstNameController,
                                      decoration: const InputDecoration(
                                          labelText: 'First Name'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your first name';
                                        }
                                        if (!RegExp(r'^[a-zA-Z]+$')
                                            .hasMatch(value)) {
                                          return 'First name must contain only letters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12.0),
                                    TextFormField(
                                      controller: passwordController,
                                      decoration: const InputDecoration(
                                          labelText: 'Password'),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter a password';
                                        }
                                        if (!RegExp(
                                                r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                                            .hasMatch(value)) {
                                          return 'Password must contain at least 8 characters, including both letters and digits';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12.0),
                                    TextFormField(
                                      controller: emailController,
                                      decoration: const InputDecoration(
                                          labelText: 'Email'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!RegExp(
                                                r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid email address';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TextFormField(
                                      controller: lastNameController,
                                      decoration: const InputDecoration(
                                          labelText: 'Last Name'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your last name';
                                        }
                                        if (!RegExp(r'^[a-zA-Z]+$')
                                            .hasMatch(value)) {
                                          return 'Last name must contain only letters';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12.0),
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      decoration: const InputDecoration(
                                          labelText: 'Confirm Password'),
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please confirm your password';
                                        } else if (value !=
                                            passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                    ),
                                    const SizedBox(height: 12.0),
                                    TextFormField(
                                      controller: phoneNumberController,
                                      decoration: const InputDecoration(
                                          labelText: 'Phone Number'),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (!RegExp(r'^[0-9]{9,15}$')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                              )
                            ]) : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextFormField(
                                controller: firstNameController,
                                decoration: const InputDecoration(
                                    labelText: 'First Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                  if (!RegExp(r'^[a-zA-Z]+$')
                                      .hasMatch(value)) {
                                    return 'First name must contain only letters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: lastNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Last Name'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                  if (!RegExp(r'^[a-zA-Z]+$')
                                      .hasMatch(value)) {
                                    return 'Last name must contain only letters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                    labelText: 'Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (!RegExp(
                                      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                                      .hasMatch(value)) {
                                    return 'Password must contain at least 8 characters, including both letters and digits';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: confirmPasswordController,
                                decoration: const InputDecoration(
                                    labelText: 'Confirm Password'),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please confirm your password';
                                  } else if (value !=
                                      passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                    labelText: 'Email'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(
                                      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12.0),
                              TextFormField(
                                controller: phoneNumberController,
                                decoration: const InputDecoration(
                                    labelText: 'Phone Number'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  if (!RegExp(r'^[0-9]{9,15}$')
                                      .hasMatch(value)) {
                                    return 'Please enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ]
                        ),
                        const SizedBox(height: 36.0),
                        ElevatedButton(
                          onPressed: _register,
                          child: const Text('Register'),
                        ),
                      ],
                    )),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
