import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class TermsAndConditions extends StatelessWidget{
  const TermsAndConditions({super.key});

  @override
  Widget build(BuildContext context) {
    // Terms and conditions
    return Container(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          const Divider(
            color: Colors.grey,
            thickness: 0.5,
          ),
          const SizedBox(height: 3),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              children: [
                const TextSpan(
                  text: "By signing up you agree to Money Mouthy's ",
                ),
                TextSpan(
                  text: "terms and conditions",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    // Handle login tap
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}