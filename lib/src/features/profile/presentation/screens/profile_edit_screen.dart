import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:myapp/src/core/providers/app_provider.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AppProvider>().user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phoneNumber);
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 500,
    );

      if (pickedFile != null) {
        setState(() => _isUploading = true);
        if (!mounted) return;
        final provider = context.read<AppProvider>();
        try {
          final success = await provider.uploadProfilePicture(File(pickedFile.path));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success ? 'Profile picture updated!' : 'Upload failed'),
              backgroundColor: success ? Colors.green : Colors.red,
            ),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        } finally {
          if (mounted) setState(() => _isUploading = false);
        }
      }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: colorScheme.primaryContainer,
                  backgroundImage: user.profileImageUrl != null 
                    ? NetworkImage(user.profileImageUrl!) 
                    : null,
                  child: user.profileImageUrl == null 
                    ? Icon(Icons.person, size: 60, color: colorScheme.primary) 
                    : null,
                ),
                if (_isUploading)
                  const Positioned.fill(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    child: const Icon(Icons.camera_alt),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Full Name (Legal)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: TextEditingController(text: user.id),
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'CNIC Number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone_outlined),
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest.withAlpha(50),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.withAlpha(100)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber[900], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'CNIC and Phone Number are verified identity markers and cannot be changed manually.',
                          style: TextStyle(color: Colors.amber[900], fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
