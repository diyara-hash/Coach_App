import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import 'student_detail_page.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';

class AdminMeasurementsPanel extends StatefulWidget {
  const AdminMeasurementsPanel({super.key});

  @override
  State<AdminMeasurementsPanel> createState() => _AdminMeasurementsPanelState();
}

class _AdminMeasurementsPanelState extends State<AdminMeasurementsPanel> {
  final _db = DatabaseService();
  bool? _isReadFilter; // null = Tümü, false = Okunmamış, true = Okunmuş
  String _searchQuery = '';

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Öğrenci Ara...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _db.getMeasurements(isRead: _isReadFilter),
              builder: (context, snapshot) {
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
                          onPressed: () {},
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: 5,
                    itemBuilder: (context, index) => const SkeletonListTile(),
                  );
                }

                var measurements = snapshot.data ?? [];

                if (_searchQuery.isNotEmpty) {
                  measurements = measurements.where((m) {
                    final name =
                        m['studentName']?.toString().toLowerCase() ?? '';
                    return name.contains(_searchQuery);
                  }).toList();
                }

                if (measurements.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.straighten_rounded,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.3),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Bulunamadı',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      await Future.delayed(const Duration(milliseconds: 500)),
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
                          itemCount: measurements.length,
                          itemBuilder: (context, index) {
                            final m = measurements[index];
                            final values =
                                m['measurements'] as Map<String, dynamic>;
                            final date = (m['date'] as dynamic).toDate();
                            final submittedAt = (m['submittedAt'] as dynamic)
                                .toDate();
                            final isRead = m['isRead'] ?? false;

                            final studentName =
                                m['studentName']?.toString().toUpperCase() ??
                                'İSİMSİZ';
                            final studentId = m['studentId']?.toString() ?? '';

                            return Card(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  if (studentId.isNotEmpty) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => StudentDetailPage(
                                          athleteId: studentId,
                                          athleteName: studentName,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
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
                                                studentName,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                              ),
                                              Text(
                                                'Ölçüm: ${DateFormat('dd.MM.yyyy').format(date)}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.labelSmall,
                                              ),
                                            ],
                                          ),
                                          if (!isRead)
                                            Row(
                                              children: [
                                                Container(
                                                  width: 8,
                                                  height: 8,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color: Colors.redAccent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                ),
                                                const SizedBox(width: 4),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.redAccent
                                                        .withValues(alpha: 0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'YENİ',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      GridView.count(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        childAspectRatio: 2.2,
                                        mainAxisSpacing: AppSpacing.sm,
                                        crossAxisSpacing: AppSpacing.sm,
                                        children: [
                                          _buildValueItem(
                                            'BOY',
                                            '${values['height']}cm',
                                          ),
                                          _buildValueItem(
                                            'KİLO',
                                            '${values['weight']}kg',
                                          ),
                                          _buildValueItem(
                                            'BEL',
                                            '${values['waist']}cm',
                                          ),
                                          _buildValueItem(
                                            'KALÇA',
                                            '${values['hips']}cm',
                                          ),
                                          _buildValueItem(
                                            'GÖĞÜS',
                                            '${values['chest']}cm',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Gönderildi: ${DateFormat('HH:mm').format(submittedAt)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(fontSize: 10),
                                          ),
                                          if (!isRead)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                _db.markMeasurementAsRead(
                                                  m['id'],
                                                );
                                                AppHaptics.success();
                                                AppSnackBar.showSuccess(
                                                  context,
                                                  'Ölçüm okundu olarak işaretlendi',
                                                );
                                              },
                                              icon: const Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                size: 18,
                                              ),
                                              label: const Text('GÖRÜLDÜ'),
                                              style: ElevatedButton.styleFrom(
                                                minimumSize: const Size(
                                                  100,
                                                  36,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                    ),
                                              ),
                                            )
                                          else
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle_rounded,
                                                  size: 16,
                                                  color: Theme.of(
                                                    context,
                                                  ).textTheme.bodyMedium?.color,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'OKUNDU',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.color,
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueItem(String label, String value) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(
                context,
              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
