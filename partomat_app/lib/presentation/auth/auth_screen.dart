import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for InputFormatters

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Authentication state
  String _authStage = 'phone'; // 'phone', 'verification', 'googleProfile', 'success'
  bool _isLoading = false;
  String? _errorText;

  // Phone auth states
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  // Timer state
  Timer? _resendTimer;
  int _timerSeconds = 60;
  bool _canResendCode = false;

  @override
  void dispose() {
    _phoneController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _timerSeconds = 60;
      _canResendCode = false;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _canResendCode = true;
          timer.cancel();
        }
      });
    });
  }

  void _handlePhoneSubmit() {
    if (_phoneController.text.length < 9) {
      setState(() => _errorText = 'Düzgün telefon nömrəsi daxil edin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement actual Firebase phone authentication
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _authStage = 'verification';
      });
      _startResendTimer();
    });
  }

  void _handleVerifyCode() {
    final code = _otpControllers.map((c) => c.text).join();
    
    if (code.length < 6) {
      setState(() => _errorText = '6 rəqəmli təsdiq kodunu daxil edin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement actual Firebase code verification
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _authStage = 'success';
      });
    });
  }

  void _handleResendCode() {
    if (!_canResendCode) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Clear existing code
    for (var controller in _otpControllers) {
      controller.clear();
    }

    // TODO: Implement actual Firebase resend code
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
      _startResendTimer();
    });
  }

  void _handleGoogleSignIn() {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement actual Firebase Google Sign-In
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _authStage = 'googleProfile';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: _buildCurrentSection(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_authStage) {
      case 'verification':
        return _buildVerificationSection();
      case 'googleProfile':
        return Container(); // TODO: Implement Google profile section
      case 'success':
        return Container(); // TODO: Implement success section
      case 'phone':
      default:
        return _buildPhoneInputSection();
    }
  }

  // Updated Phone Input UI section
  Widget _buildPhoneInputSection() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // TODO: Add state management for phone number, loading, errors
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
          controller: _phoneController,
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

        // Continue Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handlePhoneSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
          ),
          child: _isLoading
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
          onPressed: _isLoading ? null : _handleGoogleSignIn,
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

  Widget _buildVerificationSection() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Logo and App Name (reused from phone input section)
        Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colorScheme.primary,
              child: const Icon(Icons.key, size: 30, color: Colors.white),
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

        // Phone Number Display with Back Option
        InkWell(
          onTap: () => setState(() => _authStage = 'phone'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, size: 16),
              const SizedBox(width: 8),
              Text(
                '+994 ${_phoneController.text}',
                style: textTheme.titleSmall,
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Verification Code Title
        Text(
          'Təsdiq kodunu daxil edin',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // OTP Input Fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: textTheme.titleLarge,
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colorScheme.primary),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    _otpFocusNodes[index + 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 16),

        // Timer and Resend Option
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SMS təsdiq kodu göndərildi',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            if (_timerSeconds > 0)
              Text(
                'Yenidən göndər (${_timerSeconds}s)',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              )
            else
              TextButton(
                onPressed: _canResendCode ? _handleResendCode : null,
                child: const Text('Yenidən göndər'),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (_errorText != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: textTheme.bodyMedium?.copyWith(color: Colors.red[700]),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 24),

        // Verify Button
        ElevatedButton(
          onPressed: _isLoading ? null : _handleVerifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Təsdiqlə'),
        ),
      ],
    );
  }

  // Placeholder for the Google Profile Completion UI section
  // Widget _buildGoogleProfileSection(BuildContext context) { ... }

  // Placeholder for the Success UI section
  // Widget _buildSuccessSection(BuildContext context) { ... }
} 