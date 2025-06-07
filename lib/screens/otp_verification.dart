import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:money_mouthy_two/widgets/button.dart';
import 'package:money_mouthy_two/screens/choose_username.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_mouthy_two/screens/create_profile.dart';
import 'package:money_mouthy_two/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Replace these imports with your actual widget imports if needed
import '../widgets/app_logo.dart';
import '../widgets/page_title_with_indicator.dart';
import '../widgets/terms_and_conditions.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final bool isLogin;

  const OtpVerificationScreen({
    super.key,
    required this.email,
    this.isLogin = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  String? _verificationId;
  int _resendToken = 0;
  bool _isPasscodeMode = false;
  final List<TextEditingController> _passcodeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _passcodeFocusNodes = List.generate(
    4,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _passcodeControllers) {
      controller.dispose();
    }
    for (var node in _passcodeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate OTP sending for testing (remove phone auth for now)
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test OTP: 123456'),
        backgroundColor: Colors.green,
      ),
    );
  }

    Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });

    // For testing, accept 123456 as valid OTP
    if (otp == '123456') {
      if (widget.isLogin) {
        // Handle login flow
        _checkPasscode();
      } else {
        // Handle registration flow
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateProfile(),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid OTP. Use 123456 for testing.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkPasscode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');

    if (savedPasscode == null) {
      // First time login, set up passcode
      setState(() {
        _isPasscodeMode = true;
      });
    } else {
      // Verify existing passcode
      setState(() {
        _isPasscodeMode = true;
      });
    }
  }

  Future<void> _verifyPasscode() async {
    final enteredPasscode = _passcodeControllers.map((c) => c.text).join();
    final prefs = await SharedPreferences.getInstance();
    final savedPasscode = prefs.getString('passcode');

    if (savedPasscode == null) {
      // Save new passcode
      await prefs.setString('passcode', enteredPasscode);
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      // Verify existing passcode
      if (enteredPasscode == savedPasscode) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid passcode'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isPasscodeMode) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Enter Passcode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _passcodeControllers[index],
                        focusNode: _passcodeFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _passcodeFocusNodes[index + 1].requestFocus();
                          }
                          if (value.length == 1 && index == 3) {
                            _verifyPasscode();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a verification code to ${widget.email}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 40,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.length == 1 && index == 5) {
                          final otp = _controllers.map((c) => c.text).join();
                          _verifyOtp(otp);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                  TextButton(
                  onPressed: _sendOtp,
                    child: const Text(
                    'Resend Code',
                      style: TextStyle(
                        color: Color(0xFF5159FF),
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}