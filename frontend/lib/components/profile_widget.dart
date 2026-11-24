import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frontend/main.dart';
import 'package:frontend/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;

import '../model/user_model.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  ProfileWidgetState createState() => ProfileWidgetState();
}

class ProfileWidgetState extends State<ProfileWidget> {
  User? _user;
  final TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<String> getTokenFromLocalStorage() async {
    final prefs = await sp.SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<int> getUserIdFromLocalStorage() async {
    final prefs = await sp.SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
  }

  Future<void> _fetchUserDetails() async {
    final prefs = await sp.SharedPreferences.getInstance();
    try {
      User user = await UserService().getUserById(
          prefs.getString('token')!, await getUserIdFromLocalStorage());
      setState(() {
        _user = user;
      });
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching user details: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _user != null
        ? Center(
            child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 5.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              'User Information',
                              style: TextStyle(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.bold,
                                fontSize: 15.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.person,
                            color: Colors.blue[900],
                            size: 15,
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MediaQuery.of(context).size.width < 920
                              ? Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'First Name:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.firstName,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16, height: 16),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Last Name:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.lastName,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'First Name:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.firstName,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),),
                                    const SizedBox(width: 16, height: 16),
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Last Name:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.lastName,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),)
                                  ],
                                ),
                          const SizedBox(height: 16),
                          MediaQuery.of(context).size.width < 920
                              ? Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Email:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.email,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                    ),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Phone Number:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.phoneNumber,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Email:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.email,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),),
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                    ),
                                    Expanded(child: Container(
                                      padding: const EdgeInsets.only(
                                          top: 6,
                                          bottom: 6,
                                          right: 15,
                                          left: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          const AutoSizeText(
                                            'Phone Number:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          AutoSizeText(
                                            _user!.phoneNumber,
                                            style: const TextStyle(
                                              fontSize: 10.0,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                    ),
                                  ],
                                )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                Container(
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Text(
                                  'Actions',
                                  style: TextStyle(
                                    color: Colors.blue[900],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.settings,
                                color: Colors.blue[900],
                                size: 15,
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          MediaQuery.of(context).size.width < 1200
                              ? MediaQuery.of(context).size.width < 920
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                          onPressed: _changePassword,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.lock, size: 10),
                                              SizedBox(width: 8),
                                              AutoSizeText(
                                                'Change Password',
                                                minFontSize: 10,
                                                maxLines: 1,
                                              ),
                                            ],
                                          )),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                          onPressed: _editProfile,
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.edit, size: 10),
                                              SizedBox(width: 8),
                                              AutoSizeText(
                                                'Edit Profile',
                                                minFontSize: 10,
                                                maxLines: 1,
                                              ),
                                            ],
                                          )),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                          onPressed: _logout,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.logout, size: 10),
                                              SizedBox(width: 8),
                                              AutoSizeText(
                                                'Logout',
                                                minFontSize: 10,
                                                maxLines: 1,
                                              )
                                            ],
                                          )),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                          onPressed: _deleteAccount,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.delete, size: 10),
                                              SizedBox(width: 8),
                                              AutoSizeText(
                                                'Delete Account',
                                                minFontSize: 10,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ))
                                    ],
                                  )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: _changePassword,
                                                child: const SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.lock,
                                                          size: 10),
                                                      SizedBox(width: 8),
                                                      AutoSizeText(
                                                        'Change Password',
                                                        minFontSize: 10,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                              onPressed: _editProfile,
                                              child: const SizedBox(
                                                width: 150,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(Icons.edit, size: 10),
                                                    SizedBox(width: 8),
                                                    AutoSizeText(
                                                      'Edit Profile',
                                                      minFontSize: 10,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                                onPressed: _logout,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.logout,
                                                          size: 10),
                                                      SizedBox(width: 8),
                                                      AutoSizeText(
                                                        'Logout',
                                                        minFontSize: 10,
                                                        maxLines: 1,
                                                      )
                                                    ],
                                                  ),
                                                )),
                                            const SizedBox(width: 16),
                                            ElevatedButton(
                                                onPressed: _deleteAccount,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                ),
                                                child: const SizedBox(
                                                  width: 150,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(Icons.delete,
                                                          size: 10),
                                                      SizedBox(width: 8),
                                                      AutoSizeText(
                                                        'Delete Account',
                                                        minFontSize: 10,
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                          ],
                                        )
                                      ],
                                    )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                        onPressed: _changePassword,
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.lock, size: 10),
                                            SizedBox(width: 8),
                                            AutoSizeText(
                                              'Change Password',
                                              minFontSize: 10,
                                              maxLines: 1,
                                            ),
                                          ],
                                        )),
                                    ElevatedButton(
                                        onPressed: _editProfile,
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.edit, size: 10),
                                            SizedBox(width: 8),
                                            AutoSizeText(
                                              'Edit Profile',
                                              minFontSize: 10,
                                              maxLines: 1,
                                            ),
                                          ],
                                        )),
                                    ElevatedButton(
                                        onPressed: _logout,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.logout, size: 10),
                                            SizedBox(width: 8),
                                            AutoSizeText(
                                              'Logout',
                                              minFontSize: 10,
                                              maxLines: 1,
                                            )
                                          ],
                                        )),
                                    ElevatedButton(
                                        onPressed: _deleteAccount,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        child: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.delete, size: 10),
                                            SizedBox(width: 8),
                                            AutoSizeText(
                                              'Delete Account',
                                              minFontSize: 10,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ))
                                  ],
                                ),
                        ]))
              ],
            ),
          ))
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  Future<void> _logout() async {
    final prefs = await sp.SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  Future<void> _deleteAccount() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Account'),
            content:
                const Text('Are you sure you want to delete your account?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () async {
                  final prefs = await sp.SharedPreferences.getInstance();
                  String response = await UserService().deleteUser(
                      await getTokenFromLocalStorage(),
                      await getUserIdFromLocalStorage());

                  if (response == 'User deleted successfully') {
                    await prefs.remove('token');
                    await prefs.remove('userId');

                    Navigator.of(context).pop();

                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  } else {
                    if (kDebugMode) {
                      print('Error deleting user: $response');
                    }
                  }
                },
                child: const Text('Delete Account',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        });
  }

  Future<void> _changePassword() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      hintText: 'New Password',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$')
                          .hasMatch(value)) {
                        return 'Password must contain at least 8 characters, including both letters and digits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final prefs = await sp.SharedPreferences.getInstance();
                  String response = await UserService().updateUser(
                    prefs.getString('token')!,
                    await getUserIdFromLocalStorage(),
                    _user!.firstName,
                    _user!.lastName,
                    _user!.email,
                    passwordController.text,
                    _user!.phoneNumber,
                  );

                  if (response == 'User updated successfully') {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Password updated successfully'),
                        duration: Duration(seconds: 3)));
                    setState(() {});
                  } else {
                    if (kDebugMode) {
                      print('Error updating password: $response');
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Error updating password'),
                        duration: Duration(seconds: 3)));
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Change Password',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProfile() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  onChanged: (value) {
                    _user!.firstName = value;
                  },
                  decoration: InputDecoration(
                    hintText: _user!.firstName,
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    _user!.lastName = value;
                  },
                  decoration: InputDecoration(
                    hintText: _user!.lastName,
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    _user!.email = value;
                  },
                  decoration: InputDecoration(
                    hintText: _user!.email,
                  ),
                ),
                TextField(
                  onChanged: (value) {
                    _user!.phoneNumber = value;
                  },
                  decoration: InputDecoration(
                    hintText: _user!.phoneNumber,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                final prefs = await sp.SharedPreferences.getInstance();
                String response = await UserService().updateUser(
                  prefs.getString('token')!,
                  await getUserIdFromLocalStorage(),
                  _user!.firstName,
                  _user!.lastName,
                  _user!.email,
                  _user!.password,
                  _user!.phoneNumber,
                );

                if (response == 'User updated successfully') {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Profile updated successfully'),
                      duration: Duration(seconds: 3)));
                  setState(() {});
                } else {
                  if (kDebugMode) {
                    print('Error updating profile: $response');
                  }
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Error updating profile'),
                      duration: Duration(seconds: 3)));
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save Changes',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }
}
