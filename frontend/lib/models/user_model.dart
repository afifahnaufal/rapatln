class User {
  final String? id;
  final String name;
  final String position;
  final String bio;
  final String? profileImagePath;

  User({
    this.id,
    required this.name,
    required this.position,
    required this.bio,
    this.profileImagePath,
  });

  // Convert to JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'bio': bio,
      'profileImagePath': profileImagePath,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String,
      position: json['position'] as String,
      bio: json['bio'] as String,
      profileImagePath: json['profileImagePath'] as String?,
    );
  }

  // Copy with untuk update data
  User copyWith({
    String? name,
    String? position,
    String? bio,
    String? profileImagePath,
  }) {
    return User(
      name: name ?? this.name,
      position: position ?? this.position,
      bio: bio ?? this.bio,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
