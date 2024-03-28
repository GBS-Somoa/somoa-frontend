class Member {
  final int id;
  final String username;
  final String name;
  String role;

  Member({
    required this.id,
    required this.username,
    required this.name,
    required this.role
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['userId'] as int,
      username: json['userUsername'] as String,
      name: json['userNickname'] as String,
      role: json['role'] as String,
    );
  }
}