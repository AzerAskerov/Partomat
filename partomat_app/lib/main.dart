import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // Import App Check
import 'package:flutter/material.dart';

// import 'presentation/screens/home_screen.dart'; // Keep or remove as needed
// import 'presentation/auth/phone_auth_screen.dart'; // Remove or comment out
import 'presentation/auth/auth_screen.dart'; // Import AuthScreen
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Activate App Check
  await FirebaseAppCheck.instance.activate(
    // Use Play Integrity provider for Android
    androidProvider: AndroidProvider.playIntegrity,
    // You can also provide appleProvider for iOS/macOS if needed later
    // appleProvider: AppleProvider.appAttest,
  );
  
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
      // home: const PhoneAuthScreen(), // Change this
      home: const AuthScreen(), // Set AuthScreen as home
    );
  }
}
