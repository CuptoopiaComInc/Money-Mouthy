import 'package:flutter/material.dart';
import 'package:money_mouthy_two/screens/create_profile.dart';
import '../widgets/app_logo.dart';
import '../widgets/button.dart';
import '../widgets/terms_and_conditions.dart';
import '../widgets/page_title_with_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseUsernameScreen extends StatefulWidget {
  const ChooseUsernameScreen({Key? key}) : super(key: key);

  @override
  State<ChooseUsernameScreen> createState() => _ChooseUsernameScreenState();
}

class _ChooseUsernameScreenState extends State<ChooseUsernameScreen> {
  final _usernameController = TextEditingController();
  bool _isUsernameAvailable = false;
  bool _isCheckingUsername = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_checkUsernameAvailability);
  }

  @override
  void dispose() {
    _usernameController.removeListener(_checkUsernameAvailability);
    _usernameController.dispose();
    super.dispose();
  }

  void _checkUsernameAvailability() {
    final usernameRaw = _usernameController.text.trim();
    if (usernameRaw.length < 3) {
      if (_isUsernameAvailable || _isCheckingUsername) {
      setState(() {
        _isUsernameAvailable = false;
        _isCheckingUsername = false;
      });
      }
      return;
    }
    if (!_isCheckingUsername) {
      setState(() {
        _isCheckingUsername = true;
      });
    }
  }

  Future<void> _submit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final username = _usernameController.text.trim().toLowerCase();

    // Final check before submission
    try {
      final doc = await FirebaseFirestore.instance.doc('usernames/$username').get();
      if (doc.exists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username is already taken.'), backgroundColor: Colors.red));
        setState(() {
          _isUsernameAvailable = false;
        });
        return;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error verifying username. Please try again.'), backgroundColor: Colors.red));
      return;
    }

    try {
      await FirebaseFirestore.instance.runTransaction((txn) async {
        final unameRef = FirebaseFirestore.instance.doc('usernames/$username');
        txn.set(unameRef, {'uid': user.uid});
        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        txn.set(userRef, {'username': username}, SetOptions(merge: true));
      });
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CreateProfileScreen()),
      );
    } catch (e) {
      debugPrint('Saving username failed: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to save username. It might have been taken.'),
          backgroundColor: Colors.red));
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              
              // Logo
              const Center(
                child: AppLogo(),
              ),
              
              const SizedBox(height: 60),
              
              // Title
              const Text(
                'Choose your username',
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
                  widthFactor: 0.6, // 60% progress
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF5159FF),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Username input field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isUsernameAvailable 
                        ? Colors.green 
                        : Colors.grey.shade300,
                    width: _isUsernameAvailable ? 2 : 1,
                  ),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    // Dollar sign prefix
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: const Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    
                    // Username input
                    Expanded(
                      child: TextField(
                        controller: _usernameController,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'charitejames',
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    // Status indicator
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: _isCheckingUsername
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5159FF)),
                              ),
                            )
                          : _isUsernameAvailable
                              ? Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                )
                              : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Help text
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your username is unique and cannot be changed later.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Next button
              ElevatedButton(
                onPressed: () {
                  // Re-check and submit
                  _submit();
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
                child: const Text(
                  'Next',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Terms and conditions
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    children: const [
                      TextSpan(
                        text: "By signing up you agree to Money Mouthy's ",
                      ),
                      TextSpan(
                        text: "terms and conditions",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: ".",
                      ),
                    ],
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