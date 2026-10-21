import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_state_provider.dart';
import '../theme/app_colors.dart';
import 'profile_avatar.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profile = authState.profile;
    final user = authState.user;

    final name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (user?.mobile.isNotEmpty == true ? user!.mobile : 'Member');
    final matrimonyId = profile != null
        ? (profile.profileId.startsWith('PC') ? profile.profileId : 'PC${profile.profileId.padLeft(6, '0')}')
        : 'M12860282';
    final plan = user?.planId.toUpperCase() ?? 'FREE MEMBER';

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Top user header matching Image 2
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  // Avatar with camera edit badge
                  Stack(
                    children: [
                      ProfileAvatar(
                        imageUrl: profile?.primaryPhoto,
                        gender: profile?.gender ?? 'Male',
                        name: name,
                        radius: 28,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 11, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  // Name, ID, Free Member badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          matrimonyId,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            plan == 'FREE' || plan == 'FREE MEMBER' ? 'Free Member' : plan,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Upgrade Banner matching Image 2
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFFCC80)),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Upgrade membership to call or message with matches',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.brown,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.saffronOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      visualDensity: VisualDensity.compact,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/upgrade');
                    },
                    child: const Text('Upgrade now', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            // Switch account dropdown
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Text(
                    'Switch account',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  ),
                  Spacer(),
                  Icon(Icons.people_alt, color: Color(0xFFD32F2F), size: 18),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 20),
                ],
              ),
            ),

            const Divider(height: 16),

            // Main Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit profile',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/profile-edit');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    title: 'Edit preferences',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/partner-preferences');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.badge_outlined,
                    title: 'Verify your profile',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ID & Selfie Verification active.')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.download_outlined,
                    title: 'Download biodata',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Generating PDF Biodata...')),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                  // Section header: Support & feedback
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Text(
                      'Support & feedback',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),

                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/settings');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/help');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.star_outline,
                    title: 'Rate us',
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you for your rating!')),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.photo_library_outlined,
                    title: 'Success stories',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/success-stories');
                    },
                  ),

                  const Divider(height: 16),

                  // Logout & Delete Account
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log out',
                    iconColor: AppColors.saffronOrange,
                    textColor: AppColors.saffronOrange,
                    onTap: () async {
                      Navigator.pop(context);
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.delete_forever,
                    title: 'Delete Profile',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteDialog(context, ref);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.grey.shade700, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
      dense: true,
      visualDensity: const VisualDensity(vertical: -1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onTap: onTap,
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    String selectedReason = 'Found my match on Pondy Connect';
    final reasons = [
      'Found my match on Pondy Connect',
      'Found match elsewhere',
      'Privacy concerns',
      'Taking a break',
      'Other reason',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Delete Account? (கணக்கை நீக்குதல்)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Per DPDP Act 2023, this will permanently deactivate your profile, purge active sessions, and remove contact information.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select a reason:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              ...reasons.map((r) => RadioListTile<String>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(r, style: const TextStyle(fontSize: 12)),
                    value: r,
                    groupValue: selectedReason,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedReason = val);
                      }
                    },
                  )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                final success = await ref.read(authStateProvider.notifier).deleteAccount(reason: selectedReason);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Your account has been deleted.' : 'Account deletion failed.'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                  context.go('/login');
                }
              },
              child: const Text('Confirm Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
