import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'language_selector_sheet.dart';

class LanguageToggleButton extends StatelessWidget {
  final Color? color;
  final Color? borderColor;

  const LanguageToggleButton({
    super.key,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => LanguageSelectorSheet.show(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade400,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.language, size: 16, color: color ?? AppColors.textPrimary),
            const SizedBox(width: 4),
            Text(
              'A / அ',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
