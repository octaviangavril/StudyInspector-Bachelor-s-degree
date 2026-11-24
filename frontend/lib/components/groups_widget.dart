import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/services/group_service.dart';
import 'package:shared_preferences/shared_preferences.dart' as sp;
import '../model/group_model.dart';
import '../model/student_model.dart';

class GroupsWidget extends StatefulWidget {
  const GroupsWidget({super.key});

  @override
  GroupsWidgetState createState() => GroupsWidgetState();
}

class GroupsWidgetState extends State<GroupsWidget> {
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      String token = await getTokenFromLocalStorage();
      int userId = await getUserIdFromLocalStorage();
      final groups =
          await GroupService().getAllGroupsByLabTeacherId(userId, token);

      if (groups != null) {
        setState(() {
          _groups = groups;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> groupNames = _groups.map((group) => group.groupName).toList();
    return groupNames.isEmpty
        ? const Center(
            child: Text('No groups found'),
          )
        : Column(
            children: [
              const Text("My Groups",
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(height: 16.0),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 850
                            ? 3
                            : MediaQuery.of(context).size.width > 600
                                ? 2
                                : 1,
                        childAspectRatio: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      padding: const EdgeInsets.all(10),
                      itemCount: groupNames.length,
                      // shrinkWrap: true,
                      // physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GroupDetailsPage(
                                        group: _groups[index],
                                        reloadGroups: _loadGroups,
                                      ),
                                    ),
                                  );
                                },
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: MediaQuery.of(context).size.width <
                                                600 &&
                                            MediaQuery.of(context).size.width >
                                                400
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.group,
                                                size: 30,
                                                color: Colors.blue[900],
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Group ${groupNames[index]}',
                                                style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.group,
                                                size: 30,
                                                color: Colors.blue[900],
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                'Group ${groupNames[index]}',
                                                style: TextStyle(
                                                  color: Colors.blue[900],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                )));
                      },
                    );
                  },
                ),
              )
            ],
          );
  }
}

Future<String> getTokenFromLocalStorage() async {
  final prefs = await sp.SharedPreferences.getInstance();
  return prefs.getString('token') ?? '';
}

Future<int> getUserIdFromLocalStorage() async {
  final prefs = await sp.SharedPreferences.getInstance();
  return prefs.getInt('userId') ?? -1;
}

class GroupDetailsPage extends StatefulWidget {
  final VoidCallback reloadGroups;
  final Group group;

  const GroupDetailsPage(
      {super.key, required this.group, required this.reloadGroups});

  @override
  GroupDetailsPageState createState() => GroupDetailsPageState(group);
}

class GroupDetailsPageState extends State<GroupDetailsPage> {
  Group group;
  List<Student> students;
  Map<String, List<String>> studentsTable = {};
  final ValueNotifier<bool> _isUpdating = ValueNotifier<bool>(false);
  Timer? _debounce;

  GroupDetailsPageState(this.group) : students = group.students;

  @override
  void initState() {
    super.initState();
    _loadStudentsTable(null);
  }

