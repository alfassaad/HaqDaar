import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/src/auth/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  final AuthService _authService = AuthService();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String _verificationId = "";

  @override
  void dispose() {
    _cnicController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    final cnic = _cnicController.text.trim();
    String phoneInput = _phoneController.text.trim();

    if (cnic.isEmpty || phoneInput.isEmpty || cnic.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid CNIC (10+ digits) and Phone Number')),
      );
      return;
    }

    // Smart auto-prefixing
    if (phoneInput.startsWith('+')) {
      // Already has a plus, use as is
    } else if (phoneInput.startsWith('0')) {
      // Local Pakistani number
      phoneInput = '+92${phoneInput.substring(1)}';
    } else if (phoneInput.startsWith('974')) {
      // Qatar number shortcut
      phoneInput = '+$phoneInput';
    } else {
      // Fallback: Assume Pakistan if it's 10 digits
      if (phoneInput.length == 10) {
        phoneInput = '+92$phoneInput';
      } else {
        // Just add a plus and hope for the best
        phoneInput = '+$phoneInput';
      }
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhone(
        phoneNumber: phoneInput,
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification code sent!')),
          );
        },
        onVerificationFailed: (e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed [${e.code}]: ${e.message}'), backgroundColor: Colors.red),
          );
        },
        onVerificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          if (mounted) context.go('/home');
        },
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _verifyOtp() async {
    if (_otpController.text.length < 6) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithOtp(_verificationId, _otpController.text);
      
      if (!mounted) return;
      
      final cnic = _cnicController.text.trim();
      final phoneInput = _phoneController.text.trim();
      
      String name = 'User';
      String phone = phoneInput;

      await Provider.of<AppProvider>(context, listen: false).login(
        name: name,
        cnic: cnic,
        phone: phone,
      );
      
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      String errorMsg = 'Invalid OTP: $e';
      if (e.toString().contains('permission-denied')) {
        errorMsg = 'Permission Denied: Please deploy Firestore rules.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_isOtpSent) {
              setState(() => _isOtpSent = false);
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                _isOtpSent ? 'Verify OTP' : 'Welcome Back',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isOtpSent 
                    ? 'Enter the 6-digit code sent to ${_phoneController.text}'
                    : 'Sign in to your HaqDaar account',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withAlpha((0.6 * 255).toInt()),
                ),
              ),
              const SizedBox(height: 48),

              if (!_isOtpSent) ...[
                Text(
                  'CNIC Number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _cnicController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0123456789',
                    prefixIcon: Icon(Icons.badge_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Phone Number',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: '03001234567',
                    prefixIcon: Icon(Icons.phone_outlined, color: colorScheme.primary),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ] else ...[
                Text(
                  'Verification Code',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 20, fontWeight: FontWeight.bold),
                  maxLength: 6,
                  decoration: InputDecoration(
                    hintText: '******',
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha((0.3 * 255).toInt()),
                    counterText: "",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isOtpSent ? _verifyOtp : _sendOtp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isOtpSent ? 'Verify & Login' : 'Get OTP',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {
                    if (_isOtpSent) {
                      setState(() => _isOtpSent = false);
                    }
                  },
                  child: Text(
                    _isOtpSent ? 'Change Credentials?' : 'Need help signing in?',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


}
