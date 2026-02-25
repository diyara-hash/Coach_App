import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/measurement.dart';
import '../student/measurement_history.dart';
import '../student/progress_charts.dart';

class StudentDetailPage extends StatelessWidget {
  final String athleteId;
  final String athleteName;

  const StudentDetailPage({
    super.key,
    required this.athleteId,
    required this.athleteName,
  });

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(athleteName.toUpperCase()),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ÖLÇÜ GEÇMİŞİ'),
              Tab(text: 'İLERLEME GRAFİĞİ'),
            ],
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            // Top Summary Card
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: DatabaseService().getMeasurements(studentId: athleteId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    child: Center(child: Text("Henüz ölçü kaydı bulunmuyor.")),
                  );
                }

                final items = snapshot.data!;
                final latestMap = items.first;
                final latest = BodyMeasurement.fromMap(
                  latestMap,
                  latestMap['id'],
                );

                final bmi = _calculateBMI(latest.weight, latest.height);
                final bmiColor = _getBMIColor(bmi);

                return Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryItem(
                        context,
                        'Son Kayıt',
                        DateFormat('dd MMM yyyy').format(latest.date),
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                      ),
                      _buildSummaryItem(
                        context,
                        'Son BMI',
                        bmi.toStringAsFixed(1),
                        valueColor: bmiColor,
                      ),
                      Container(
                        width: 1,
                        height: 40,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                      ),
                      _buildSummaryItem(
                        context,
                        'Toplam Kayıt',
                        '${items.length}',
                      ),
                    ],
                  ),
                );
              },
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  MeasurementHistory(athleteId: athleteId),
                  ProgressCharts(athleteId: athleteId),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Placeholder for assigning a new program
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Yakında eklenecek: Yeni Program Ekle'),
              ),
            );
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.black),
          label: const Text(
            'YENİ PROGRAM',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
