class TravelBuddy {
  final String name;
  final String username;

  const TravelBuddy({required this.name, required this.username});

  factory TravelBuddy.fromJson(Map<String, dynamic> json) {
    return TravelBuddy(
      name: json['name'],
      username: json['username'],
    );
  }
}
