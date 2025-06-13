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
  XFile? _pickedFile;
  String? _profileImageUrl;
  bool _isSaving = false;
  Uint8List? _webImage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_user == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (mounted) {
        setState(() {
          _nameController.text = data?['name'] ?? _user?.displayName ?? '';
          _profileImageUrl = data?['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    if (_isSaving) return;
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 800);
    if (pickedFile != null) {
      if (kIsWeb) {
        final f = await pickedFile.readAsBytes();
        setState(() {
          _pickedFile = pickedFile;
          _webImage = f;
        });
      } else {
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_user == null || _nameController.text.trim().isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    String? imageUrl;

    // Step 1: Handle File Upload if an image was picked.
    if (_pickedFile != null) {
      try {
        final ref = FirebaseStorage.instance.ref().child('user_uploads').child(_user!.uid).child('profile.jpg');
        
        if (kIsWeb) {
          if (_webImage == null) throw Exception("Image data could not be read.");
          await ref.putData(_webImage!);
        } else {
          await ref.putFile(File(_pickedFile!.path));
        }
        imageUrl = await ref.getDownloadURL();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ));
          setState(() => _isSaving = false);
        }
        return; // Stop the process if image upload fails.
      }
    }

    // Step 2: Update Firestore with the new data.
    try {
      final Map<String, dynamic> dataToUpdate = {
        'name': _nameController.text.trim(),
      };
      
      if (imageUrl != null) {
        dataToUpdate['profileImageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set(
        dataToUpdate,
        SetOptions(merge: true),
      );

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
          content: Text('Failed to save profile: $e'),
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
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)))),
          if (!_isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveProfile,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _displayImage(),
                child: _displayImage() == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tap on the image to choose a new profile picture.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
          ],
        ),
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