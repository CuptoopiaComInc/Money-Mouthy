import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({Key? key}) : super(key: key);

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  XFile? _pickedFile;
  Uint8List? _webImage;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    // Compress image and set max width to reduce file size.
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      // Validate file size before proceeding
      final fileSize = await picked.length();
      if (fileSize > 5 * 1024 * 1024) {
        // 5 MB limit
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selected image is too large (max 5MB).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() {
          _pickedFile = picked;
          _webImage = bytes;
        });
      } else {
        if (!mounted) return;
        setState(() => _pickedFile = picked);
      }
    }
  }

  /// Uploads the selected image to Firebase Storage and returns the download URL.
  /// Handles both web and mobile platforms. Throws an exception if the upload fails.
  Future<String> _uploadProfileImage(String userId) async {
    if (_pickedFile == null) {
      throw Exception('No image selected');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ref = FirebaseStorage.instance
        .ref()
        .child('user_uploads')
        .child(userId)
        .child('profile_$timestamp.jpg');
    debugPrint('Starting image upload to ${ref.fullPath}...');

    try {
      UploadTask uploadTask;

      if (kIsWeb) {
        if (_webImage == null) {
          throw Exception('Web image data not available');
        }
        uploadTask = ref.putData(_webImage!);
      } else {
        uploadTask = ref.putFile(File(_pickedFile!.path));
      }

      // Listen for progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            100.0 * (snapshot.bytesTransferred / snapshot.totalBytes);
        debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
      });

      // Await completion with increased timeout
      final snapshot = await uploadTask.timeout(const Duration(seconds: 120));
      final downloadUrl = await snapshot.ref.getDownloadURL().timeout(
        const Duration(seconds: 30),
      );

      debugPrint('Upload successful. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('Upload failed: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication error. Please sign in again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_pickedFile != null) {
        // Upload image with improved error handling
        imageUrl = await _uploadProfileImage(user.uid);
      }

      final userData = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
        if (imageUrl != null) 'photoUrl': imageUrl,
      };

      debugPrint('Saving user data to Firestore...');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true))
          .timeout(const Duration(seconds: 60));

      debugPrint('Updating FirebaseAuth profile...');
      await user
          .updateDisplayName(_nameController.text.trim())
          .timeout(const Duration(seconds: 30));
      if (imageUrl != null) {
        await user
            .updatePhotoURL(imageUrl)
            .timeout(const Duration(seconds: 30));
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      // This will now catch errors from _uploadProfileImage as well.
      debugPrint('** An error occurred during save process: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  ImageProvider? _displayImage() {
    if (_pickedFile != null) {
      if (kIsWeb && _webImage != null) {
        return MemoryImage(_webImage!);
      } else if (!kIsWeb) {
        return FileImage(File(_pickedFile!.path));
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _displayImage(),
                  child:
                      _displayImage() == null
                          ? const Icon(
                            Icons.camera_alt,
                            size: 40,
                            color: Colors.grey,
                          )
                          : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Tap to add a profile picture",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Please enter your name'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio (optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
