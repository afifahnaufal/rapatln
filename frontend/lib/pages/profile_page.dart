import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'edit_profile_page.dart';
import 'login_page.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _userService = UserService();
  User? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await _userService.getUserProfile();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        // ID sudah tidak valid di database, paksa logout
        await UserService.logout();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        setState(() {
          _error = 'Gagal mengambil profil: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await UserService.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _buildProfileContent(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_off_outlined, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _fetchUser, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    if (_user == null) return const SizedBox();

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header dengan curved background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF800000),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 57,
                    backgroundColor: const Color(
                      0xFF800000,
                    ).withValues(alpha: 0.1),
                    backgroundImage: _buildProfileImage(),
                    child: _buildProfileImage() == null
                        ? const Icon(
                            Icons.person,
                            color: Color(0xFF800000),
                            size: 60,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _user!.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _user!.position,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Email Card
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _user!
                      .name, // Ini bisa disesuaikan dengan field email jika ada
                ),
                const SizedBox(height: 12),

                // Position Card
                _buildInfoCard(
                  icon: Icons.work_outline,
                  label: 'Posisi',
                  value: _user!.position,
                ),
                const SizedBox(height: 12),

                // Bio Card (hanya preview)
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: 'Tentang',
                  value: _user!.bio.isEmpty ? 'Belum ada info' : _user!.bio,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Tentang Saya Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tentang Saya',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  _user!.bio.isEmpty
                      ? 'Belum ada bio. Klik Edit Profil untuk menambahkan.'
                      : _user!.bio,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Edit Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push<User>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: _user!),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _user = result;
                    });
                    // Purge image cache untuk force reload foto
                    imageCache.clearLiveImages();
                    imageCache.clear();
                    _fetchUser();
                  }
                },
                child: const Text('EDIT PROFIL'),
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF800000).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF800000), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildProfileImage() {
    final path = _user?.profileImagePath;
    if (path == null || path.isEmpty) return null;

    if (kIsWeb || path.startsWith('http') || path.startsWith('blob:')) {
      return NetworkImage(path);
    }

    if (File(path).existsSync()) {
      return FileImage(File(path));
    }

    return null;
  }
}
