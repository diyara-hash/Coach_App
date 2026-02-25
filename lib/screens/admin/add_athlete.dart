import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../models/athlete.dart';
import '../../core/theme/app_theme.dart';

class AddAthlete extends StatefulWidget {
  final Athlete? athlete;

  const AddAthlete({super.key, this.athlete});

  @override
  State<AddAthlete> createState() => _AddAthleteState();
}

class _AddAthleteState extends State<AddAthlete> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.athlete != null) {
      _nameController.text = widget.athlete!.name;
      _emailController.text = widget.athlete!.email;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = DateTime.now().microsecondsSinceEpoch;
    String code = '';
    for (var i = 0; i < 6; i++) {
      code += chars[(rnd + i) % chars.length];
    }
    return 'TR-$code';
  }

  Future<void> _saveAthlete() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final coachId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final isEditing = widget.athlete != null;
      final inviteCode = isEditing
          ? widget.athlete!.inviteCode
          : _generateInviteCode();
      final athleteId = isEditing ? widget.athlete!.id : const Uuid().v4();

      await FirebaseFirestore.instance
          .collection('athletes')
          .doc(athleteId)
          .set({
            'id': athleteId,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'inviteCode': inviteCode,
            if (!isEditing) 'password': null,
            if (!isEditing) 'coachId': coachId,
            if (!isEditing) 'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      if (mounted) {
        if (!isEditing) {
          _showSuccessDialog(inviteCode);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Sporcu güncellendi!')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Hata: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sporcu Eklendi! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sporcunun kayıt olması için bu kodu paylaşın:',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Kod kopyalandı!')));
            },
            child: const Text('KOPYALA'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
            child: const Text('TAMAM'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.athlete != null ? 'SPORCUYU DÜZENLE' : 'YENİ SPORCU EKLE',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sporcu Bilgilerini Girin',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Davet kodu otomatik olarak oluşturulacaktır.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen isim giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen e-posta giriniz';
                  }
                  if (!value.contains('@')) {
                    return 'Geçerli bir e-posta giriniz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveAthlete,
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        widget.athlete != null
                            ? 'SPORCUYU GÜNCELLE'
                            : 'SPORCUYU KAYDET',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
