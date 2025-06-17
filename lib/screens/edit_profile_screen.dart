import 'dart:io';
import 'dart:typed_data';
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
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (mounted) {
          setState(() {
            _nameController.text = data?['username'] ?? _user?.displayName ?? '';
            _profileImageUrl = data?['profileImageUrl'];
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to load user data: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isSaving) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    
    if (pickedFile != null) {
      // File size check (5MB limit)
      final fileLength = await pickedFile.length();
      if (fileLength > 5 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Image is too large. Please select a file under 5MB.'),
            backgroundColor: Colors.red,
          ));
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

    final ref = FirebaseStorage.instance.ref().child('user_uploads').child(_user!.uid).child('profile.jpg');

    try {
      if (kIsWeb) {
        if (_webImage == null) throw Exception("Image data is not available for web.");
        // Add a 60-second timeout
        await ref.putData(_webImage!).timeout(const Duration(seconds: 60));
      } else {
        // Add a 60-second timeout
        await ref.putFile(File(_pickedFile!.path)).timeout(const Duration(seconds: 60));
      }
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }
    
    setState(() => _isSaving = true);
    
    try {
      String? newImageUrl = await _uploadImage();

      final Map<String, dynamic> dataToUpdate = {
        'username': _nameController.text.trim(),
      };
      
      if (newImageUrl != null) {
        dataToUpdate['profileImageUrl'] = newImageUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set(
        dataToUpdate,
        SetOptions(merge: true),
      );
      
      await _user?.updateDisplayName(_nameController.text.trim());
      if (newImageUrl != null) {
        await _user?.updatePhotoURL(newImageUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to save profile: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
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
            icon: _isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.0)) : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveProfile,
            tooltip: 'Save Profile',
          )
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
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
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
            child: _displayImage() == null
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
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
} 