import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConnectScreen extends StatelessWidget {
  const ConnectScreen({Key? key}) : super(key: key);

  Future<void> _toggleFollow(String targetUid) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final followDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);

    final docSnap = await followDoc.get();
    if (docSnap.exists) {
      await followDoc.delete();
    } else {
      await followDoc.set({'followedAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<bool> _isFollowingStream(String targetUid) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((snap) => snap.exists);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Connect',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs.where((doc) => doc.id != currentUserUid).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final userDoc = users[index];
              final user = userDoc.data() as Map<String, dynamic>;
              final username = user['username'] ?? 'N/A';
              final profileImageUrl = user['profileImageUrl'];

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                      child: profileImageUrl == null ? const Icon(Icons.person) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        username,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    StreamBuilder<bool>(
                      stream: _isFollowingStream(userDoc.id),
                      builder: (context, followSnap) {
                        final isFollowing = followSnap.data ?? false;
                        return ElevatedButton(
                          onPressed: () => _toggleFollow(userDoc.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.grey.shade300 : const Color(0xFF5159FF),
                            foregroundColor: isFollowing ? Colors.black : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
} 