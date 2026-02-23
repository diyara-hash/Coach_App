class Athlete {
  final String id;
  final String name;
  final String email;
  final String inviteCode;
  final String coachId;
  final DateTime createdAt;

  Athlete({
    required this.id,
    required this.name,
    required this.email,
    required this.inviteCode,
    required this.coachId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'inviteCode': inviteCode,
      'coachId': coachId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Athlete.fromMap(Map<String, dynamic> map) {
    return Athlete(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      coachId: map['coachId'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
