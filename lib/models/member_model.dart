class Member {
  final String id;
  final String name;
  String role;

  Member({
    required this.id,
    required this.name,
    required this.role
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['userUsername'] as String,
      name: json['userNickname'] as String,
      role: json['role'] as String,
    );
  }
}