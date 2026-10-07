import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/profile_avatar.dart';
import '../../auth/providers/auth_state_provider.dart';

class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final p = authState.profile;
    final user = authState.user;
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('My Profile & Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Profile Hero Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      ProfileAvatar(
                        imageUrl: p?.primaryPhoto,
                        gender: p?.gender ?? 'Female',
                        name: p?.name ?? 'Member',
                        radius: 36,
                        isVerified: (p?.completenessPct ?? 0) >= 80,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p?.name ?? 'Pondy Connect Member',
                              style: AppTypography.heading3.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${p?.profileId.isNotEmpty == true ? p!.profileId : "Pending"} • ${user?.mobile ?? ""}',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${p?.completenessPct ?? 70}% Complete',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit Profile'),
                          onPressed: () => context.push('/profile-edit'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.saffronOrange,
                            side: const BorderSide(color: AppColors.saffronOrange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: const Text('Photos'),
                          onPressed: () => context.push('/register/photo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.saffronOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Account & Activities Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.workspace_premium,
                    iconColor: Colors.amber.shade800,
                    title: 'Membership & Plans',
                    subtitle: 'Current Plan: Free (Upgrade for Phone Numbers)',
                    onTap: () => context.push('/membership'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.favorite,
                    iconColor: Colors.redAccent,
                    title: 'Shortlisted Profiles',
                    subtitle: 'Profiles you saved for review',
                    onTap: () => context.push('/shortlist'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.mail,
                    iconColor: Colors.purple,
                    title: 'Interests & Requests',
                    subtitle: 'Received, sent, and accepted interests',
                    onTap: () => context.push('/interests'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.stars,
                    iconColor: Colors.teal,
                    title: '10-Porutham Horoscope Tool',
                    subtitle: 'Check compatibility with any star & rasi',
                    onTap: () => context.push('/horoscope'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Settings & Help Menu
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder.withAlpha(80)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.translate,
                    iconColor: AppColors.saffronOrange,
                    title: 'Language',
                    subtitle: isTamil ? 'தமிழ் (Selected)' : 'English (Selected)',
                    onTap: () {
                      ref.read(localeProvider.notifier).toggleLocale();
                    },
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.shield,
                    iconColor: Colors.blue,
                    title: 'Settings & Privacy',
                    subtitle: 'Biometrics, photo privacy, notifications',
                    onTap: () => context.push('/settings'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.admin_panel_settings,
                    iconColor: Colors.indigo,
                    title: 'Developer Console (Offline DB)',
                    subtitle: 'Inspect CSV tables, export zip, seed stats',
                    onTap: () => context.push('/admin'),
                  ),
                  _buildDivider(),
                  _buildMenuItem(
                    icon: Icons.logout,
                    iconColor: Colors.red,
                    title: 'Log Out',
                    subtitle: 'Sign out of Pondy Connect',
                    onTap: () async {
                      await ref.read(authStateProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              'Pondy Connect Matrimony v1.0.0 (Offline CSV Edition)',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withAlpha(25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }
}
