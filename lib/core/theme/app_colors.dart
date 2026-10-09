import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFFE2670A); // vivid orange
  static const Color primaryPressed = Color(0xFFB85407);
  static const Color primaryLight = Color(0xFFFFF3EB);

  // Aliases for feature screens
  static const Color saffronOrange = primary;
  static const Color successGreen = Color(0xFF16A34A);
  static const Color bgCream = Color(0xFFF4F5F9);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color dividerColor = Color(0xFFE5E7EB);
  static const Color maroon = Color(0xFF881337);
  static const Color maroonBorder = Color(0xFFB45309);
  static const Color maroonText = Color(0xFF78350F);

  // Progress Bar Gradient
  static const Color progressStart = Color(0xFF0E9F3E);
  static const Color progressEnd = Color(0xFF14B24A);

  // Selected chip gradient (Teal-Green)
  static const Color chipSelectedStart = Color(0xFF2F7F6F);
  static const Color chipSelectedEnd = Color(0xFF4FA37D);

  // Borders
  static const Color chipBorder = Color(0xFF111111);
  static const Color fieldBorder = Color(0xFF8A8F98);
  static const Color fieldActiveBorder = Color(0xFF1FA64A);
  static const Color errorRed = Color(0xFFE5331B);

  // Teaser strip gradient
  static const Color teaserBgStart = Color(0xFFEFFAF1);
  static const Color teaserBgEnd = Color(0xFFFFFFFF);

  // Backgrounds & Surface
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBg = Color(0xFFF4F5F9);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Dividers & Greys
  static const Color divider = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Status & Membership badges
  static const Color gold = Color(0xFFD97706);
  static const Color diamond = Color(0xFF2563EB);
  static const Color platinum = Color(0xFF7C3AED);
  static const Color success = Color(0xFF16A34A);
  static const Color verifiedBadge = Color(0xFF0284C7);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFE2670A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient progressGradient = LinearGradient(
    colors: [progressStart, progressEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient chipSelectedGradient = LinearGradient(
    colors: [chipSelectedStart, chipSelectedEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient teaserGradient = LinearGradient(
    colors: [teaserBgStart, teaserBgEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
