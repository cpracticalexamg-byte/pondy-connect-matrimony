import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pondy_logo.dart';
import '../providers/registration_provider.dart';

class RegistrationCompleteScreen extends ConsumerStatefulWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  ConsumerState<RegistrationCompleteScreen> createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends ConsumerState<RegistrationCompleteScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 4));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reg = ref.watch(registrationProvider);
    final profileId = reg.createdProfileId ?? 'PC000621';
    final completeness = reg.photoPath != null ? 85 : 70;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Confetti emitter at top center
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primary,
                AppColors.chipSelectedStart,
                Color(0xFFFBBF24),
                Color(0xFF3B82F6),
                Color(0xFFEC4899),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  const PondyLogo(size: 72, showText: false),
                  const SizedBox(height: 24),

                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCFCE7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppColors.progressStart, size: 48),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Your Profile is Live!',
                    style: AppTypography.titleLarge(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome to Pondy Connect Matrimony community.',
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // Profile ID & completeness card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Profile ID', style: AppTypography.caption(color: AppColors.textMuted)),
                            Text(
                              profileId,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Profile Completeness', style: AppTypography.caption(color: AppColors.textMuted)),
                            Text(
                              '$completeness%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.progressStart,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: completeness / 100,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.progressStart),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  AppButton(
                    text: 'See Matches Waiting for You',
                    onPressed: () {
                      context.go('/home');
                    },
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    text: 'Add Partner Preferences',
                    type: AppButtonType.outline,
                    onPressed: () {
                      context.go('/home');
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
