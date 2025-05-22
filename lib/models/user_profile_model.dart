// user_profile_model.dart
class UserProfile {
  final String username;
  final String name;
  final List<String>? styles;
  final List<String>? interests;
  final String? imageBase64;

  UserProfile({
    required this.username,
    required this.name,
    this.styles,
    this.interests,
    this.imageBase64,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'],
      name: json['name'],
      styles: (json['styles'] as List?)?.whereType<String>().toList() ?? [],
      interests: (json['interests'] as List?)?.whereType<String>().toList() ?? [],
      imageBase64: json['imageBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'name': name,
      'styles': styles ?? [],
      'interests': interests ?? [],
      'imageBase64': imageBase64,
    };
  }
}
