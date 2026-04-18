import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi', style: TextStyle(color: Colors.white)), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App Info Card
              _buildAppInfoCard(),
              const SizedBox(height: 32),

              // Tim Pengembang Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF800000).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.group,
                        color: Color(0xFF800000),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Tim Pengembang',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Team Members List
              _buildTeamMemberCard(
                'Afifah Naufal Rahmani',
                'Frontend Developer',
              ),
              const SizedBox(height: 12),
              _buildTeamMemberCard('Ahmad Karta Nugraha', 'Backend Developer'),
              const SizedBox(height: 32),

              // Teknologi Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Teknologi yang Digunakan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTechChip('Flutter', Icons.flutter_dash),
                  _buildTechChip('Dart', Icons.code),
                  _buildTechChip('VS Code', Icons.computer),
                  _buildTechChip('Android', Icons.android),
                ],
              ),
              const SizedBox(height: 48),

              // Copyright Footer
              Center(
                child: Column(
                  children: [
                    Text(
                      'RapatIn v1.0.0',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2024 Tim RapatIn',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF800000).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: Color(0xFF800000),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RapatIn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'RapatIn adalah solusi modern untuk manajemen rapat yang efisien. Aplikasi ini dirancang untuk memudahkan Anda dalam:\n\n'
              '• Menjadwalkan rapat dengan detail yang lengkap\n'
              '• Mencatat notulensi, keputusan, dan tindak lanjut rapat\n'
              '• Mengelola riwayat pertemuan secara terstruktur\n'
              '• Memantau agenda mendatang dengan mudah\n\n'
              'Dengan antarmuka yang intuitif, RapatIn membantu produktivitas tim Anda tetap terjaga.',
              style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMemberCard(String name, String position) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF800000).withValues(alpha: 0.2),
              child: Text(
                name[0],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF800000),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    position,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTechChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF800000)),
      label: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF800000),
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFF800000).withOpacity(0.05),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
