import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'auth_success_screen.dart';
import 'phone_auth_screen.dart';

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

  void _handleVerifyCode() async {
    final String smsCode = _otpControllers.map((c) => c.text).join();

    if (smsCode.length != 6) {
      setState(() => _errorText = '6 rəqəmli təsdiq kodunu daxil edin');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (!mounted) return;
      setState(() { _isLoading = false; });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthSuccessScreen(),
        ),
      );
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Uğurla daxil oldunuz: ${userCredential.user?.phoneNumber ?? ""}')),
      );

    } on FirebaseAuthException catch (e) {
       if (!mounted) return;
       setState(() {
         _isLoading = false;
         if (e.code == 'invalid-verification-code') {
            _errorText = 'Yanlış kod daxil edildi.';
         } else if (e.code == 'session-expired') {
            _errorText = 'Kodun vaxtı bitib. Yenidən göndərin.';
         } else {
           _errorText = 'Təsdiq uğursuz oldu: ${e.message}';
         }
       });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Xəta: ${_errorText ?? 'Bilinməyən xəta'}')),
        );
       for (var controller in _otpControllers) {
          controller.clear();
        }
        if (_otpFocusNodes.isNotEmpty) {
          _otpFocusNodes[0].requestFocus();
        }
    } catch (e) {
       if (!mounted) return;
       setState(() {
         _isLoading = false;
         _errorText = 'Gözlənilməyən xəta baş verdi: $e';
       });
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Xəta: ${_errorText ?? 'Bilinməyən xəta'}')),
        );
    }
  }

  void _handleResendCode() async {
    if (!_canResendCode) return;

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    for (var controller in _otpControllers) {
      controller.clear();
    }
    if (_otpFocusNodes.isNotEmpty) {
       _otpFocusNodes[0].requestFocus();
    }

    try {
       await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: widget.phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
             if (!mounted) return;
             print("Verification completed after resend.");
          }, 
          verificationFailed: (FirebaseAuthException e) {
              if (!mounted) return;
              setState(() {
                _isLoading = false;
                _errorText = 'Yenidən göndərmə uğursuz oldu: ${e.message}';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Xəta: ${_errorText ?? 'Bilinməyən xəta'}')),
              );
          }, 
          codeSent: (String verificationId, int? resendToken) {
              if (!mounted) return;
              print("New code sent. New verification ID: $verificationId"); 
             _resendToken = resendToken; 
              setState(() { _isLoading = false; });
             _startResendTimer();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yeni təsdiq kodu göndərildi.')),
              );
          }, 
          codeAutoRetrievalTimeout: (String verificationId) {
              if (!mounted) return;
              print("Auto retrieval timeout for resent code: $verificationId");
          },
          timeout: const Duration(seconds: 60),
          forceResendingToken: _resendToken,
       );
    } catch (e) {
       if (!mounted) return;
       setState(() {
          _isLoading = false;
          _errorText = 'Yenidən göndərmə zamanı xəta: $e';
       });
       ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Xəta: ${_errorText ?? 'Bilinməyən xəta'}')),
       );
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
                    onTap: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const PhoneAuthScreen()),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone_iphone, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          widget.phoneNumber,
                          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.edit_outlined, size: 16, color: Colors.grey[700]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Verification Code Input Title
                  Text(
                    'Təsdiq kodunu daxil edin',
                    textAlign: TextAlign.center,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 24),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 60,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(1),
                          ],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 5) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]);
                            }
                            setState(() {
                              _errorText = null;
                            });
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Resend Code Area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SMS təsdiq kodu göndərildi',
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: _canResendCode && !_isLoading ? _handleResendCode : null,
                        child: Text(
                          _canResendCode
                              ? 'Yenidən göndər'
                              : 'Yenidən göndər (${_timerSeconds}s)',
                          style: textTheme.bodySmall?.copyWith(
                            color: _canResendCode ? colorScheme.primary : Colors.grey[600],
                            fontWeight: _canResendCode ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
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
                        borderRadius: BorderRadius.circular(12.0),
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