// Import necessary packages and files
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:student_d/login_screen.dart';
import 'package:student_d/home_screen.dart';
import 'package:student_d/registration_screen.dart';
import 'package:student_d/home_bloc.dart'; // Import HomeBloc
import 'package:student_d/teacher_page.dart'; // Import TeacherPage
import 'package:student_d/teacher_bloc.dart'; // Import TeacherBloc

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final Future<FirebaseApp> initialization = Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCnH1SDNB_VH3PYX9aqGpWAiWj9EBpzpno',
      appId: '1:911947052300:android:4de1e4482bc8ef349e4529',
      messagingSenderId: '911947052300',
      projectId: 'studentinfo-855d9',
      databaseURL: 'https://studentinfo-855d9-default-rtdb.firebaseio.com',
      storageBucket: 'studentinfo-855d9.appspot.com',
    ),
  );

  runApp(MyApp(initialization: initialization));
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> initialization;

  const MyApp({Key? key, required this.initialization}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: Text("Initializing..."),
              ),
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              appBar: AppBar(
                title: Text("Error initializing Firebase"),
              ),
              body: Center(
                child: Text("Something went wrong!"),
              ),
            ),
          );
        }

        // Create instances of HomeBloc and TeacherBloc
        final HomeBloc homeBloc =
            HomeBloc(firestore: FirebaseFirestore.instance);
        final TeacherBloc teacherBloc =
            TeacherBloc(firestore: FirebaseFirestore.instance);

        return MultiBlocProvider(
          providers: [
            BlocProvider<HomeBloc>(create: (context) => homeBloc),
            BlocProvider<TeacherBloc>(create: (context) => teacherBloc),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Student Info App',
            theme: ThemeData.dark(),
            initialRoute: '/login', // Set the initial route to the login screen
            routes: {
              '/login': (context) => LoginScreen(),
              '/home': (context) => MyHomePage(
                  homeBloc: homeBloc,
                  teacherBloc: teacherBloc), // Main home page with navigation
              '/registration': (context) => RegistrationScreen(),
              '/teacher': (context) => TeacherPage(),
            },
          ),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final HomeBloc homeBloc;
  final TeacherBloc teacherBloc;

  const MyHomePage(
      {Key? key, required this.homeBloc, required this.teacherBloc})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(homeBloc: widget.homeBloc),
      TeacherPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Student Details',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
