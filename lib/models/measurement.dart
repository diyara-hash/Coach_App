import 'package:cloud_firestore/cloud_firestore.dart';

class BodyMeasurement {
  final String id;
  final String studentId;
  final String studentName;
  final double height;
  final double weight;
  final double waist;
  final double hips;
  final double chest;
  final DateTime date;
  final DateTime submittedAt;
  final bool isRead;

  BodyMeasurement({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.height,
    required this.weight,
    required this.waist,
    required this.hips,
    required this.chest,
    required this.date,
    required this.submittedAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'measurements': {
        'height': height,
        'weight': weight,
        'waist': waist,
        'hips': hips,
        'chest': chest,
      },
      'date': Timestamp.fromDate(date),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'isRead': isRead,
    };
  }

  factory BodyMeasurement.fromMap(Map<String, dynamic> map, String documentId) {
    final measurements = map['measurements'] as Map<String, dynamic>;
    return BodyMeasurement(
      id: documentId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      height: (measurements['height'] ?? 0).toDouble(),
      weight: (measurements['weight'] ?? 0).toDouble(),
      waist: (measurements['waist'] ?? 0).toDouble(),
      hips: (measurements['hips'] ?? 0).toDouble(),
      chest: (measurements['chest'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      submittedAt: (map['submittedAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }
}
