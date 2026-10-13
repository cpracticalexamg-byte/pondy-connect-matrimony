import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entitlements/entitlements_engine.dart';
import '../../../domain/entitlements/entitlements_model.dart';
import '../../../domain/models/profile_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class ContactPaywallSheet extends ConsumerStatefulWidget {
  final ProfileModel targetProfile;
  final bool initialRevealRequested;

  const ContactPaywallSheet({
    super.key,
    required this.targetProfile,
    this.initialRevealRequested = false,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileModel targetProfile,
    bool initialRevealRequested = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ContactPaywallSheet(
        targetProfile: targetProfile,
        initialRevealRequested: initialRevealRequested,
      ),
    );
  }

  @override
  ConsumerState<ContactPaywallSheet> createState() => _ContactPaywallSheetState();
}

class _ContactPaywallSheetState extends ConsumerState<ContactPaywallSheet> {
  bool _revealed = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAlreadyRevealed();
  }

  Future<void> _checkAlreadyRevealed() async {
    final auth = ref.read(authStateProvider);
    final myProfileId = auth.profile?.profileId ?? '';
    if (myProfileId.isEmpty) return;

    final repo = ref.read(profileRepoProvider);
    final already = await repo.hasViewedContact(myProfileId, widget.targetProfile.profileId);
    if (already && mounted) {
      setState(() => _revealed = true);
    }
  }

  String _getMaskedPhone(String raw) {
    if (widget.targetProfile.isSample) {
      return '+91 95XXXXXXXX';
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final prefix = digits.substring(digits.length - 10, digits.length - 8);
      return '+91 ${prefix}XXXXXXXX';
    }
    return '+91 95XXXXXXXX';
  }

  String _getRealOrSafePhone(String raw) {
    if (widget.targetProfile.isSample) {
      return '+91 98400 12345 (Demo)';
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      final ten = digits.substring(digits.length - 10);
      return '+91 ${ten.substring(0, 5)} ${ten.substring(5)}';
    }
    return raw.isNotEmpty ? raw : '+91 98400 12345';
  }

  Future<void> _revealContact(Entitlements entitlements) async {
    setState(() => _isLoading = true);
    final auth = ref.read(authStateProvider);
    final myProfileId = auth.profile?.profileId ?? '';
    final repo = ref.read(profileRepoProvider);

    await repo.recordContactView(
      myProfileId,
      widget.targetProfile.profileId,
      quotaWindowId: entitlements.tier,
    );

    ref.invalidate(entitlementsProvider);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _revealed = true;
      });
    }
  }

  Future<void> _launchCall(String phone) async {
    if (widget.targetProfile.isSample) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is a sample profile for demonstration.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone, String name) async {
    if (widget.targetProfile.isSample) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This is a sample profile for demonstration.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final msg = Uri.encodeComponent(
      'Vanakkam $name! I came across your profile on Pondy Connect Matrimony and would love to connect.',
    );
    final uri = Uri.parse('https://wa.me/91$clean?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlementsAsync = ref.watch(entitlementsProvider);
    final entitlements = entitlementsAsync.value ?? Entitlements.free();
    final target = widget.targetProfile;
    final auth = ref.watch(authStateProvider);
    final myProfile = auth.profile;

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
      child: entitlements.isPaid ? _buildPaidMemberFlow(entitlements, target) : _buildFreeMemberPaywall(target, myProfile),
    );
  }

  Widget _buildFreeMemberPaywall(ProfileModel target, ProfileModel? myProfile) {
    final maskedPhone = _getMaskedPhone(target.phone ?? '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Close Button
        Align(
          alignment: Alignment.topRight,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        // Overlapping Avatars Header
        Center(
          child: SizedBox(
            width: 140,
            height: 70,
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ProfileAvatar(
                      name: myProfile?.name ?? 'You',
                      gender: myProfile?.gender ?? 'Male',
                      radius: 30,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: ProfileAvatar(
                      name: target.name,
                      gender: target.gender,
                      imageUrl: target.primaryPhoto,
                      radius: 30,
                    ),
                  ),
                ),
                Positioned(
                  left: 56,
                  top: 18,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Center(
          child: Text(
            'Upgrade to Paid Membership',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20)),
          ),
        ),

        const SizedBox(height: 6),

        if (target.isSample)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: const Text(
              'Sample Profile: Demonstration phone number',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.brown, fontWeight: FontWeight.bold),
            ),
          ),

        Center(
          child: Text(
            'Chat / Call $maskedPhone to connect with ${target.name}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ),

        const SizedBox(height: 18),

        // Value Props Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FBF9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paid membership lets you:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1B5E20)),
              ),
              const SizedBox(height: 10),
              _buildBenefitRow(Icons.phone_in_talk, 'View contact numbers and call / WhatsApp matches'),
              const SizedBox(height: 8),
              _buildBenefitRow(Icons.chat_bubble_outline, 'Send personalised messages & start chats'),
              const SizedBox(height: 8),
              _buildBenefitRow(Icons.auto_awesome, 'View detailed horoscopes and full 10-Porutham match'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        AppButton(
          text: 'Continue to Upgrade',
          onPressed: () {
            Navigator.of(context).pop();
            context.push('/upgrade?source=contact_paywall&profile=${target.profileId}');
          },
        ),
      ],
    );
  }

  Widget _buildPaidMemberFlow(Entitlements entitlements, ProfileModel target) {
    final realPhone = _getRealOrSafePhone(target.phone ?? '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_enabled, color: Color(0xFF2E7D32), size: 20),
                const SizedBox(width: 8),
                Text(
                  _revealed ? 'Contact Details' : 'View Contact Number',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (!_revealed) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Text(
                  'View contact of ${target.name}? (${entitlements.contactViewsRemaining} of 40 contact views left)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                Text(
                  entitlements.isUnlimitedContacts
                      ? 'You have unlimited contact views with active ${entitlements.planName}.'
                      : 'You have ${entitlements.contactViewsRemaining} contact views left under your plan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                if (entitlements.isUnlimitedContacts) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Fair-use cap: ${entitlements.dailyContactCap} contacts/day',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            text: _isLoading ? 'Accessing...' : 'Reveal Contact Number',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : () => _revealContact(entitlements),
          ),
        ] else ...[
          // Revealed State
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF81C784)),
            ),
            child: Column(
              children: [
                const Text('Verified Phone Number', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  realPhone,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF1B5E20)),
                ),
                if (target.isSample)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      'Sample profile for demonstration only',
                      style: TextStyle(fontSize: 11, color: Colors.brown, fontStyle: FontStyle.italic),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Action Buttons: Call & WhatsApp
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.phone, color: Color(0xFFE65100)),
                  label: const Text('Call Now', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE65100), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _launchCall(realPhone),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text('WhatsApp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _launchWhatsApp(realPhone, target.name),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBenefitRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF2E7D32)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.2),
          ),
        ),
      ],
    );
  }
}
