import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Privacy Policy',
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
                      'Privacy Policy for Money Mouthy by Cuptoopia.com, Inc.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Effective Date: July 1, 2025',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    const Text(
                      'Your privacy is important to us. This policy explains how we collect, use, and protect your data.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection(
                      '1. Data Collection',
                      'We collect:\n\n'
                      '• Account information: email, age verification, and username.\n'
                      '• Financial data: payment history, balance, and transactions is collected by a third-party processor.\n'
                      '• Content: PutUps, uploaded media, and user activity.',
                    ),

                    _buildSection(
                      '2. Use of Data',
                      'We use data to:\n\n'
                      '• Deliver platform functionality.\n'
                      '• Process payments.\n'
                      '• Prevent fraud and ensure safety.\n'
                      '• Improve user experience.',
                    ),

                    _buildSection(
                      '3. Data Sharing',
                      'We do not sell your data to third-party companies.\n'
                      'Data may be shared with payment processors and service providers who support our operations.',
                    ),

                    _buildSection(
                      '4. Account Control',
                      'Users can delete their accounts and associated data at any time.',
                    ),

                    _buildSection(
                      '5. Data Security',
                      'We implement encryption, firewalls, and access controls to safeguard your data.',
                    ),

                    _buildSection(
                      '6. Policy Changes',
                      'We may update this policy and will notify users of material changes.',
                    ),

                    const SizedBox(height: 32),
                    
                    // Contact Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563eb).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2563eb).withOpacity(0.3)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.contact_mail, color: Color(0xFF2563eb), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Questions about this Privacy Policy?',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF2563eb),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'If you have any questions about this Privacy Policy, please contact us at wbsbpd88@gmail.com',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.black87,
                            ),
                          ),
                        ],
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

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
