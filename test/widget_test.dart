import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:student_d/main.dart';
import 'package:flutter/services.dart'; // Import necessary package for MethodChannel

void main() {
  // Ensure that mock method calls are set up before Flutter initializes
  WidgetsFlutterBinding.ensureInitialized();

  // Mock setup function to initialize Firebase
  setupFirebaseAuthMocks();

  setUpAll(() async {
    // Initialize Firebase
    await Firebase.initializeApp();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a mock initialization for Firebase
    final Future<FirebaseApp> mockInitialization = Future.value();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(initialization: mockInitialization));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

// Mock setup function to initialize Firebase
void setupFirebaseAuthMocks() {
  // Mock method channel for Firebase
  const MethodChannel channel =
      MethodChannel('plugins.flutter.io/firebase_core');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    if (methodCall.method == 'Firebase#initializeCore') {
      return null;
    }

    if (methodCall.method == 'Firebase#initializeApp') {
      return null;
    }

    return null;
  });
}
