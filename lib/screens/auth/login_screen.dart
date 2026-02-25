import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import '../athlete/athlete_home.dart';
import '../../core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  bool _hasSavedCredentials = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricsAndCredentials();
  }

  Future<void> _checkBiometricsAndCredentials() async {
    try {
      _canCheckBiometrics =
          await auth.canCheckBiometrics || await auth.isDeviceSupported();
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('inviteCode');
      final savedPassword = prefs.getString('password');

      if (savedCode != null && savedPassword != null) {
        setState(() {
          _hasSavedCredentials = true;
          _rememberMe = true;
          _codeController.text = savedCode;
          _passwordController.text = savedPassword;
        });
      } else {
        setState(
          () {},
        ); // trigger rebuild to show/hide biometric button if needed
      }
    } catch (e) {
      debugPrint("Biometric Check Error: $e");
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await auth.authenticate(
        localizedReason: 'Giriş yapmak için kimliğinizi doğrulayın',
      );
      if (authenticated) {
        _login();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Doğrulama hatası: $e')));
    }
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      final code = _codeController.text.trim().toUpperCase();

      final query = await FirebaseFirestore.instance
          .collection('athletes')
          .where('inviteCode', isEqualTo: code)
          .get();

      if (query.docs.isEmpty) {
        if (code == 'ADMIN' && _passwordController.text == 'admin123') {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDashboard()),
          );
          return;
        }

        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Geçersiz kod!')));
        return;
      }

      final athlete = query.docs.first.data();
      final savedPassword = athlete['password'];
      final enteredPassword = _passwordController.text;

      if (savedPassword == null || savedPassword.isEmpty) {
        await FirebaseFirestore.instance
            .collection('athletes')
            .doc(query.docs.first.id)
            .update({'password': enteredPassword});
      } else if (savedPassword != enteredPassword) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Hatalı şifre!')));
        return;
      }

      if (_rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('inviteCode', code);
        await prefs.setString('password', enteredPassword);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('inviteCode');
        await prefs.remove('password');
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AthleteHome(athleteId: query.docs.first.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_main.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.9),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeIn,
                    builder: (context, value, child) {
                      return Opacity(opacity: value, child: child);
                    },
                    child:
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.8),
                                blurRadius: 60,
                                spreadRadius: 10,
                              ),
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/splash_logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ).animate().scale(
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                        'MYCOACH',
                        style: Theme.of(context).textTheme.displayLarge,
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 200.ms)
                      .slideY(begin: 0.2),
                  Text(
                        'PERFORMANCE & ELITE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 300.ms)
                      .slideY(begin: 0.2),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _codeController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(
                                hintText: 'Davet Kodunuz',
                                prefixIcon: Icon(Icons.vpn_key_outlined),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: 'Şifreniz',
                                prefixIcon: const Icon(
                                  Icons.lock_outline_rounded,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: Checkbox(
                                    value: _rememberMe,
                                    onChanged: (value) {
                                      setState(() {
                                        _rememberMe = value ?? false;
                                      });
                                    },
                                    activeColor: AppColors.primary,
                                    checkColor: Colors.black,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Text(
                                  'Beni Hatırla',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 56,
                                    decoration: AppTheme.primaryGradient,
                                    child: ElevatedButton(
                                      onPressed: _isLoading ? null : _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        minimumSize: Size.zero,
                                      ),
                                      child: _isLoading
                                          ? const CircularProgressIndicator(
                                              color: Colors.black,
                                            )
                                          : const Text('GİRİŞ YAP'),
                                    ),
                                  ),
                                ),
                                if (_canCheckBiometrics &&
                                    _hasSavedCredentials) ...[
                                  const SizedBox(width: AppSpacing.md),
                                  InkWell(
                                    onTap: _authenticateWithBiometrics,
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceElevated,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                        boxShadow: [AppColors.emeraldGlow],
                                      ),
                                      child: const Icon(
                                        Icons.fingerprint_rounded,
                                        color: AppColors.primary,
                                        size: 32,
                                      ),
                                    ),
                                  ).animate().fade().scale(),
                                ],
                              ],
                            ),
                          ],
                        ),
                      )
                      .animate()
                      .fade(duration: 600.ms, delay: 400.ms)
                      .slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
