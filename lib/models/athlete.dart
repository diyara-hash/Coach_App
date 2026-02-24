import 'package:cloud_firestore/cloud_firestore.dart';

class Athlete {
  final String id;
  final String name;
  final String email;
  final String inviteCode;
  final String coachId;
  final DateTime createdAt;
  final String? bio;
  final String? phone;

  Athlete({
    required this.id,
    required this.name,
    required this.email,
    required this.inviteCode,
    required this.coachId,
    required this.createdAt,
    this.bio,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'inviteCode': inviteCode,
      'coachId': coachId,
      'createdAt': createdAt.toIso8601String(),
      'bio': bio,
      'phone': phone,
    };
  }

  factory Athlete.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return Athlete(
      id: map['id'] ?? documentId ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      inviteCode: map['inviteCode'] ?? '',
      coachId: map['coachId'] ?? '',
      createdAt: parseDate(map['createdAt']),
      bio: map['bio'],
      phone: map['phone'],
    );
  }
}
