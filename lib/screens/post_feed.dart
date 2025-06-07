import 'package:flutter/material.dart';
import 'package:money_mouthy_two/screens/categories_ranking.dart';

class PostFeedScreen extends StatefulWidget {
  const PostFeedScreen({super.key});

  @override
  State<PostFeedScreen> createState() => _PostFeedScreenState();
}

class _PostFeedScreenState extends State<PostFeedScreen> {
  String _selectedCategory = 'All';
  String _sortBy = 'Highest Paid'; // Default to highest paid per requirements
  
  // Available categories for filtering
  final List<String> _categories = [
    'All', 'Technology', 'Business', 'Finance', 'Lifestyle', 
    'Education', 'Health', 'Travel', 'Food', 'Sports', 'Entertainment'
  ];
  
  final List<String> _sortOptions = [
    'Highest Paid', 'Most Popular', 'Recent'
  ];

  // Top posts with 24-hour rotation system
  final Map<String, Map<String, dynamic>> _topPostsByCategory = {
    'Technology': {
      'id': 'top_tech',
      'author': 'TechGuru',
      'avatar': 'TG',
      'title': '🔥 Revolutionary AI Breakthrough',
      'content': 'This new AI model changes everything we know about machine learning and could revolutionize the entire tech industry within the next 12 months...',
      'price': 85.50,
      'isPaid': false,
      'likes': 892,
      'comments': 156,
      'tags': ['#ai', '#breakthrough', '#tech'],
      'timeAgo': '6h ago',
      'category': 'Technology',
      'isTopPost': true,
      'hoursRemaining': 18,
      'postedAt': DateTime.now().subtract(const Duration(hours: 6)),
    },
    'Business': {
      'id': 'top_business',
      'author': 'WallStreetPro',
      'avatar': 'WP',
      'title': '📈 Stock Market Predictions 2024',
      'content': 'My comprehensive analysis suggests these 5 stocks will significantly outperform the market in the coming quarter based on insider analysis...',
      'price': 92.75,
      'isPaid': false,
      'likes': 647,
      'comments': 98,
      'tags': ['#stocks', '#predictions', '#investing'],
      'timeAgo': '12h ago',
      'category': 'Business',
      'isTopPost': true,
      'hoursRemaining': 12,
      'postedAt': DateTime.now().subtract(const Duration(hours: 12)),
    },
    'Finance': {
      'id': 'top_finance',
      'author': 'CryptoKing',
      'avatar': 'CK',
      'title': '💰 Crypto Investment Strategy Guide',
      'content': 'Here\'s exactly how I turned \$1000 into \$50,000 with this proven cryptocurrency strategy that took me 3 years to perfect...',
      'price': 127.00,
      'isPaid': false,
      'likes': 1234,
      'comments': 267,
      'tags': ['#crypto', '#strategy', '#investment'],
      'timeAgo': '16h ago',
      'category': 'Finance',
      'isTopPost': true,
      'hoursRemaining': 8,
      'postedAt': DateTime.now().subtract(const Duration(hours: 16)),
    },
  };
  
