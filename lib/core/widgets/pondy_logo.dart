import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PondyLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isHorizontal;
  final VoidCallback? onTap;

  const PondyLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.isHorizontal = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = Image.asset(
      'assets/images/logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PondyLogoPainter(),
        ),
      ),
    );

    if (!showText) {
      return GestureDetector(
        onTap: onTap,
        child: iconWidget,
      );
    }

    if (isHorizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Pondy ',
                      style: AppTypography.titleLarge(color: AppColors.primary),
                    ),
                    Text(
                      'Connect',
                      style: AppTypography.titleLarge(color: AppColors.chipSelectedStart),
                    ),
                  ],
                ),
                const Text(
                  'MATRIMONY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.2,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Pondy ',
                style: AppTypography.titleLarge(color: AppColors.primary),
              ),
              Text(
                'Connect',
                style: AppTypography.titleLarge(color: AppColors.chipSelectedStart),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'MATRIMONY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 3.0,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Find your life partner, the Pondy way',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class _PondyLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // Outer subtle glow
    final bgGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.primary.withOpacity(0.12),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w / 2));
    canvas.drawCircle(center, w / 2, bgGlowPaint);

    // Puducherry Lighthouse silhouette in background
    final lighthousePaint = Paint()
      ..color = AppColors.chipSelectedStart.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    final lighthousePath = Path();
    final lhBaseW = w * 0.22;
    final lhTopW = w * 0.12;
    final lhTopY = h * 0.16;
    final lhBottomY = h * 0.72;

    lighthousePath.moveTo(center.dx - lhBaseW / 2, lhBottomY);
    lighthousePath.lineTo(center.dx - lhTopW / 2, lhTopY);
    lighthousePath.lineTo(center.dx + lhTopW / 2, lhTopY);
    lighthousePath.lineTo(center.dx + lhBaseW / 2, lhBottomY);
    lighthousePath.close();
    canvas.drawPath(lighthousePath, lighthousePaint);

    // Lighthouse dome
    final domePaint = Paint()
      ..color = AppColors.chipSelectedStart.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.dx, lhTopY), width: lhTopW * 1.2, height: lhTopW),
      math.pi,
      math.pi,
      true,
      domePaint,
    );

    // Lighthouse light rays
    final rayPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFBBF24).withOpacity(0.4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    final rayPath = Path();
    rayPath.moveTo(center.dx, lhTopY);
    rayPath.lineTo(w * 0.95, h * 0.05);
    rayPath.lineTo(w * 0.85, h * 0.35);
    rayPath.close();
    canvas.drawPath(rayPath, rayPaint);

    // Left Ring (Groom - Deep Teal/Gold rim)
    final ringRadius = w * 0.23;
    final ringStroke = w * 0.07;
    final leftCenter = Offset(w * 0.40, h * 0.58);
    final rightCenter = Offset(w * 0.60, h * 0.58);

    final leftRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..shader = const LinearGradient(
        colors: [Color(0xFF2F7F6F), Color(0xFF4FA37D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: leftCenter, radius: ringRadius));

    // Right Ring (Bride - Vivid Orange/Gold rim)
    final rightRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..shader = const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFE2670A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: rightCenter, radius: ringRadius));

    // Draw interlocking rings with heart-like overlap
    canvas.drawCircle(leftCenter, ringRadius, leftRingPaint);
    canvas.drawCircle(rightCenter, ringRadius, rightRingPaint);

    // Draw little heart accent at top overlap
    final heartCenter = Offset(w * 0.50, h * 0.44);
    final heartSize = w * 0.16;
    final heartPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    final heartPath = Path();
    final hx = heartCenter.dx;
    final hy = heartCenter.dy;
    heartPath.moveTo(hx, hy + heartSize * 0.35);
    heartPath.cubicTo(
      hx - heartSize * 0.6, hy - heartSize * 0.3,
      hx - heartSize * 0.3, hy - heartSize * 0.6,
      hx, hy - heartSize * 0.15,
    );
    heartPath.cubicTo(
      hx + heartSize * 0.3, hy - heartSize * 0.6,
      hx + heartSize * 0.6, hy - heartSize * 0.3,
      hx, hy + heartSize * 0.35,
    );
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
