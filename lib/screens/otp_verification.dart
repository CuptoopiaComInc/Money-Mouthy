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
              builder: (context) => const ChooseUsernameScreen(),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // Logo
                const Center(
                  child: AppLogo(),
                ),
                
                const SizedBox(height: 60),
                
                const Text(
                  'Enter Passcode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                
                const SizedBox(height: 20),
                
                const Text(
                  'Enter your 4-digit passcode',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (index) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: TextField(
                        controller: _passcodeControllers[index],
                        focusNode: _passcodeFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        obscureText: true,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF5159FF), width: 2),
                          ),
                        ),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 3) {
                            _passcodeFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _passcodeFocusNodes[index - 1].requestFocus();
                          }
                          
                          if (index == 3 && value.isNotEmpty) {
                            _verifyPasscode();
                          }
                        },
                      ),
                    );
                  }),
                ),
                
                const Spacer(),
                
                // Terms and conditions
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: Text(
                    "By signing up you agree to Money Mouthy's terms and conditions.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Logo
              const Center(
                child: AppLogo(),
              ),
              
              const SizedBox(height: 60),
              
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Progress indicator
              Container(
                width: 120,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey.shade200,
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 0.4, // 40% progress
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF5159FF),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'Code has been sent to\n${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    height: 60,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF5159FF), width: 2),
                        ),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        
                        if (index == 5 && value.isNotEmpty) {
                          final otp = _controllers.map((c) => c.text).join();
                          if (otp.length == 6) {
                            _verifyOtp(otp);
                          }
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 30),
              
              // Resend text
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Haven't received the verification code? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: _sendOtp,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5159FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
            ),
              
              const SizedBox(height: 40),
              
              // Verify button
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        final otp = _controllers.map((c) => c.text).join();
                        if (otp.length == 6) {
                          _verifyOtp(otp);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter complete OTP'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5159FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              
              const Spacer(),
              
              // Terms and conditions
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Text(
                  "By signing up you agree to Money Mouthy's terms and conditions.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}