  // Sample posts data with categories
  final List<Map<String, dynamic>> _allPosts = [
    {
      'id': '1',
      'author': 'John Doe',
      'avatar': 'JD',
      'title': 'The Future of Cryptocurrency',
      'content': 'Cryptocurrency is revolutionizing the way we think about money and financial transactions. In this comprehensive guide, I will share insights from 5 years of experience in the crypto space...',
      'price': 149.99,
      'isPaid': false,
      'likes': 245,
      'comments': 67,
      'tags': ['#crypto', '#finance', '#future'],
      'timeAgo': '2h ago',
      'category': 'Finance',
    },
    {
      'id': '2',
      'author': 'Sarah Wilson',
      'avatar': 'SW',
      'title': 'Building a Successful Startup',
      'content': 'Starting a business is one of the most challenging yet rewarding experiences. After building 3 successful companies, here are my proven strategies...',
      'price': 89.99,
      'isPaid': true,
      'likes': 428,
      'comments': 134,
      'tags': ['#startup', '#business', '#entrepreneur'],
      'timeAgo': '5h ago',
      'category': 'Business',
    },
    {
      'id': '3',
      'author': 'Mike Chen',
      'avatar': 'MC',
      'title': 'Free Investment Tips',
      'content': 'Here are some basic investment strategies that everyone should know. These are foundational principles that can help you get started...',
      'price': 0.0,
      'isPaid': false,
      'likes': 189,
      'comments': 43,
      'tags': ['#investment', '#tips', '#money'],
      'timeAgo': '1d ago',
      'category': 'Finance',
    },
    {
      'id': '4',
      'author': 'Tech Guru',
      'avatar': 'TG',
      'title': 'AI Revolution 2024',
      'content': 'Artificial Intelligence is transforming every industry. As someone who has worked at Google and Meta, I will reveal the secrets...',
      'price': 79.99,
      'isPaid': false,
      'likes': 356,
      'comments': 89,
      'tags': ['#ai', '#tech', '#future'],
      'timeAgo': '3h ago',
      'category': 'Technology',
    },
    {
      'id': '5',
      'author': 'Dr. Smith',
      'avatar': 'DS',
      'title': 'Mental Health Mastery',
      'content': 'As a practicing psychologist for 15 years, I have developed proven techniques for managing stress and anxiety...',
      'price': 59.99,
      'isPaid': false,
      'likes': 298,
      'comments': 76,
      'tags': ['#mentalhealth', '#wellness', '#psychology'],
      'timeAgo': '6h ago',
      'category': 'Health',
    },
    {
      'id': '6',
      'author': 'Travel Pro',
      'avatar': 'TP',
      'title': 'Budget Travel Secrets',
      'content': 'I have traveled to 50+ countries on a shoestring budget. Here are my insider tips for affordable luxury travel...',
      'price': 29.99,
      'isPaid': true,
      'likes': 167,
      'comments': 45,
      'tags': ['#travel', '#budget', '#adventure'],
      'timeAgo': '8h ago',
      'category': 'Travel',
    },
  ];

  List<Map<String, dynamic>> get _filteredAndSortedPosts {
    var posts = List<Map<String, dynamic>>.from(_allPosts);
    
    // Add top post for specific category if exists
    if (_selectedCategory != 'All' && _topPostsByCategory.containsKey(_selectedCategory)) {
      final topPost = _topPostsByCategory[_selectedCategory]!;
      // Remove any existing top post to avoid duplicates
      posts.removeWhere((post) => post['id'] == topPost['id']);
      // Add the top post at the beginning
      posts.insert(0, topPost);
    }
    
    // Filter by category (but keep top posts)
    if (_selectedCategory != 'All') {
      posts = posts.where((post) => 
        post['category'] == _selectedCategory || 
        (post['isTopPost'] == true && post['category'] == _selectedCategory)
      ).toList();
    } else {
      // For 'All' category, add all top posts at the beginning
      for (final topPost in _topPostsByCategory.values) {
        posts.removeWhere((post) => post['id'] == topPost['id']);
        posts.insert(0, topPost);
      }
    }
    
    // Sort posts (excluding top posts which are already at the top)
    var regularPosts = posts.where((post) => post['isTopPost'] != true).toList();
    var topPosts = posts.where((post) => post['isTopPost'] == true).toList();
    
    switch (_sortBy) {
      case 'Highest Paid':
        regularPosts.sort((a, b) => b['price'].compareTo(a['price']));
        break;
      case 'Recent':
        // Simulate recent sorting (in real app, sort by timestamp)
        break;
      case 'Most Popular':
        regularPosts.sort((a, b) => b['likes'].compareTo(a['likes']));
        break;
    }
    
    // Combine top posts (always first) with sorted regular posts
    return [...topPosts, ...regularPosts];
  }

