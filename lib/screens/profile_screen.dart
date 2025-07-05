import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_mouthy_two/screens/connect_screen.dart';
import '../services/post_service.dart';
import '../services/wallet_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  const ProfileScreen({super.key, required this.userId});

  Future<Map<String, dynamic>?> _loadUser() async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final bool isSelf = currentUid == userId;

    final PostService postService = PostService();
    final WalletService walletService = WalletService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const Spacer(),
            // Paid Post label – show if user has paid posts
            FutureBuilder<List<Post>>(
              future: Future.value(
                postService
                    .getAllPosts()
                    .where((p) => p.authorId == userId && p.price > 0)
                    .toList(),
              ),
              builder: (context, postSnap) {
                if (!postSnap.hasData || postSnap.data!.isEmpty)
                  return const SizedBox();
                final topPrice = postSnap.data!
                    .map((e) => e.price)
                    .reduce((a, b) => a > b ? a : b);
                return Row(
                  children: [
                    Text(
                      'Paid Post',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationThickness: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Text(
                        '\$ ${topPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
        actions:
            isSelf
                ? [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black),
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_profile');
                    },
                  ),
                ]
                : null,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadUser(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data == null) {
            return const Center(child: Text('No Data Found'));
          }
          final data = snap.data!;
          final username = data['username'] ?? 'Unknown';
          final bio = data['bio'] ?? '';
          final profileImageUrl = data['profileImageUrl'];

          final userPosts =
              postService
                  .getAllPosts()
                  .where((p) => p.authorId == userId)
                  .toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with avatar overlay
                Stack(
                  children: [
                    Container(height: 120, color: Colors.grey[300]),
                    Positioned(
                      left: 16,
                      bottom: -40,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage:
                                profileImageUrl != null
                                    ? NetworkImage(profileImageUrl)
                                    : null,
                            child:
                                profileImageUrl == null
                                    ? const Icon(Icons.person, size: 40)
                                    : null,
                          ),
                          if (isSelf)
                            Positioned(
                              right: -4,
                              bottom: -4,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5159FF),
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (bio.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Text(
                      bio,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 16),

                // Fund Account Section (self only)
                if (isSelf) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Fund Account',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _AddPaymentButton(
                      onPressed: () async {
                        final added = await walletService.addFunds(
                          10,
                        ); // demo $10
                        if (added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment simulated')),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ValueListenableBuilder<double>(
                      valueListenable: ValueNotifier<double>(
                        walletService.currentBalance,
                      ),
                      builder: (context, balance, _) {
                        final pct = (balance / 100).clamp(0.0, 1.0);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: pct,
                                  child: Container(
                                    height: 2,
                                    color: const Color(0xFF5159FF),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(walletService.formatCurrency(balance)),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Follow other accounts section (only for self)
                if (isSelf) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Follow Other accounts',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Connect with other users around the world.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/connect');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5159FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      icon: const Icon(Icons.people),
                      label: const Text('Connect'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // User posts list
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Posts',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (userPosts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text('This user has no posts'),
                    ),
                  )
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: userPosts.length,
                    itemBuilder: (context, i) {
                      final post = userPosts[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(post.title ?? ''),
                          subtitle: Text(
                            post.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(post.formattedPrice),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AddPaymentButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _AddPaymentButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5159FF),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      icon: const Icon(Icons.add),
      label: const Text('Add Payment'),
    );
  }
}
