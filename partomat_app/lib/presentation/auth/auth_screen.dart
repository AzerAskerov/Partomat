import 'package:firebase_auth/firebase_auth.dart'; // Add Firebase Auth
import 'package:flutter/material.dart';
import 'package:partomat_app/presentation/auth/phone_auth_screen.dart'; // Add PhoneAuthScreen import
import 'package:partomat_app/presentation/screens/home_screen.dart'; // Add HomeScreen import

class AuthScreen extends StatelessWidget { // Change to StatelessWidget
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, show HomeScreen
        if (snapshot.hasData) {
          // You might want to pass the User object to HomeScreen if needed
          // return HomeScreen(user: snapshot.data!); 
          return const HomeScreen(); 
        }

        // If user is not logged in, show PhoneAuthScreen
        return const PhoneAuthScreen();
      },
    );
  }
}

// Remove the old _AuthScreenState class entirely, including:
// - _authStage, _isLoading, _errorText
// - Controllers and FocusNodes
// - Timer logic (_resendTimer, _timerSeconds, _canResendCode)
// - All handler methods (_handlePhoneSubmit, _handleVerifyCode, etc.)
// - All _build... section methods (_buildCurrentSection, _buildPhoneInputSection, etc.) 