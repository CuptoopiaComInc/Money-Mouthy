import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
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
  final String _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
  final String _currentUserName = 'Anonymous User';

  // Sample posts for demo
  final List<Map<String, dynamic>> _samplePosts = [
    {
      'author': 'John Doe',
      'title': 'The Future of Cryptocurrency',
      'content': 'Cryptocurrency is revolutionizing the way we think about money and financial transactions. In this comprehensive guide, I will share insights from 5 years of experience in the crypto space, including strategies that have helped me achieve consistent returns.',
      'price': 149.99,
      'category': 'Finance',
      'tags': ['#crypto', '#finance', '#future'],
      'likes': 245,
      'comments': 67,
      'views': 1203,
    },
    {
      'author': 'Sarah Wilson',
      'title': 'Building a Successful Startup',
      'content': 'Starting a business is one of the most challenging yet rewarding experiences. After building 3 successful companies worth over \$10M, here are my proven strategies for turning ideas into profitable ventures.',
      'price': 89.99,
      'category': 'Business',
      'tags': ['#startup', '#business', '#entrepreneur'],
      'likes': 428,
      'comments': 134,
      'views': 2156,
    },
    {
      'author': 'Mike Chen',
      'title': 'Free Investment Tips for Beginners',
      'content': 'Here are some basic investment strategies that everyone should know. These are foundational principles that can help you get started on your wealth-building journey without breaking the bank.',
      'price': 0.0,
      'category': 'Finance',
      'tags': ['#investment', '#tips', '#money'],
      'likes': 189,
      'comments': 43,
      'views': 892,
    },
    {
      'author': 'Tech Guru',
      'title': 'AI Revolution 2024: What\'s Coming Next',
      'content': 'Artificial Intelligence is transforming every industry. As someone who has worked at Google and Meta, I will reveal the secrets of AI development and what breakthrough technologies are coming in 2024.',
      'price': 79.99,
      'category': 'Technology',
      'tags': ['#ai', '#tech', '#future'],
      'likes': 356,
      'comments': 89,
      'views': 1678,
    },
    {
      'author': 'Dr. Smith',
      'title': 'Mental Health Mastery Guide',
      'content': 'As a practicing psychologist for 15 years, I have developed proven techniques for managing stress, anxiety, and depression. This comprehensive guide includes exercises and strategies used by top performers.',
      'price': 59.99,
      'category': 'Health',
      'tags': ['#mentalhealth', '#wellness', '#psychology'],
      'likes': 298,
      'comments': 76,
      'views': 987,
    },
  ];

  Future<void> initialize() async {
    await _loadPosts();
    
    // Add sample posts if none exist
    if (_posts.isEmpty) {
      await _addSamplePosts();
    }
  }

  Future<void> _addSamplePosts() async {
    final now = DateTime.now();
    
    for (int i = 0; i < _samplePosts.length; i++) {
      final samplePost = _samplePosts[i];
      final post = Post(
        id: 'sample_${i + 1}',
        author: samplePost['author'],
        authorId: 'user_sample_$i',
        title: samplePost['title'],
        content: samplePost['content'],
        price: samplePost['price'].toDouble(),
        category: samplePost['category'],
        tags: List<String>.from(samplePost['tags']),
        createdAt: now.subtract(Duration(hours: i * 2 + 1)),
        likes: samplePost['likes'],
        comments: samplePost['comments'],
        views: samplePost['views'],
      );
      
      _posts.add(post);
    }
    
    await _savePosts();
  }

  Future<void> _loadPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = prefs.getStringList('user_posts') ?? [];
      
      _posts.clear();
      for (final json in postsJson) {
        final map = Map<String, dynamic>.from(jsonDecode(json));
        _posts.add(Post.fromMap(map));
      }
      
      // Sort posts by creation date (newest first)
      _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading posts: $e');
      }
    }
  }

  Future<void> _savePosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final postsJson = _posts.map((post) => jsonEncode(post.toMap())).toList();
      await prefs.setStringList('user_posts', postsJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving posts: $e');
      }
    }
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
    final postId = 'post_${DateTime.now().millisecondsSinceEpoch}';
    
    final post = Post(
      id: postId,
      author: _currentUserName,
      authorId: _currentUserId,
      title: title?.trim().isEmpty == true ? null : title?.trim(),
      content: content.trim(),
      price: price,
      category: category,
      tags: tags ?? [],
      createdAt: DateTime.now(),
      isPublic: isPublic,
      allowComments: allowComments,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
    );

    _posts.insert(0, post); // Add to beginning for newest first
    await _savePosts();
    
    return postId;
  }

  List<Post> getAllPosts() {
    return List.unmodifiable(_posts);
  }

  List<Post> getPostsByCategory(String category) {
    if (category == 'All') return getAllPosts();
    return _posts.where((post) => post.category == category).toList();
  }

  List<Post> getPostsSortedBy(String sortBy, {String? category}) {
    var posts = category == null || category == 'All' 
        ? List<Post>.from(_posts)
        : getPostsByCategory(category);

    switch (sortBy) {
      case 'Highest Paid':
        posts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'Most Popular':
        posts.sort((a, b) => (b.likes + b.comments).compareTo(a.likes + a.comments));
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
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(likes: _posts[index].likes + 1);
      await _savePosts();
    }
  }

  Future<void> viewPost(String postId) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(views: _posts[index].views + 1);
      await _savePosts();
    }
  }

  Future<void> deletePost(String postId) async {
    _posts.removeWhere((post) => post.id == postId && post.authorId == _currentUserId);
    await _savePosts();
  }

  List<Post> getUserPosts() {
    return _posts.where((post) => post.authorId == _currentUserId).toList();
  }

  List<String> getCategories() {
    return [
      'All',
      'Technology',
      'Business', 
      'Finance',
      'Lifestyle',
      'Education',
      'Health',
      'Travel',
      'Food',
      'Sports',
      'Entertainment'
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