import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double logoSize;
  final double titleFontSize;
  final double taglineFontSize;
  
  const AppLogo({
    Key? key,
    this.logoSize = 100,
    this.titleFontSize = 18,
    this.taglineFontSize = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
          width: logoSize,
          height: logoSize,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color.fromARGB(255, 177, 175, 175),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/money_mouth.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // App Name
        Text(
          "Money Mouthy",
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        // Tagline
        RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              children: [
                TextSpan(
                  text: "Monetized ",
                  style: TextStyle(
                    fontSize: taglineFontSize,
                    color: const Color(0xFF5159FF),
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  )
                ),
                TextSpan(
                  text: "microblogging",
                  style: TextStyle(
                    fontSize: taglineFontSize,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}