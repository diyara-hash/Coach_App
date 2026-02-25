import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/measurement.dart';
import 'measurement_history.dart';
import 'progress_charts.dart';
import '../measurements/student_measurement_form.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/elite_glass_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import '../../models/athlete.dart';
import '../../core/utils/app_haptics.dart';

class StudentDashboard extends StatelessWidget {
  final String athleteId;
  const StudentDashboard({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ÖLÇÜLERİM'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ÖZET'),
              Tab(text: 'GEÇMİŞ'),
              Tab(text: 'GRAFİK'),
            ],
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: TabBarView(
          children: [
            _SummaryTab(athleteId: athleteId),
            MeasurementHistory(athleteId: athleteId),
            ProgressCharts(athleteId: athleteId),
          ],
        ),
      ),
    );
  }
}

class _SummaryTab extends StatelessWidget {
  final String athleteId;
  const _SummaryTab({required this.athleteId});

  double _calculateBMI(double weight, double height) {
    if (height == 0) return 0;
    final hInMeters = height / 100;
    return weight / (hInMeters * hInMeters);
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.yellow.shade600;
    if (bmi >= 18.5 && bmi < 25) return AppColors.primary;
    if (bmi >= 25 && bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Zayıf";
    if (bmi >= 18.5 && bmi < 25) return "Normal";
    if (bmi >= 25 && bmi < 30) return "Fazla Kilolu";
    return "Obez";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getMeasurements(studentId: athleteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SingleChildScrollView(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                SkeletonCard(),
                SizedBox(height: AppSpacing.lg),
                SkeletonStatsRow(),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        if (items.isEmpty) {
          return _buildEmptyState(context);
        }

        final currentStr = items.first;
        final current = BodyMeasurement.fromMap(currentStr, currentStr['id']);

        BodyMeasurement? previous;
        if (items.length > 1) {
          final prevStr = items[1];
          previous = BodyMeasurement.fromMap(prevStr, prevStr['id']);
        }

        final bmi = _calculateBMI(current.weight, current.height);
        final bmiColor = _getBMIColor(bmi);
        final bmiCategory = _getBMICategory(bmi);

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          onRefresh: () async {
            AppHaptics.lightImpact();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Section
                FutureBuilder<Athlete?>(
                  future: DatabaseService().getAthleteById(athleteId),
                  builder: (context, snapshot) {
                    final athlete = snapshot.data;
                    final name = athlete?.name.split(' ').first ?? 'Sporcu';
                    final days = athlete != null
                        ? DateTime.now().difference(athlete.createdAt).inDays
                        : 0;

                    return Container(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merhaba $name! 👋',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            days == 0
                                ? 'Sistemdeki ilk günün, harika bir başlangıç!'
                                : 'Son ölçümlerinden bu yana harika ilerliyorsun. ($days gün geçti)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color
                                      ?.withOpacity(0.7),
                                ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Quick Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          DefaultTabController.of(context).animateTo(1);
                        },
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text(
                          'Son Ölçü',
                          style: TextStyle(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSurface,
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  StudentMeasurementForm(athleteId: athleteId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Yeni Ekle',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Hero Card (BMI)
                Tilt(
                  child: EliteGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Text(
                          'BMI ENDEKSİ',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            letterSpacing: 1.5,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: bmiColor,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: bmiColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: bmiColor.withAlpha(50)),
                          ),
                          child: Text(
                            bmiCategory.toUpperCase(),
                            style: TextStyle(
                              color: bmiColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
                const SizedBox(height: AppSpacing.lg),

                // Summary Card
                Tilt(
                      child: EliteGlassCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'SON ÖLÇÜM',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7),
                                    letterSpacing: 1.5,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(current.date),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _buildComparisonRow(
                              'Kilo',
                              current.weight,
                              previous?.weight,
                              'kg',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.1),
                              ),
                            ),
                            _buildComparisonRow(
                              'Bel',
                              current.waist,
                              previous?.waist,
                              'cm',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.1),
                              ),
                            ),
                            _buildComparisonRow(
                              'Kalça',
                              current.hips,
                              previous?.hips,
                              'cm',
                            ),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .fade(duration: 500.ms, delay: 100.ms)
                    .slideY(begin: 0.1),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComparisonRow(
    String label,
    double current,
    double? previous,
    String unit,
  ) {
    if (previous == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '$current $unit',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    final diff = current - previous;
    final isPositive = diff > 0;
    final isNegative = diff < 0;
    final isZero = diff == 0;

    // Logic: for weight/waist usually going down is good for some, up for others.
    // We'll just use general colors:
    // Decrease -> Green, Increase -> Red. But it depends on the goal. Let's just use neutral visually or simple red/green.
    Color trendColor = isZero
        ? Colors.grey
        : (isNegative ? Colors.greenAccent : Colors.redAccent);
    IconData trendIcon = isZero
        ? Icons.horizontal_rule
        : (isNegative ? Icons.arrow_downward : Icons.arrow_upward);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Text(
              '$current $unit',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trendColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    '${isPositive ? '+' : ''}${diff.toStringAsFixed(1)}$unit',
                    style: TextStyle(
                      color: trendColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(trendIcon, color: trendColor, size: 14),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 80,
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.24),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Henüz ölçü kaydın yok',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.add),
            label: const Text('İlk Ölçümünü Ekle'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudentMeasurementForm(athleteId: athleteId),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
