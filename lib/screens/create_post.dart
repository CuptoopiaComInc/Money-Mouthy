import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/wallet_service.dart';
import '../services/post_service.dart';
import 'wallet_screen.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _contentController = TextEditingController();
  final WalletService _walletService = WalletService();
  final PostService _postService = PostService();
  
  double _postPrice = 0.05; // Minimum $0.05
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _selectedCategory;
  bool _showExpandedView = false;
  String _selectedTab = 'Explore'; // Track which tab is selected
  
  // Available categories with their themes
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Politics', 'icon': Icons.how_to_vote, 'color': const Color(0xFF5159FF)},
    {'name': 'Technology', 'icon': Icons.computer, 'color': Colors.blue},
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.green},
    {'name': 'Finance', 'icon': Icons.monetization_on, 'color': Colors.orange},
    {'name': 'Lifestyle', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'color': Colors.red},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.cyan},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.amber},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.teal},
  ];
  
  @override
  void initState() {
    super.initState();
    
    // Check if category was passed from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['selectedCategory'] != null) {
        setState(() {
          _selectedCategory = args['selectedCategory'];
        });
      } else {
        // Default to Politics as shown in the design
        setState(() {
          _selectedCategory = 'Politics';
        });
      }
    });
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getCategoryData(String categoryName) {
    return _categories.firstWhere(
      (cat) => cat['name'] == categoryName,
      orElse: () => _categories[0],
    );
  }

  String _getCategoryPrompt(String categoryName) {
    switch (categoryName) {
      case 'Politics':
        return "Don't miss out on trending new happening around the world, choose from our list of categories and share your stories";
      case 'Technology':
        return "Share the latest tech innovations, gadgets, and digital trends happening around the world";
      case 'Business':
        return "Discuss market trends, entrepreneurship, and business insights that matter to professionals";
      case 'Finance':
        return "Share investment tips, market analysis, and financial advice with the community";
      case 'Lifestyle':
        return "Share your daily experiences, wellness tips, and lifestyle inspiration";
      case 'Education':
        return "Share knowledge, learning resources, and educational insights with students and educators";
      case 'Health':
        return "Discuss wellness, fitness, mental health, and medical developments";
      case 'Travel':
        return "Share your adventures, travel tips, and destination recommendations";
      case 'Food':
        return "Share recipes, restaurant reviews, and culinary experiences";
      case 'Sports':
        return "Discuss games, athletes, teams, and sporting events happening worldwide";
      default:
        return "Share your thoughts and engage with the community";
    }
  }

  Future<void> _publishPost() async {
    if (_isSubmitting) return;

    if (_contentController.text.trim().isEmpty) {
      _showErrorMessage('Please write something to share');
      return;
    }
    
    if (_selectedCategory == null) {
      _showErrorMessage('Please select a category');
      return;
    }
    
    // Check wallet balance
    final currentBalance = _walletService.currentBalance;
    if (_postPrice > currentBalance) {
      _showErrorMessage(
        'Insufficient funds. Your balance: ${_walletService.formatCurrency(currentBalance)}',
        showAddFunds: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _isLoading = true;
    });

    try {
      // Deduct balance for post creation
      final balanceDeducted = await _walletService.deductBalance(
        _postPrice,
        'Post creation in $_selectedCategory',
        postId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!balanceDeducted) {
        throw Exception('Failed to process payment. Please try again.');
      }

      // Create the post
      final postId = await _postService.createPost(
        content: _contentController.text.trim(),
        price: _postPrice,
        category: _selectedCategory!,
        tags: [],
        isPublic: true,
        allowComments: true,
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Post published in $_selectedCategory! Amount: ${_walletService.formatCurrency(_postPrice)}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        Navigator.pop(context, {
          'success': true,
          'postId': postId,
          'category': _selectedCategory,
          'price': _postPrice,
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Failed to create post: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isLoading = false;
        });
      }
    }
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['name'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category['name'];
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? category['color'] : Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: category['color'],
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'],
                          size: 18,
                          color: isSelected ? Colors.white : category['color'],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category['name'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : category['color'],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage(String message, {bool showAddFunds = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: showAddFunds ? SnackBarAction(
                        label: 'ReUp!',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WalletScreen()),
            ).then((_) => setState(() {}));
          },
        ) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = _getCategoryData(_selectedCategory ?? 'Politics');
    final categoryColor = categoryData['color'] as Color;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
            child: Column(
              children: [
            // Header Section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                children: [
                  // Top Header with Logo (centered)
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/images/money_mouth.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Tab Bar Row (Explore and Following)
                  Row(
                    children: [
                                             // Explore Tab
                       Expanded(
                         child: GestureDetector(
                           onTap: () {
                             setState(() {
                               _selectedTab = 'Explore';
                             });
                           },
                           child: Column(
                             children: [
                               Text(
                                 'Explore',
                  style: TextStyle(
                    fontSize: 16,
                                   color: _selectedTab == 'Explore' ? Colors.black : Colors.grey[600],
                                   fontWeight: _selectedTab == 'Explore' ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                               const SizedBox(height: 4),
                Container(
                                 height: 2,
                                 color: _selectedTab == 'Explore' ? const Color(0xFF5159FF) : Colors.transparent,
                               ),
                             ],
                           ),
                         ),
                       ),
                      // Following Tab
                      Expanded(
                        child: GestureDetector(
                            onTap: () {
                              setState(() {
                              _selectedTab = 'Following';
                              });
                            },
                          child: Column(
                                children: [
                                  Text(
                                'Following',
                                textAlign: TextAlign.center,
                                    style: TextStyle(
                                  fontSize: 16,
                                  color: _selectedTab == 'Following' ? Colors.black : Colors.grey[600],
                                  fontWeight: _selectedTab == 'Following' ? FontWeight.w600 : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 2,
                                color: _selectedTab == 'Following' ? const Color(0xFF5159FF) : Colors.transparent,
                              ),
                                ],
                              ),
                            ),
                      ),
                    ],
                ),
                
                const SizedBox(height: 20),
                
                  // Category Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                  child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                              Text(
                                '${_selectedCategory ?? 'Politics'} Category',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Featuring latest news trends and more',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                          ),
                        ],
                      ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: _showCategoryPicker,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _selectedCategory ?? 'Politics',
                              style: const TextStyle(
                                color: Colors.white,
                    fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  

                ],
              ),
            ),
            
            // Main Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _showExpandedView ? _buildExpandedView(categoryColor) : _buildSimpleView(categoryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleView(Color categoryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
        color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          // Title
          Text(
            'Today!',
                            style: TextStyle(
              fontSize: 24,
                              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Subtitle
                                Text(
            'What\'s New?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          
                      const SizedBox(height: 16),
          
          // Content Input
          Expanded(
            child: TextFormField(
              controller: _contentController,
              decoration: InputDecoration(
                hintText: 'Create 20 character text',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                          fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              onTap: () {
                              setState(() {
                  _showExpandedView = true;
                              });
                            },
            ),
                      ),
                      
                      const SizedBox(height: 20),
                      
          // Say It Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isLoading || _isSubmitting) ? null : () {
                if (_contentController.text.trim().isEmpty) {
                  setState(() {
                    _showExpandedView = true;
                  });
                } else {
                  _publishPost();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: (_isLoading || _isSubmitting)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Put Up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedView(Color categoryColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
                                color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
          // Header with close button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                '${_selectedCategory ?? 'Politics'} today!',
                                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              GestureDetector(
                onTap: () {
                                setState(() {
                    _showExpandedView = false;
                                });
                              },
                child: Icon(
                  Icons.close,
                  color: Colors.grey[600],
                  size: 20,
                            ),
                          ),
                        ],
                      ),
                      
          const SizedBox(height: 12),
          
          // Description
          Text(
            _getCategoryPrompt(_selectedCategory ?? 'Politics'),
                            style: TextStyle(
                              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Content Input
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts about ${_selectedCategory?.toLowerCase()}...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Character count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_contentController.text.length}/2000 characters',
                                style: TextStyle(
                                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                'Cost: ${_walletService.formatCurrency(_postPrice)}',
                                style: TextStyle(
                                  fontSize: 12,
                  color: categoryColor,
                  fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
          ),
          
          const SizedBox(height: 20),
          
          // Say It Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: (_isLoading || _isSubmitting) ? null : _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: categoryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: (_isLoading || _isSubmitting)
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Put Up',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
} 