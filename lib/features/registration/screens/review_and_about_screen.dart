import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/step_scaffold.dart';
import '../../auth/providers/auth_state_provider.dart';
import '../providers/registration_provider.dart';

class ReviewAndAboutScreen extends ConsumerStatefulWidget {
  const ReviewAndAboutScreen({super.key});

  @override
  ConsumerState<ReviewAndAboutScreen> createState() => _ReviewAndAboutScreenState();
}

class _ReviewAndAboutScreenState extends ConsumerState<ReviewAndAboutScreen> {
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final reg = ref.read(registrationProvider);
    _bioController = TextEditingController(text: reg.aboutMe);
    if (_bioController.text.isEmpty) {
      ref.read(registrationProvider.notifier).suggestBio();
      _bioController.text = ref.read(registrationProvider).aboutMe;
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    final reg = ref.watch(registrationProvider);
    final prefix = auth.relationPrefix;

    final inconsistency = reg.checkInconsistencies();
    final bioError = reg.bioModerationError;
    final isBioValid = _bioController.text.trim().length >= 30 && _bioController.text.trim().length <= 500 && bioError == null;
    final canProceed = isBioValid && inconsistency == null;

    return StepScaffold(
      title: 'Review & About',
      progress: 0.95,
      isNextEnabled: canProceed,
      nextButtonText: 'Proceed to Photo',
      onNext: () {
        context.push('/register/photo');
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Details & Write Bio',
            style: AppTypography.titleLarge(),
          ),
          const SizedBox(height: 6),
          Text(
            'Ensure details are accurate for high trust and faster responses',
            style: AppTypography.bodyMedium(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Smart validation inconsistency alert
          if (inconsistency != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.errorRed, width: 1.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.errorRed, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Some details may be incorrect. Please review.',
                          style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.errorRed, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          inconsistency,
                          style: AppTypography.caption(color: const Color(0xFF991B1B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Review Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Entered Profile Summary', style: AppTypography.sectionTitle()),
                    TextButton(
                      onPressed: () => context.go('/register/step1'),
                      child: const Text('Edit', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const Divider(height: 16),
                _buildSummaryRow('Gender & Age', '${reg.gender}, ${reg.calculatedAge} yrs (${reg.heightCm} cm)'),
                _buildSummaryRow('Marital Status', reg.maritalStatus.replaceAll('_', ' ').toUpperCase()),
                _buildSummaryRow('Religion & Community', '${reg.religion.toUpperCase()} • ${reg.caste}'),
                _buildSummaryRow('Location', '${reg.city}, ${reg.state}'),
                _buildSummaryRow('Education', reg.education.toUpperCase()),
                _buildSummaryRow('Occupation', reg.occupation.replaceAll('_', ' ')),
                _buildSummaryRow('Income', reg.annualIncomeRange.replaceAll('_', ' ')),
                _buildSummaryRow('Family Status', reg.familyStatus.replaceAll('_', ' ')),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // About Me / Bio Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'A few words about $prefix${prefix.isEmpty ? "myself" : ""}',
                style: AppTypography.sectionTitle(),
              ),
              TextButton.icon(
                onPressed: () {
                  ref.read(registrationProvider.notifier).suggestBio();
                  _bioController.text = ref.read(registrationProvider).aboutMe;
                },
                icon: const Icon(Icons.auto_awesome, size: 16, color: AppColors.chipSelectedStart),
                label: const Text(
                  'Suggest Text',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.chipSelectedStart,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Write at least 30 characters. Do not include phone numbers, emails, or links.',
            style: AppTypography.caption(color: AppColors.textMuted),
          ),
          const SizedBox(height: 10),

          // Bio Text Field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: bioError != null ? AppColors.errorRed : AppColors.fieldBorder,
                width: bioError != null ? 1.5 : 1.0,
              ),
            ),
            child: TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Share hobbies, values, expectations from a life partner...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
              onChanged: (text) {
                ref.read(registrationProvider.notifier).updateAboutMe(text);
              },
            ),
          ),

          if (bioError != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 6),
              child: Text(
                bioError,
                style: AppTypography.caption(color: AppColors.errorRed),
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: AppTypography.caption(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
