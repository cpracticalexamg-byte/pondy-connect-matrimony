import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Render PondyLogo to 1024x1024 PNG icons for flutter_launcher_icons', () async {
    final iconsDir = Directory('assets/icons');
    if (!await iconsDir.exists()) {
      await iconsDir.create(recursive: true);
    }

    // 1. Generate Full App Icon (1024x1024 with clean solid background, no alpha for iOS)
    final fullImage = await _renderIcon(
      size: 1024,
      drawBackground: true,
      scaleFactor: 0.75, // comfortable margin inside 1024
      isMonochrome: false,
    );
    final fullPngBytes = await fullImage.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/icons/app_icon_1024.png').writeAsBytes(fullPngBytes!.buffer.asUint8List());

    // 2. Generate Adaptive Foreground (1024x1024 with transparent bg, logo scaled to 66% safe zone)
    final foregroundImage = await _renderIcon(
      size: 1024,
      drawBackground: false,
      scaleFactor: 0.60, // 60% fits safely inside Android's 66% circle mask
      isMonochrome: false,
    );
    final fgPngBytes = await foregroundImage.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/icons/app_icon_foreground.png').writeAsBytes(fgPngBytes!.buffer.asUint8List());

    // 3. Generate Android 13 Themed Monochrome Icon
    final monoImage = await _renderIcon(
      size: 1024,
      drawBackground: false,
      scaleFactor: 0.60,
      isMonochrome: true,
    );
    final monoPngBytes = await monoImage.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/icons/app_icon_monochrome.png').writeAsBytes(monoPngBytes!.buffer.asUint8List());

    // 4. Generate Splash Logo (512x512 transparent for flutter_native_splash)
    final splashImage = await _renderIcon(
      size: 512,
      drawBackground: false,
      scaleFactor: 0.85,
      isMonochrome: false,
    );
    final splashPngBytes = await splashImage.toByteData(format: ui.ImageByteFormat.png);
    await File('assets/icons/splash_logo.png').writeAsBytes(splashPngBytes!.buffer.asUint8List());

    expect(File('assets/icons/app_icon_1024.png').existsSync(), isTrue);
    expect(File('assets/icons/app_icon_foreground.png').existsSync(), isTrue);
    expect(File('assets/icons/app_icon_monochrome.png').existsSync(), isTrue);
    expect(File('assets/icons/splash_logo.png').existsSync(), isTrue);
  });
}

Future<ui.Image> _renderIcon({
  required double size,
  required bool drawBackground,
  required double scaleFactor,
  required bool isMonochrome,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size, size));

  if (drawBackground) {
    // Solid warm white/cream background (no alpha)
    final bgPaint = Paint()..color = const Color(0xFFFFFBF7);
    canvas.drawRect(Rect.fromLTWH(0, 0, size, size), bgPaint);
  }

  // Draw PondyLogo centered and scaled
  final contentSize = size * scaleFactor;
  final offset = (size - contentSize) / 2;

  canvas.save();
  canvas.translate(offset, offset);
  _paintPondyLogo(canvas, Size(contentSize, contentSize), isMonochrome);
  canvas.restore();

  final picture = recorder.endRecording();
  return await picture.toImage(size.toInt(), size.toInt());
}

void _paintPondyLogo(Canvas canvas, Size size, bool isMonochrome) {
  final w = size.width;
  final h = size.height;
  final center = Offset(w / 2, h / 2);

  if (!isMonochrome) {
    // Outer subtle glow
    final bgGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        w / 2,
        [
          const Color(0xFFE2670A).withOpacity(0.15),
          Colors.transparent,
        ],
      );
    canvas.drawCircle(center, w / 2, bgGlowPaint);
  }

  // Puducherry Lighthouse silhouette in background
  final lighthouseColor = isMonochrome
      ? Colors.white.withOpacity(0.4)
      : const Color(0xFF2F7F6F).withOpacity(0.28);
  final lighthousePaint = Paint()
    ..color = lighthouseColor
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
    ..color = isMonochrome ? Colors.white.withOpacity(0.6) : const Color(0xFF2F7F6F).withOpacity(0.45)
    ..style = PaintingStyle.fill;
  canvas.drawArc(
    Rect.fromCenter(center: Offset(center.dx, lhTopY), width: lhTopW * 1.2, height: lhTopW),
    math.pi,
    math.pi,
    true,
    domePaint,
  );

  // Lighthouse light rays
  if (!isMonochrome) {
    final rayPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(w, h),
        [
          const Color(0xFFFBBF24).withOpacity(0.45),
          Colors.transparent,
        ],
      );
    final rayPath = Path();
    rayPath.moveTo(center.dx, lhTopY);
    rayPath.lineTo(w * 0.95, h * 0.05);
    rayPath.lineTo(w * 0.85, h * 0.35);
    rayPath.close();
    canvas.drawPath(rayPath, rayPaint);
  }

  // Interlocking Rings
  final ringRadius = w * 0.23;
  final ringStroke = w * 0.07;
  final leftCenter = Offset(w * 0.40, h * 0.58);
  final rightCenter = Offset(w * 0.60, h * 0.58);

  if (isMonochrome) {
    final monoRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..color = Colors.white;
    canvas.drawCircle(leftCenter, ringRadius, monoRingPaint);
    canvas.drawCircle(rightCenter, ringRadius, monoRingPaint);
  } else {
    // Left Ring (Groom - Deep Teal/Emerald)
    final leftRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..shader = ui.Gradient.linear(
        Offset(leftCenter.dx - ringRadius, leftCenter.dy - ringRadius),
        Offset(leftCenter.dx + ringRadius, leftCenter.dy + ringRadius),
        [const Color(0xFF2F7F6F), const Color(0xFF4FA37D)],
      );

    // Right Ring (Bride - Vivid Orange/Gold)
    final rightRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = ringStroke
      ..shader = ui.Gradient.linear(
        Offset(rightCenter.dx - ringRadius, rightCenter.dy - ringRadius),
        Offset(rightCenter.dx + ringRadius, rightCenter.dy + ringRadius),
        [const Color(0xFFF97316), const Color(0xFFE2670A)],
      );

    canvas.drawCircle(leftCenter, ringRadius, leftRingPaint);
    canvas.drawCircle(rightCenter, ringRadius, rightRingPaint);
  }

  // Top heart accent at overlap
  final heartCenter = Offset(w * 0.50, h * 0.44);
  final heartSize = w * 0.16;
  final heartPaint = Paint()
    ..color = isMonochrome ? Colors.white : const Color(0xFFE2670A)
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
