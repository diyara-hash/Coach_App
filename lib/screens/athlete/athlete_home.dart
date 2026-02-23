import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/program_model.dart';
import '../auth/login_screen.dart';
import '../common/chat_screen.dart';
import '../common/notification_screen.dart';
import 'athlete_profile.dart';

class AthleteHome extends StatefulWidget {
  final String athleteId;

  const AthleteHome({super.key, required this.athleteId});

  @override
  State<AthleteHome> createState() => _AthleteHomeState();
}

class _AthleteHomeState extends State<AthleteHome> {
  Stream<DocumentSnapshot>? _programStream;
  StreamSubscription? _notificationSubscription;
  int selectedDay = 0;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadProgram();
    _listenNotifications();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _listenNotifications() {
    _notificationSubscription = FirebaseFirestore.instance
        .collection('notifications')
        .where('targetUserId', isEqualTo: widget.athleteId)
        .where('timestamp', isGreaterThan: _startTime)
        .snapshots()
        .listen((snapshot) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              _showInAppNotification(
                data['title'] ?? 'Yeni Bildirim',
                data['body'] ?? '',
              );
            }
          }
        });
  }

  void _showInAppNotification(String title, String body) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              body,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE94560),
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Gör',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationScreen(userId: widget.athleteId),
              ),
            );
          },
        ),
      ),
    );
  }

  void _loadProgram() {
    _programStream = FirebaseFirestore.instance
        .collection('athletes')
        .doc(widget.athleteId)
        .collection('programs')
        .orderBy('assignedAt', descending: true)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.isNotEmpty
              ? snapshot.docs.first
              : throw 'No program',
        );
  }

  Future<void> _logActivity({
    required String type,
    required String title,
    required String subtitle,
  }) async {
    await FirebaseFirestore.instance
        .collection('athletes')
        .doc(widget.athleteId)
        .collection('activity_logs')
        .add({
          'type': type,
          'title': title,
          'subtitle': subtitle,
          'timestamp': FieldValue.serverTimestamp(),
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _programStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return _buildNoProgramUI();
        }

        try {
          final programData = snapshot.data!.data() as Map<String, dynamic>;
          final program = ProgramModel.fromMap(programData);

          return Scaffold(
            backgroundColor: const Color(0xFF0A0A0A),
            body: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 180,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFFE94560),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Antrenmanım',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE94560), Color(0xFF0A0A0A)],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            CircleAvatar(
                              radius: 35,
                              backgroundColor: Colors.white,
                              child: Text(
                                widget.athleteId.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFE94560),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('notifications')
                          .where('targetUserId', isEqualTo: widget.athleteId)
                          .where('isRead', isEqualTo: false)
                          .snapshots(),
                      builder: (context, snapshot) {
                        int unreadCount = snapshot.hasData
                            ? snapshot.data!.docs.length
                            : 0;
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NotificationScreen(
                                      userId: widget.athleteId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (unreadCount > 0)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    unreadCount > 9
                                        ? '9+'
                                        : unreadCount.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.account_circle),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AthleteProfile(athleteId: widget.athleteId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // İçerik
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Haftalık Bilgi (Firestore'dan tek bir program geldiği için sabit gösterim yapıyoruz veya programın gününü gösteriyoruz)
                        const SizedBox(height: 8),

                        // Bugünün Programı Kartı
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFE94560).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        program.muscle,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFE94560),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${program.duration} • ${program.exercises.length} egzersiz',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFE94560,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.fitness_center,
                                      color: Color(0xFFE94560),
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: program.exercises.isEmpty
                                      ? 0
                                      : program.exercises
                                                .where((e) => e.done)
                                                .length /
                                            program.exercises.length,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.1,
                                  ),
                                  valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFFE94560),
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${program.exercises.where((e) => e.done).length}/${program.exercises.length} tamamlandı',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Egzersiz Listesi
                        const Text(
                          'Egzersizler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        ...program.exercises.map((exercise) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: exercise.done
                                    ? Colors.green.withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: exercise.done
                                        ? Colors.green.withOpacity(0.2)
                                        : const Color(
                                            0xFFE94560,
                                          ).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    exercise.done
                                        ? Icons.check
                                        : Icons.fitness_center,
                                    color: exercise.done
                                        ? Colors.green
                                        : const Color(0xFFE94560),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        exercise.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: exercise.done
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: exercise.done
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        exercise.sets,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Checkbox(
                                  value: exercise.done,
                                  onChanged: (value) async {
                                    final bool isDone = value ?? false;
                                    setState(() {
                                      exercise.done = isDone;
                                    });

                                    // Firestore'u güncelle
                                    await FirebaseFirestore.instance
                                        .collection('athletes')
                                        .doc(widget.athleteId)
                                        .collection('programs')
                                        .doc(program.id)
                                        .update({
                                          'exercises': program.exercises
                                              .map((e) => e.toMap())
                                              .toList(),
                                        });

                                    // Aktiviteyi kaydet
                                    if (isDone) {
                                      await _logActivity(
                                        type: 'exercise',
                                        title: '${exercise.name} tamamlandı',
                                        subtitle: '${program.muscle} programı',
                                      );

                                      // Program bitti mi kontrol et
                                      bool allDone = program.exercises.every(
                                        (e) => e.done,
                                      );
                                      if (allDone) {
                                        await _logActivity(
                                          type: 'program_complete',
                                          title: 'Antrenman Bitti! 🎉',
                                          subtitle:
                                              '${program.muscle} programını başarıyla tamamladı.',
                                        );

                                        // Coach'a bildirim gönder
                                        final notifId = FirebaseFirestore
                                            .instance
                                            .collection('notifications')
                                            .doc()
                                            .id;
                                        await FirebaseFirestore.instance
                                            .collection('notifications')
                                            .doc(notifId)
                                            .set({
                                              'id': notifId,
                                              'title':
                                                  'Antrenman Tamamlandı! 🔥',
                                              'body':
                                                  'Bir sporcu ${program.muscle} programını bitirdi!',
                                              'type': 'programCompleted',
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                              'isRead': false,
                                              'targetUserId': 'admin',
                                              'senderId': widget.athleteId,
                                            });
                                      }
                                    }
                                  },
                                  activeColor: Colors.green,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      athleteId: widget.athleteId,
                      athleteName: 'Sporcu', // Sporcu adı da eklenebilir
                      currentUserId: widget.athleteId,
                      isCoach: false,
                    ),
                  ),
                );
              },
              backgroundColor: const Color(0xFFE94560),
              icon: const Icon(Icons.chat),
              label: const Text('Coach\'a Yaz'),
            ),
          );
        } catch (e) {
          return _buildNoProgramUI();
        }
      },
    );
  }

  Widget _buildNoProgramUI() {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Henüz atanmış bir programın yok.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coach\'un program atadığında burada görünecek.',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
