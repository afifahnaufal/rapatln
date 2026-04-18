import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';
import 'edit_meeting_page.dart';

class MeetingDetailPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailPage({super.key, required this.meeting});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  late Meeting _meeting;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      // Pastikan ID tidak null sebelum fetch
      if (_meeting.id != null) {
        final updatedMeeting = await MeetingService().getMeetingById(_meeting.id!);
        if (mounted) {
          setState(() {
            _meeting = updatedMeeting;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteMeeting() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Rapat'),
        content: const Text('Apakah Anda yakin ingin menghapus rapat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MeetingService().deleteMeeting(_meeting.id.toString());
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Notulensi', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edit Rapat',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditMeetingPage(meeting: _meeting),
                ),
              );
              // Jika result adalah Meeting (data update), update state langsung
              if (result is Meeting) {
                setState(() {
                  _meeting = result;
                });
              } else if (result == true) {
                _refreshData();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus Rapat',
            onPressed: _deleteMeeting,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _meeting.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              // Badge Status di Detail Page
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _meeting.status == 'Selesai'
                                      ? Colors.green.withOpacity(0.1)
                                      : const Color(0xFF800000).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _meeting.status == 'Belum Selesai'
                                      ? 'Terjadwal'
                                      : _meeting.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _meeting.status == 'Selesai'
                                        ? Colors.green
                                        : const Color(0xFF800000),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 18,
                                color: Color(0xFF800000),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _meeting.date,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Color(0xFF800000),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _meeting.location,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'RINGKASAN RAPAT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildSection(
                    Icons.speaker_notes,
                    'Pembahasan',
                    _meeting.discussion,
                  ),
                  _buildSection(Icons.gavel, 'Keputusan', _meeting.decision),
                  _buildSection(
                    Icons.assignment_turned_in,
                    'Tindak Lanjut',
                    _meeting.followUp,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(IconData icon, String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF800000)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              content.isEmpty ? 'Tidak ada data.' : content,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: content.isEmpty ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
