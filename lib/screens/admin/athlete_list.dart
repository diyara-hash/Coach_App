import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/athlete.dart';
import '../../services/database_service.dart';
import '../common/chat_screen.dart';
import '../../core/theme/app_theme.dart';
import 'add_athlete.dart';
import '../../features/admin/student_crm_page.dart';

class AthleteList extends StatelessWidget {
  const AthleteList({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final coachId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    return Scaffold(
      appBar: AppBar(title: const Text('SPORCULARIM')),
      body: StreamBuilder<List<Athlete>>(
        stream: db.getAthletes(coachId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final athletes = snapshot.data!;

          if (athletes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.people_outline_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Henüz sporcu eklenmemiş',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: athletes.length,
            itemBuilder: (context, index) {
              final athlete = athletes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppColors.eliteShadow, AppColors.emeraldGlow],
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            athlete.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          athlete.name,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          athlete.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.forum_outlined,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      athleteId: athlete.id,
                                      athleteName: athlete.name,
                                      currentUserId: coachId,
                                      isCoach: true,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.assignment_ind_outlined,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () =>
                                  _assignProgram(context, athlete, db),
                            ),
                          ],
                        ),
                        onTap: () => _showAthleteDetail(context, athlete),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Sporcuyu Sil'),
                                content: Text(
                                  '${athlete.name} adlı sporcuyu silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext),
                                    child: const Text('İPTAL'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                    ),
                                    onPressed: () {
                                      db.deleteAthlete(athlete.id);
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('SİL'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddAthlete(athlete: athlete),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAthleteDetail(BuildContext context, Athlete athlete) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StudentCrmPage(athlete: athlete)),
    );
  }

  void _assignProgram(
    BuildContext context,
    Athlete athlete,
    DatabaseService db,
  ) async {
    final coachId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    final programs = await db.getPrograms(coachId).first;

    if (programs.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Önce program oluşturun!')));
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${athlete.name} için Program Seç'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: programs.length,
            itemBuilder: (context, index) {
              final program = programs[index];
              return ListTile(
                title: Text(program.name),
                subtitle: Text('${program.exercises.length} egzersiz'),
                trailing: program.assignedAthleteId == athlete.id
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () async {
                  await db.assignProgramToAthlete(program.id, athlete.id);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${program.name} atandı!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
