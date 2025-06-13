import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:money_mouthy_two/screens/categories_ranking.dart';
import 'package:money_mouthy_two/screens/connect_screen.dart';
import 'package:money_mouthy_two/screens/edit_profile_screen.dart';
import 'package:money_mouthy_two/screens/wallet_screen.dart';
import 'package:share_plus/share_plus.dart';

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
      final doc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
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
      return const Drawer(child: Center(child: CircularProgressIndicator()));
    }
    if (_user == null || _userDoc == null || !_userDoc!.exists) {
      return Drawer(
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
              )
            ],
          ),
        ),
      );
    }

    final userData = _userDoc!.data() as Map<String, dynamic>;
    final username = userData['username'] ?? 'No Username';
    final profileImageUrl = userData['profileImageUrl'];

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildProfileHeader(username, profileImageUrl),
          const SizedBox(height: 20),
          _buildFundAccount(context),
          const SizedBox(height: 20),
          _buildIncreasePostAmount(),
          const SizedBox(height: 30),
          _buildNavigationButton(
            'Explore Categories',
            Icons.category,
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoriesRankingScreen()));
            },
          ),
          const SizedBox(height: 10),
          _buildNavigationButton(
            'Connect with others',
            Icons.people,
            () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ConnectScreen()));
            },
          ),
          const SizedBox(height: 30),
          _buildShareToOthers(username),
          const Divider(height: 40),
          _buildDeleteAccount(context, username),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String username, String? profileImageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
              child: profileImageUrl == null
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                },
                child: const CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.edit, size: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          '\$$username',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        const Row(
          children: [
            Text('10 Posts'), // Placeholder
            SizedBox(width: 16),
            Text('100 Follows'), // Placeholder
          ],
        )
      ],
    );
  }

  Widget _buildFundAccount(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Paid Post', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('\$150', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        const Text('Fund Account', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WalletScreen()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Payment'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5159FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildIncreasePostAmount() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Increase post amount', style: TextStyle(fontWeight: FontWeight.w600)),
        Slider(
          value: _postAmount,
          min: 0.05,
          max: 10.0,
          divisions: 199,
          label: '\$${_postAmount.toStringAsFixed(2)}',
          onChangeEnd: (value) {
            _updatePostAmount(value);
          },
          onChanged: (value) {
            setState(() {
              _postAmount = value;
            });
          },
        ),
        Align(
          alignment: Alignment.center,
          child: Text('\$${_postAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildNavigationButton(String title, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5159FF),
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildShareToOthers(String username) {
    // A map of social icons to be displayed
    final Map<String, IconData> socialIcons = {
      'Facebook': FontAwesomeIcons.facebook,
      'Instagram': FontAwesomeIcons.instagram,
      'Twitter': FontAwesomeIcons.twitter,
      'TikTok': FontAwesomeIcons.tiktok,
      'YouTube': FontAwesomeIcons.youtube,
      'Telegram': FontAwesomeIcons.telegram,
      'WhatsApp': FontAwesomeIcons.whatsapp,
      'LinkedIn': FontAwesomeIcons.linkedin,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Share to others',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 15),
        Wrap(
          spacing: 12.0, // Horizontal space between icons
          runSpacing: 12.0, // Vertical space between rows
          alignment: WrapAlignment.center,
          children: socialIcons.entries.map((entry) {
            return CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey.shade200,
              child: IconButton(
                icon: FaIcon(entry.value, size: 22),
                color: Colors.black87,
                onPressed: () {
                  final textToShare = 'Check out my profile on Money Mouthy! \nUsername: $username';
                  Share.share(textToShare);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDeleteAccount(BuildContext context, String username) {
    return TextButton(
      onPressed: () {
        // Show confirmation dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Account'),
              content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close dialog
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        // Delete Firestore data first
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
                        await FirebaseFirestore.instance.collection('usernames').doc(username).delete();
                        // Then delete the auth user
                        await user.delete();
                      }
                      if (mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete account: $e')),
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
      child: const Text('Delete Account', style: TextStyle(color: Colors.red)),
    );
  }
} 