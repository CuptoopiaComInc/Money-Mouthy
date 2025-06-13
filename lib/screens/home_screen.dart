import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_mouthy_two/screens/create_post.dart';
import 'package:money_mouthy_two/screens/wallet_screen.dart';
import 'package:money_mouthy_two/services/wallet_service.dart';
import 'package:money_mouthy_two/widgets/app_logo.dart';
import 'package:money_mouthy_two/widgets/profile_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final WalletService _walletService = WalletService();
  late TabController _tabController;
  String selectedCategory = 'News';

  final List<Map<String, dynamic>> categories = [
    {'name': 'News', 'color': const Color(0xFF29CC76)},
    {'name': 'Politics', 'color': const Color(0xFF4C5DFF)},
    {'name': 'Sex', 'color': const Color(0xFFFF4081)},
    {'name': 'Entertainment', 'color': const Color(0xFFA06A00)},
    {'name': 'Sport', 'color': const Color(0xFFC43DFF)},
    {'name': 'Religion', 'color': const Color(0xFF000000)},
  ];

  final List<Map<String, dynamic>> samplePosts = [
    {
      'author': 'Lina Kamson',
      'time': '6h',
      'title': 'Reality in Ethiopia',
      'content': 'Don\'t miss out on trending new happening around the world, choose from our list of categories and share your stories',
      'image': 'https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0?q=80&w=1887&auto=format&fit=crop',
      'category': 'News',
      'isPaid': true,
      'amount': 100,
      'likes': 0,
      'reposts': 0,
      'comments': 12,
      'avatar': 'https://ui-avatars.com/api/?name=Lina+Kamson&color=7F9CF5&background=EBF4FF',
    },
    {
      'author': 'Doris Camilla',
      'time': '8h',
      'title': 'The Future of Tech',
      'content': 'Exploring the next wave of innovation and what it means for our daily lives. A deep dive into AI, blockchain, and more.',
      'image': 'https://images.unsplash.com/photo-1531297484001-80022131f5a1?q=80&w=2020&auto=format&fit=crop',
      'category': 'Politics',
      'isPaid': true,
      'amount': 100,
      'likes': 0,
      'reposts': 0,
      'comments': 8,
      'avatar': 'https://ui-avatars.com/api/?name=Doris+Camilla&color=7F9CF5&background=EBF4FF',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color getCategoryColor(String category) {
    final categoryData = categories.firstWhere(
      (c) => c['name'] == category,
      orElse: () => {'color': Colors.grey},
    );
    return categoryData['color'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Center(
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF5159FF),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/money_mouth.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF5159FF),
                    ),
                    child: const Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        actions: [
          // Empty actions - no wallet balance shown
        ],
      ),
      drawer: ProfileDrawer(),
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF4C5DFF),
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Explore'),
                Tab(text: 'Following'),
              ],
            ),
          ),
          

          
          // Posts list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Explore tab
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Top Ranked Category section
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.grey.shade50,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5159FF),
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://ui-avatars.com/api/?name=John+Doe&color=7F9CF5&background=EBF4FF',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.person, color: Colors.white);
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.star, color: Colors.amber, size: 12),
                                          SizedBox(width: 2),
                                          Text(
                                            'Top Ranked Category',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        '\$100',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      '1 hr',
                                      style: TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.refresh, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$selectedCategory Category',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: getCategoryColor(selectedCategory),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        selectedCategory,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Featuring latest news trends and more',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Posts
                    ...samplePosts.map((post) => _buildPostCard(post)).toList(),
                  ],
                ),
                // Following tab
                const Center(
                  child: Text(
                    'Following feed will show here',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4C5DFF),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
        ],
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(post['avatar']),
                backgroundColor: Colors.grey.shade200,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['author'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(post['time'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const Spacer(),
              if (post['isPaid'])
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('\$${post['amount']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (post['image'] != null && (post['image'] as String).isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post['image'],
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image_not_supported, color: Colors.white),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Text(post['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(post['content'], style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconTextButton(Icons.favorite_border, '${post['likes']} Likes'),
              _iconTextButton(Icons.repeat, '${post['reposts']} Reposts'),
              _iconTextButton(Icons.comment_outlined, '${post['comments']} Comments'),
            ],
          )
        ],
      ),
    );
  }

  Widget _iconTextButton(IconData icon, String label) {
    return TextButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 18, color: Colors.grey),
      label: Text(label, style: const TextStyle(color: Colors.grey)),
    );
  }
} 