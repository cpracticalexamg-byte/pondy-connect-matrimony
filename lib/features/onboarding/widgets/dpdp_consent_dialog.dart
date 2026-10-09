import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class DpdpConsentResult {
  final bool sensitiveConsent;
  final String photoVisibility;

  const DpdpConsentResult({
    required this.sensitiveConsent,
    required this.photoVisibility,
  });
}

class DpdpConsentDialog extends StatefulWidget {
  final String initialPhotoVisibility;

  const DpdpConsentDialog({
    super.key,
    this.initialPhotoVisibility = 'members',
  });

  static Future<DpdpConsentResult?> show(
    BuildContext context, {
    String initialPhotoVisibility = 'members',
  }) {
    return showModalBottomSheet<DpdpConsentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DpdpConsentDialog(
        initialPhotoVisibility: initialPhotoVisibility,
      ),
    );
  }

  @override
  State<DpdpConsentDialog> createState() => _DpdpConsentDialogState();
}

class _DpdpConsentDialogState extends State<DpdpConsentDialog> {
  late String _photoVisibility;
  bool _dataProcessingConsent = true;

  @override
  void initState() {
    super.initState();
    _photoVisibility = widget.initialPhotoVisibility;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DPDP Act 2023 Privacy Notice',
                        style: AppTypography.heading3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'தனிநபர் தரவு பாதுகாப்பு சம்மதம் (Pondy Connect)',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Text(
                'In accordance with India\'s Digital Personal Data Protection Act (DPDP Act 2023), your personal information (name, horoscope, community, location, and family details) is processed exclusively for matrimonial match-making with your explicit consent.',
                style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Profile Photo Visibility',
              style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),

            _buildRadioOption(
              title: 'Registered Members Only (Recommended)',
              subtitle: 'Visible only to verified, logged-in seekers in Puducherry',
              value: 'members',
            ),
            _buildRadioOption(
              title: 'Visible to All Users',
              subtitle: 'Open visibility to accelerate match discovery',
              value: 'all',
            ),
            _buildRadioOption(
              title: 'Blurred / Visible on Request',
              subtitle: 'Photo is shielded until you explicitly accept interest',
              value: 'request',
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.phone_locked_outlined, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your phone number is always private and only shared after mutual interest acceptance.',
                      style: TextStyle(fontSize: 11, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: AppColors.primary,
              value: _dataProcessingConsent,
              onChanged: (val) => setState(() => _dataProcessingConsent = val ?? false),
              title: const Text(
                'I consent to the processing of my matrimonial profile data per the Privacy Policy.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _dataProcessingConsent
                        ? () {
                            Navigator.of(context).pop(
                              DpdpConsentResult(
                                sensitiveConsent: true,
                                photoVisibility: _photoVisibility,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      'Agree & Continue',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = _photoVisibility == value;
    return InkWell(
      onTap: () => setState(() => _photoVisibility = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _photoVisibility,
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (val) {
                if (val != null) setState(() => _photoVisibility = val);
              },
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
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
