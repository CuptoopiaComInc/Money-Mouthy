import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:developer' as developer;
import '../services/wallet_service.dart';
import '../services/post_service.dart';
import '../services/category_preference_service.dart';
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

  String _selectedTab = 'Explore'; // Track which tab is selected

  // Media upload variables
  XFile? _selectedImage;
  String? _linkUrl;
  final ImagePicker _imagePicker = ImagePicker();

  // Character limit
  static const int _maxCharacters = 480;

  // Available categories with their themes
  final List<Map<String, dynamic>> _categories = [
    {
      'name': 'Politics',
      'icon': Icons.how_to_vote,
      'color': const Color(0xFF4C5DFF),
    },
    {'name': 'News', 'icon': Icons.newspaper, 'color': const Color(0xFF29CC76)},
    {
      'name': 'Sports',
      'icon': Icons.sports_soccer,
      'color': const Color(0xFFC43DFF),
    },
    {'name': 'Sex', 'icon': Icons.favorite, 'color': const Color(0xFFFF4081)},
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': const Color(0xFFA06A00),
    },
    {
      'name': 'Religion',
      'icon': Icons.church,
      'color': const Color(0xFF000000),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCategory();
  }

  Future<void> _initializeCategory() async {
    // Check if category was passed from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      String categoryToUse;
      if (args != null && args['selectedCategory'] != null) {
        categoryToUse = args['selectedCategory'];
      } else {
        // Use last selected category or default
        categoryToUse =
            await CategoryPreferenceService.getLastSelectedCategory();
      }

      if (mounted) {
        setState(() {
          _selectedCategory = categoryToUse;
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      _showErrorMessage('Failed to take photo: $e');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _showAddLinkDialog() {
    final TextEditingController linkController = TextEditingController(
      text: _linkUrl,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Link'),
            content: TextField(
              controller: linkController,
              decoration: const InputDecoration(
                hintText: 'Enter URL (https://...)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final url = linkController.text.trim();
                  if (url.isNotEmpty) {
                    setState(() {
                      _linkUrl = url;
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _removeLink() {
    setState(() {
      _linkUrl = null;
    });
  }

  void _insertEmoji(String emoji) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = text.replaceRange(selection.start, selection.end, emoji);

    if (newText.length <= _maxCharacters) {
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: selection.start + emoji.length,
      );
    }
  }

  Future<String> _uploadPostImage() async {
    if (_selectedImage == null) {
      throw Exception('No image selected');
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('post_images')
        .child(user.uid)
        .child('$timestamp.jpg');

    print('🔄 Starting post image upload...');
    print('📁 Upload path: ${ref.fullPath}');
    print('👤 User ID: ${user.uid}');
    print('⏰ Timestamp: $timestamp');

    // Retry mechanism for image upload
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        UploadTask uploadTask;

        if (kIsWeb) {
          final bytes = await _selectedImage!.readAsBytes();
          uploadTask = ref.putData(bytes);
        } else {
          uploadTask = ref.putFile(File(_selectedImage!.path));
        }

        // Upload with timeout
        final snapshot = await uploadTask.timeout(const Duration(seconds: 120));

        // Verify upload was successful
        if (snapshot.state == TaskState.success) {
          final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
            const Duration(seconds: 30),
          );
          print('✅ Post image uploaded successfully: $downloadUrl');
          developer.log(
            'Post image uploaded successfully: $downloadUrl',
            name: 'PostImageUpload',
          );
          return downloadUrl;
        } else {
          throw Exception('Upload failed with state: ${snapshot.state}');
        }
      } on FirebaseException catch (e) {
        print('❌ Firebase error on attempt $attempt: ${e.code} - ${e.message}');
        print('🔍 Full error details: $e');
        print('📁 Attempted path: ${ref.fullPath}');
        developer.log(
          'Firebase error on attempt $attempt: ${e.code} - ${e.message}',
          name: 'PostImageUpload',
          error: e,
        );

        // Handle specific Firebase errors
        if (e.code == 'object-not-found') {
          print('🚫 Object not found error during post image upload');
        } else if (e.code == 'unauthorized') {
          print(
            '🔐 Unauthorized error - check Firebase Storage rules for post_images path',
          );
          throw Exception(
            'Unauthorized to upload image. Please check permissions.',
          );
        } else if (e.code == 'canceled') {
          print('⏹️ Post image upload was canceled');
          throw Exception('Upload was canceled.');
        }

        if (attempt == 3) {
          throw Exception(
            'Failed to upload post image after 3 attempts: ${e.message}',
          );
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        debugPrint('General error on attempt $attempt: $e');
        if (attempt == 3) {
          throw Exception('Failed to upload post image after 3 attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    throw Exception('Failed to upload post image after all attempts');
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
        return "Share your political views and engage in meaningful political discourse";
      case 'News':
        return "Don't miss out on trending news happening around the world, share breaking stories and current events";
      case 'Sports':
        return "Discuss games, athletes, teams, and sporting events happening worldwide";
      case 'Sex':
        return "Share mature content and adult discussions in a respectful manner";
      case 'Entertainment':
        return "Discuss movies, TV shows, music, celebrities, and entertainment industry news";
      case 'Religion':
        return "Share your faith, spiritual insights, and engage in respectful religious discussions";
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

    if (_contentController.text.length > _maxCharacters) {
      _showErrorMessage('Post exceeds $_maxCharacters character limit');
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
      // Upload image if selected
      String? imageUrl;
      if (_selectedImage != null) {
        try {
          imageUrl = await _uploadPostImage();
          debugPrint('Image uploaded successfully for post: $imageUrl');
        } catch (e) {
          debugPrint('Image upload failed: $e');
          _showErrorMessage('Failed to upload image: $e');
          return; // Don't proceed if image upload fails
        }
      }

      // Deduct balance for post creation
      final balanceDeducted = await _walletService.deductBalance(
        _postPrice,
        'Post creation in $_selectedCategory',
        postId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!balanceDeducted) {
        throw Exception('Failed to process payment. Please try again.');
      }

      // Create the post with image and link
      final postId = await _postService.createPost(
        content: _contentController.text.trim(),
        price: _postPrice,
        category: _selectedCategory!,
        tags: [],
        isPublic: true,
        allowComments: true,
        imageUrl: imageUrl,
        linkUrl: _linkUrl,
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
        _showErrorMessage(
          'Failed to create post: ${e.toString().replaceAll('Exception: ', '')}',
        );
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
      builder:
          (context) => Container(
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
                  children:
                      _categories.map((category) {
                        final isSelected =
                            _selectedCategory == category['name'];
                        return GestureDetector(
                          onTap: () {
                            final categoryName = category['name'];
                            setState(() {
                              _selectedCategory = categoryName;
                            });
                            Navigator.pop(context);
                            // Save the selected category for future use (async but not blocking)
                            CategoryPreferenceService.saveLastSelectedCategory(
                              categoryName,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? category['color']
                                      : Colors.grey[100],
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
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : category['color'],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : category['color'],
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
        action:
            showAddFunds
                ? SnackBarAction(
                  label: 'ReUp!',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WalletScreen(),
                      ),
                    ).then((_) => setState(() {}));
                  },
                )
                : null,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
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

                          //    // Tab Bar Row (Explore and Following)
                          //     Row(
                          //       children: [
                          //         // Explore Tab
                          //         Expanded(
                          //           child: GestureDetector(
                          //             onTap: () {
                          //               setState(() {
                          //                 _selectedTab = 'Explore';
                          //               });
                          //             },
                          //             child: Column(
                          //               children: [
                          //                 Text(
                          //                   'Explore',
                          //                   style: TextStyle(
                          //                     fontSize: 16,
                          //                     color:
                          //                         _selectedTab == 'Explore'
                          //                             ? Colors.black
                          //                             : Colors.grey[600],
                          //                     fontWeight:
                          //                         _selectedTab == 'Explore'
                          //                             ? FontWeight.w600
                          //                             : FontWeight.w500,
                          //                   ),
                          //                 ),
                          //                 const SizedBox(height: 4),
                          //                 Container(
                          //                   height: 2,
                          //                   color:
                          //                       _selectedTab == 'Explore'
                          //                           ? const Color(0xFF5159FF)
                          //                           : Colors.transparent,
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //         // Following Tab
                          //         Expanded(
                          //           child: GestureDetector(
                          //             onTap: () {
                          //               setState(() {
                          //                 _selectedTab = 'Following';
                          //               });
                          //             },
                          //             child: Column(
                          //               children: [
                          //                 Text(
                          //                   'Following',
                          //                   textAlign: TextAlign.center,
                          //                   style: TextStyle(
                          //                     fontSize: 16,
                          //                     color:
                          //                         _selectedTab == 'Following'
                          //                             ? Colors.black
                          //                             : Colors.grey[600],
                          //                     fontWeight:
                          //                         _selectedTab == 'Following'
                          //                             ? FontWeight.w600
                          //                             : FontWeight.w500,
                          //                   ),
                          //                 ),
                          //                 const SizedBox(height: 4),
                          //                 Container(
                          //                   height: 2,
                          //                   color:
                          //                       _selectedTab == 'Following'
                          //                           ? const Color(0xFF5159FF)
                          //                           : Colors.transparent,
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     ),

                          //     const SizedBox(height: 20),

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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
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
                        padding: const EdgeInsets.all(0),
                        child: _buildExpandedView(categoryColor),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpandedView(Color categoryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              '${_selectedCategory ?? 'Politics'} today!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
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
            Container(
              height: 200, // Fixed height for text input area
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText:
                      'Share your thoughts about ${_selectedCategory?.toLowerCase()}...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                maxLines: null,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),

            const SizedBox(height: 16),

            // Media upload section
            _buildMediaSection(),

            const SizedBox(height: 16),

            // Character count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_contentController.text.length}/$_maxCharacters characters',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        _contentController.text.length > _maxCharacters
                            ? Colors.red
                            : Colors.grey[500],
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
                child:
                    (_isLoading || _isSubmitting)
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
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Media upload buttons - scrollable to prevent overflow
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildMediaButton(
                icon: Icons.photo_library,
                label: 'Photo',
                onTap: _pickImage,
              ),
              const SizedBox(width: 12),
              _buildMediaButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _takePhoto,
              ),
              const SizedBox(width: 12),
              _buildMediaButton(
                icon: Icons.link,
                label: 'Link',
                onTap: _showAddLinkDialog,
              ),
              const SizedBox(width: 12),
              _buildMediaButton(
                icon: Icons.emoji_emotions,
                label: 'Emoji',
                onTap: _showEmojiPicker,
              ),
              const SizedBox(width: 12), // Extra padding at the end
            ],
          ),
        ),

        // Show selected image
        if (_selectedImage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.image, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image selected: ${_selectedImage!.name}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: _removeImage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],

        // Show selected link
        if (_linkUrl != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _linkUrl!,
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: _removeLink,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Emoji',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 8,
                    children:
                        [
                              '😀',
                              '😃',
                              '😄',
                              '😁',
                              '😆',
                              '😅',
                              '😂',
                              '🤣',
                              '😊',
                              '😇',
                              '🙂',
                              '🙃',
                              '😉',
                              '😌',
                              '😍',
                              '🥰',
                              '😘',
                              '😗',
                              '😙',
                              '😚',
                              '😋',
                              '😛',
                              '😝',
                              '😜',
                              '🤪',
                              '🤨',
                              '🧐',
                              '🤓',
                              '😎',
                              '🤩',
                              '🥳',
                              '😏',
                              '😒',
                              '😞',
                              '😔',
                              '😟',
                              '😕',
                              '🙁',
                              '☹️',
                              '😣',
                              '😖',
                              '😫',
                              '😩',
                              '🥺',
                              '😢',
                              '😭',
                              '😤',
                              '😠',
                              '😡',
                              '🤬',
                              '🤯',
                              '😳',
                              '🥵',
                              '🥶',
                              '😱',
                              '😨',
                              '😰',
                              '😥',
                              '😓',
                              '🤗',
                              '🤔',
                              '🤭',
                              '🤫',
                              '🤥',
                            ]
                            .map(
                              (emoji) => GestureDetector(
                                onTap: () {
                                  _insertEmoji(emoji);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey[100],
                                  ),
                                  child: Center(
                                    child: Text(
                                      emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
