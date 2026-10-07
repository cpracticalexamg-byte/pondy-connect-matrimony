import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class OutlinedDropdownField extends StatelessWidget {
  final String label;
  final String? valueText;
  final String placeholder;
  final VoidCallback onTap;
  final String? errorText;
  final bool isRequired;
  final Widget? prefixIcon;
  final bool isFocused;

  const OutlinedDropdownField({
    super.key,
    required this.label,
    this.valueText,
    this.placeholder = 'Select',
    required this.onTap,
    this.errorText,
    this.isRequired = false,
    this.prefixIcon,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = valueText != null && valueText!.isNotEmpty;
    final hasError = errorText != null && errorText!.isNotEmpty;

    Color borderColor;
    if (hasError) {
      borderColor = AppColors.errorRed;
    } else if (isFocused || hasValue) {
      borderColor = AppColors.fieldActiveBorder;
    } else {
      borderColor = AppColors.fieldBorder;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
                width: hasError || isFocused ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  prefixIcon!,
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            label,
                            style: AppTypography.caption(
                              color: hasError
                                  ? AppColors.errorRed
                                  : (hasValue ? AppColors.textMuted : AppColors.textLight),
                            ),
                          ),
                          if (isRequired)
                            const Text(
                              ' *',
                              style: TextStyle(color: AppColors.errorRed, fontSize: 13),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasValue ? valueText! : placeholder,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                          color: hasValue ? AppColors.textPrimary : AppColors.textLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText!,
              style: AppTypography.caption(color: AppColors.errorRed),
            ),
          ),
      ],
    );
  }
}
