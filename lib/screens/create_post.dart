import 'package:flutter/material.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  double _postPrice = 0.05; // Minimum $0.05
  double _maxPrice = 100.0;
  double _userAccountBalance = 50.0; // Simulated user balance
  String _selectedCurrency = 'USD';
  bool _isPublic = true;
  bool _allowComments = true;
  bool _isLoading = false;
  String? _selectedCategory;
  
  // Available categories
  final List<Map<String, dynamic>> _categories = [
    {'name': 'Technology', 'icon': Icons.computer, 'color': Colors.blue},
    {'name': 'Business', 'icon': Icons.business, 'color': Colors.green},
    {'name': 'Finance', 'icon': Icons.monetization_on, 'color': Colors.orange},
    {'name': 'Lifestyle', 'icon': Icons.favorite, 'color': Colors.pink},
    {'name': 'Education', 'icon': Icons.school, 'color': Colors.purple},
    {'name': 'Health', 'icon': Icons.health_and_safety, 'color': Colors.red},
    {'name': 'Travel', 'icon': Icons.flight, 'color': Colors.cyan},
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Colors.amber},
    {'name': 'Sports', 'icon': Icons.sports_soccer, 'color': Colors.teal},
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.indigo},
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
      }
    });
  }
  
  @override
  void dispose() {
    _contentController.dispose();
    _titleController.dispose();
    _tagsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildEnhancementButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _addPhoto() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📸 Photo upload feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _addLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🔗 Link attachment feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addEmoji() {
    // Add popular emojis to content
    final emojis = ['😀', '💰', '🚀', '💡', '🔥', '❤️', '👍', '💯'];
    final currentText = _contentController.text;
    final emoji = emojis[DateTime.now().millisecond % emojis.length];
    _contentController.text = '$currentText $emoji';
    _contentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _contentController.text.length),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added emoji $emoji'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _addAd() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📢 Advertisement integration coming soon!'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showCustomAmountDialog() {
    final TextEditingController customAmountController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Custom Amount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Available Balance: \$${_userAccountBalance.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: customAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(customAmountController.text);
              if (amount != null && amount >= 0.05 && amount <= _userAccountBalance) {
                setState(() {
                  _postPrice = amount;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter amount between \$0.05 and \$${_userAccountBalance.toStringAsFixed(2)}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Set Amount'),
          ),
        ],
      ),
    );
  }

  Future<void> _publishPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_postPrice < 0.05) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum post price is \$0.05'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (_postPrice > _userAccountBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Insufficient funds. Your balance: \$${_userAccountBalance.toStringAsFixed(2)}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate post creation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post successfully put up in $_selectedCategory! Amount: ${_selectedCurrency == 'USD' ? '\$' : '₿'}${_postPrice.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Put Up',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5159FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Put Up'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field (Optional)
                const Text(
                  'Title (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Add a catchy title...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLength: 100,
                ),
                
                const SizedBox(height: 20),
                
                // Content Field (Required)
                const Text(
                  'Content *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    hintText: 'What\'s on your mind? Share your thoughts...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  maxLines: 6,
                  maxLength: 2000,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Content is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Content must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Category Selection (Required)
                const Text(
                  'Category *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a category for your post:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          final isSelected = _selectedCategory == category['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['name'];
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? category['color']
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                                    size: 16,
                                    color: isSelected
                                        ? Colors.white
                                        : category['color'],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category['name'],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : category['color'],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Enhanced Content Options
                const Text(
                  'Enhance Your Post',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Media and Content Enhancement Buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildEnhancementButton(
                            Icons.photo_camera_outlined,
                            'Photo',
                            Colors.blue,
                            () => _addPhoto(),
                          ),
                          _buildEnhancementButton(
                            Icons.link_outlined,
                            'Link',
                            Colors.green,
                            () => _addLink(),
                          ),
                          _buildEnhancementButton(
                            Icons.emoji_emotions_outlined,
                            'Emoji',
                            Colors.orange,
                            () => _addEmoji(),
                          ),
                          _buildEnhancementButton(
                            Icons.campaign_outlined,
                            'Ad',
                            Colors.purple,
                            () => _addAd(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Tags Field (Optional)
                const Text(
                  'Tags (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    hintText: '#technology #money #business',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Description Field (Optional)
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Add a brief description...',
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 500,
                ),
                
                const SizedBox(height: 30),
                
                // Payment Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5159FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF5159FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            color: Color(0xFF5159FF),
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Set Post Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5159FF),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_balance_wallet, size: 14, color: Colors.green),
                                const SizedBox(width: 4),
                                Text(
                                  '\$${_userAccountBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'All posts require a minimum payment of \$0.05. Higher amounts increase visibility.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Currency Selection
                      Row(
                        children: [
                          const Text('Currency: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          ToggleButtons(
                            isSelected: [_selectedCurrency == 'USD', _selectedCurrency == 'BTC'],
                            onPressed: (index) {
                              setState(() {
                                _selectedCurrency = index == 0 ? 'USD' : 'BTC';
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: const Color(0xFF5159FF),
                            color: const Color(0xFF5159FF),
                            constraints: const BoxConstraints(minHeight: 32, minWidth: 50),
                            children: const [
                              Text('USD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              Text('BTC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Price Display
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Post Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF5159FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_selectedCurrency == 'USD' ? '\$' : '₿'}${_postPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Price Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$0.05 (min)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '\$${_userAccountBalance.toStringAsFixed(2)} (max)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF5159FF),
                              inactiveTrackColor: Colors.grey[300],
                              thumbColor: const Color(0xFF5159FF),
                              overlayColor: const Color(0xFF5159FF).withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 12,
                              ),
                              trackHeight: 4,
                            ),
                            child: Slider(
                              value: _postPrice,
                              min: 0.05,
                              max: _userAccountBalance,
                              divisions: ((_userAccountBalance - 0.05) * 20).round(),
                              onChanged: (value) {
                                setState(() {
                                  _postPrice = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      // Quick Price Buttons
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Quick Select:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to Add Funds screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Add Funds feature coming soon!'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            child: const Text(
                              'Add Funds',
                              style: TextStyle(
                                color: Color(0xFF5159FF),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [1.0, 5.0, 10.0, 20.0, 50.0].where((price) => price <= _userAccountBalance).map((price) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _postPrice = price;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _postPrice == price 
                                    ? const Color(0xFF5159FF)
                                    : Colors.white,
                                border: Border.all(
                                  color: const Color(0xFF5159FF),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: _postPrice == price 
                                      ? Colors.white
                                      : const Color(0xFF5159FF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList()
                        ..add(
                          GestureDetector(
                            onTap: () {
                              // TODO: Show custom amount dialog
                              _showCustomAmountDialog();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Other Amount',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Additional Options
                const Text(
                  'Post Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Public/Private Toggle
                SwitchListTile(
                  title: const Text('Public Post'),
                  subtitle: const Text('Anyone can discover this post'),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: const Color(0xFF5159FF),
                  contentPadding: EdgeInsets.zero,
                ),
                
                // Comments Toggle
                SwitchListTile(
                  title: const Text('Allow Comments'),
                  subtitle: const Text('Users can comment on this post'),
                  value: _allowComments,
                  onChanged: (value) {
                    setState(() {
                      _allowComments = value;
                    });
                  },
                  activeColor: const Color(0xFF5159FF),
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 