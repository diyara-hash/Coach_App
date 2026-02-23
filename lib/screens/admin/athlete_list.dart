import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/chat_screen.dart';
import 'athlete_progress.dart';
import 'assign_program.dart';

class AthleteList extends StatelessWidget {
  const AthleteList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sporcu Listesi'),
        backgroundColor: const Color(0xFFE94560),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('athletes') // ← athletes olarak değiştir!
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Henüz sporcu eklenmemiş'),
                ],
              ),
            );
          }

          final athletes = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: athletes.length,
            itemBuilder: (context, index) {
              final athlete = athletes[index].data() as Map<String, dynamic>;
              final name = athlete['name'] ?? 'İsimsiz';
              final email = athlete['email'] ?? '';
              final inviteCode = athlete['inviteCode'] ?? '';

              // TARİH DÜZELTME
              DateTime? createdAt;
              if (athlete['createdAt'] != null) {
                try {
                  createdAt = DateTime.parse(athlete['createdAt']);
                } catch (e) {
                  createdAt = null;
                }
              }

              return Card(
                color: const Color(0xFF1A1A2E),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFE94560),
                    child: Text(
                      name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(email),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kod: $inviteCode',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[400],
                            ),
                          ),
                          if (createdAt != null)
                            Text(
                              'Kayıt: ${createdAt.day}.${createdAt.month}.${createdAt.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () => _showAthleteDetail(context, athlete),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAthleteDetail(BuildContext context, Map<String, dynamic> athlete) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFFE94560),
                    child: Text(
                      athlete['name']?.substring(0, 1).toUpperCase() ?? '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          athlete['name'] ?? 'İsimsiz',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          athlete['email'] ?? '',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Davet Kodu:',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SelectableText(
                            athlete['inviteCode'] ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'İşlemler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.fitness_center, color: Colors.orange),
                title: const Text('Program Ata'),
                onTap: () {
                  Navigator.pop(context); // Önce bottom sheet'i kapat
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssignProgram(
                        athleteId: athlete['id'] ?? '',
                        athleteName: athlete['name'] ?? 'İsimsiz',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.green),
                title: const Text('İlerlemeyi Gör'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AthleteProgress(
                        athleteId: athlete['id'] ?? '',
                        athleteName: athlete['name'] ?? 'İsimsiz',
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.message, color: Colors.blue),
                title: const Text('Mesaj Gönder'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        athleteId: athlete['id'] ?? '',
                        athleteName: athlete['name'] ?? 'İsimsiz',
                        currentUserId: 'admin',
                        isCoach: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
