import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _userService = UserService();
  late TextEditingController nameController;
  late TextEditingController positionController;
  late TextEditingController bioController;
  String? selectedImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.name);
    positionController = TextEditingController(text: widget.user.position);
    bioController = TextEditingController(text: widget.user.bio);
    selectedImagePath = widget.user.profileImagePath;
  }

  @override
  void dispose() {
    nameController.dispose();
    positionController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImagePath = image.path;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final updatedUser = User(
        id: widget.user.id,
        name: nameController.text,
        position: positionController.text,
        bio: bioController.text,
        profileImagePath: selectedImagePath,
      );

      await _userService.updateUserProfile(updatedUser);

      if (mounted) {
        Navigator.pop(context, updatedUser);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: Colors.red,
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
        title: const Text('Edit Profil', style: TextStyle(color: Colors.white)),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 700;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? constraints.maxWidth * 0.2 : 24,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Edit Section
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 70,
                        backgroundColor: const Color(
                          0xFF800000,
                        ).withValues(alpha: 0.1),
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: const Color(0xFF800000),
                          backgroundImage: _buildPreviewImage(),
                          child: _buildPreviewImage() == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 65,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          elevation: 4,
                          shape: const CircleBorder(),
                          color: const Color(0xFF800000),
                          child: InkWell(
                            onTap: _pickImage,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),

                _buildSectionLabel('INFORMASI PENGGUNA'),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: positionController,
                          decoration: const InputDecoration(
                            labelText: 'Posisi / Jabatan',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: bioController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Bio / Tentang Anda',
                            alignLabelWithHint: true,
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(bottom: 60),
                              child: Icon(Icons.description_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('BATAL'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('SIMPAN'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }

  ImageProvider? _buildPreviewImage() {
    if (selectedImagePath == null || selectedImagePath!.isEmpty) return null;

    if (selectedImagePath!.startsWith('http') ||
        selectedImagePath!.startsWith('blob:')) {
      return NetworkImage(selectedImagePath!);
    }

    if (File(selectedImagePath!).existsSync()) {
      return FileImage(File(selectedImagePath!));
    }

    return null;
  }
}
