import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedFitnessBackground extends StatefulWidget {
  final Widget child;

  const AnimatedFitnessBackground({super.key, required this.child});

  @override
  State<AnimatedFitnessBackground> createState() =>
      _AnimatedFitnessBackgroundState();
}

class _AnimatedFitnessBackgroundState extends State<AnimatedFitnessBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animasyonu 20 saniye sürecek şekilde ayarla ve sürekli tekrarla
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold arka planını korumak için, buraya tema bazlı ana rengi veriyoruz.
    // İçerisindeki scaffold'lar saydam olacağı için bu renk görünecek.
    final bgColor = Theme.of(context).brightness == Brightness.dark
        ? AppColors.background
        : AppColors.lightBackground;

    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // Hareket eden arka plan desenleri
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FitnessPatternPainter(
                    animationValue: _controller.value,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white.withValues(
                            alpha: 0.03,
                          ) // Dark modda hafif beyaz ikonlar
                        : Colors.black.withValues(
                            alpha: 0.03,
                          ), // Light modda hafif siyah ikonlar
                  ),
                );
              },
            ),
          ),

          // Asıl içerik (App Navigator vb.)
          widget.child,
        ],
      ),
    );
  }
}

class _FitnessPatternPainter extends CustomPainter {
  final double animationValue;
  final Color color;

  _FitnessPatternPainter({required this.animationValue, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Desenin ne kadar kayacağını hesapla
    // İhtiyaca göre iconBoyutu değişebilir
    final iconSize = 60.0;
    final spacing = 120.0;

    // Pattern offset x ve y ekseninde kaydırma yapıyor
    final offsetX = animationValue * spacing;
    final offsetY = animationValue * spacing;

    // Ekrana sığacak kadar satır ve sütun hesapla (-2 ve +2 ekstra çizmek için, köşelerde kesiklik olmasın diye)
    final cols = (size.width / spacing).ceil() + 2;
    final rows = (size.height / spacing).ceil() + 2;

    for (int r = -1; r < rows; r++) {
      for (int c = -1; c < cols; c++) {
        // Her satırı biraz kaydırarak çapraz bir görünüm elde et
        final x = c * spacing - offsetX + (r % 2 == 0 ? spacing / 2 : 0);
        final y = r * spacing - offsetY;

        // Dumbell benzeri basit bir path çizimi
        _drawSimpleDumbbell(canvas, paint, x, y, iconSize);
      }
    }
  }

  void _drawSimpleDumbbell(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double size,
  ) {
    canvas.save();
    canvas.translate(x + size / 2, y + size / 2);
    // 45 derece eğik dursun
    canvas.rotate(math.pi / 4);

    final handleWidth = size * 0.4;
    final handleHeight = size * 0.1;
    final weightWidth = size * 0.15;
    final weightHeight = size * 0.4;

    // Connect bar
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: handleWidth,
        height: handleHeight,
      ),
      paint,
    );

    // Left weights
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-handleWidth / 2 - weightWidth / 2, 0),
          width: weightWidth,
          height: weightHeight,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Smaller left weight edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(-handleWidth / 2 - weightWidth - weightWidth / 4, 0),
          width: weightWidth / 2,
          height: weightHeight * 0.6,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    // Right weights
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(handleWidth / 2 + weightWidth / 2, 0),
          width: weightWidth,
          height: weightHeight,
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Smaller right weight edge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(handleWidth / 2 + weightWidth + weightWidth / 4, 0),
          width: weightWidth / 2,
          height: weightHeight * 0.6,
        ),
        const Radius.circular(2),
      ),
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FitnessPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
