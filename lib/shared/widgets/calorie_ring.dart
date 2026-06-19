import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../theme.dart';

/// Animated circular calorie progress ring — 3D style with glow effect.
class CalorieRing extends StatefulWidget {
  final int consumed;
  final int burned;
  final int goal;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.burned,
    required this.goal,
  });

  @override
  State<CalorieRing> createState() => _CalorieRingState();
}

class _CalorieRingState extends State<CalorieRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    final net = widget.consumed - widget.burned;
    final target = (net / widget.goal).clamp(0.0, 1.0);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(CalorieRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.consumed != widget.consumed || 
        oldWidget.burned != widget.burned || 
        oldWidget.goal != widget.goal) {
      
      final net = widget.consumed - widget.burned;
      final target = (net / widget.goal).clamp(0.0, 1.0);

      _animation = Tween<double>(begin: _animation.value, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final net = widget.consumed - widget.burned;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          // Outer glow container
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(240, 240),
                painter: _RingPainter3D(progress: _animation.value),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$net',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(
                              color: Color(0x80C4C0FF),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                  ),
                  Text(
                    '/ ${widget.goal} kcal',
                    style:
                        Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    child: Text(
                      'NETTO',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RingPainter3D extends CustomPainter {
  final double progress;
  const _RingPainter3D({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 12.0;

    // Background track — darker with inner-shadow feel
    final bgPaint = Paint()
      ..color = const Color(0xFF1A1A2A)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Progress arc — gradient primary with glow
    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE3DFFF), AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    // Crisp top layer
    final fgPaintCrisp = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFE3DFFF), AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final sweepAngle = 2 * math.pi * progress;
      const startAngle = -math.pi / 2;
      final rect = Rect.fromCircle(center: center, radius: radius);

      // Glow layer
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
      // Crisp layer on top
      canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaintCrisp);
    }
  }

  @override
  bool shouldRepaint(_RingPainter3D old) => old.progress != progress;
}
