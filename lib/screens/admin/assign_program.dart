import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';

class AssignProgram extends StatefulWidget {
  final String athleteId;
  final String athleteName;

  const AssignProgram({
    super.key,
    required this.athleteId,
    required this.athleteName,
  });

  @override
  State<AssignProgram> createState() => _AssignProgramState();
}

class _AssignProgramState extends State<AssignProgram> {
  List<ProgramModel> templates = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    // Hazır program şablonlarını yükle (Firestore'dan veya local)
    // Şimdilik local örnekler
    setState(() {
      templates = [
        ProgramModel(
          id: '1',
          day: 'Pazartesi',
          muscle: 'Göğüs & Triceps',
          duration: '45 dk',
          exercises: [
            ExerciseModel(name: 'Bench Press', sets: '4x10'),
            ExerciseModel(name: 'Incline Dumbbell Press', sets: '3x12'),
            ExerciseModel(name: 'Cable Fly', sets: '3x15'),
            ExerciseModel(name: 'Triceps Pushdown', sets: '4x12'),
          ],
        ),
        ProgramModel(
          id: '2',
          day: 'Salı',
          muscle: 'Sırt & Biceps',
          duration: '50 dk',
          exercises: [
            ExerciseModel(name: 'Deadlift', sets: '4x8'),
            ExerciseModel(name: 'Lat Pulldown', sets: '4x12'),
            ExerciseModel(name: 'Barbell Row', sets: '3x10'),
            ExerciseModel(name: 'Dumbbell Curl', sets: '3x12'),
          ],
        ),
        ProgramModel(
          id: '3',
          day: 'Çarşamba',
          muscle: 'Bacak',
          duration: '55 dk',
          exercises: [
            ExerciseModel(name: 'Squat', sets: '4x10'),
            ExerciseModel(name: 'Leg Press', sets: '3x12'),
            ExerciseModel(name: 'Leg Curl', sets: '3x15'),
            ExerciseModel(name: 'Calf Raise', sets: '4x20'),
          ],
        ),
      ];
      isLoading = false;
    });

    // Firestore'dan çekmek istersen:
    /*
    final snapshot = await FirebaseFirestore.instance
        .collection('program_templates')
        .get();
    
    templates = snapshot.docs
        .map((doc) => ProgramModel.fromMap(doc.data()))
        .toList();
    */
  }

  Future<void> _assignProgram(ProgramModel program) async {
    try {
      // Sporcunun program koleksiyonuna ekle
      await FirebaseFirestore.instance
          .collection('athletes')
          .doc(widget.athleteId)
          .collection('programs')
          .doc(program.id)
          .set({
            ...program.toMap(),
            'assignedAt': FieldValue.serverTimestamp(),
            'assignedBy': 'admin',
          });

      // Ana dokümana da ekle (son programı görmek için)
      await FirebaseFirestore.instance
          .collection('athletes')
          .doc(widget.athleteId)
          .update({
            'currentProgramId': program.id,
            'programMuscle': program.muscle,
            'programLastAssigned': FieldValue.serverTimestamp(),
          });

      // Bildirim gönder
      final notificationId = FirebaseFirestore.instance
          .collection('notifications')
          .doc()
          .id;
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set({
            'id': notificationId,
            'title': 'Yeni Program Atandı! 🏋️‍♂️',
            'body': '${program.muscle} programın hazır. Hemen kontrol et!',
            'type': 'programAssigned',
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'targetUserId': widget.athleteId,
            'senderId': 'admin',
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${program.muscle} programı ${widget.athleteName} isimli sporcuya atandı.',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.athleteName} - Program Ata')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : templates.isEmpty
          ? const Center(child: Text('Hazır program bulunamadı.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final program = templates[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              program.muscle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              program.duration,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gün: ${program.day}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Egzersizler:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        ...program.exercises
                            .take(3)
                            .map(
                              (e) => Text(
                                '• ${e.name} (${e.sets})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                        if (program.exercises.length > 3)
                          Text(
                            '...ve ${program.exercises.length - 3} egzersiz daha',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _assignProgram(program),
                            child: const Text('Bu Programı Ata'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
