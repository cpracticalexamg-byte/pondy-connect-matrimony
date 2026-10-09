import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'app_button.dart';
import 'progress_header.dart';
import 'teaser_strip.dart';

class StepScaffold extends StatelessWidget {
  final String title;
  final double progress;
  final Widget body;
  final String nextButtonText;
  final VoidCallback? onNext;
  final bool isNextEnabled;
  final bool isNextLoading;
  final VoidCallback? onBack;
  final bool showBack;
  final bool showTeaser;
  final int matchCount;
  final List<TeaserProfileItem> teaserProfiles;
  final Widget? bottomExtra;

  const StepScaffold({
    super.key,
    required this.title,
    required this.progress,
    required this.body,
    this.nextButtonText = 'Next',
    this.onNext,
    this.isNextEnabled = true,
    this.isNextLoading = false,
    this.onBack,
    this.showBack = true,
    this.showTeaser = false,
    this.matchCount = 0,
    this.teaserProfiles = const [],
    this.bottomExtra,
  });

  Future<void> _callSupport() async {
    final cleanNumber = AppConfig.supportPhoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: ProgressHeader(
        title: title,
        progress: progress,
        onBack: onBack,
        showBack: showBack,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: body,
              ),
            ),

            // Teaser Strip (Step 3 onward)
            if (showTeaser)
              TeaserStrip(
                matchCount: matchCount,
                sampleProfiles: teaserProfiles,
              ),

            // Fixed Bottom Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (bottomExtra != null) ...[
                    bottomExtra!,
                    const SizedBox(height: 10),
                  ],
                  // Full-width pill CTA button
                  AppButton(
                    text: nextButtonText,
                    onPressed: onNext,
                    isEnabled: isNextEnabled,
                    isLoading: isNextLoading,
                    height: 52,
                  ),
                  const SizedBox(height: 10),
                  // Dashed divider
                  Row(
                    children: List.generate(
                      30,
                      (index) => Expanded(
                        child: Container(
                          color: index.isEven ? AppColors.divider : Colors.transparent,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Support phone dialer
                  InkWell(
                    onTap: _callSupport,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.phone_in_talk_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Need help? Call ',
                            style: AppTypography.helper(color: AppColors.textMuted),
                          ),
                          const Text(
                            AppConfig.supportPhoneNumber,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
