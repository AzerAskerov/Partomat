import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Implement authentication UI based on state (phone, verify, google profile, success)
    return Scaffold(
      // Remove AppBar for a cleaner look like the mockup
      // appBar: AppBar(
      //   title: const Text('PartoMat Auth'),
      // ),
      backgroundColor: Colors.grey[50], // Match mockup background
      body: Center(
        child: SingleChildScrollView( // Allow scrolling if content overflows
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Limit width on larger screens
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildPhoneInputSection(context),
            ),
          ),
        ),
      ),
    );
  }

  // Updated Phone Input UI section
  Widget _buildPhoneInputSection(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Add state management for phone number, loading, errors
    final phoneNumberController = TextEditingController(); 
    bool isLoading = false; // Placeholder state
    String? errorText; // Placeholder state
    bool isPhoneNumberValid = false; // Placeholder state, derive from controller

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo and App Name
        Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.key, size: 30, color: Colors.white), // Placeholder icon
            ),
            const SizedBox(height: 8),
            Text(
              'PartoMat',
              style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Avtomobil hissələri axtarışı',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Phone Number Input
        Text(
          'Telefon nömrənizi daxil edin',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: phoneNumberController,
          decoration: InputDecoration(
            // labelText: 'Telefon nömrəsi', // Using hintText instead
            hintText: '50 123 45 67',
            prefixIcon: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
              child: Text('+994', style: textTheme.bodyLarge),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0), // Fit prefix
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide.none, // Use filled style
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: Colors.grey[300]!), 
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.primary), 
            ),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9), // Limit to 9 digits after prefix
          ],
          // TODO: Add onChanged to update isPhoneNumberValid state
          // onChanged: (value) { ... },
        ),
        const SizedBox(height: 8),
        Text(
          'Təsdiq kodu göndəriləcək',
          style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),

        // TODO: Add Error Message Widget here if errorText is not null

        // Continue Button
        ElevatedButton(
          onPressed: isLoading || !isPhoneNumberValid ? null : () {
            // TODO: Handle phone number submission
            print('Phone number: ${phoneNumberController.text}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Davam et'),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, size: 20),
                  ],
                ),
        ),
        const SizedBox(height: 24),

        // Separator
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'və ya',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ),
            Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),

        // Google Sign-In Button
        OutlinedButton.icon(
          icon: Image.asset('assets/google_logo.png', height: 20.0), // Placeholder - requires asset
          label: const Text('Google ilə davam edin'),
          onPressed: isLoading ? null : () {
            // TODO: Handle Google Sign-In
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black87,
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.grey[300]!), 
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
             textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }

  // Placeholder for the Verification Code UI section
  // Widget _buildVerificationSection(BuildContext context) { ... }

  // Placeholder for the Google Profile Completion UI section
  // Widget _buildGoogleProfileSection(BuildContext context) { ... }

  // Placeholder for the Success UI section
  // Widget _buildSuccessSection(BuildContext context) { ... }
} 