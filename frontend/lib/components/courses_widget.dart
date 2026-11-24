import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/course_model.dart';
import '../model/course_teacher_model.dart';
import '../model/lab_teacher_model.dart';
import '../services/course_teacher_service.dart';
import '../services/lab_teacher_service.dart';
import 'groups_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:auto_size_text/auto_size_text.dart';

class CoursesWidget extends StatefulWidget {
  const CoursesWidget({super.key});

  @override
  CoursesWidgetPage createState() => CoursesWidgetPage();
}

class CoursesWidgetPage extends State<CoursesWidget> {
  List<bool> _isLoading = [];
  bool _isLoadingCourse = false;
  List<Course> courses = [];
  CourseTeacher? _courseTeacher;
  List<String> spreadSheetTemplateColumns = [];

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    String token = await getTokenFromLocalStorage();
    int userId = await getUserIdFromLocalStorage();

    try {
      final courseTeacher =
          await CourseTeacherService().getTeacherById(userId, token);
      if (courseTeacher != null) {
        setState(() {
          _courseTeacher = courseTeacher;
          courses = courseTeacher.courses;
          _isLoading = List.filled(courses.length, false);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading courses: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _isLoadingCourse
          ? const AlertDialog(
              title: Text(
                'Your course is creating...(this may take a while)',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              content: LinearProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("My Courses",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16.0),
                  courses.isEmpty
                      ? const Expanded(
                          child: Center(
                          child: Text('No courses found'),
                        ))
                      : Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            physics: const ScrollPhysics(),
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              for (var course in courses) ...[
                                ListTile(
                                  title: Row(children: [
                                    const Icon(Icons.book),
                                    AutoSizeText(
                                      '${courses.indexOf(course) + 1}. Name: ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      minFontSize: 10,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Expanded(
                                      child: AutoSizeText(
                                        course.courseName,
                                        style: const TextStyle(),
                                        maxLines: 1,
                                        minFontSize: 10,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ]),
                                  subtitle: GestureDetector(
                                    onTap: () {
                                      launchUrl(
                                          Uri.parse(course.urlFileAllStudents));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 8.0),
                                      padding: const EdgeInsets.all(8.0),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: MediaQuery.of(context).size.width <
                                              560
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text('SpreadSheet: ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        )),
                                                    const SizedBox(width: 8.0),
                                                    MouseRegion(
                                                      cursor: SystemMouseCursors
                                                          .click,
                                                      child: Text(
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                700
                                                            ? "here"
                                                            : course
                                                                .urlFileAllStudents,
                                                        softWrap: true,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          decoration:
                                                              TextDecoration
                                                                  .underline,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .surface,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8.0),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    IconButton(
                                                      icon: _isLoading[courses
                                                              .indexOf(course)]
                                                          ? const SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : const Icon(
                                                              Icons.delete,
                                                              size: 30,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      onPressed: () async {
                                                        updateIsLoading(
                                                            courses.indexOf(
                                                                course),
                                                            true);
                                                        try {
                                                          await CourseTeacherService()
                                                              .deleteCourseEntities(
                                                            await getTokenFromLocalStorage(),
                                                            course.id,
                                                          );
                                                          loadCourses();
                                                        } catch (e) {
                                                          if (kDebugMode) {
                                                            print(
                                                                'Error deleting course: $e');
                                                          }
                                                        } finally {
                                                          updateIsLoading(
                                                              courses.indexOf(
                                                                  course),
                                                              false);
                                                        }
                                                      },
                                                      tooltip: 'Delete course',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.download,
                                                        size: 30,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () async {
                                                        _downloadCSV(
                                                            context, course);
                                                      },
                                                      tooltip:
                                                          'Download Excel with public data',
                                                    ),
                                                  ],
                                                )
                                              ],
                                            )
                                          : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      const Text(
                                                        'SpreadSheet: ',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 8.0),
                                                      Expanded(
                                                        child: MouseRegion(
                                                          cursor:
                                                              SystemMouseCursors
                                                                  .click,
                                                          child: Text(
                                                            MediaQuery.of(context)
                                                                        .size
                                                                        .width <
                                                                    700
                                                                ? "here"
                                                                : course
                                                                    .urlFileAllStudents,
                                                            softWrap: true,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              decoration:
                                                                  TextDecoration
                                                                      .underline,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surface,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: _isLoading[courses
                                                              .indexOf(course)]
                                                          ? const SizedBox(
                                                              width: 30,
                                                              height: 30,
                                                              child:
                                                                  CircularProgressIndicator(),
                                                            )
                                                          : const Icon(
                                                              Icons.delete,
                                                              size: 30,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      onPressed: () async {
                                                        updateIsLoading(
                                                            courses.indexOf(
                                                                course),
                                                            true);
                                                        try {
                                                          await CourseTeacherService()
                                                              .deleteCourseEntities(
                                                            await getTokenFromLocalStorage(),
                                                            course.id,
                                                          );
                                                          loadCourses();
                                                        } catch (e) {
                                                          if (kDebugMode) {
                                                            print(
                                                                'Error deleting course: $e');
                                                          }
                                                        } finally {
                                                          updateIsLoading(
                                                              courses.indexOf(
                                                                  course),
                                                              false);
                                                        }
                                                      },
                                                      tooltip: 'Delete course',
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.download,
                                                        size: 30,
                                                        color: Colors.black,
                                                      ),
                                                      onPressed: () async {
                                                        _downloadCSV(
                                                            context, course);
                                                      },
                                                      tooltip:
                                                          'Download CSV with public data',
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                  Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.add,
                        size: 50.0,
                      ),
                      onPressed: () {
                        _showAddCourseDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void updateIsLoading(int index, bool value) {
    setState(() {
      _isLoading[index] = value;
    });
  }

  void updateIsLoadingCourse(bool value) {
    setState(() {
      _isLoadingCourse = value;
    });
  }

  Future<void> _showAddCourseDialog(BuildContext context) async {
    TextEditingController courseNameController = TextEditingController();
    Map<String, LabTeacher> selectedLabTeacher = {};
    String token = await getTokenFromLocalStorage();
    List<LabTeacher> labTeachersList =
        await LabTeacherService().getAllTeachers(token);
    PlatformFile selectedDataFile = PlatformFile(name: '', size: 0);
    TextEditingController columnController = TextEditingController();
    List<String> columns = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Course'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.3,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: courseNameController,
                        style: const TextStyle(
                          fontSize: 12.0,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Course Name',
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(6.0),
                              margin: const EdgeInsets.all(6.0),
                              child: const Text('Columns: ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.0))),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (var column in columns) ...[
                                    Container(
                                      padding: const EdgeInsets.only(left: 5.0),
                                      margin: const EdgeInsets.only(right: 3.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[900],
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4.0,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            column,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.0,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                columns.remove(column);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.15,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(4.0),
                                        child: TextField(
                                          controller: columnController,
                                          style: const TextStyle(
                                            fontSize: 12.0,
                                          ),
                                          decoration: const InputDecoration(
                                            labelText: 'Add a new column',
                                            labelStyle: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          if (columnController
                                              .text.isNotEmpty) {
                                            columns.add(columnController.text);
                                            columnController.clear();
                                          }
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: Container(
                                padding: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius: BorderRadius.circular(8.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    FilePickerResult? result =
                                        await FilePicker.platform.pickFiles(
                                      type: FileType.custom,
                                      allowedExtensions: ['xlsx'],
                                    );
                                    if (result != null) {
                                      PlatformFile file = result.files.first;
                                      setState(() {
                                        selectedDataFile = file;
                                      });

                                      bool isFileOk = CourseTeacherService()
                                          .validateFile(file);

                                      if (isFileOk) {
                                        List<String> groups =
                                            CourseTeacherService()
                                                .generateGroups(file);
                                        groups.sort();

                                        selectedLabTeacher =
                                            await showSelectLabTeachersDialog(
                                                context,
                                                labTeachersList,
                                                groups);
                                      } else {
                                        showInvalidationMessage(context);
                                        selectedDataFile =
                                            PlatformFile(name: "", size: 0);
                                      }
                                    }
                                  },
                                  child: Text(
                                    selectedDataFile.name == ""
                                        ? 'Select Excel File'
                                        : selectedDataFile.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selectedDataFile = PlatformFile(name: "", size: 0);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      spreadSheetTemplateColumns = columns;
                    });

                    if (courseNameController.text.isEmpty ||
                        courseNameController.text == "") {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text(
                                "Please enter a course name!",
                                style: TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            );
                          });
                    } else if (selectedDataFile ==
                        PlatformFile(name: "", size: 0)) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text(
                                "Please upload a file!",
                                style: TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            );
                          });
                    } else if (spreadSheetTemplateColumns.isEmpty) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text(
                                "Please add at least a column!",
                                style: TextStyle(fontSize: 14.0),
                                textAlign: TextAlign.center,
                              ),
                            );
                          });
                    } else {
                      Navigator.pop(context);
                      updateIsLoadingCourse(true);
                      try {
                        String? message =
                            await CourseTeacherService().createCourseEntities(
                          await getTokenFromLocalStorage(),
                          _courseTeacher!.id,
                          {
                            'courseName': courseNameController.text,
                            'labTeachersIds': selectedLabTeacher
                                .map((key, value) => MapEntry(key, value.id)),
                          },
                          selectedDataFile,
                          spreadSheetTemplateColumns,
                        );

                        updateIsLoadingCourse(false);
                        loadCourses();
                        selectedDataFile = PlatformFile(name: "", size: 0);
                        spreadSheetTemplateColumns = [];

                        if (message == 'Course already exists!') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Status: $message"),
                            ),
                          );
                        }
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error creating course entities: $e');
                        }
                        updateIsLoadingCourse(false);
                      }
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _downloadCSV(BuildContext context, Course course) async {
    String token = await getTokenFromLocalStorage();
    try {
      final csvContent =
          await CourseTeacherService().getPrivateFile(token, course.id);

      if (csvContent != "Failed to get GDPR file") {
        if (kIsWeb) {
          final fileBytes = utf8.encode(csvContent);
          final base64EncodedData = base64Encode(fileBytes);

          final dataUri = Uri.parse("data:text/csv;base64,$base64EncodedData");

          launchUrl(dataUri);
        } else {
          final directory = await getExternalStorageDirectory();
          final file = File('${directory!.path}/${course.courseName}.csv');
          await file.writeAsString(csvContent);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('CSV file downloaded successfully'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to download CSV file'),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading CSV file: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download CSV file: $e'),
        ),
      );
    }
  }

  void showInvalidationMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
            child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AlertDialog(
                    title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error),
                        SizedBox(width: 8.0),
                        Text(
                          'Invalid File',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        )
                      ],
                    ),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'The file you selected is invalid. Please select a valid Excel file.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The file should be an xlsx file.',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'The file should have the following columns:',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                            "Numar matricol, Nume, Prenume, An, Grupa, Email, Telefon",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  Future<Map<String, LabTeacher>> showSelectLabTeachersDialog(
      BuildContext context,
      List<LabTeacher> labTeachersList,
      List<String> groups) {
    final Completer<Map<String, LabTeacher>> completer = Completer();
    Map<String, LabTeacher> selectedLabTeachers = {};

    selectedLabTeachers.addAll(
        {for (var groupName in groups) groupName: labTeachersList.first});

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Center(child: Text('Select Lab Teachers')),
              content: SizedBox(
                width: 250,
                height: MediaQuery.of(context).size.height * 0.4,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    String groupName = groups[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.blue[900],
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 4.0,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(groupName,
                                style: const TextStyle(fontSize: 15)),
                          ),
                          const SizedBox(width: 16.0),
                          DropdownButton<LabTeacher>(
                            value: selectedLabTeachers[groupName],
                            onChanged: (LabTeacher? newValue) {
                              setState(() {
                                selectedLabTeachers[groupName] = newValue!;
                              });
                            },
                            items: labTeachersList
                                .map<DropdownMenuItem<LabTeacher>>(
                                    (LabTeacher value) {
                              return DropdownMenuItem<LabTeacher>(
                                value: value,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${value.firstName} ${value.lastName}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      value.email,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    completer.complete(selectedLabTeachers);
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );

    return completer.future;
  }
}
