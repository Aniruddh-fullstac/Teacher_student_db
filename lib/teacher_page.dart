import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'teacher_bloc.dart';
import 'package:intl/intl.dart';

class TeacherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TeacherBloc(firestore: FirebaseFirestore.instance)
        ..add(FetchStudents()),
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white
        appBar: AppBar(
          backgroundColor: Colors.black, // Set AppBar background color to black
          title: Text('Teacher Page',
              style: TextStyle(
                  color: Colors.white)), // Set AppBar text color to white
        ),
        body: BlocBuilder<TeacherBloc, TeacherState>(
          builder: (context, state) {
            if (state is TeacherLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is TeacherLoaded) {
              if (state.students.isEmpty) {
                return Center(
                    child: Text('No students found.',
                        style: TextStyle(
                            color: Colors.black))); // Set text color to black
              }
              return ListView.builder(
                itemCount: state.students.length,
                itemBuilder: (context, index) {
                  final student = state.students[index];
                  return ListTile(
                    title: Text(student['name'] ?? 'No Name',
                        style: TextStyle(
                            color: Colors.black)), // Set text color to black
                    subtitle: Text(
                      'Date of Birth: ${DateFormat('yyyy-MM-dd').format(student['dateOfBirth']?.toDate() ?? DateTime.now())} | Gender: ${student['gender'] ?? 'Unknown'}',
                      style: TextStyle(
                          color: Colors.black), // Set text color to black
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit,
                          color: Colors.black), // Set icon color to black
                      onPressed: () {
                        _showEditDialog(context, student);
                      },
                    ),
                  );
                },
              );
            } else if (state is TeacherError) {
              return Center(
                  child: Text(state.message,
                      style: TextStyle(
                          color: Colors.black))); // Set text color to black
            }
            return Center(
                child: Text('No students found.',
                    style: TextStyle(
                        color: Colors.black))); // Set text color to black
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot student) {
    final nameController = TextEditingController(text: student['name']);
    final dateOfBirthController = TextEditingController(
        text: student['dateOfBirth']?.toDate().toString() ?? '');
    final genderController =
        TextEditingController(text: student['gender'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Set dialog background color to white
          title: Text('Edit Student',
              style: TextStyle(
                  color: Colors.black)), // Set title text color to black
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(
                      color: Colors.black), // Set label text color to black
                ),
                style:
                    TextStyle(color: Colors.black), // Set text color to black
              ),
              ListTile(
                title: Text(
                  'Date of Birth: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(dateOfBirthController.text))}',
                  style:
                      TextStyle(color: Colors.black), // Set text color to black
                ),
                trailing: Icon(Icons.calendar_today,
                    color: Colors.black), // Set icon color to black
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    dateOfBirthController.text = picked.toString();
                  }
                },
              ),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                      color: Colors.black), // Set label text color to black
                ),
                value: genderController.text,
                items: ['Male', 'Female', 'Other'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender,
                        style: TextStyle(
                            color: Colors
                                .black)), // Set dropdown item text color to black
                  );
                }).toList(),
                onChanged: (value) {
                  genderController.text = value!;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.black)), // Set button text color to black
            ),
            ElevatedButton(
              onPressed: () {
                final updatedData = {
                  'name': nameController.text,
                  'dateOfBirth': DateTime.parse(dateOfBirthController.text),
                  'gender': genderController.text,
                };
                BlocProvider.of<TeacherBloc>(context).add(
                  UpdateStudent(
                    studentId: student.id,
                    updatedData: updatedData,
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.black, // Set button background color to black
                foregroundColor: Colors.white, // Set button text color to white
              ),
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
