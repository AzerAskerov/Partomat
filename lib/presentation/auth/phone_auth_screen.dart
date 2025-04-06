import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'verification_screen.dart';
import 'package:partomat_app/core/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoadingPhone = false;
  bool _isLoadingGoogle = false;
  String? _errorText;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    Logger.info('PhoneAuthScreen: Initialized');
    _phoneController.addListener(_validatePhone);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _phoneController.dispose();
    Logger.info('PhoneAuthScreen: Disposed');
    super.dispose();
  }

  void _validatePhone() {
    setState(() {
      _isPhoneValid = _phoneController.text.length == 9;
      if (_isPhoneValid) {
        _errorText = null;
      }
    });
    Logger.debug('PhoneAuthScreen: Phone validation - $_isPhoneValid');
  }

  Future<void> _handlePhoneSubmit() async {
    if (!_formKey.currentState!.validate()) {
      Logger.warning('PhoneAuthScreen: Form validation failed');
      return;
    }

    setState(() {
      _isLoadingPhone = true;
      _errorText = null;
    });

    Logger.info('PhoneAuthScreen: Starting phone verification for ${_phoneController.text}');

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) {
          Logger.info('PhoneAuthScreen: Auto verification completed');
          setState(() => _isLoadingPhone = false);
        },
        verificationFailed: (FirebaseAuthException e) {
          Logger.error('PhoneAuthScreen: Verification failed', e);
          setState(() {
            _isLoadingPhone = false;
            _errorText = e.message ?? 'Verification failed';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          Logger.info('PhoneAuthScreen: Verification code sent, navigating to VerificationScreen');
          setState(() => _isLoadingPhone = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationScreen(
                verificationId: verificationId,
                phoneNumber: _phoneController.text,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          Logger.warning('PhoneAuthScreen: Auto retrieval timeout');
          setState(() => _isLoadingPhone = false);
        },
      );
    } catch (e) {
      Logger.error('PhoneAuthScreen: Unexpected error during verification', e);
      setState(() {
        _isLoadingPhone = false;
        _errorText = 'An unexpected error occurred';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoadingGoogle = true;
      _errorText = null;
    });
    Logger.info('PhoneAuthScreen: Starting Google Sign-In');

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        Logger.warning('PhoneAuthScreen: Google Sign-In cancelled by user');
        setState(() => _isLoadingGoogle = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Logger.info('PhoneAuthScreen: Google Sign-In successful, user authenticated');
    } on FirebaseAuthException catch (e) {
      Logger.error('PhoneAuthScreen: Google Sign-In failed (Firebase)', e);
      setState(() {
        _errorText = e.message ?? 'Google Sign-In failed';
      });
    } catch (e, stackTrace) {
      Logger.error('PhoneAuthScreen: Google Sign-In failed (Unexpected)', e, stackTrace);
      setState(() {
        _errorText = 'An unexpected error occurred during Google Sign-In';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoadingGoogle = false);
      }
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

                  // Phone Number Input
                  Text(
                    'Telefon nömrənizi daxil edin',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      hintText: '50 123 45 67',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 8, 0),
                        child: Text('+994', style: textTheme.bodyLarge),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                        borderSide: BorderSide(color: colorScheme.primary),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Təsdiq kodu göndəriləcək',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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

                  // Continue Button
                  ElevatedButton(
                    onPressed: _isLoadingPhone || _isLoadingGoogle ? null : _handlePhoneSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    child: _isLoadingPhone
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('Davam et'),
                              SizedBox(width: 8),
                              Icon(Icons.chevron_right, size: 20),
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
                    icon: Image.asset('assets/google_logo.png', height: 20.0),
                    label: const Text('Google ilə davam edin'),
                    onPressed: _isLoadingPhone || _isLoadingGoogle ? null : _handleGoogleSignIn,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      textStyle: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
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