  Future<void> _loadStudentsTable(String? messageStatus) async {
    try {
      String token = await getTokenFromLocalStorage();
      int courseId = group.courseId;
      Map<String, List<String>> table = await GroupService().getStudentsTable(
          token,
          courseId,
          students.map((student) => student.matriculationNumber).toList());
      setState(() {
        studentsTable = table;
      });
      if (messageStatus != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(messageStatus),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading students table: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: studentsTable.isNotEmpty
            ? AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(group.groupName),
                    ValueListenableBuilder<bool>(
                      valueListenable: _isUpdating,
                      builder: (context, isUpdating, _) {
                        return Row(
                          children: isUpdating
                              ? [
                                  const SizedBox(
                                    width: 12.0,
                                    height: 12.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
                                    "Updating file...",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  ),
                                ]
                              : [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 8.0),
                                  const Text(
                                    "File up to date",
                                    style: TextStyle(
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : null,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                studentsTable.isNotEmpty
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showBottomBorder: true,
                          columnSpacing: 10.0,
                          columns: [const DataColumn(label: Text(""))] +
                              (studentsTable.keys
                                  .toList()
                                  .sublist(0, studentsTable.keys.length - 1)
                                  .map(
                                    (columnName) => DataColumn(
                                        label: Text(columnName,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.0))),
                                  )
                                  .toList()),
                          rows: _buildTableRows(),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
          ),
        ));
  }

  List<DataRow> _buildTableRows() {
    return students.map((student) {
      int rowIndex = students.indexOf(student);
      List<DataCell> cells = [];

      cells.add(DataCell(
        IconButton(
          icon: const Icon(Icons.change_circle),
          onPressed: () {
            changeGroup(student.id, context);
          },
          tooltip: 'Change group',
        ),
      ));
      studentsTable.keys
          .toList()
          .sublist(0, studentsTable.keys.length - 1)
          .map((columnName) {
        int columnIndex = studentsTable.keys.toList().indexOf(columnName);
        TextEditingController controller =
            TextEditingController(text: studentsTable[columnName]![rowIndex]);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
        cells.add(DataCell(
          columnIndex < 4
              ? Text(
                  studentsTable[columnName]![rowIndex],
                )
              : SizedBox(
                  width: 40,
                  child: TextField(
                    textAlign: TextAlign.center,
                    onChanged: (value) async {
                      _onCellEdit(rowIndex, columnIndex, value);
                      controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: controller.text.length));
                    },
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                    ],
                  ),
                ),
        ));
      }).toList();
      return DataRow(
        cells: cells,
        color: MaterialStateColor.resolveWith(
            (states) => rowIndex % 2 == 0 ? Colors.blue[900]! : Colors.black12),
      );
    }).toList();
  }

  Future<void> _onCellEdit(int rowIndex, int columnIndex, String value) async {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      String matriculationNumber = students[rowIndex].matriculationNumber;
      String columnName = studentsTable.keys.toList()[columnIndex];
      String token = await getTokenFromLocalStorage();

      _isUpdating.value = true;

      String response = await GroupService().updateLabGrade(group.courseId,
          columnName, double.parse(value), token, matriculationNumber);

      if (response == 'Failed to update lab grade') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update lab grade. Try later.'),
          duration: Duration(milliseconds: 500),
        ));
        _isUpdating.value = false;
      } else {
        _isUpdating.value = false;
      }
    });
  }

  void removeStudent(int studentId) {
    setState(() {
      students.removeWhere((student) => student.id == studentId);
    });
  }

  Future<void> changeGroup(int studentId, BuildContext context) async {
    String token = await getTokenFromLocalStorage();
    int courseId = group.courseId;
    List<Group> availableGroups = await GroupService()
        .getAllGroupsByCourseId(token, courseId)
        .then((value) =>
            value.where((element) => element.id != group.id).toList());

    Group? selectedGroup;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Change Group'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Group>(
                    value: selectedGroup,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGroup = newValue;
                      });
                    },
                    items: availableGroups
                        .map((group) => DropdownMenuItem(
                              value: group,
                              child: Text(group.groupName),
                            ))
                        .toList(),
                    decoration: const InputDecoration(
                      labelText: 'Select Group',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedGroup == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Please fill group field'),
                      ));
                      return;
                    } else {
                      await GroupService()
                          .removeStudentFromGroup(token, studentId, group.id);
                      String response = await GroupService().updateStudentGroup(
                          token, selectedGroup!.id, studentId);

                      Navigator.of(context).pop();
                      removeStudent(studentId);
                      widget.reloadGroups();
                      if (response == 'Student updated successfully') {
                        setState(() {
                          studentsTable = {};
                        });
                        _loadStudentsTable(response);
                      }
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          });
        });
  }
}
