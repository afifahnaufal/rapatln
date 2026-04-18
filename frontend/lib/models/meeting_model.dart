class Meeting {
  final String? id;
  final String title;
  final String date;
  final String location;
  final String discussion;
  final String decision;
  final String followUp;
  final String status; // 'Belum Selesai' atau 'Selesai'

  Meeting({
    this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.discussion,
    required this.decision,
    required this.followUp,
    this.status = 'Belum Selesai',
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as String?,
      title: json['title'] as String,
      date: json['date'] as String,
      location: json['location'] as String,
      discussion: json['discussion'] as String,
      decision: json['decision'] as String,
      followUp: json['followUp'] as String,
      status: json['status'] as String? ?? 'Belum Selesai',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'date': date,
      'location': location,
      'discussion': discussion,
      'decision': decision,
      'followUp': followUp,
      'status': status,
    };
  }
}
