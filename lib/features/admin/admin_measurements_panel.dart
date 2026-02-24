import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';

class AdminMeasurementsPanel extends StatefulWidget {
  const AdminMeasurementsPanel({super.key});

  @override
  State<AdminMeasurementsPanel> createState() => _AdminMeasurementsPanelState();
}

class _AdminMeasurementsPanelState extends State<AdminMeasurementsPanel> {
  final _db = DatabaseService();
  bool? _isReadFilter; // null = Tümü, false = Okunmamış, true = Okunmuş

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ÖĞRENCİ ÖLÇÜLERİ'),
        actions: [
          PopupMenuButton<bool?>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (value) => setState(() => _isReadFilter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('Tümü')),
              const PopupMenuItem(value: false, child: Text('Okunmamış')),
              const PopupMenuItem(value: true, child: Text('Okunmuş')),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _db.getMeasurements(isRead: _isReadFilter),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final measurements = snapshot.data ?? [];

          if (measurements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.straighten_rounded,
                    size: 80,
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Henüz ölçüm bulunmuyor',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: measurements.length,
            itemBuilder: (context, index) {
              final m = measurements[index];
              final values = m['measurements'] as Map<String, dynamic>;
              final date = (m['date'] as dynamic).toDate();
              final submittedAt = (m['submittedAt'] as dynamic).toDate();
              final isRead = m['isRead'] ?? false;

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m['studentName']?.toString().toUpperCase() ??
                                    'İSİMSİZ',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                              ),
                              Text(
                                'Ölçüm: ${DateFormat('dd.MM.yyyy').format(date)}',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          if (!isRead)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YENİ',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio: 2,
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        children: [
                          _buildValueItem('BOY', '${values['height']}cm'),
                          _buildValueItem('KİLO', '${values['weight']}kg'),
                          _buildValueItem('BEL', '${values['waist']}cm'),
                          _buildValueItem('KALÇA', '${values['hips']}cm'),
                          _buildValueItem('GÖĞÜS', '${values['chest']}cm'),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gönderildi: ${DateFormat('HH:mm').format(submittedAt)}',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(fontSize: 10),
                          ),
                          if (!isRead)
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _db.markMeasurementAsRead(m['id']),
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                size: 18,
                              ),
                              label: const Text('GÖRÜLDÜ'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            )
                          else
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'OKUNDU',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildValueItem(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
