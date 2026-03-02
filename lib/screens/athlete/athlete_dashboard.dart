import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/athlete.dart';
import '../auth/login_screen.dart';
import '../common/chat_screen.dart';
import 'athlete_profile.dart';

class AthleteDashboard extends StatelessWidget {
  final String athleteId;
  final Function(int) onNavigate;

  const AthleteDashboard({
    super.key,
    required this.athleteId,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MYCOACH'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: FutureBuilder<Athlete?>(
        future: DatabaseService().getAthleteById(athleteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final athlete = snapshot.data;
          final name = athlete?.name ?? 'Sporcu';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Hoşgeldin,',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(
                  'HIZLI ERİŞİM',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<int>(
                  stream: DatabaseService().getUnreadNotificationsCount(
                    athleteId,
                    'program',
                  ),
                  builder: (context, programSnapshot) {
                    final unreadPrograms = programSnapshot.data ?? 0;

                    return StreamBuilder<int>(
                      stream: DatabaseService().getUnreadNotificationsCount(
                        athleteId,
                        'message',
                      ),
                      builder: (context, messageSnapshot) {
                        final unreadMessages = messageSnapshot.data ?? 0;

                        return GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                          childAspectRatio: 1.0,
                          children: [
                            _buildQuickAccessCard(
                              context,
                              title: 'Antrenmanlarım',
                              icon: Icons.fitness_center_rounded,
                              badgeCount: unreadPrograms,
                              onTap: () {
                                if (unreadPrograms > 0) {
                                  DatabaseService().markNotificationsAsRead(
                                    athleteId,
                                    'program',
                                  );
                                }
                                onNavigate(1);
                              },
                            ),
                            _buildQuickAccessCard(
                              context,
                              title: 'Ölçülerim',
                              icon: Icons.straighten_rounded,
                              onTap: () => onNavigate(2),
                            ),
                            _buildQuickAccessCard(
                              context,
                              title: 'Mesajlarım',
                              icon: Icons.forum_rounded,
                              badgeCount: unreadMessages,
                              onTap: () {
                                if (unreadMessages > 0) {
                                  DatabaseService().markNotificationsAsRead(
                                    athleteId,
                                    'message',
                                  );
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      athleteId: athleteId,
                                      athleteName: 'Coach',
                                      currentUserId: athleteId,
                                      isCoach: false,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _buildQuickAccessCard(
                              context,
                              title: 'Profilim',
                              icon: Icons.person_rounded,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        AthleteProfile(athleteId: athleteId),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 36, color: AppColors.primary),
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          badgeCount > 9 ? '9+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
