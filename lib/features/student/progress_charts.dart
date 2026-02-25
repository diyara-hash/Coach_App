import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../models/measurement.dart';

class ProgressCharts extends StatelessWidget {
  final String athleteId;
  const ProgressCharts({super.key, required this.athleteId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: DatabaseService().getMeasurements(studentId: athleteId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return Center(
            child: Text(
              'Grafik oluşturmak için henüz veri yok.',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          );
        }

        // Sort ascending for chart layout
        final measurements =
            items.map((e) => BodyMeasurement.fromMap(e, e['id'])).toList()
              ..sort((a, b) => a.date.compareTo(b.date));

        // Take last 10
        final recent = measurements.length > 10
            ? measurements.sublist(measurements.length - 10)
            : measurements;

        return DefaultTabController(
          length: 3,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: 'KİLO'),
                  Tab(text: 'BEL'),
                  Tab(text: 'TÜMÜ'),
                ],
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.54),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildChartTab(
                      context,
                      recent,
                      'weight',
                      AppColors.primary,
                      'kg',
                    ),
                    _buildChartTab(
                      context,
                      recent,
                      'waist',
                      Colors.orange,
                      'cm',
                    ),
                    _buildAllChartTab(context, recent),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartTab(
    BuildContext context,
    List<BodyMeasurement> data,
    String field,
    Color color,
    String unit,
  ) {
    if (data.isEmpty) return const SizedBox();

    final spots = data.asMap().entries.map((e) {
      double yVal = 0;
      if (field == 'weight') yVal = e.value.weight;
      if (field == 'waist') yVal = e.value.waist;
      return FlSpot(e.key.toDouble(), yVal);
    }).toList();

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) - 5;
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) + 5;
    if (minY < 0) minY = 0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (value) => const FlLine(strokeWidth: 1),
            getDrawingVerticalLine: (value) => const FlLine(strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('d MMM').format(data[index].date),
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.54),
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.54),
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            ),
          ),
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: color.withAlpha(50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllChartTab(BuildContext context, List<BodyMeasurement> data) {
    if (data.isEmpty) return const SizedBox();

    final weightSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weight))
        .toList();
    final waistSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.waist))
        .toList();
    final hipsSpots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.hips))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(context, 'Kilo', Colors.blueAccent),
              const SizedBox(width: AppSpacing.md),
              _buildLegend(context, 'Bel', AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              _buildLegend(context, 'Kalça', Colors.orange),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('d MMM').format(data[index].date),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.54),
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.1),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: weightSpots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: waistSpots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: hipsSpots,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(
              context,
            ).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