  void _purchasePost(String postId, double price) {
    setState(() {
      final postIndex = _allPosts.indexWhere((post) => post['id'] == postId);
      if (postIndex != -1) {
        _allPosts[postIndex]['isPaid'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post purchased for \$${price.toStringAsFixed(2)}!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final posts = _filteredAndSortedPosts;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with Rankings Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Money Mouthy Feed',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoriesRankingScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard, size: 16),
                  label: const Text('Rankings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5159FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
          
          // Filter and Sort Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                // Category Filter
                Row(
                  children: [
                    const Text(
                      'Category: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _categories.map((category) {
                            final isSelected = _selectedCategory == category;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF5159FF)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : Colors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Sort Options and Put Up Button
                Row(
                  children: [
                    const Text(
                      'Sort by: ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    _buildSortButton('Highest Paid', 'Highest Paid'),
                    const SizedBox(width: 8),
                    _buildSortButton('Most Popular', 'Most Popular'),
                    const SizedBox(width: 8),
                    _buildSortButton('Recent', 'Recent'),
                    const Spacer(),
                    
                    // Put Up button (only show when specific category is selected)
                    if (_selectedCategory != 'All') ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/create_post',
                            arguments: {'selectedCategory': _selectedCategory},
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Put Up'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5159FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Posts Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            child: Row(
              children: [
                Text(
                  '${posts.length} posts found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (_selectedCategory != 'All') ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5159FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Posts List
          Expanded(
            child: posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts found in $_selectedCategory',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return _buildPostCard(post);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSortButton(String label, String sortType) {
    final isSelected = _sortBy == sortType;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = sortType;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5159FF) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final bool isPaidPost = post['price'] > 0;
    final bool hasAccess = post['isPaid'] || !isPaidPost;
    final bool isTopPost = post['isTopPost'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isTopPost ? Border.all(
          color: Colors.amber,
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: isTopPost 
                ? Colors.amber.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isTopPost ? 15 : 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Post Badge
          if (isTopPost)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'TOP POST',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  if (post['hoursRemaining'] != null) ...[
                    const Icon(Icons.timer, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${post['hoursRemaining']}h remaining',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF5159FF),
                  child: Text(
                    post['avatar'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (post['category'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          post['category'],
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (post['category'] != null && isPaidPost) 
                      const SizedBox(width: 8),
                    if (isPaidPost)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasAccess 
                              ? Colors.green.withOpacity(0.1)
                              : const Color(0xFF5159FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: hasAccess 
                                ? Colors.green
                                : const Color(0xFF5159FF),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              hasAccess ? Icons.check_circle : Icons.monetization_on,
                              size: 14,
                              color: hasAccess 
                                  ? Colors.green
                                  : const Color(0xFF5159FF),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              hasAccess 
                                  ? 'Purchased'
                                  : '\$${post['price'].toStringAsFixed(2)}',
                              style: TextStyle(
                                color: hasAccess 
                                    ? Colors.green
                                    : const Color(0xFF5159FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Title
          if (post['title'] != null && post['title'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 8),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: hasAccess
                ? Text(
                    post['content'],
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.4,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post['content'].substring(0, 50)}...',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5159FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF5159FF).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.lock,
                              color: Color(0xFF5159FF),
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Premium Content',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Purchase this post to read the full content',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _purchasePost(post['id'], post['price']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5159FF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 8,
                                ),
                              ),
                              child: Text('Purchase for \$${post['price'].toStringAsFixed(2)}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),

          const SizedBox(height: 16),

          // Tags
          if (post['tags'] != null && post['tags'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: (post['tags'] as List<String>).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          const SizedBox(height: 16),

          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildActionButton(
                  Icons.favorite_border,
                  '${post['likes']}',
                  () {},
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  Icons.comment_outlined,
                  '${post['comments']}',
                  () {},
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  Icons.share_outlined,
                  'Share',
                  () {},
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_border),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
} 