import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/button.dart';
import '../widgets/terms_and_conditions.dart';
import '../widgets/page_title_with_indicator.dart';

class CreateProfile extends StatefulWidget {
  const CreateProfile({Key? key}) : super(key: key);

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: () {
                // Handle skip logic here
                print("Skip for Now pressed");
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200], // Color with opacity
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0), // Rounded corners
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: Size.zero, // Set minimum size constraints
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // Remove extra padding
              ),
              child: const Text(
                'Skip for Now',
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 200,
                        height: 10,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  height: 2,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            Positioned(
                              left: (200 + 100) * 0.5,
                              top: 2.5,
                              child: Container(
                                width: 50,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF5159FF),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14), // spacing between line and text
                      Text(
                        "Create your profile",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 80),
                      Text(
                        "Make it easy for people to know its you by uploading your picture",
                        style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // place here
                      Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.add_a_photo_rounded,
                            size: 30.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      PurpleButton(buttonText: 'Next', onPressed: () {}),
                      const Spacer(),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: TermsAndConditions(),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
