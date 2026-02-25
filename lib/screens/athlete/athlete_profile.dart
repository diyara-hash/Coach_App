import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/athlete.dart';
import '../../services/database_service.dart';
import '../auth/login_screen.dart';
import '../../main.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/elite_glass_card.dart';
import '../../core/utils/app_haptics.dart';
import 'package:flutter/cupertino.dart';

class AthleteProfile extends StatefulWidget {
  final String athleteId;
  const AthleteProfile({super.key, required this.athleteId});

  @override
  State<AthleteProfile> createState() => _AthleteProfileState();
}

class _AthleteProfileState extends State<AthleteProfile> {
  final _db = DatabaseService();
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showPasswordDialog() {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şifre Değiştir'),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Yeni Şifreniz',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İPTAL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.isNotEmpty) {
                await _db.updateAthletePassword(
                  widget.athleteId,
                  passwordController.text,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Şifre güncellendi'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                }
              }
            },
            child: const Text('GÜNCELLE'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    await _db.updateAthlete(widget.athleteId, {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    });
    setState(() => _isEditing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil güncellendi'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFİLİM'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: () => setState(() => _isEditing = true),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('athletes')
            .doc(widget.athleteId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Sporcu bilgisi bulunamadı'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final athlete = Athlete.fromMap(data, documentId: snapshot.data!.id);

          if (!_isEditing) {
            _nameController.text = athlete.name;
            _phoneController.text = athlete.phone ?? '';
            _bioController.text = athlete.bio ?? '';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 4),
                    boxShadow: [AppColors.emeraldGlow],
                  ),
                  child: CircleAvatar(
                    radius: 60, // 120px diameter
                    backgroundColor: AppColors.surfaceElevated,
                    child: Text(
                      athlete.name.isNotEmpty
                          ? athlete.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Premium Üye',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_isEditing) ...[
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Biyografi',
                      prefixIcon: Icon(Icons.info_outline_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _isEditing = false),
                          child: const Text('İPTAL'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _saveProfile,
                          child: const Text('KAYDET'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Text(
                    athlete.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    athlete.email,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),

                  // Info Cards
                  _buildInfoItem(
                    Icons.phone_rounded,
                    'Telefon',
                    athlete.phone ?? 'Girilmemiş',
                  ),
                  _buildInfoItem(
                    Icons.info_outline_rounded,
                    'Hakkımda',
                    athlete.bio ?? 'Girilmemiş',
                  ),
                  _buildInfoItem(
                    Icons.vpn_key_rounded,
                    'Davet Kodu',
                    athlete.inviteCode,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Settings List
                  EliteGlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          title: const Text(
                            'Şifre Değiştir',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          onTap: _showPasswordDialog,
                        ),
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                          indent: 64,
                        ),
                        ListenableBuilder(
                          listenable: themeProvider,
                          builder: (context, _) {
                            final isDark =
                                themeProvider.themeMode == ThemeMode.dark;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(
                                    alpha: 0.15,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  color: AppColors.accent,
                                ),
                              ),
                              title: const Text(
                                'Karanlık Mod',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              trailing: CupertinoSwitch(
                                value: isDark,
                                activeColor: AppColors.primary,
                                onChanged: (val) {
                                  themeProvider.setTheme(
                                    val ? ThemeMode.dark : ThemeMode.light,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                          indent: 64,
                        ),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.sm,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.error,
                            ),
                          ),
                          title: const Text(
                            'Çıkış Yap',
                            style: TextStyle(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return EliteGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
