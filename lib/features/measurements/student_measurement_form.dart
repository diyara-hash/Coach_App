import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';
import '../../core/utils/haptics.dart';
import '../../core/widgets/app_snackbar.dart';

class StudentMeasurementForm extends StatefulWidget {
  final String athleteId;
  const StudentMeasurementForm({super.key, required this.athleteId});

  @override
  State<StudentMeasurementForm> createState() => _StudentMeasurementFormState();
}

class _StudentMeasurementFormState extends State<StudentMeasurementForm> {
  final _formKey = GlobalKey<FormState>();
  final _db = DatabaseService();

  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _chestController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  int _filledSteps = 0;

  @override
  void initState() {
    super.initState();
    _heightController.addListener(_updateProgress);
    _weightController.addListener(_updateProgress);
    _waistController.addListener(_updateProgress);
    _hipsController.addListener(_updateProgress);
    _chestController.addListener(_updateProgress);
  }

  void _updateProgress() {
    int count = 0;
    if (_heightController.text.isNotEmpty) count++;
    if (_weightController.text.isNotEmpty) count++;
    if (_waistController.text.isNotEmpty) count++;
    if (_hipsController.text.isNotEmpty) count++;
    if (_chestController.text.isNotEmpty) count++;

    if (count != _filledSteps) {
      setState(() {
        _filledSteps = count;
      });
    }
  }

  @override
  void dispose() {
    _heightController.removeListener(_updateProgress);
    _weightController.removeListener(_updateProgress);
    _waistController.removeListener(_updateProgress);
    _hipsController.removeListener(_updateProgress);
    _chestController.removeListener(_updateProgress);

    _heightController.dispose();
    _weightController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _chestController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      AppHaptics.error();
      AppSnackBar.showError(context, 'Lütfen formdaki hataları düzeltin');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final athlete = await _db.getAthleteById(widget.athleteId);

      await _db.addMeasurement({
        'studentId': widget.athleteId,
        'studentName': athlete?.name ?? 'Bilinmeyen Sporcu',
        'measurements': {
          'height': double.parse(_heightController.text),
          'weight': double.parse(_weightController.text),
          'waist': double.parse(_waistController.text),
          'hips': double.parse(_hipsController.text),
          'chest': double.parse(_chestController.text),
        },
        'date': _selectedDate,
        'submittedAt': DateTime.now(),
        'isRead': false,
      });

      if (mounted) {
        AppHaptics.heavy();
        AppSnackBar.showSuccess(
          context,
          'Ölçüleriniz koçunuza başarıyla gönderildi',
        );
        // Clear form
        _heightController.clear();
        _weightController.clear();
        _waistController.clear();
        _hipsController.clear();
        _chestController.clear();
        setState(() => _selectedDate = DateTime.now());
      }
    } catch (e) {
      if (mounted) {
        AppHaptics.error();
        AppSnackBar.showError(context, 'Hata: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VÜCUT ÖLÇÜLERİM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Ölçülerinizi Girin',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Gelişiminizi takip edebilmemiz için değerleri doğru girin.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'İlerleme',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Adım $_filledSteps/5',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              LinearProgressIndicator(
                value: _filledSteps / 5,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.1),
                color: AppColors.primary,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),

              const SizedBox(height: AppSpacing.xl),

              _buildInputField(
                controller: _heightController,
                label: 'Boy (cm)',
                icon: Icons.straighten_rounded,
                hint: '180',
                min: 100,
                max: 250,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInputField(
                controller: _weightController,
                label: 'Kilo (kg)',
                icon: Icons.fitness_center_rounded,
                hint: '75',
                min: 30,
                max: 300,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInputField(
                controller: _waistController,
                label: 'Bel (cm)',
                icon: Icons.accessibility_new_rounded,
                hint: '80',
                min: 40,
                max: 200,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInputField(
                controller: _hipsController,
                label: 'Kalça (cm)',
                icon: Icons.adjust_rounded,
                hint: '95',
                min: 50,
                max: 250,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildInputField(
                controller: _chestController,
                label: 'Göğüs (cm)',
                icon: Icons.panorama_fish_eye_rounded,
                hint: '100',
                min: 50,
                max: 200,
              ),
              const SizedBox(height: AppSpacing.md),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ölçüm Tarihi',
                    prefixIcon: Icon(Icons.calendar_today_rounded),
                  ),
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Container(
                height: 56,
                decoration: AppTheme.primaryGradient,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : const Text('KAYDET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    required double min,
    required double max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Lütfen bu alanı doldurun';
        final val = double.tryParse(value);
        if (val == null) return 'Lütfen geçerli bir sayı girin';
        if (val < min || val > max) return '$min - $max arası bir değer girin';
        return null;
      },
    );
  }
}
