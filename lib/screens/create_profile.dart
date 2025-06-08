import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:money_mouthy_two/screens/onboarding_complete.dart';
import '../widgets/app_logo.dart';
import '../widgets/button.dart';
import '../widgets/terms_and_conditions.dart';
import '../widgets/page_title_with_indicator.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  bool _hasProfileImage = false;

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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: TextButton(
              onPressed: () {
                // Handle skip logic here
                Navigator.pushReplacementNamed(context, '/home');
              },
              child: const Text(
                'Skip for Now',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
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
                  widthFactor: 0.8, // 80% progress
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: const Color(0xFF5159FF),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Title
              const Text(
                'Create your profile',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Subtitle
              const Text(
                'Make it easy for people to know its you\nby uploading your picture.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 80),
              
              // Profile image picker
              GestureDetector(
                onTap: () {
                  setState(() {
                    _hasProfileImage = !_hasProfileImage;
                  });
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _hasProfileImage ? null : Colors.grey.shade200,
                    image: _hasProfileImage
                        ? const DecorationImage(
                            image: AssetImage('assets/images/profile_sample.png'),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _hasProfileImage
                      ? Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5159FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.grey.shade500,
                        ),
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Next button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OnboardingCompleteScreen(),
                    ),
                  );
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
