import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_success_screen.dart';
import 'phone_auth_screen.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  
  Timer? _resendTimer;
  int _timerSeconds = 60;
  bool _canResendCode = false;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
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

  void _handleVerifyCode() {
    final code = _otpControllers.map((c) => c.text).join();
    const String correctOtp = '123456'; // Define the correct OTP for simulation

    if (code.length < 6) {
      setState(() => _errorText = '6 rəqəmli təsdiq kodunu daxil edin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // TODO: Implement actual Firebase code verification
    // --- SIMULATION LOGIC START ---
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      if (code == correctOtp) {
        // Simulate success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AuthSuccessScreen(),
          ),
        );
      } else {
        // Simulate error
        setState(() {
          _isLoading = false;
          _errorText = 'Yanlış kod daxil edildi. Düzgün kod: $correctOtp'; // Show error
        });
        // Clear the OTP fields and reset focus
        for (var controller in _otpControllers) {
          controller.clear();
        }
        if (_otpFocusNodes.isNotEmpty) {
          _otpFocusNodes[0].requestFocus();
        }
      }
    });
    // --- SIMULATION LOGIC END ---

    /* --- ORIGINAL SUCCESS NAVIGATION (Now handled within simulation) ---
    Future.delayed(const Duration(seconds: 2), () { ... });
    */

    /* --- PREVIOUS ERROR SIMULATION (Replaced) ---
    Future.delayed(const Duration(seconds: 1), () { ... });
    */
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
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      _startResendTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and App Name
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
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '+994 ${widget.phoneNumber}',
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
              ),
            ),
          ),
        ),
      ),
    );
  }
} 