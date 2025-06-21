import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_mouthy_two/screens/create_post.dart';
import 'package:money_mouthy_two/screens/wallet_screen.dart';
import 'package:money_mouthy_two/services/wallet_service.dart';
import 'package:money_mouthy_two/widgets/app_logo.dart';
import 'package:money_mouthy_two/widgets/profile_drawer.dart';
import 'package:money_mouthy_two/screens/profile_screen.dart';

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
  int currentCategoryIndex = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'News', 'color': const Color(0xFF29CC76)},
    {'name': 'Politics', 'color': const Color(0xFF4C5DFF)},
    {'name': 'Sex', 'color': const Color(0xFFFF4081)},
    {'name': 'Entertainment', 'color': const Color(0xFFA06A00)},
    {'name': 'Sport', 'color': const Color(0xFFC43DFF)},
    {'name': 'Religion', 'color': const Color(0xFF000000)},
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
                    // Top Ranked Category section - Three Column Layout with 3D Effect
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white,
                            Colors.grey.shade50,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(-2, -2),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Column 1: User Profile Picture
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade300, width: 1),
                            ),
                            child: ClipOval(
                              child: Image.network(
                                'https://ui-avatars.com/api/?name=John+Doe&color=FFFFFF&background=4C5DFF',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF4C5DFF),
                                    child: const Icon(Icons.person, color: Colors.white, size: 30),
                                  );
                                },
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Column 2: Top Ranked Category with colored lines
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top Ranked Category with crown icon
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.military_tech, 
                                      size: 16, 
                                      color: Color(0xFF4C5DFF)
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Top Ranked Category',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Colored progress lines - constrained to text width
                                SizedBox(
                                  width: 160, // Approximate width of "Top Ranked Category" text
                                  child: Column(
                                    children: [
                                      // First line - Blue (longest)
                                    Container(
                                        height: 3,
                                        width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFF4C5DFF),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      
                                      // Second line - Green (80% of text width)
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 8,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF10B981),
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          ),
                                          const Expanded(flex: 2, child: SizedBox()),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      
                                      // Third line - Orange (60% of text width)
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 6,
                                            child: Container(
                                              height: 3,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF59E0B),
                                                borderRadius: BorderRadius.circular(2),
                                          ),
                                      ),
                                    ),
                                          const Expanded(flex: 4, child: SizedBox()),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      
                                      // Fourth line - Pink (40% of text width)
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 4,
                                            child: Container(
                                              height: 3,
                                      decoration: BoxDecoration(
                                                color: const Color(0xFFEC4899),
                                                borderRadius: BorderRadius.circular(2),
                                      ),
                                            ),
                                          ),
                                          const Expanded(flex: 6, child: SizedBox()),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Column 3: Price with blue progress bar
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Price text
                              const Text(
                                        '\$100',
                                        style: TextStyle(
                                  fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Blue progress bar container
                              Container(
                                width: 60,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    // Blue progress (75% filled)
                                    Expanded(
                                      flex: 75,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4C5DFF),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    // Remaining empty space
                                    const Expanded(flex: 25, child: SizedBox()),
                                  ],
                                ),
                              ),
                              
                              // Small price indicator below bar
                              const SizedBox(height: 4),
                                    const Text(
                                '\$100',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF4C5DFF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Switchable Categories Container - After Top Ranked
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                      child: Row(
                        children: [
                          // Column 1: Cross Arrows - Single Row Layout
                          SizedBox(
                            height: 60, // Match the content height
                            child: Row(
                                  children: [
                                // Left arrow
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentCategoryIndex = currentCategoryIndex == 0 
                                          ? categories.length - 1 
                                          : currentCategoryIndex - 1;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_rounded,
                                      size: 20,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 4),
                                
                                // Right arrow
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      currentCategoryIndex = (currentCategoryIndex + 1) % categories.length;
                                    });
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      ),
                                    child: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 20,
                                      color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Column 2: Category name and description
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${categories[currentCategoryIndex]['name']} Category',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Featuring latest news trends and more',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Column 3: Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: categories[currentCategoryIndex]['color'],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              categories[currentCategoryIndex]['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Placeholder when posts will be fetched via PostService or PostFeedScreen.
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: Text('No posts to show')),
                    ),
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
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/chats');
              break;
            case 2:
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreatePostScreen()),
            );
              break;
            case 3:
              Navigator.pushNamed(context, '/search');
              break;
            case 4:
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(userId: uid)),
                );
              }
              break;
          }
        },
      ),
    );
  }
} 