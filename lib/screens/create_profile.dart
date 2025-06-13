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
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600, imageQuality: 80);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _pickedFile = picked;
          _webImage = bytes;
        });
      } else {
        setState(() => _pickedFile = picked);
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    String? imageUrl;
    // Step 1: Upload image if selected
    if (_pickedFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref('user_uploads/${user.uid}/profile.jpg');
        if (kIsWeb) {
          if (_webImage == null) throw Exception("Image data not found for web.");
          await ref.putData(_webImage!);
        } else {
          await ref.putFile(File(_pickedFile!.path));
        }
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image upload failed: $e'), backgroundColor: Colors.red));
          setState(() => _isLoading = false);
        }
        return; // Stop if upload fails
      }
    }

    // Step 2: Save profile data to Firestore
    try {
      final data = {
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        if (imageUrl != null) 'profileImageUrl': imageUrl,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(data, SetOptions(merge: true));

      // Also update the FirebaseAuth user profile
      await user.updateDisplayName(_nameController.text.trim());
      if (imageUrl != null) await user.updatePhotoURL(imageUrl);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save profile: $e'), backgroundColor: Colors.red));
      }
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
                  child: _displayImage() == null ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) : null,
                ),
              ),
              const SizedBox(height: 8),
              const Text("Tap to add a profile picture", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Your Name'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null,
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
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Finish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}