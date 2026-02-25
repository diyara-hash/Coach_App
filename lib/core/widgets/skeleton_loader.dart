import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import 'elite_glass_card.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  const SkeletonLoader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF262626) : const Color(0xFFD1D1D6),
      highlightColor: isDark
          ? const Color(0xFF404040)
          : const Color(0xFFFFFFFF),
      child: child,
    );
  }
}

class SkeletonListTile extends StatelessWidget {
  const SkeletonListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: EliteGlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: SkeletonLoader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 120, height: 20, color: Colors.white),
                  Container(width: 40, height: 20, color: Colors.white),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60, height: 30, color: Colors.white),
                  Container(width: 60, height: 30, color: Colors.white),
                  Container(width: 60, height: 30, color: Colors.white),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 60, height: 30, color: Colors.white),
                  Container(width: 60, height: 30, color: Colors.white),
                  Container(width: 60, height: 30, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: SkeletonLoader(
        child: Column(
          children: [
            Container(width: 100, height: 14, color: Colors.white),
            const SizedBox(height: AppSpacing.sm),
            Container(width: 80, height: 50, color: Colors.white),
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 80,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SkeletonStatsRow extends StatelessWidget {
  const SkeletonStatsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return EliteGlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SkeletonLoader(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80, height: 14, color: Colors.white),
                Container(width: 100, height: 16, color: Colors.white),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _buildRow(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            _buildRow(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Divider(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            _buildRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(width: 40, height: 20, color: Colors.white),
        Row(
          children: [
            Container(width: 60, height: 20, color: Colors.white),
            const SizedBox(width: 12),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
