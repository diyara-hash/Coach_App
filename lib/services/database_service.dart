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

  Future<void> deleteAthlete(String athleteId) async {
    await _firestore.collection('athletes').doc(athleteId).delete();
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

  Future<void> deleteProgram(String programId) async {
    await _firestore.collection('programs').doc(programId).delete();
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

  // ===== CRM =====
  Stream<DocumentSnapshot> getAthleteCrmProfile(String athleteId) {
    return _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm')
        .doc('profile')
        .snapshots();
  }

  Future<void> updateAthleteCrmProfile(
    String athleteId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm')
        .doc('profile')
        .set(data, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getAthleteGoals(String athleteId) {
    return _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_goals')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> addAthleteGoal(
    String athleteId,
    Map<String, dynamic> goalData,
  ) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_goals')
        .add({...goalData, 'createdAt': FieldValue.serverTimestamp()});
  }

  Future<void> updateAthleteGoal(
    String athleteId,
    String goalId,
    Map<String, dynamic> goalData,
  ) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_goals')
        .doc(goalId)
        .update(goalData);
  }

  Stream<QuerySnapshot> getAthleteNotes(String athleteId) {
    return _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_notes')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Future<void> addAthleteNote(
    String athleteId,
    Map<String, dynamic> noteData,
  ) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_notes')
        .add({...noteData, 'createdAt': FieldValue.serverTimestamp()});
  }

  Stream<QuerySnapshot> getAthleteFiles(String athleteId) {
    return _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_files')
        .orderBy('uploadedAt', descending: true)
        .snapshots();
  }

  Future<void> addAthleteFile(
    String athleteId,
    Map<String, dynamic> fileData,
  ) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_files')
        .add({...fileData, 'uploadedAt': FieldValue.serverTimestamp()});
  }

  Future<void> deleteAthleteFile(String athleteId, String fileId) async {
    await _firestore
        .collection('athletes')
        .doc(athleteId)
        .collection('crm_files')
        .doc(fileId)
        .delete();
  }
}
