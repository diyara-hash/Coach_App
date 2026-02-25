import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import '../athlete/athlete_home.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Wait for the animation to complete and a bit more
    await Future.delayed(const Duration(milliseconds: 2800));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    Widget nextScreen;

    if (user != null) {
      if (user.email == 'admin@mycoach.com') {
        nextScreen = const AdminDashboard();
      } else {
        nextScreen = AthleteHome(athleteId: user.uid);
      }
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg_main.png', fit: BoxFit.cover),
          ).animate().fade(duration: 800.ms),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 40,
                            spreadRadius: 5,
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
                    )
                    .animate()
                    .scale(duration: 1000.ms, curve: Curves.easeOutBack)
                    .then()
                    .shimmer(duration: 1200.ms, color: AppColors.primaryLight),
                const SizedBox(height: AppSpacing.xl),
                Text(
                      'MYCOACH',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 40,
                        letterSpacing: 2,
                      ),
                    )
                    .animate()
                    .fade(duration: 800.ms, delay: 400.ms)
                    .slideY(begin: 0.2),
                const SizedBox(height: AppSpacing.sm),
                Text(
                      'PERFORMANCE & ELITE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 6,
                      ),
                    )
                    .animate()
                    .fade(duration: 800.ms, delay: 600.ms)
                    .slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
