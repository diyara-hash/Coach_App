import 'package:cloud_firestore/cloud_firestore.dart';

class ProgramModel {
  final String id;
  final String day;
  final String muscle;
  final String duration;
  final List<ExerciseModel> exercises;
  final DateTime? assignedAt;

  ProgramModel({
    required this.id,
    required this.day,
    required this.muscle,
    required this.duration,
    required this.exercises,
    this.assignedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'muscle': muscle,
      'duration': duration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'assignedAt': assignedAt != null ? Timestamp.fromDate(assignedAt!) : null,
    };
  }

  factory ProgramModel.fromMap(Map<String, dynamic> map) {
    return ProgramModel(
      id: map['id'] ?? '',
      day: map['day'] ?? '',
      muscle: map['muscle'] ?? '',
      duration: map['duration'] ?? '',
      exercises:
          (map['exercises'] as List?)
              ?.map((e) => ExerciseModel.fromMap(e))
              .toList() ??
          [],
      assignedAt: map['assignedAt']?.toDate(),
    );
  }
}

class ExerciseModel {
  final String name;
  final String sets;
  final String? videoUrl;
  bool done;

  ExerciseModel({
    required this.name,
    required this.sets,
    this.videoUrl,
    this.done = false,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'sets': sets, 'videoUrl': videoUrl, 'done': done};
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      name: map['name'] ?? '',
      sets: map['sets'] ?? '',
      videoUrl: map['videoUrl'],
      done: map['done'] ?? false,
    );
  }
}
