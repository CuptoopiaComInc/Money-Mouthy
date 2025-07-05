import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0f172a),
        title: const Text(
          'Terms of Service',
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
                      'Terms of Service for Money Mouthy by Cuptoopia.com, Inc.',
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
                      'Welcome to Money Mouthy, a microblogging platform owned and operated by Cuptoopia.com, Inc. By using our platform, you agree to the following terms and conditions:',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),

                    _buildSection(
                      '1. Eligibility',
                      'Users must be 18 years or older.\n'
                      'You agree to provide accurate information and maintain the security of your account.',
                    ),

                    _buildSection(
                      '2. Platform Use',
                      'Users can create posts ("PutUps") in six categories: News, Politics, Sports, Entertainment, Sex, and Religion.\n'
                      'Each PutUp costs a minimum of \$0.05 to post. Users may increase their post amount.\n'
                      'The highest-paid PutUp in each category is displayed in a static container for 24 hours unless outbid by a higher-paid PutUp.',
                    ),

                    _buildSection(
                      '3. Payments',
                      'All transactions are in USD.\n'
                      'Users must add funds to their account in advance.\n'
                      'No refunds will be issued for any reason.',
                    ),

                    _buildSection(
                      '4. Content Guidelines',
                      'Users can upload a limited number of text characters, images, photos, videos, emojis, links, and ads.\n'
                      'Adult content must comply with applicable laws.\n'
                      'Money Mouthy supports and encourages free speech and robust civil debate in all six categories.',
                    ),

                    _buildSection(
                      '5. Account Termination',
                      'Users may delete their accounts at any time.\n'
                      'Cuptoopia.com, Inc., reserves the right to suspend or terminate accounts for any reason.',
                    ),

                    _buildSection(
                      '6. Ownership & Rights',
                      'Users retain ownership of their content but grant Money Mouthy a license to display and distribute it on the platform.',
                    ),

                    _buildSection(
                      '7. Modifications',
                      'We reserve the right to update these Terms. Continued use of the platform constitutes acceptance of the new terms.',
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
                              Icon(Icons.gavel, color: Color(0xFF2563eb), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Questions about these Terms?',
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
                            'If you have any questions about these Terms of Service, please contact us at wbsbpd88@gmail.com',
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
