import 'package:flutter/material.dart';
import 'meeting_form_page.dart';

class AddMeetingPage extends StatelessWidget {
  const AddMeetingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Rapat', style: TextStyle(color: Colors.white))),
      body: const Padding(padding: EdgeInsets.all(16), child: MeetingForm()),
    );
  }
}
