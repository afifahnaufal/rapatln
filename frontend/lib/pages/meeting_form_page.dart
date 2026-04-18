import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import '../services/meeting_service.dart';

class MeetingForm extends StatefulWidget {
  final Meeting? meeting;

  const MeetingForm({super.key, this.meeting});

  @override
  State<MeetingForm> createState() => _MeetingFormState();
}

class _MeetingFormState extends State<MeetingForm> {
  final _meetingService = MeetingService();
  final title = TextEditingController();
  final date = TextEditingController();
  final location = TextEditingController();
  final discussion = TextEditingController();
  final decision = TextEditingController();
  final followUp = TextEditingController();
  String _status = 'Belum Selesai';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      title.text = widget.meeting!.title;
      date.text = widget.meeting!.date;
      location.text = widget.meeting!.location;
      discussion.text = widget.meeting!.discussion;
      decision.text = widget.meeting!.decision;
      followUp.text = widget.meeting!.followUp;
      _status = widget.meeting!.status;
    }
  }

  Future<void> _save() async {
    // BUG 1: Validasi input dimatikan secara sengaja
    // Seharusnya form tidak bisa disimpan jika judul rapat kosong.
    // if (title.text.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Judul tidak boleh kosong'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() => _isSaving = true);

    try {
      final meeting = Meeting(
        id: widget.meeting?.id,
        title: title.text,
        date: date.text,
        location: location.text,
        discussion: discussion.text,
        decision: decision.text,
        followUp: followUp.text,
        status: _status,
      );

      Meeting savedMeeting;
      if (widget.meeting == null) {
        savedMeeting = await _meetingService.createMeeting(meeting);
      } else {
        savedMeeting = await _meetingService.updateMeeting(
          widget.meeting!.id.toString(),
          meeting,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, savedMeeting);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 700;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? constraints.maxWidth * 0.1 : 16,
            vertical: 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('INFORMASI UMUM'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: title,
                        decoration: const InputDecoration(
                          labelText: 'Judul Rapat',
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: date,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Tanggal',
                                prefixIcon: Icon(Icons.calendar_month),
                              ),
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (d != null) {
                                  // BUG 2: Nilai dari date picker tidak dimasukkan ke controller secara sengaja
                                  // Sehingga teks tanggal di layar tetap kosong setelah dipilih.
                                  // date.text = '${d.day}/${d.month}/${d.year}';
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              controller: location,
                              decoration: const InputDecoration(
                                labelText: 'Lokasi',
                                prefixIcon: Icon(Icons.place_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader('NOTULENSI RAPAT'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: discussion,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Pembahasan',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: decision,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Keputusan / Hasil',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: followUp,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Tindak Lanjut',
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isSaving ? 'MENYIMPAN...' : 'SIMPAN NOTULENSI'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
        letterSpacing: 1.5,
        color: Colors.grey,
      ),
    );
  }
}
