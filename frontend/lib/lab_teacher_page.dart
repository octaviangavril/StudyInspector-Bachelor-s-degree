import 'package:flutter/material.dart';
import 'package:frontend/components/groups_widget.dart';
import 'package:frontend/components/profile_widget.dart';

class LabTeacherPage extends StatefulWidget {
  const LabTeacherPage({super.key});

  @override
  LabTeacherPageState createState() => LabTeacherPageState();
}

class LabTeacherPageState extends State<LabTeacherPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: _selectedIndex == 0 ? _buildProfile() : _buildMyGroups(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'My Groups',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMyGroups() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: MediaQuery.of(context).size.width < 360 ? null : const EdgeInsets.all(20.0),
        decoration: MediaQuery.of(context).size.width < 360 ? null : BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const GroupsWidget(),
      ),
    );
  }

  Widget _buildProfile() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.7,
        alignment: Alignment.center,
        padding: MediaQuery.of(context).size.width < 650 ? null :
        const EdgeInsets.only(top: 36, bottom: 36, left: 100, right: 100),
        decoration: MediaQuery.of(context).size.width < 650 ? null : BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const ProfileWidget(),
      ),
    );
  }
}
