import 'package:cloud_firestore/cloud_firestore.dart';

class Program {
  final String id;
  final String name;
  final String coachId;
  final List<Exercise> exercises;
  final DateTime createdAt;
  final String? assignedAthleteId; // Sporcuya atanmış mı?

  Program({
    required this.id,
    required this.name,
    required this.coachId,
    required this.exercises,
    required this.createdAt,
    this.assignedAthleteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coachId': coachId,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'assignedAthleteId': assignedAthleteId,
    };
  }

  factory Program.fromMap(Map<String, dynamic> map, {String? documentId}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return Program(
      id: map['id'] ?? documentId ?? '',
      name: map['name'] ?? '',
      coachId: map['coachId'] ?? '',
      exercises:
          (map['exercises'] as List<dynamic>?)
              ?.map((e) => Exercise.fromMap(e))
              .toList() ??
          [],
      createdAt: parseDate(map['createdAt']),
      assignedAthleteId: map['assignedAthleteId'],
    );
  }
}

class Exercise {
  final String name;
  final String sets;
  final String? videoId;

  Exercise({required this.name, required this.sets, this.videoId});

  Map<String, dynamic> toMap() {
    return {'name': name, 'sets': sets, 'videoId': videoId};
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      name: map['name'] ?? '',
      sets: map['sets'] ?? '',
      videoId: map['videoId'],
    );
  }
}
