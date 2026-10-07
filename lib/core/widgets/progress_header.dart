import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/locale_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class ProgressHeader extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final double progress; // 0.0 to 1.0 (e.g. 0.2, 0.4, 0.6, 0.7, 0.9, 1.0)
  final VoidCallback? onBack;
  final bool showBack;
  final bool showLanguageToggle;

  const ProgressHeader({
    super.key,
    required this.title,
    required this.progress,
    this.onBack,
    this.showBack = true,
    this.showLanguageToggle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(100);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isTamil = currentLocale.languageCode == 'ta';

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Bar: Back | Title | Language Toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  if (showBack)
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      color: AppColors.textPrimary,
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTypography.titleLarge(isTamil: isTamil),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showLanguageToggle)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          ref.read(localeProvider.notifier).toggleLocale();
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.fieldBorder, width: 1.2),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.language, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                isTamil ? 'A' : 'அ',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // Animated Progress Bar & Percentage
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  final percent = (val * 100).round();
                  return Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            height: 7,
                            color: Colors.grey.shade200,
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: val,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: AppColors.progressGradient,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.progressStart,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}
