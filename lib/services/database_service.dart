import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/athlete.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addAthlete(Athlete athlete) async {
    await _firestore
        .collection('athletes')
        .doc(athlete.id)
        .set(athlete.toMap());
  }

  Stream<List<Athlete>> getAthletes(String coachId) {
    return _firestore
        .collection('athletes')
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Athlete.fromMap(doc.data()))
              .toList();
        });
  }

  Future<Athlete?> getAthleteByInviteCode(String code) async {
    final snapshot = await _firestore
        .collection('athletes')
        .where('inviteCode', isEqualTo: code)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Athlete.fromMap(snapshot.docs.first.data());
  }
}
