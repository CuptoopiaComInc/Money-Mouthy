import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Add container for web to prevent stretching
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF0f172a),
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Column(
                        children: [
                          const Text(
                            'Money Mouthy',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Put Your Money Where Your Mouth Is',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          // Video container
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Money Mouthy Intro Video',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        'YouTube: fklNi_PsvmE',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 48),

                          // Download buttons
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildDownloadButton(
                                'Download for Android',
                                Icons.android,
                                const Color(0xFF10b981),
                                () => _launchURL('/downloads/moneymouthy-android.apk'),
                              ),
                              _buildDownloadButton(
                                'Download for iOS',
                                Icons.apple,
                                const Color(0xFF10b981),
                                () => _launchURL('/downloads/moneymouthy-ios.ipa'),
                              ),
                              _buildActionButton(
                                'Register',
                                const Color(0xFF2563eb),
                                () => Navigator.pushNamed(context, '/signup'),
                              ),
                              _buildActionButton(
                                'Log In',
                                const Color(0xFF2563eb),
                                () => Navigator.pushNamed(context, '/login'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 64),

                          // Footer links
                          Wrap(
                            spacing: 24,
                            runSpacing: 16,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildFooterLink('Support', () => Navigator.pushNamed(context, '/support')),
                              _buildFooterLink('Privacy Policy', () => Navigator.pushNamed(context, '/privacy')),
                              _buildFooterLink('Terms of Service', () => Navigator.pushNamed(context, '/terms')),
                              _buildFooterLink('Contact', () => Navigator.pushNamed(context, '/contact')),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Footer
                    Container(
                      width: double.infinity,
                      color: const Color(0xFF0f172a),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      child: const Text(
                        '© 2025 Money Mouthy. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDownloadButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF2563eb),
          fontSize: 14,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
