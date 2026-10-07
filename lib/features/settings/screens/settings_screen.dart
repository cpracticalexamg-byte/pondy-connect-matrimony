import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/providers/auth_state_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;
  String _photoPrivacy = 'all';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _biometricEnabled = prefs.getBool('biometric_enabled') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _photoPrivacy = prefs.getString('photo_privacy') ?? 'all';
    });
  }

  Future<void> _toggleBiometrics(bool enable) async {
    if (enable) {
      try {
        final canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
        if (!canAuth) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Biometric authentication not supported on this device.')),
            );
          }
          return;
        }

        final didAuth = await _auth.authenticate(
          localizedReason: 'Please authenticate to enable Biometric Lock',
          options: const AuthenticationOptions(biometricOnly: true),
        );

        if (!didAuth) return;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Biometrics error: $e')));
        }
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', enable);
    setState(() => _biometricEnabled = enable);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isTamil = locale.languageCode == 'ta';

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Settings & Privacy', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Security & Login'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint, color: AppColors.saffronOrange),
                  title: const Text('Biometric App Lock', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Fingerprint or Face unlock upon opening app', style: TextStyle(fontSize: 12)),
                  value: _biometricEnabled,
                  activeColor: AppColors.saffronOrange,
                  onChanged: _toggleBiometrics,
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_active_outlined, color: Colors.blue),
                  title: const Text('Push & Match Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Get notified for new interests & messages', style: TextStyle(fontSize: 12)),
                  value: _notificationsEnabled,
                  activeColor: AppColors.saffronOrange,
                  onChanged: (val) async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notifications_enabled', val);
                    setState(() => _notificationsEnabled = val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Privacy Controls'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.teal),
                  title: const Text('Photo Visibility', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(_privacyLabel(_photoPrivacy), style: const TextStyle(fontSize: 12, color: AppColors.saffronOrange)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPhotoPrivacySheet(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Language & Preferences'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate, color: Colors.purple),
                  title: const Text('App Language', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(isTamil ? 'தமிழ் (Tamil)' : 'English', style: const TextStyle(fontSize: 12, color: AppColors.saffronOrange)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ref.read(localeProvider.notifier).toggleLocale();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader('Account Actions'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.orange),
                  title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  onTap: () async {
                    await ref.read(authStateProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                  subtitle: const Text('Permanently remove your profile and chats', style: TextStyle(fontSize: 11)),
                  onTap: () => _showDeleteDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title, style: AppTypography.heading3.copyWith(fontSize: 14, color: AppColors.textSecondary)),
    );
  }

  String _privacyLabel(String code) {
    switch (code) {
      case 'members':
        return 'Visible to Registered Members Only';
      case 'request':
        return 'Visible on Request / Blurred';
      default:
        return 'Visible to All Users';
    }
  }

  void _showPhotoPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Photo Privacy Settings', style: AppTypography.heading3),
            const SizedBox(height: 12),
            RadioListTile<String>(
              title: const Text('Visible to All'),
              subtitle: const Text('All matrimony searchers can view your photo'),
              value: 'all',
              groupValue: _photoPrivacy,
              activeColor: AppColors.saffronOrange,
              onChanged: (val) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('photo_privacy', val!);
                setState(() => _photoPrivacy = val);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Visible to Members Only'),
              subtitle: const Text('Only registered logged-in members can view'),
              value: 'members',
              groupValue: _photoPrivacy,
              activeColor: AppColors.saffronOrange,
              onChanged: (val) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('photo_privacy', val!);
                setState(() => _photoPrivacy = val);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
            RadioListTile<String>(
              title: const Text('Visible on Request / Blurred'),
              subtitle: const Text('Photo is blurred until you grant permission'),
              value: 'request',
              groupValue: _photoPrivacy,
              activeColor: AppColors.saffronOrange,
              onChanged: (val) async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('photo_privacy', val!);
                setState(() => _photoPrivacy = val);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action is irreversible. All your messages, interests and profile data will be permanently removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) context.go('/login');
            },
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }
}
