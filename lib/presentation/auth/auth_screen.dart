import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partomat_app/presentation/auth/phone_auth_screen.dart';
import 'package:partomat_app/presentation/screens/home_screen.dart';
import 'package:partomat_app/core/utils/logger.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Logger.info('AuthScreen: Initializing authentication state stream');
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          Logger.debug('AuthScreen: Checking authentication state...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show HomeScreen
        if (snapshot.hasData) {
          final user = snapshot.data!;
          Logger.info('AuthScreen: User authenticated - Phone: ${user.phoneNumber}, UID: ${user.uid}');
          return const HomeScreen();
        }

        // If user is not logged in, show PhoneAuthScreen
        Logger.info('AuthScreen: No authenticated user found, showing PhoneAuthScreen');
        return const PhoneAuthScreen();
      },
    );
  }
} 