import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/athlete.dart';
import '../models/program.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===== ATHLETE =====
  Future<void> addAthlete(Athlete athlete) async {
    await _firestore
        .collection('athletes')
        .doc(athlete.id)
        .set(athlete.toMap());
  }

  Stream<List<Athlete>> getAthletes(String coachId) {
    return _firestore
        .collection('athletes')
        // .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Athlete.fromMap(doc.data(), documentId: doc.id))
              .toList();
        });
  }

  Future<Athlete?> getAthleteById(String id) async {
    final doc = await _firestore.collection('athletes').doc(id).get();
    if (!doc.exists) return null;
    return Athlete.fromMap(doc.data()!, documentId: doc.id);
  }

  Future<Athlete?> getAthleteByInviteCode(String code) async {
    final snapshot = await _firestore
        .collection('athletes')
        .where('inviteCode', isEqualTo: code)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Athlete.fromMap(
      snapshot.docs.first.data(),
      documentId: snapshot.docs.first.id,
    );
  }

  // ===== PROGRAM =====
  Future<void> addProgram(Program program) async {
    await _firestore
        .collection('programs')
        .doc(program.id)
        .set(program.toMap());
  }

  Stream<List<Program>> getPrograms(String coachId) {
    return _firestore
        .collection('programs')
        // .where('coachId', isEqualTo: coachId)
        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Program.fromMap(doc.data(), documentId: doc.id))
              .toList();
        });
  }

  Future<void> assignProgramToAthlete(
    String programId,
    String athleteId,
  ) async {
    await _firestore.collection('programs').doc(programId).update({
      'assignedAthleteId': athleteId,
    });
  }

  Stream<List<Program>> getAthletePrograms(String athleteId) {
    return _firestore
        .collection('programs')
        .where('assignedAthleteId', isEqualTo: athleteId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Program.fromMap(doc.data(), documentId: doc.id))
              .toList();
        });
  }

  Future<void> updateAthlete(String id, Map<String, dynamic> data) async {
    await _firestore.collection('athletes').doc(id).update(data);
  }

  Future<void> updateAthletePassword(String id, String newPassword) async {
    await _firestore.collection('athletes').doc(id).update({
      'password': newPassword,
    });
  }

  // ===== MEASUREMENTS =====
  Future<void> addMeasurement(Map<String, dynamic> measurementData) async {
    await _firestore.collection('measurements').add(measurementData);
  }

  Stream<List<Map<String, dynamic>>> getMeasurements({
    String? studentId,
    bool? isRead,
  }) {
    Query query = _firestore
        .collection('measurements')
        .orderBy('submittedAt', descending: true);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (isRead != null) {
      query = query.where('isRead', isEqualTo: isRead);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> markMeasurementAsRead(String measurementId) async {
    await _firestore.collection('measurements').doc(measurementId).update({
      'isRead': true,
    });
  }
}
