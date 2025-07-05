import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'wbsbpd88@gmail.com',
      query: 'subject=Money Mouthy Contact',
    );
    if (!await launchUrl(emailUri)) {
      throw Exception('Could not launch email');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: '614-668-0327',
    );
    if (!await launchUrl(phoneUri)) {
      throw Exception('Could not launch phone');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Contact Us',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'We\'d love to hear from you. Contact us for any questions, feedback, or support needs.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Contact Information Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Company Name
                          const Text(
                            'Cuptoopia.com, Inc.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Money Mouthy',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Address
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.location_on, color: Color(0xFF2563eb), size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '7108 Bennell Drive\nReynoldsburg, Ohio 43068\nUnited States',
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Email
                          Row(
                            children: [
                              const Icon(Icons.email, color: Color(0xFF2563eb), size: 20),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _launchEmail,
                                child: const Text(
                                  'wbsbpd88@gmail.com',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2563eb),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone
                          Row(
                            children: [
                              const Icon(Icons.phone, color: Color(0xFF2563eb), size: 20),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: _launchPhone,
                                child: const Text(
                                  '614-668-0327',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF2563eb),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Business Hours
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10b981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF10b981).withOpacity(0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Color(0xFF10b981), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Response Time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10b981),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'We typically respond to all inquiries within 24-48 hours during business days. For urgent matters, please call us directly.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Links
                    const Text(
                      'Quick Links',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildQuickLink(
                          'Support',
                          Icons.help_outline,
                          () => Navigator.pushNamed(context, '/support'),
                        ),
                        _buildQuickLink(
                          'Privacy Policy',
                          Icons.privacy_tip_outlined,
                          () => Navigator.pushNamed(context, '/privacy'),
                        ),
                        _buildQuickLink(
                          'Terms of Service',
                          Icons.description_outlined,
                          () => Navigator.pushNamed(context, '/terms'),
                        ),
                      ],
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

  Widget _buildQuickLink(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2563eb).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF2563eb).withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF2563eb), size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF2563eb),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
