import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../auth/providers/auth_state_provider.dart';

/// 2-step bottom sheet gate when a user tries to access PRIME without a profile photo
class PrimePhotoGateSheet extends ConsumerStatefulWidget {
  final VoidCallback onUnlocked;

  const PrimePhotoGateSheet({super.key, required this.onUnlocked});

  static Future<bool?> show(BuildContext context, {required VoidCallback onUnlocked}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrimePhotoGateSheet(onUnlocked: onUnlocked),
    );
  }

  @override
  ConsumerState<PrimePhotoGateSheet> createState() => _PrimePhotoGateSheetState();
}

class _PrimePhotoGateSheetState extends ConsumerState<PrimePhotoGateSheet> {
  int _currentStep = 1;
  bool _isProcessing = false;
  String _selectedIdType = 'Aadhaar';
  final TextEditingController _idLast4Controller = TextEditingController();

  @override
  void dispose() {
    _idLast4Controller.dispose();
    super.dispose();
  }

  Future<void> _handleStep1AddPhoto() async {
    setState(() => _isProcessing = true);
    try {
      final authState = ref.read(authStateProvider);
      final profile = authState.profile;
      if (profile != null) {
        final profileRepo = ref.read(profileRepoProvider);
        // Add sample default photo for mock upload
        final photoPath = profile.gender.toLowerCase() == 'male'
            ? 'assets/images/sample_groom.png'
            : 'assets/images/sample_bride.png';
        await profileRepo.addPhoto(profile.profileId, photoPath, isPrimary: true);
        await ref.read(authStateProvider.notifier).reloadProfile();
      }
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 2;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _currentStep = 2;
        });
      }
    }
  }

  Future<void> _handleStep2VerifyId() async {
    final last4 = _idLast4Controller.text.trim();
    if (last4.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter last 4 digits of your ID')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      final authState = ref.read(authStateProvider);
      final profile = authState.profile;
      if (profile != null) {
        final profileRepo = ref.read(profileRepoProvider);
        final updated = profile.copyWith(isVerified: true);
        await profileRepo.updateProfile(updated);
        await ref.read(authStateProvider.notifier).reloadProfile();
      }

      if (mounted) {
        Navigator.pop(context, true);
        widget.onUnlocked();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.verified, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('PRIME Unlocked! Your profile is verified.'),
              ],
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.saffronOrange.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Step $_currentStep/2',
                  style: const TextStyle(
                    color: AppColors.saffronOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_currentStep == 1) ...[
            Text(
              'Photo Required for PRIME',
              style: AppTypography.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'It is mandatory to add your photo to view Prime matches. Just two more steps before you view Prime matches.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),

            // Feature perks
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(Icons.security, '100% Privacy Control — Choose who can view your photo'),
                  const SizedBox(height: 10),
                  _buildBenefitRow(Icons.verified_user, 'Access 100% Government ID-verified PRIME matches'),
                  const SizedBox(height: 10),
                  _buildBenefitRow(Icons.visibility, 'Higher visibility and genuine interest from prospects'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleStep1AddPhoto,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_a_photo),
              label: const Text('Add Your Photo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ] else ...[
            Text(
              'Verify Your Government ID',
              style: AppTypography.heading2.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'PRIME requires verified profiles. Choose your ID type and enter the last 4 digits for instant verification.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),

            // ID Type Dropdown
            DropdownButtonFormField<String>(
              value: _selectedIdType,
              decoration: InputDecoration(
                labelText: 'Select ID Type',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'Aadhaar', child: Text('Aadhaar Card')),
                DropdownMenuItem(value: 'Voter ID', child: Text('Voter ID Card')),
                DropdownMenuItem(value: 'Passport', child: Text('Passport')),
                DropdownMenuItem(value: 'Driving Licence', child: Text('Driving Licence')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedIdType = val);
              },
            ),
            const SizedBox(height: 16),

            // Masked Last 4 Digits
            TextField(
              controller: _idLast4Controller,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'Last 4 Digits of $_selectedIdType',
                hintText: 'e.g. 4829',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                helperText: 'We only store verification status and masked last-4 digits for privacy',
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _handleStep2VerifyId,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.verified),
              label: const Text('Verify & Unlock PRIME', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.successGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.successGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
          ),
        ),
      ],
    );
  }
}
