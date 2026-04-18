import 'package:flutter/material.dart';
import '../models/meeting_model.dart';
import 'meeting_form_page.dart';

class EditMeetingPage extends StatelessWidget {
  final Meeting meeting;

  const EditMeetingPage({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Rapat', style: TextStyle(color: Colors.white))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: MeetingForm(meeting: meeting),
      ),
    );
  }
}
