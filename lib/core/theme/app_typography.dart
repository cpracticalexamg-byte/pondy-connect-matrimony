import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get heading1 => titleLarge();
  static TextStyle get heading2 => sectionTitle();
  static TextStyle get heading3 => sectionTitle();
  static TextStyle get bodySmall => helper();

  static TextStyle titleLarge({bool isTamil = false, Color color = AppColors.textPrimary}) {
    final style = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle sectionTitle({bool isTamil = false, Color color = AppColors.textPrimary}) {
    final style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
      height: 1.3,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle fieldText({bool isTamil = false, Color color = AppColors.textPrimary}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.4,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle bodyMedium({bool isTamil = false, Color color = AppColors.textPrimary}) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.4,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle helper({bool isTamil = false, Color color = AppColors.textMuted}) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.3,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle caption({bool isTamil = false, Color color = AppColors.textLight}) {
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.2,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }

  static TextStyle buttonText({bool isTamil = false, Color color = Colors.white}) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: 0.3,
    );
    return isTamil
        ? GoogleFonts.notoSansTamil(textStyle: style)
        : GoogleFonts.lato(textStyle: style);
  }
}
