// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'add_athlete.dart';
import 'program_builder.dart';
import 'program_list.dart';
import 'athlete_list.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/elite_glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/admin/admin_measurements_panel.dart';
import '../../core/utils/app_haptics.dart';
import '../../services/database_service.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADMIN PANEL'),
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
      drawer: Drawer(
        backgroundColor: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: AppTheme.primaryGradient.copyWith(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [AppColors.emeraldGlow],
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'MYCOACH',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Divider(
                  color: Theme.of(
                    context,
                    // ignore: duplicate_ignore
                    // ignore: deprecated_member_use
                  ).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildDrawerItem(
                context,
                icon: Icons.dashboard_rounded,
                title: 'Dashboard',
                isActive: true,
                onTap: () {
                  AppHaptics.selectionClick();
                  Navigator.pop(context);
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.people_alt_rounded,
                title: 'Sporcular',
                onTap: () {
                  AppHaptics.selectionClick();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AthleteList()),
                  );
                },
              ),
              _buildDrawerItem(
                context,
                icon: Icons.straighten_rounded,
                title: 'Öğrenci Ölçüleri',
                onTap: () {
                  AppHaptics.selectionClick();
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminMeasurementsPanel(),
                    ),
                  );
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Divider(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                ),
              ),
              _buildDrawerItem(
                context,
                icon: Icons.logout_rounded,
                title: 'Çıkış Yap',
                isDestructive: true,
                onTap: () {
                  AppHaptics.heavyImpact();
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hoş Geldin, Coach! 💪',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Bugün sporcuların için ne yapıyoruz?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: StreamBuilder<int>(
                stream: DatabaseService().getUnreadNotificationsCount(
                  'admin',
                  'message',
                ),
                builder: (context, messageSnapshot) {
                  final unreadMessages = messageSnapshot.data ?? 0;

                  return StreamBuilder<List<Map<String, dynamic>>>(
                    stream: DatabaseService().getMeasurements(isRead: false),
                    builder: (context, measurementSnapshot) {
                      final unreadMeasurements =
                          measurementSnapshot.data?.length ?? 0;

                      return GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        children: [
                          _buildMenuCard(
                            context,
                            'Sporcu Listesi',
                            Icons.people_alt_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AthleteList(),
                                ),
                              );
                            },
                            0,
                          ),
                          _buildMenuCard(
                            context,
                            'Öğrenci Ölçüleri',
                            Icons.straighten_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AdminMeasurementsPanel(),
                                ),
                              );
                            },
                            1,
                            badgeCount: unreadMeasurements,
                          ),
                          _buildMenuCard(
                            context,
                            'Programlarım',
                            Icons.fitness_center_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProgramList(),
                                ),
                              );
                            },
                            2,
                          ),
                          _buildMenuCard(
                            context,
                            'Yeni Program',
                            Icons.add_task_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProgramBuilder(),
                                ),
                              );
                            },
                            3,
                          ),
                          _buildMenuCard(
                            context,
                            'Yeni Sporcu',
                            Icons.person_add_alt_1_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddAthlete(),
                                ),
                              );
                            },
                            4,
                          ),
                          _buildMenuCard(
                            context,
                            'Mesajlar',
                            Icons.forum_rounded,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AthleteList(),
                                ),
                              );
                            },
                            5,
                            badgeCount: unreadMessages,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
    int index, {
    int badgeCount = 0,
  }) {
    return GestureDetector(
          onTap: onTap,
          child: EliteGlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Icon(icon, size: 32, color: AppColors.primary),
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
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fade(duration: 400.ms, delay: (index * 50).ms)
        .scaleXY(begin: 0.9, duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isActive = false,
    bool isDestructive = false,
  }) {
    final activeColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.primary
        : AppColors.primaryDark;

    final color = isDestructive
        ? Colors.redAccent
        : isActive
        ? activeColor
        : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 4,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        tileColor: isActive
            ? activeColor.withValues(alpha: 0.1)
            : Colors.transparent,
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isActive || isDestructive ? color : null,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
