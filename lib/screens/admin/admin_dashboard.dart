import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'add_athlete.dart';
import 'program_builder.dart';
import 'program_list.dart';
import 'athlete_list.dart';
import '../../core/theme/app_theme.dart';

import '../../features/admin/admin_measurements_panel.dart';

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
        backgroundColor: AppColors.surface,
        child: Column(
          children: [
            DrawerHeader(
              decoration: AppTheme.primaryGradient,
              child: const Center(
                child: Text(
                  'MYCOACH PRO',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(
                Icons.dashboard_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Dashboard'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(
                Icons.people_alt_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Sporcular'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AthleteList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.straighten_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Öğrenci Ölçüleri'),
              onTap: () {
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
            ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text('Çıkış Yap'),
              onTap: () {
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
              child: GridView.count(
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
                        MaterialPageRoute(builder: (_) => const AthleteList()),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Öğrenci Ölçüleri',
                    Icons.straighten_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminMeasurementsPanel(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    context,
                    'Programlarım',
                    Icons.fitness_center_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProgramList()),
                      );
                    },
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
                  ),
                  _buildMenuCard(
                    context,
                    'Yeni Sporcu',
                    Icons.person_add_alt_1_rounded,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AddAthlete()),
                      );
                    },
                  ),
                  _buildMenuCard(context, 'Mesajlar', Icons.forum_rounded, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AthleteList()),
                    );
                  }),
                ],
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
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.primary),
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
      ),
    );
  }
}
