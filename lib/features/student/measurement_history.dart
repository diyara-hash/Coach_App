import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/measurement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/elite_glass_card.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MeasurementHistory extends StatelessWidget {
  final String athleteId;
  const MeasurementHistory({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getMeasurements(studentId: athleteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: 4,
            itemBuilder: (context, index) => const SkeletonListTile(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bir hata oluştu',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () {
                    // Triggers a rebuild / re-subscription if we were handling state, but Stream handles itself.
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          );
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.24),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Henüz kayıt yok',
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: AppColors.primary,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Son güncelleme: ${DateFormat('HH:mm').format(DateTime.now())}',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.54),
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final map = items[index];
                    final measurement = BodyMeasurement.fromMap(map, map['id']);

                    double bmi = 0;
                    if (measurement.height > 0) {
                      bmi =
                          measurement.weight /
                          ((measurement.height / 100) *
                              (measurement.height / 100));
                    }

                    return EliteGlassCard(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.lg),
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
                                        DateFormat(
                                          'dd MMM',
                                        ).format(measurement.date),
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      Text(
                                        DateFormat(
                                          'yyyy',
                                        ).format(measurement.date),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.color
                                              ?.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        onPressed: () => _confirmDelete(
                                          context,
                                          measurement.id,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(
                                  color: AppColors.border,
                                  height: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatColumn(
                                    context,
                                    'Boy',
                                    '${measurement.height.toStringAsFixed(0)} cm',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'Kilo',
                                    '${measurement.weight.toStringAsFixed(1)} kg',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'BMI',
                                    bmi.toStringAsFixed(1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatColumn(
                                    context,
                                    'Bel',
                                    '${measurement.waist.toStringAsFixed(1)} cm',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'Kalça',
                                    '${measurement.hips.toStringAsFixed(1)} cm',
                                  ),
                                  _buildStatColumn(
                                    context,
                                    'Göğüs',
                                    '${measurement.chest.toStringAsFixed(1)} cm',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fade(duration: 400.ms, delay: (50 * index).ms)
                        .slideX(begin: 0.05);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.54),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, String measurementId) {
    AppHaptics.warning();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: const Text('Ölçümü Sil'),
        content: const Text(
          'Bu ölçüm kaydını silmek istediğine emin misin? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İPTAL',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('measurements')
                  .doc(measurementId)
                  .delete();
              Navigator.pop(ctx);
              AppHaptics.success();
              AppSnackBar.showSuccess(context, 'Ölçüm silindi');
            },
            child: const Text('SİL', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
