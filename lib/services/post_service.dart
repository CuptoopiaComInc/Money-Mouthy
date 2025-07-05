// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Post {
  final String id;
  final String author;
  final String authorId;
  final String? title;
  final String content;
  final double price;
  final String category;
  final List<String> tags;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final int views;
  final bool isPaid;
  final bool isPublic;
  final bool allowComments;
  final String? imageUrl;
  final String? linkUrl;

  Post({
    required this.id,
    required this.author,
    required this.authorId,
    this.title,
    required this.content,
    required this.price,
    required this.category,
    this.tags = const [],
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.isPaid = false,
    this.isPublic = true,
    this.allowComments = true,
    this.imageUrl,
    this.linkUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'author': author,
      'authorId': authorId,
      'title': title,
      'content': content,
      'price': price,
      'category': category,
      'tags': tags,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'likes': likes,
      'comments': comments,
      'views': views,
      'isPaid': isPaid,
      'isPublic': isPublic,
      'allowComments': allowComments,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
    };
  }

  static Post fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      author: map['author'],
      authorId: map['authorId'],
      title: map['title'],
      content: map['content'],
      price: map['price'].toDouble(),
      category: map['category'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt:
          map['createdAt'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
              : (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: map['likes'] ?? 0,
      comments: map['comments'] ?? 0,
      views: map['views'] ?? 0,
      isPaid: map['isPaid'] ?? false,
      isPublic: map['isPublic'] ?? true,
      allowComments: map['allowComments'] ?? true,
      imageUrl: map['imageUrl'],
      linkUrl: map['linkUrl'],
    );
  }

  Post copyWith({
    String? id,
    String? author,
    String? authorId,
    String? title,
    String? content,
    double? price,
    String? category,
    List<String>? tags,
    DateTime? createdAt,
    int? likes,
    int? comments,
    int? views,
    bool? isPaid,
    bool? isPublic,
    bool? allowComments,
    String? imageUrl,
    String? linkUrl,
  }) {
    return Post(
      id: id ?? this.id,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      price: price ?? this.price,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      isPaid: isPaid ?? this.isPaid,
      isPublic: isPublic ?? this.isPublic,
      allowComments: allowComments ?? this.allowComments,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedPrice {
    if (price == 0) return 'Free';
    return '\$${price.toStringAsFixed(2)}';
  }
}

class PostService {
  static final PostService _instance = PostService._internal();
  factory PostService() => _instance;
  PostService._internal();

  final List<Post> _posts = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _postsSubscription;
  String get _currentUserId => _auth.currentUser?.uid ?? 'anonymous';
  String get _currentUserName =>
      _auth.currentUser?.displayName ??
      _auth.currentUser?.email ??
      'Anonymous User';

  Future<void> initialize() async {
    _listenToPosts();
  }

  void _listenToPosts() {
    _postsSubscription?.cancel();
    _postsSubscription = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _posts
            ..clear()
            ..addAll(
              snapshot.docs.map((doc) {
                final data = doc.data();
                final map = Map<String, dynamic>.from(data)..['id'] = doc.id;
                return Post.fromMap(map);
              }),
            );
        });
  }

  Future<String> createPost({
    String? title,
    required String content,
    required double price,
    required String category,
    List<String>? tags,
    bool isPublic = true,
    bool allowComments = true,
    String? imageUrl,
    String? linkUrl,
  }) async {
    final docRef = await _firestore.collection('posts').add({
      'author': _currentUserName,
      'authorId': _currentUserId,
      'title': title?.trim().isEmpty == true ? null : title?.trim(),
      'content': content.trim(),
      'price': price,
      'category': category,
      'tags': tags ?? [],
      'createdAt': FieldValue.serverTimestamp(),
      'likes': 0,
      'comments': 0,
      'views': 0,
      'isPaid': false,
      'isPublic': isPublic,
      'allowComments': allowComments,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
    });

    return docRef.id;
  }

  List<Post> getAllPosts() {
    return List.unmodifiable(_posts);
  }

  List<Post> getPostsByCategory(String category) {
    if (category == 'All') return getAllPosts();
    return _posts.where((post) => post.category == category).toList();
  }

  List<Post> getPostsSortedBy(String sortBy, {String? category}) {
    var posts =
        category == null || category == 'All'
            ? List<Post>.from(_posts)
            : getPostsByCategory(category);

    switch (sortBy) {
      case 'Highest Paid':
        posts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Most Popular':
        posts.sort(
          (a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments),
        );
        break;
      case 'Recent':
        posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'Most Views':
        posts.sort((a, b) => b.views.compareTo(a.views));
        break;
    }

    return posts;
  }

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> likePost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'likes': FieldValue.increment(1),
    });
  }

  Future<void> viewPost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'views': FieldValue.increment(1),
    });
  }

  Future<void> deletePost(String postId) async {
    final doc = _firestore.collection('posts').doc(postId);
    final snapshot = await doc.get();
    if (snapshot.exists && snapshot['authorId'] == _currentUserId) {
      await doc.delete();
    }
  }

  List<Post> getUserPosts() {
    return _posts.where((post) => post.authorId == _currentUserId).toList();
  }

  List<String> getCategories() {
    return [
      'All',
      'Politics',
      'News',
      'Sports',
      'Sex',
      'Entertainment',
      'Religion',
    ];
  }

  List<String> getSortOptions() {
    return ['Highest Paid', 'Most Popular', 'Recent', 'Most Views'];
  }

  // Statistics
  int get totalPosts => _posts.length;
  int get userPostsCount => getUserPosts().length;

  double get averagePostPrice {
    if (_posts.isEmpty) return 0.0;
    return _posts.map((p) => p.price).reduce((a, b) => a + b) / _posts.length;
  }

  double get totalValueInPosts {
    return _posts.map((p) => p.price).fold(0.0, (a, b) => a + b);
  }

  Map<String, int> get postsByCategory {
    final Map<String, int> categoryCount = {};
    for (final post in _posts) {
      categoryCount[post.category] = (categoryCount[post.category] ?? 0) + 1;
    }
    return categoryCount;
  }
}
