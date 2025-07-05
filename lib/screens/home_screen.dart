import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:money_mouthy_two/screens/create_post.dart';
import 'package:money_mouthy_two/services/wallet_service.dart';
import 'package:money_mouthy_two/services/post_service.dart';
import 'package:money_mouthy_two/widgets/profile_drawer.dart';
import 'package:money_mouthy_two/screens/profile_screen.dart';

// Category data model
class CategoryData {
  final String name;
  final Color color;
  final double topPrice;

  const CategoryData({
    required this.name,
    required this.color,
    required this.topPrice,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int currentCategoryIndex = 0;

  static const List<CategoryData> categories = [
    CategoryData(name: 'News', color: Color(0xFF29CC76), topPrice: 8.75),
    CategoryData(name: 'Politics', color: Color(0xFF4C5DFF), topPrice: 12.50),
    CategoryData(name: 'Sex', color: Color(0xFFFF4081), topPrice: 25.00),
    CategoryData(
      name: 'Entertainment',
      color: Color(0xFFA06A00),
      topPrice: 10.25,
    ),
    CategoryData(name: 'Sports', color: Color(0xFFC43DFF), topPrice: 15.00),
    CategoryData(name: 'Religion', color: Color(0xFF000000), topPrice: 7.50),
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    try {
      await WalletService().initialize();
      await PostService().initialize();
      if (mounted) {
        setState(() {
          // Refresh UI after services are ready
        });
      }
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  Future<bool> _showLogoutDialog() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Logout'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
      }
    }
  }

  void _previousCategory() {
    setState(() {
      currentCategoryIndex = (currentCategoryIndex - 1) % categories.length;
    });
  }

  void _nextCategory() {
    setState(() {
      currentCategoryIndex = (currentCategoryIndex + 1) % categories.length;
    });
  }

  Future<void> _navigateToCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreatePostScreen(),
        settings: RouteSettings(
          arguments: {
            'selectedCategory': categories[currentCategoryIndex].name,
          },
        ),
      ),
    );

    // If post was successfully created, set category to Politics
    if (result != null && result is Map && result['success'] == true) {
      setState(() {
        // Find Politics category index (should be index 1)
        final politicsIndex = categories.indexWhere(
          (cat) => cat.name == 'Politics',
        );
        if (politicsIndex != -1) {
          currentCategoryIndex = politicsIndex;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldLogout = await _showLogoutDialog();
        if (shouldLogout) {
          await _handleLogout();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 768;

          return Scaffold(
            key: _scaffoldKey,
            backgroundColor: Colors.white,
            drawer: !isWideScreen ? ProfileDrawer() : null,
            appBar: HomeAppBar(scaffoldKey: _scaffoldKey),
            body:
                isWideScreen ? _buildWideScreenLayout() : _buildMobileLayout(),
            bottomNavigationBar: HomeBottomNavigationBar(
              currentCategoryIndex: currentCategoryIndex,
              categories: categories,
              onNavigateToCreatePost: _navigateToCreatePost,
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideScreenLayout() {
    return Row(
      children: [
        // Permanent sidebar for wide screens
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: ProfileDrawer(),
        ),
        // Main content
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: _buildMainContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    return Column(
      children: [
        HomeTabBar(tabController: _tabController),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              ExploreTab(
                currentCategoryIndex: currentCategoryIndex,
                categories: categories,
                onPreviousCategory: _previousCategory,
                onNextCategory: _nextCategory,
              ),
              const FollowingTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Home App Bar Widget
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const HomeAppBar({super.key, required this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
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
      actions: const [
        // Empty actions - no wallet balance shown
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Home Tab Bar Widget
class HomeTabBar extends StatelessWidget {
  final TabController tabController;

  const HomeTabBar({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: TabBar(
        controller: tabController,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF4C5DFF),
        indicatorWeight: 3,
        tabs: const [Tab(text: 'Explore'), Tab(text: 'Following')],
      ),
    );
  }
}

// Explore Tab Widget
class ExploreTab extends StatelessWidget {
  final int currentCategoryIndex;
  final List<CategoryData> categories;
  final VoidCallback onPreviousCategory;
  final VoidCallback onNextCategory;

  const ExploreTab({
    super.key,
    required this.currentCategoryIndex,
    required this.categories,
    required this.onPreviousCategory,
    required this.onNextCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        TopRankedCategorySection(
          currentCategoryIndex: currentCategoryIndex,
          categories: categories,
          onPreviousCategory: onPreviousCategory,
          onNextCategory: onNextCategory,
        ),
        const PostsPlaceholder(),
      ],
    );
  }
}

// Top Ranked Category Section Widget
class TopRankedCategorySection extends StatelessWidget {
  final int currentCategoryIndex;
  final List<CategoryData> categories;
  final VoidCallback onPreviousCategory;
  final VoidCallback onNextCategory;

  const TopRankedCategorySection({
    super.key,
    required this.currentCategoryIndex,
    required this.categories,
    required this.onPreviousCategory,
    required this.onNextCategory,
  });

  @override
  Widget build(BuildContext context) {
    final currentCategory = categories[currentCategoryIndex];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.grey.shade50],
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
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          // Column 1: Top Ranked text and price
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Ranked',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade300),
                  ),
                  child: Text(
                    '\$${currentCategory.topPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Column 2: Category navigation arrows
          // Column 3: Category badge
          CategoryBadge(category: currentCategory),
          const SizedBox(width: 16),
          CategoryNavigationArrows(
            onPreviousCategory: onPreviousCategory,
            onNextCategory: onNextCategory,
          ),
        ],
      ),
    );
  }
}

// Category Navigation Arrows Widget
class CategoryNavigationArrows extends StatelessWidget {
  final VoidCallback onPreviousCategory;
  final VoidCallback onNextCategory;

  const CategoryNavigationArrows({
    super.key,
    required this.onPreviousCategory,
    required this.onNextCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPreviousCategory,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              Icons.keyboard_arrow_up,
              color: Colors.grey.shade600,
              size: 15,
            ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onNextCategory,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
              size: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// Category Badge Widget
class CategoryBadge extends StatelessWidget {
  final CategoryData category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Posts Placeholder Widget
class PostsPlaceholder extends StatelessWidget {
  const PostsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32.0),
      child: Center(
        child: Text('No posts to show', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

// Following Tab Widget
class FollowingTab extends StatelessWidget {
  const FollowingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Following feed will show here',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}

// Home Bottom Navigation Bar Widget
class HomeBottomNavigationBar extends StatelessWidget {
  final int currentCategoryIndex;
  final List<CategoryData> categories;
  final VoidCallback onNavigateToCreatePost;

  const HomeBottomNavigationBar({
    super.key,
    required this.currentCategoryIndex,
    required this.categories,
    required this.onNavigateToCreatePost,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF4C5DFF),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
      onTap: (index) => _handleBottomNavTap(context, index),
    );
  }

  void _handleBottomNavTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        Navigator.pushNamed(context, '/chats');
        break;
      case 2:
        onNavigateToCreatePost();
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
  }
}
