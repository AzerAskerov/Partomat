import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:partomat_app/presentation/auth/auth_screen.dart';
import 'package:partomat_app/core/utils/logger.dart'; // Import Logger
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Logger.init(); // Initialize Logger
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartoMat App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthScreen(), // Start with AuthScreen
    );
  }
} 