import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_success_screen.dart';
import 'phone_auth_screen.dart';
import 'package:partomat_app/core/utils/logger.dart';

class VerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const VerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
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
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    Logger.info('VerificationScreen: Initialized for phone ${widget.phoneNumber}');
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
    Logger.info('VerificationScreen: Disposed');
    super.dispose();
  }

  void _startResendTimer() {
    Logger.debug('VerificationScreen: Starting resend timer');
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _canResendCode = true;
          timer.cancel();
          Logger.debug('VerificationScreen: Resend timer expired');
        }
      });
    });
  }

  void _handleVerifyCode() async {
    final String smsCode = _otpControllers.map((c) => c.text).join();
    if (smsCode.length != 6) {
      Logger.warning('VerificationScreen: Invalid OTP length - ${smsCode.length}');
      setState(() => _errorText = 'Please enter a valid 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    Logger.info('VerificationScreen: Attempting to verify code for phone ${widget.phoneNumber}');

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Logger.info('VerificationScreen: Code verified successfully');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthSuccessScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      Logger.error('VerificationScreen: Verification failed', e);
      setState(() {
        _isLoading = false;
        _errorText = e.message ?? 'Verification failed';
      });
    } catch (e) {
      Logger.error('VerificationScreen: Unexpected error during verification', e);
      setState(() {
        _isLoading = false;
        _errorText = 'An unexpected error occurred';
      });
    }
  }

  void _handleResendCode() async {
    if (!_canResendCode) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
      _canResendCode = false;
      _timerSeconds = 60;
    });

    Logger.info('VerificationScreen: Attempting to resend code to ${widget.phoneNumber}');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          Logger.info('VerificationScreen: Auto verification completed on resend');
          setState(() => _isLoading = false);
        },
        verificationFailed: (FirebaseAuthException e) {
          Logger.error('VerificationScreen: Resend verification failed', e);
          setState(() {
            _isLoading = false;
            _errorText = e.message ?? 'Resend failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          Logger.info('VerificationScreen: New code sent successfully');
          setState(() {
            _isLoading = false;
            _canResendCode = false;
          });
          _startResendTimer();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Logger.warning('VerificationScreen: Auto retrieval timeout on resend');
          setState(() => _isLoading = false);
        },
      );
    } catch (e) {
      Logger.error('VerificationScreen: Unexpected error during resend', e);
      setState(() {
        _isLoading = false;
        _errorText = 'An unexpected error occurred';
      });
    }
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
                    onTap: () {
                      Logger.info('Navigating back to phone input screen');
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                      );
                    },
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
                          onPressed: _isLoading || !_canResendCode ? null : _handleResendCode,
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