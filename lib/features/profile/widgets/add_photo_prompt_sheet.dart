import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_state_provider.dart';

/// Dismissible bottom sheet for photo-less members appearing max once per session
class AddPhotoPromptSheet extends ConsumerStatefulWidget {
  const AddPhotoPromptSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddPhotoPromptSheet(),
    );
  }

  @override
  ConsumerState<AddPhotoPromptSheet> createState() => _AddPhotoPromptSheetState();
}

class _AddPhotoPromptSheetState extends ConsumerState<AddPhotoPromptSheet> {
  bool _isUploading = false;

  Future<void> _handleUpload() async {
    setState(() => _isUploading = true);
    try {
      final authState = ref.read(authStateProvider);
      final profile = authState.profile;
      if (profile != null) {
        final profileRepo = ref.read(profileRepoProvider);
        final photoPath = profile.gender.toLowerCase() == 'male'
            ? 'assets/images/sample_groom.png'
            : 'assets/images/sample_bride.png';
        await profileRepo.addPhoto(profile.profileId, photoPath, isPrimary: true);
        await ref.read(authStateProvider.notifier).reloadProfile();
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo added successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (_) {
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Icon / Illustration
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.saffronOrange.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_a_photo_rounded, size: 36, color: AppColors.saffronOrange),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Add Your Photo Now',
            textAlign: TextAlign.center,
            style: AppTypography.heading2.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),

          // Guardrail-compliant text: NO fake "95% of people" claim
          Text(
            'If no photo → less visibility → less response',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium().copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.green.shade800, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '100% privacy control — choose who can view your photo anytime in settings.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Upload button
          ElevatedButton.icon(
            onPressed: _isUploading ? null : _handleUpload,
            icon: _isUploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.upload),
            label: const Text('Upload Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.saffronOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),

          // Later button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'I\'ll add photo later ›',
              style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
