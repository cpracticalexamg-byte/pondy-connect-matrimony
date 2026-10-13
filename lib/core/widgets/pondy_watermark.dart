import 'dart:math' as math;
import 'package:flutter/material.dart';

class PondyWatermark extends StatelessWidget {
  final Widget child;
  final String text;
  final double opacity;
  final double fontSize;

  const PondyWatermark({
    super.key,
    required this.child,
    this.text = 'Pondy Connect',
    this.opacity = 0.18,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _WatermarkPainter(
                text: text,
                opacity: opacity,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String text;
  final double opacity;
  final double fontSize;

  _WatermarkPainter({
    required this.text,
    required this.opacity,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final textPainter = TextPainter(
      text: TextSpan(
        text: ' $text  • ',
        style: TextStyle(
          color: Colors.white.withValues(alpha: opacity),
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final textWidth = textPainter.width > 0 ? textPainter.width : 120.0;
    final textHeight = textPainter.height > 0 ? textPainter.height : 24.0;
    final stepX = math.max(80.0, textWidth + 40);
    final stepY = math.max(50.0, textHeight + 60);

    canvas.save();
    canvas.rotate(-math.pi / 6); // -30 degrees diagonal

    // Cover expanded bounds due to rotation
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);
    for (double y = -diagonal; y < diagonal * 1.5; y += stepY) {
      for (double x = -diagonal; x < diagonal * 1.5; x += stepX) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _WatermarkPainter oldDelegate) {
    return oldDelegate.text != text ||
        oldDelegate.opacity != opacity ||
        oldDelegate.fontSize != fontSize;
  }
}
