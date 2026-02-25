import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/athlete.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/elite_glass_card.dart';
import '../../core/utils/app_haptics.dart';
import '../../core/utils/pdf_report_generator.dart';
import '../../services/database_service.dart';

class StudentCrmPage extends StatefulWidget {
  final Athlete athlete;

  const StudentCrmPage({super.key, required this.athlete});

  @override
  State<StudentCrmPage> createState() => _StudentCrmPageState();
}

class _StudentCrmPageState extends State<StudentCrmPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _db = DatabaseService();

  // Personal Controllers
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _goalValue;
  String? _levelValue;

  // Health Controllers
  final _injuriesController = TextEditingController();
  final _medicationsController = TextEditingController();
  bool _doctorApproved = false;
  List<String> _selectedDiseases = [];

  // Nutrition Controllers
  String? _dietTypeValue;
  final _allergiesController = TextEditingController();
  final _dislikesController = TextEditingController();
  final _waterTargetController = TextEditingController();

  // Goals Controllers
  final _shortGoalController = TextEditingController();
  DateTime? _shortGoalDate;
  bool _shortGoalCompleted = false;

  final _mediumGoalController = TextEditingController();
  DateTime? _mediumGoalDate;
  bool _mediumGoalCompleted = false;

  final _longGoalController = TextEditingController();
  DateTime? _longGoalDate;
  bool _longGoalCompleted = false;

  final List<String> _goalOptions = [
    'Kilo verme',
    'Kas kazanma',
    'Sıkılaşma',
    'Kondisyon',
  ];
  final List<String> _levelOptions = ['Başlangıç', 'Orta', 'İleri'];
  final List<String> _dietOptions = [
    'Normal',
    'Vejetaryen',
    'Vegan',
    'Keto',
    'Intermittent',
  ];
  final List<String> _diseaseOptions = [
    'Diyabet',
    'Tansiyon',
    'Astım',
    'Kalp Rahatsızlığı',
    'Bel/Boyun Fıtığı',
  ];

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        AppHaptics.selectionClick();
        setState(() {}); // Update FloatingActionButton visibility
      }
    });
    _loadCrmData();
  }

  Future<void> _loadCrmData() async {
    try {
      final snap = await _db.getAthleteCrmProfile(widget.athlete.id).first;
      if (snap.exists && snap.data() != null) {
        final data = snap.data() as Map<String, dynamic>;

        final personal = data['personal'] ?? {};
        _ageController.text = personal['age']?.toString() ?? '';
        _jobController.text = personal['job'] ?? '';
        _phoneController.text = personal['phone'] ?? '';
        _goalValue = personal['goal'];
        _levelValue = personal['level'];

        final health = data['health'] ?? {};
        _injuriesController.text = health['injuries'] ?? '';
        _medicationsController.text = health['medications'] ?? '';
        _doctorApproved = health['doctorApproved'] ?? false;
        _selectedDiseases = List<String>.from(health['diseases'] ?? []);

        final nutrition = data['nutrition'] ?? {};
        _dietTypeValue = nutrition['dietType'];
        _allergiesController.text = nutrition['allergies'] ?? '';
        _dislikesController.text = nutrition['dislikes'] ?? '';
        _waterTargetController.text =
            nutrition['waterTarget']?.toString() ?? '';

        final goals = data['goals'] ?? {};
        final shortG = goals['short'] ?? {};
        _shortGoalController.text = shortG['title'] ?? '';
        _shortGoalDate = shortG['deadline'] != null
            ? DateTime.tryParse(shortG['deadline'])
            : null;
        _shortGoalCompleted = shortG['completed'] ?? false;

        final mediumG = goals['medium'] ?? {};
        _mediumGoalController.text = mediumG['title'] ?? '';
        _mediumGoalDate = mediumG['deadline'] != null
            ? DateTime.tryParse(mediumG['deadline'])
            : null;
        _mediumGoalCompleted = mediumG['completed'] ?? false;

        final longG = goals['long'] ?? {};
        _longGoalController.text = longG['title'] ?? '';
        _longGoalDate = longG['deadline'] != null
            ? DateTime.tryParse(longG['deadline'])
            : null;
        _longGoalCompleted = longG['completed'] ?? false;
      }
    } catch (e) {
      debugPrint('Error loading CRM data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    AppHaptics.lightImpact();

    try {
      final profileData = {
        'personal': {
          'age': _ageController.text.trim(),
          'job': _jobController.text.trim(),
          'phone': _phoneController.text.trim(),
          'goal': _goalValue,
          'level': _levelValue,
        },
        'health': {
          'injuries': _injuriesController.text.trim(),
          'medications': _medicationsController.text.trim(),
          'doctorApproved': _doctorApproved,
          'diseases': _selectedDiseases,
        },
        'nutrition': {
          'dietType': _dietTypeValue,
          'allergies': _allergiesController.text.trim(),
          'dislikes': _dislikesController.text.trim(),
          'waterTarget': _waterTargetController.text.trim(),
        },
        'goals': {
          'short': {
            'title': _shortGoalController.text.trim(),
            'deadline': _shortGoalDate?.toIso8601String(),
            'completed': _shortGoalCompleted,
          },
          'medium': {
            'title': _mediumGoalController.text.trim(),
            'deadline': _mediumGoalDate?.toIso8601String(),
            'completed': _mediumGoalCompleted,
          },
          'long': {
            'title': _longGoalController.text.trim(),
            'deadline': _longGoalDate?.toIso8601String(),
            'completed': _longGoalCompleted,
          },
        },
        'lastUpdated': DateTime.now().toIso8601String(),
      };

      await _db.updateAthleteCrmProfile(widget.athlete.id, profileData);

      if (mounted) {
        AppHaptics.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil başarıyla güncellendi!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        AppHaptics.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _ageController.dispose();
    _jobController.dispose();
    _phoneController.dispose();
    _injuriesController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _dislikesController.dispose();
    _waterTargetController.dispose();
    _shortGoalController.dispose();
    _mediumGoalController.dispose();
    _longGoalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.athlete.name} - CRM'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: Colors.redAccent,
            ),
            onPressed: () async {
              AppHaptics.lightImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF Raporu hazırlanıyor...')),
              );
              try {
                final profileSnap = await _db
                    .getAthleteCrmProfile(widget.athlete.id)
                    .first;
                final notesSnap = await _db
                    .getAthleteNotes(widget.athlete.id)
                    .first;
                final measurementsSnap = await _db
                    .getMeasurements(studentId: widget.athlete.id)
                    .first;

                final profileData =
                    profileSnap.data() as Map<String, dynamic>? ?? {};
                final notesData = notesSnap.docs
                    .map((d) => d.data() as Map<String, dynamic>)
                    .toList();
                final measurementsData = measurementsSnap;

                await PdfReportGenerator.generateAndShareReport(
                  athlete: widget.athlete,
                  crmProfile: profileData,
                  notes: notesData,
                  measurements: measurementsData,
                );
                AppHaptics.mediumImpact();
              } catch (e) {
                AppHaptics.heavyImpact();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Rapor hatası: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.7),
          tabs: const [
            Tab(text: 'PROFİL', icon: Icon(Icons.person_pin_rounded)),
            Tab(text: 'HEDEFLER', icon: Icon(Icons.flag_rounded)),
            Tab(text: 'DOSYALAR', icon: Icon(Icons.folder_special_rounded)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfileTab(),
                _buildGoalsTab(),
                _buildNotesFilesTab(),
              ],
            ),
      floatingActionButton:
          _tabController.index == 0 || _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _saveProfile,
              backgroundColor: AppColors.primary,
              icon: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.save_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
              label: Text(
                _isSaving ? 'Kaydediliyor...' : 'Değişiklikleri Kaydet',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          _buildPersonalCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildHealthCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildNutritionCard(),
          const SizedBox(height: AppSpacing.xxl * 2), // FAB spacing
        ],
      ),
    );
  }

  Widget _buildPersonalCard() {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Kişisel Bilgiler',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            height: AppSpacing.xl,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Yaş',
                    prefixIcon: Icon(Icons.cake_rounded, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _jobController,
                  decoration: const InputDecoration(
                    labelText: 'Meslek',
                    prefixIcon: Icon(Icons.work_outline_rounded, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Telefon',
              prefixIcon: Icon(Icons.phone_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _goalValue,
            decoration: const InputDecoration(
              labelText: 'Temel Hedef',
              prefixIcon: Icon(Icons.track_changes_rounded, size: 20),
            ),
            items: _goalOptions
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (val) => setState(() => _goalValue = val),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<String>(
            value: _levelValue,
            decoration: const InputDecoration(
              labelText: 'Deneyim Seviyesi',
              prefixIcon: Icon(Icons.fitness_center_rounded, size: 20),
            ),
            items: _levelOptions
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (val) => setState(() => _levelValue = val),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthCard() {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                color: Colors.redAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sağlık Geçmişi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            height: AppSpacing.xl,
          ),
          TextField(
            controller: _injuriesController,
            decoration: const InputDecoration(
              labelText: 'Geçmiş Yaralanmalar',
              prefixIcon: Icon(Icons.healing_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _medicationsController,
            decoration: const InputDecoration(
              labelText: 'Kullanılan İlaçlar',
              prefixIcon: Icon(Icons.medication_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Kronik Hastalıklar',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: _diseaseOptions.map((disease) {
              final isSelected = _selectedDiseases.contains(disease);
              return FilterChip(
                label: Text(disease),
                selected: isSelected,
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _selectedDiseases.add(disease);
                    } else {
                      _selectedDiseases.remove(disease);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            title: const Text('Doktor Onayı Var Mı?'),
            subtitle: const Text('Spora başlamasında sakınca yoktur.'),
            value: _doctorApproved,
            activeColor: AppColors.primary,
            onChanged: (val) => setState(() => _doctorApproved = val),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard() {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_menu_rounded,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Beslenme', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            height: AppSpacing.xl,
          ),
          DropdownButtonFormField<String>(
            value: _dietTypeValue,
            decoration: const InputDecoration(
              labelText: 'Diyet Tipi',
              prefixIcon: Icon(Icons.grass_rounded, size: 20),
            ),
            items: _dietOptions
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (val) => setState(() => _dietTypeValue = val),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _allergiesController,
            decoration: const InputDecoration(
              labelText: 'Alerjiler (Virgülle ayırın)',
              prefixIcon: Icon(Icons.warning_amber_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dislikesController,
            decoration: const InputDecoration(
              labelText: 'Sevilmeyen Yiyecekler',
              prefixIcon: Icon(Icons.thumb_down_alt_rounded, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _waterTargetController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Günlük Su Hedefi (Litre)',
              prefixIcon: Icon(Icons.water_drop_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsTab() {
    int totalGoals = 0;
    int completedGoals = 0;

    if (_shortGoalController.text.isNotEmpty) totalGoals++;
    if (_mediumGoalController.text.isNotEmpty) totalGoals++;
    if (_longGoalController.text.isNotEmpty) totalGoals++;

    if (_shortGoalCompleted && _shortGoalController.text.isNotEmpty)
      completedGoals++;
    if (_mediumGoalCompleted && _mediumGoalController.text.isNotEmpty)
      completedGoals++;
    if (_longGoalCompleted && _longGoalController.text.isNotEmpty)
      completedGoals++;

    double progress = totalGoals > 0 ? (completedGoals / totalGoals) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress Bar
          EliteGlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hedef İlerlemesi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                  color: AppColors.primary,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildGoalCard(
            title: 'Kısa Vadeli Hedef (1 Ay)',
            icon: Icons.flag_rounded,
            controller: _shortGoalController,
            date: _shortGoalDate,
            isCompleted: _shortGoalCompleted,
            onDateChanged: (d) => setState(() => _shortGoalDate = d),
            onCompletedChanged: (v) =>
                setState(() => _shortGoalCompleted = v ?? false),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildGoalCard(
            title: 'Orta Vadeli Hedef (3 Ay)',
            icon: Icons.flag_circle_rounded,
            controller: _mediumGoalController,
            date: _mediumGoalDate,
            isCompleted: _mediumGoalCompleted,
            onDateChanged: (d) => setState(() => _mediumGoalDate = d),
            onCompletedChanged: (v) =>
                setState(() => _mediumGoalCompleted = v ?? false),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildGoalCard(
            title: 'Uzun Vadeli Hedef (6+ Ay)',
            icon: Icons.emoji_events_rounded,
            controller: _longGoalController,
            date: _longGoalDate,
            isCompleted: _longGoalCompleted,
            onDateChanged: (d) => setState(() => _longGoalDate = d),
            onCompletedChanged: (v) =>
                setState(() => _longGoalCompleted = v ?? false),
          ),
          const SizedBox(height: AppSpacing.xxl * 2), // FAB spacing
        ],
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required TextEditingController controller,
    required DateTime? date,
    required bool isCompleted,
    required Function(DateTime?) onDateChanged,
    required Function(bool?) onCompletedChanged,
  }) {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (isCompleted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primary,
                ),
            ],
          ),
          Divider(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            height: AppSpacing.xl,
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Hedef Açıklaması',
              prefixIcon: Icon(Icons.track_changes_rounded, size: 20),
            ),
            onChanged: (v) => setState(() {}), // Update progress
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () async {
                    AppHaptics.selectionClick();
                    final selected = await showDatePicker(
                      context: context,
                      initialDate:
                          date ?? DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365 * 2),
                      ),
                    );
                    if (selected != null) onDateChanged(selected);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.1),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          date != null
                              ? '${date.day}/${date.month}/${date.year}'
                              : 'Tarih Seçin',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          CheckboxListTile(
            title: const Text('Hedef Tamamlandı'),
            value: isCompleted,
            activeColor: AppColors.primary,
            checkColor: Theme.of(context).colorScheme.onPrimary,
            onChanged: controller.text.isNotEmpty ? onCompletedChanged : null,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  Widget _buildNotesFilesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Koç Notları',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              ElevatedButton.icon(
                onPressed: _showAddNoteModal,
                icon: Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                label: Text(
                  'Yeni Not',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 36),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getAthleteNotes(widget.athlete.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const CircularProgressIndicator();
              final notes = snapshot.data?.docs ?? [];
              if (notes.isEmpty)
                return Text(
                  'Henüz not eklenmedi.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final data = notes[index].data() as Map<String, dynamic>;
                  final dateRaw = data['date'];
                  final date = dateRaw != null
                      ? DateTime.tryParse(dateRaw) ?? DateTime.now()
                      : DateTime.now();
                  return EliteGlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                            if (data['priority'] == true)
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.orangeAccent,
                                size: 16,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          data['content'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ).marginOnly(bottom: AppSpacing.sm);
                },
              );
            },
          ),

          const SizedBox(height: AppSpacing.xxl),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dosyalar',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.upload_file_rounded,
                  color: AppColors.primary,
                ),
                color: Theme.of(context).colorScheme.surface,
                onSelected: (type) => _uploadFile(type),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'Doktor Raporu',
                    child: Text('Dr. Raporu Yükle'),
                  ),
                  const PopupMenuItem(
                    value: 'Diyet Listesi',
                    child: Text('Diyet Listesi Yükle'),
                  ),
                  const PopupMenuItem(
                    value: 'Diğer',
                    child: Text('Diğer Dosya Yükle'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          StreamBuilder<QuerySnapshot>(
            stream: _db.getAthleteFiles(widget.athlete.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const CircularProgressIndicator();
              final files = snapshot.data?.docs ?? [];
              if (files.isEmpty)
                return Text(
                  'Henüz dosya yüklenmedi.',
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index].data() as Map<String, dynamic>;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.file_present_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      file['name'] ?? 'İsimsiz Dosya',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      file['type'] ?? 'Belge',
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        AppHaptics.selectionClick();
                        // TODO: Open URL
                      },
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl * 2), // FAB spacer
        ],
      ),
    );
  }

  void _showAddNoteModal() {
    final noteController = TextEditingController();
    bool isPriority = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Yeni Koç Notu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Durum, sakatlık, gelişim notları...',
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                SwitchListTile(
                  title: const Text('Önemli Not (⭐)'),
                  value: isPriority,
                  activeColor: Colors.orangeAccent,
                  onChanged: (v) => setModalState(() => isPriority = v),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    if (noteController.text.trim().isEmpty) return;
                    _db.addAthleteNote(widget.athlete.id, {
                      'content': noteController.text.trim(),
                      'priority': isPriority,
                      'date': DateTime.now().toIso8601String(),
                    });
                    Navigator.pop(context);
                    AppHaptics.mediumImpact();
                  },
                  child: const Text('Notu Ekle'),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _uploadFile(String documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles();
      if (result != null && result.files.single.path != null) {
        AppHaptics.lightImpact();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dosya yükleniyor...')));

        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        Reference ref = FirebaseStorage.instance.ref().child(
          'users/${widget.athlete.id}/files/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        );
        await ref.putFile(file);
        String downloadUrl = await ref.getDownloadURL();

        await _db.addAthleteFile(widget.athlete.id, {
          'name': fileName,
          'type': documentType,
          'url': downloadUrl,
        });

        if (mounted) {
          AppHaptics.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dosya başarıyla yüklendi!'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        AppHaptics.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Yükleme hatası: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}

extension MarginExtension on Widget {
  Widget marginOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Container(
      margin: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }
}
