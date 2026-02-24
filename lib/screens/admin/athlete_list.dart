import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/athlete.dart';
import '../../services/database_service.dart';
import '../common/chat_screen.dart';
import '../../core/theme/app_theme.dart';

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
                  Icon(
                    Icons.people_outline_rounded,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Henüz sporcu eklenmemiş',
                    style: TextStyle(
                      color: AppColors.textSecondary,
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
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                        onPressed: () => _assignProgram(context, athlete, db),
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

  void _showAthleteDetail(BuildContext context, Athlete athlete) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sporcu Profili',
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 24),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _buildInfoTile(
              context,
              'AD SOYAD',
              athlete.name,
              Icons.person_outline_rounded,
            ),
            _buildInfoTile(
              context,
              'E-POSTA',
              athlete.email,
              Icons.email_outlined,
            ),
            _buildInfoTile(
              context,
              'DAVET KODU',
              athlete.inviteCode,
              Icons.vpn_key_outlined,
            ),
            _buildInfoTile(
              context,
              'KAYIT TARİHİ',
              '${athlete.createdAt.day}/${athlete.createdAt.month}/${athlete.createdAt.year}',
              Icons.calendar_today_outlined,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
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
