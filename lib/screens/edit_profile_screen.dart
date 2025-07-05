import 'dart:io';
import 'dart:typed_data';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;
  String? _profileImageUrl;
  bool _isSaving = false;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    try {
      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_user!.uid)
              .get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (mounted) {
          setState(() {
            _nameController.text = data?['username'] ?? _user.displayName ?? '';
            _profileImageUrl = data?['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load user data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isSaving) return;
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );

    if (pickedFile != null) {
      // File size check (5MB limit)
      final fileLength = await pickedFile.length();
      if (fileLength > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Image is too large. Please select a file under 5MB.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pickedFile = pickedFile;
          _webImage = bytes;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_pickedFile == null) return null;
    if (_user == null) {
      throw Exception('User is not logged in.');
    }

    // Use timestamp to ensure unique file names and avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storage = FirebaseStorage.instance;
    final ref = storage
        .ref()
        .child('user_uploads')
        .child(_user.uid)
        .child('profile_$timestamp.jpg');

    print('🔄 Starting image upload...');
    print('🪣 Storage bucket: ${storage.bucket}');
    print('📁 Upload path: ${ref.fullPath}');
    print('🔗 Full reference: gs://${storage.bucket}/${ref.fullPath}');
    print('👤 User ID: ${_user!.uid}');
    print('⏰ Timestamp: $timestamp');

    // Retry mechanism for image upload
    try {
      UploadTask uploadTask;

      if (kIsWeb) {
        if (_webImage == null) {
          throw Exception("Image data is not available for web.");
        }
        uploadTask = ref.putData(_webImage!);
      } else {
        uploadTask = ref.putFile(File(_pickedFile!.path));
      }

      // Wait for upload to complete with timeout
      final snapshot = await uploadTask.timeout(const Duration(seconds: 120));

      // Verify upload was successful
      if (snapshot.state == TaskState.success) {
        // Get download URL with timeout
        final downloadUrl = await ref.getDownloadURL().timeout(
          const Duration(seconds: 30),
        );
        print('✅ Image uploaded successfully: $downloadUrl');
        developer.log(
          'Image uploaded successfully: $downloadUrl',
          name: 'ImageUpload',
        );
        return downloadUrl;
      } else {
        throw Exception('Upload failed with state: ${snapshot.state}');
      }
    } on FirebaseException catch (e) {
      print('❌ Firebase error on attempt : ${e.code} - ${e.message}');
      print('🔍 Full error details: $e');
      developer.log(
        'Firebase error on attempt : ${e.code} - ${e.message}',
        name: 'ImageUpload',
        error: e,
      );

      // Handle specific Firebase errors
      if (e.code == 'object-not-found') {
        print('🚫 Object not found error during upload - retrying...');
        print('📁 Attempted path: ${ref.fullPath}');
      } else if (e.code == 'unauthorized') {
        print('🔐 Unauthorized error - check Firebase Storage rules');
        throw Exception(
          'Unauthorized to upload image. Please check permissions.',
        );
      } else if (e.code == 'canceled') {
        print('⏹️ Upload was canceled');
        throw Exception('Upload was canceled.');
      }
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      debugPrint('General error on attempt : $e');
      throw Exception('Failed to upload image , error: $e');
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload image first if selected
      String? newImageUrl;
      if (_pickedFile != null) {
        try {
          newImageUrl = await _uploadImage();
          debugPrint('Image upload completed: $newImageUrl');
        } catch (imageError) {
          debugPrint('Image upload failed: $imageError');
          // Continue with profile update even if image upload fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image upload failed: ${imageError.toString()}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }

      final Map<String, dynamic> dataToUpdate = {
        'username': _nameController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update image URL if upload was successful
      if (newImageUrl != null) {
        dataToUpdate['profileImageUrl'] = newImageUrl;
      }

      // Save to Firestore with retry mechanism
      await _saveToFirestoreWithRetry(dataToUpdate);

      // Update Firebase Auth profile with retry mechanism
      await _updateAuthProfileWithRetry(newImageUrl);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save profile';
        if (e.toString().contains('timeout')) {
          errorMessage =
              'Request timed out. Please check your internet connection and try again.';
        } else if (e.toString().contains('network')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else {
          errorMessage = 'Failed to save profile: ${e.toString()}';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveProfile,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon:
                _isSaving
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.0,
                      ),
                    )
                    : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
            tooltip: 'Save Profile',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAvatar(),
              const SizedBox(height: 12),
              Text(
                'Tap the image to change your avatar',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username cannot be empty';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child:
                    _isSaving
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                        : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, size: 20),
                            SizedBox(width: 10),
                            Text('Save Profile'),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _displayImage(),
            child:
                _displayImage() == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _displayImage() {
    if (_pickedFile != null) {
      if (kIsWeb && _webImage != null) {
        return MemoryImage(_webImage!);
      } else if (!kIsWeb) {
        return FileImage(File(_pickedFile!.path));
      }
    }
    if (_profileImageUrl != null) {
      return NetworkImage(_profileImageUrl!);
    }
    return null;
  }

  Future<void> _saveToFirestoreWithRetry(
    Map<String, dynamic> dataToUpdate,
  ) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .set(dataToUpdate, SetOptions(merge: true))
            .timeout(const Duration(seconds: 60));
        return; // Success, exit retry loop
      } catch (e) {
        if (attempt == 3) {
          throw Exception('Failed to save to Firestore after 3 attempts: $e');
        }
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }

  Future<void> _updateAuthProfileWithRetry(String? newImageUrl) async {
    for (int attempt = 1; attempt <= 3; attempt++) {
      try {
        await _user!
            .updateDisplayName(_nameController.text.trim())
            .timeout(const Duration(seconds: 30));

        if (newImageUrl != null) {
          await _user!
              .updatePhotoURL(newImageUrl)
              .timeout(const Duration(seconds: 30));
        }
        return; // Success, exit retry loop
      } catch (e) {
        if (attempt == 3) {
          throw Exception('Failed to update auth profile after 3 attempts: $e');
        }

        // Wait before retrying
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
  }
}
