import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_mouthy_two/screens/connect_screen.dart';
import 'package:money_mouthy_two/screens/edit_profile_screen.dart';
import 'package:money_mouthy_two/screens/wallet_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:money_mouthy_two/screens/category_selection.dart';

class ProfileDrawer extends StatefulWidget {
  const ProfileDrawer({Key? key}) : super(key: key);

  @override
  State<ProfileDrawer> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<ProfileDrawer> {
  final User? _user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? _userDoc;
  bool _isLoading = true;
  double _postAmount = 0.05;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (_user == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user.uid)
              .get();
      if (mounted) {
        setState(() {
          _userDoc = doc;
          if (doc.exists && doc.data()!.containsKey('postAmount')) {
            _postAmount = (doc.data()!['postAmount'] as num).toDouble();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to fetch user data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePostAmount(double value) async {
    if (_user == null) return;
    try {
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'postAmount': value,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to update post amount: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade50,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null || _userDoc == null || !_userDoc!.exists) {
      return Container(
        color: Colors.grey.shade50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Could not load user data.'),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    final userData = _userDoc!.data() as Map<String, dynamic>;
    final username = userData['username'] ?? 'No Username';
    final profileImageUrl = userData['profileImageUrl'];

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header Section with light purple background
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E3FF), // Light purple/lavender background
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                // Profile avatar with edit icon
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage:
                            profileImageUrl != null
                                ? NetworkImage(profileImageUrl)
                                : null,
                        child:
                            profileImageUrl == null
                                ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.white,
                                )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF5159FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Username and stats
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '100 posts • 100 followers',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main content - scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Paid Post Section
                  _buildPaidPostSection(),
                  const SizedBox(height: 16),

                  // Post Amount Section
                  _buildPostAmountSection(),
                  const SizedBox(height: 16),

                  // Categories Section
                  _buildCategoriesSection(),
                  const SizedBox(height: 12),

                  // Connect Section
                  _buildConnectSection(),
                  const SizedBox(height: 16),

                  // Share Section
                  _buildShareSection(username),
                  const SizedBox(height: 20),

                  // Delete Account
                  _buildDeleteAccount(context, username),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidPostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Paid Post container with border
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Paid Post',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '\$150',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Fund Account text
        const Text(
          'Fund Account',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),

        // ReUp! button
        SizedBox(
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text(
              'ReUp!',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5159FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Increase post amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF5159FF),
            inactiveTrackColor: Colors.grey.shade300,
            thumbColor: const Color(0xFF5159FF),
            overlayColor: const Color(0xFF5159FF).withOpacity(0.2),
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          ),
          child: Slider(
            value: _postAmount,
            min: 0.05,
            max: 10.0,
            divisions: 199,
            onChanged: (value) {
              setState(() {
                _postAmount = value;
              });
            },
            onChangeEnd: (value) {
              _updatePostAmount(value);
            },
          ),
        ),
        Center(
          child: Text(
            '\$${_postAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rank Categories',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategorySelectionScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5159FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Categories',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnectSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connect with others',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ConnectScreen()));
            },
            icon: const Icon(Icons.people, size: 20),
            label: const Text(
              'Connect',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5159FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareSection(String username) {
    final Map<String, IconData> socialIcons = {
      'Facebook': FontAwesomeIcons.facebook,
      'Twitter': FontAwesomeIcons.twitter,
      'Instagram': FontAwesomeIcons.instagram,
      'Pinterest': FontAwesomeIcons.pinterest,
      'LinkedIn': FontAwesomeIcons.linkedin,
      'TikTok': FontAwesomeIcons.tiktok,
      'YouTube': FontAwesomeIcons.youtube,
      'WhatsApp': FontAwesomeIcons.whatsapp,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share to others',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              socialIcons.entries.map((entry) {
                return Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final url = _buildSocialUrl(entry.key, username);
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: FaIcon(entry.value, size: 16, color: Colors.black54),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  String _buildSocialUrl(String platform, String username) {
    final encodedUsername = Uri.encodeComponent(username);
    switch (platform) {
      case 'Facebook':
        return 'https://www.facebook.com/sharer/sharer.php?u=https://moneymouthy.app/user/$encodedUsername';
      case 'Twitter':
        return 'https://twitter.com/intent/tweet?text=Check%20out%20my%20profile%20on%20Money%20Mouthy%20%40$encodedUsername%20https://moneymouthy.app';
      case 'Instagram':
        return 'https://www.instagram.com';
      case 'Pinterest':
        return 'https://www.pinterest.com/pin/create/button/?url=https://moneymouthy.app/user/$encodedUsername';
      case 'LinkedIn':
        return 'https://www.linkedin.com/sharing/share-offsite/?url=https://moneymouthy.app/user/$encodedUsername';
      case 'TikTok':
        return 'https://www.tiktok.com';
      case 'YouTube':
        return 'https://www.youtube.com';
      case 'WhatsApp':
        return 'https://wa.me/?text=Check%20out%20my%20profile%20on%20Money%20Mouthy%20https://moneymouthy.app/user/$encodedUsername';
      default:
        return 'https://moneymouthy.app';
    }
  }

  Widget _buildDeleteAccount(BuildContext context, String username) {
    return Center(
      child: TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .delete();
                          await FirebaseFirestore.instance
                              .collection('usernames')
                              .doc(username)
                              .delete();
                          await user.delete();
                        }
                        if (mounted) {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to delete account: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
