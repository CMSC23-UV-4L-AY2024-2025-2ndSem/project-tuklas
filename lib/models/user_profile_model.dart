class UserProfile {
  final String uid;
  final String username;
  final String firstName;
  final String lastName;
  final List<String>? styles;
  final List<String>? interests;
  final String? imageBase64;

  UserProfile({
    required this.uid,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.styles,
    this.interests,
    this.imageBase64,
  });

  // Getter for full name
  String get name => '$firstName $lastName';

  factory UserProfile.fromJson(Map<String, dynamic> json, String uid) {
    // Handle legacy data where name might be a single field
    String firstName = '';
    String lastName = '';
    if (json['fname'] != null && json['lname'] != null) {
      firstName = json['fname'] as String;
      lastName = json['lname'] as String;
    } else if (json['name'] != null) {
      // Split existing name into first and last name
      final nameParts = (json['name'] as String).split(' ');
      firstName = nameParts.first;
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    }

    return UserProfile(
      uid: uid,
      username: json['username'] as String? ?? '',
      firstName: firstName,
      lastName: lastName,
      styles: (json['styles'] as List?)?.whereType<String>().toList() ?? [],
      interests:
          (json['interests'] as List?)?.whereType<String>().toList() ?? [],
      imageBase64: json['imageBase64'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fname': firstName,
      'lname': lastName,
      'styles': styles,
      'interests': interests,
      'imageBase64': imageBase64,
    };
  }
}
