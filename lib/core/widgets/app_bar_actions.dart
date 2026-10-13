import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/locale_provider.dart';
import '../theme/app_colors.dart';

/// Compact outlined language toggle icon button (அ / A) (§7)
class LanguageToggleButton extends ConsumerWidget {
  final Color? borderColor;
  final Color? textColor;

  const LanguageToggleButton({
    super.key,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';
    final primary = textColor ?? AppColors.saffronOrange;
    final border = borderColor ?? AppColors.saffronOrange;

    return Center(
      child: Container(
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ref.read(localeProvider.notifier).toggleLocale();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isTamil ? 'A' : 'அ',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isTamil ? 'ENG' : 'தமிழ்',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared app bar actions including the language toggle button (§7)
class AppBarActions extends StatelessWidget {
  final List<Widget> additionalActions;

  const AppBarActions({
    super.key,
    this.additionalActions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...additionalActions,
        const LanguageToggleButton(),
        const SizedBox(width: 8),
      ],
    );
  }
}
