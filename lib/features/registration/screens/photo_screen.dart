import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/step_scaffold.dart';
import '../providers/registration_provider.dart';

class PhotoScreen extends ConsumerStatefulWidget {
  const PhotoScreen({super.key});

  @override
  ConsumerState<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends ConsumerState<PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  String _selectedPrivacy = 'all';

  final Map<String, String> _privacyLabels = {
    'all': 'Visible to all members',
    'premium': 'Visible only to Premium members',
    'on_request': 'Visible only upon my accepted request',
  };

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xFile = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1500,
        imageQuality: 85,
      );
      if (xFile != null) {
        ref.read(registrationProvider.notifier).updatePhoto(xFile.path, privacy: _selectedPrivacy);
      }
    } catch (_) {}
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Photo Source', style: AppTypography.sectionTitle()),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                title: const Text('Take a Photo with Camera', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: AppColors.chipSelectedStart),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishRegistration() async {
    final profileId = await ref.read(registrationProvider.notifier).finalizeRegistration();
    if (mounted) {
      if (profileId != null) {
        context.go('/register/complete');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reg = ref.watch(registrationProvider);
    final hasPhoto = reg.photoPath != null && reg.photoPath!.isNotEmpty;

    return StepScaffold(
      title: 'Add Photo',
      progress: 1.0,
      isNextEnabled: true,
      nextButtonText: hasPhoto ? 'Complete Registration' : 'Continue with Photo',
      onNext: hasPhoto ? _finishRegistration : _showImagePickerSheet,
      bottomExtra: hasPhoto
          ? null
          : InkWell(
              onTap: _finishRegistration,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  "I'll add photo later ›",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Highlight nudge card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If No Photo → Less Visibility → Less Response',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Photo preview or avatar placeholder
          Center(
            child: Stack(
              children: [
                Container(
                  width: 160,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.fieldActiveBorder, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: hasPhoto
                        ? Image.asset(
                            reg.photoPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: InkWell(
                    onTap: _showImagePickerSheet,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Truthful benefit bullets
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: const Column(
              children: [
                _BenefitBullet(
                  icon: Icons.lock_outline_rounded,
                  text: '100% Privacy Control. Choose who can view your photo.',
                ),
                SizedBox(height: 12),
                _BenefitBullet(
                  icon: Icons.thumb_up_alt_outlined,
                  text: 'Most families and matches look for profiles with verified photos.',
                ),
                SizedBox(height: 12),
                _BenefitBullet(
                  icon: Icons.security_rounded,
                  text: 'Watermarked photos ensure safety against downloads or unauthorized sharing.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Privacy Choice
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Photo Privacy Settings', style: AppTypography.sectionTitle()),
          ),
          const SizedBox(height: 10),
          Column(
            children: _privacyLabels.entries.map((entry) {
              final isSelected = _selectedPrivacy == entry.key;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight.withOpacity(0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.fieldBorder,
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: RadioListTile<String>(
                  title: Text(entry.value, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  value: entry.key,
                  groupValue: _selectedPrivacy,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedPrivacy = val);
                      ref.read(registrationProvider.notifier).updatePhoto(reg.photoPath ?? '', privacy: val);
                    }
                  },
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_outline, size: 70, color: AppColors.textMuted),
        SizedBox(height: 8),
        Text(
          'Tap to add photo',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted, fontSize: 13),
        ),
      ],
    );
  }
}

class _BenefitBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BenefitBullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.chipSelectedStart),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: AppTypography.caption(color: AppColors.textPrimary)),
        ),
      ],
    );
  }
}
