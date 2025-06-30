import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/button.dart';
import '../widgets/terms_and_conditions.dart';
import '../widgets/page_title_with_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({Key? key}) : super(key: key);

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Check network connectivity - try multiple hosts for better reliability
  Future<bool> _hasNetworkConnection() async {
    final hosts = ['google.com', '8.8.8.8', 'firebase.google.com'];
    
    for (String host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 10));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        continue; // Try next host
      }
    }
    return false; // All hosts failed
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user with Firebase with timeout - increased timeout
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      ).timeout(const Duration(seconds: 30));

      final user = credential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-creation-failed',
          message: 'Failed to create user account',
        );
      }

      // Update display name with timeout
      await user.updateDisplayName(_nameController.text.trim())
          .timeout(const Duration(seconds: 20));

      // Send verification email first with timeout
      try {
        await user.sendEmailVerification()
            .timeout(const Duration(seconds: 30));
      } catch (e) {
        // If email verification fails, delete the user and report
        try {
          await user.delete().timeout(const Duration(seconds: 20));
        } catch (deleteError) {
          debugPrint('Failed to delete user after email verification failure: $deleteError');
        }
        throw FirebaseAuthException(
          code: 'email-verification-failed',
          message: 'Failed to send verification email. Please try again.',
        );
      }

      // Attempt to save basic user information in Firestore (optional) with timeout
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'emailVerified': false,
          'createdAt': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 20));
      } catch (e) {
        // Log error but keep the account; Firestore write failure shouldn't block sign-up
        debugPrint('Failed to save user data: $e');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please check your email for verification link.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Sign out and return to login with timeout
        try {
          await FirebaseAuth.instance.signOut().timeout(const Duration(seconds: 10));
        } catch (e) {
          debugPrint('Sign out error: $e');
        }
        
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Check network connectivity only when there's a timeout
        final hasConnection = await _hasNetworkConnection();
        final errorMessage = hasConnection 
            ? 'Request timed out. Firebase servers might be slow. Please try again.'
            : 'No internet connection. Please check your network and try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        String errorMessage = 'Registration failed';
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = 'This email is already registered. Please login instead.';
            break;
          case 'invalid-email':
            errorMessage = 'Please enter a valid email address.';
            break;
          case 'weak-password':
            errorMessage = 'Password is too weak. Please use a stronger password.';
            break;
          case 'email-verification-failed':
            errorMessage = e.message ?? 'Failed to send verification email. Please try again.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection and try again.';
            break;
          default:
            errorMessage = e.message ?? 'Registration failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred. Please try again.'),
            backgroundColor: Colors.red,
                ),
              );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Logo
                const Center(
                  child: AppLogo(),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                const Text(
                  'Create your account',
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
                    widthFactor: 0.2, // 20% progress
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: const Color(0xFF5159FF),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Your Name field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Name',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                    const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                    ),
                  ),
                      style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Email Address field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                    ),
                  ),
                      style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                        hintText: 'Create a password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                      style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Confirm Password field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                        hintText: 'Confirm your password',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                    ),
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
                    contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                      style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Next button
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
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
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                
                const SizedBox(height: 40),
                
                // Terms and conditions
                Text(
                  "By signing up you agree to Money Mouthy's terms and conditions.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}