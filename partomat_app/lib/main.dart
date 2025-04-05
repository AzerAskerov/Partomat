import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// import 'presentation/screens/home_screen.dart'; // Keep or remove as needed
import 'presentation/auth/phone_auth_screen.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize logger
  Logger.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PartoMat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // home: const HomeScreen(), // Temporarily comment out HomeScreen
      home: const PhoneAuthScreen(),
    );
  }
}
