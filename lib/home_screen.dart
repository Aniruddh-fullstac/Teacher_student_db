import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:student_d/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  final HomeBloc homeBloc;

  const HomeScreen({Key? key, required this.homeBloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: homeBloc,
      child: HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({Key? key}) : super(key: key);

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  final _formKey = GlobalKey<FormState>();

  String _studentName = '';
  DateTime? _dateOfBirth;
  String? _gender;
  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is HomeSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Student data uploaded successfully!'),
            ),
          );
          _formKey.currentState?.reset();
          setState(() {
            _studentName = '';
            _dateOfBirth = null;
            _gender = null;
          });
        } else if (state is HomeErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Set background color to white
        appBar: AppBar(
          backgroundColor: Colors.black, // Set AppBar background color to black
          title: const Text(
            'Student Database',
            style: TextStyle(
              color: Colors.white, // Set AppBar text color to white
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.white, // Set icon color to white
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Name *',
                      labelStyle: TextStyle(
                        color: Colors.black, // Set label color to black
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter student name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _studentName = value;
                      });
                    },
                    style: TextStyle(
                      color: Colors.black, // Set text color to black
                    ),
                  ),
                  ListTile(
                    title: Text(
                      _dateOfBirth == null
                          ? 'Date of Birth *'
                          : 'Date of Birth *: ${DateFormat('yyyy-MM-dd').format(_dateOfBirth!)}',
                      style: TextStyle(
                        color: Colors.black, // Set text color to black
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: Colors.black, // Set icon color to black
                    ),
                    onTap: () {
                      _selectDateOfBirth(context);
                    },
                  ),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      labelStyle: TextStyle(
                        color: Colors.black, // Set label color to black
                      ),
                      fillColor: Colors
                          .white, // Set dropdown background color to white
                      filled:
                          true, // Ensure the dropdown is filled with the background color
                    ),
                    value: _gender,
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(
                          gender,
                          style: TextStyle(
                            color: gender == 'Male' ||
                                    gender == 'Female' ||
                                    gender == 'Other'
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select gender';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              final isValid = _formKey.currentState?.validate() ?? false;
              if (isValid) {
                BlocProvider.of<HomeBloc>(context).add(
                  AddStudentEvent(
                    name: _studentName,
                    dateOfBirth: _dateOfBirth!,
                    gender: _gender!,
                  ),
                );
              }
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
                Color.fromARGB(255, 13, 0, 15),
              ),
              foregroundColor: MaterialStateProperty.all<Color>(
                Colors.white,
              ),
            ),
            child: const Text('Upload Student Data'),
          ),
        ),
      ),
    );
  }

  void _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }
}
