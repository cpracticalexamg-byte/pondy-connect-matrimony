import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../core/widgets/pondy_logo.dart';
import '../providers/auth_state_provider.dart';

class RegisterScreen0 extends ConsumerStatefulWidget {
  const RegisterScreen0({super.key});

  @override
  ConsumerState<RegisterScreen0> createState() => _RegisterScreen0State();
}

class _RegisterScreen0State extends ConsumerState<RegisterScreen0> {
  final TextEditingController _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedProfileFor = 'Myself';
  String? _mobileError;

  final List<String> _profileForOptions = [
    'Myself',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Friend',
    'Relative',
  ];

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _validateAndSubmit() async {
    final rawNumber = _mobileController.text.trim();
    if (rawNumber.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(rawNumber)) {
      setState(() {
        _mobileError = 'Please enter a valid 10-digit Indian mobile number';
      });
      return;
    }

    setState(() {
      _mobileError = null;
    });

    final fullMobile = '+91 $rawNumber';
    ref.read(authStateProvider.notifier).setProfileFor(_selectedProfileFor);
    ref.read(authStateProvider.notifier).setMobile(fullMobile);

    final otp = await ref.read(authStateProvider.notifier).requestOtp(fullMobile);

    if (mounted) {
      if (AppConfig.devOtp && otp != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF065F46),
            duration: const Duration(seconds: 8),
            content: Row(
              children: [
                const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'DEV OTP for $fullMobile: $otp',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      context.push('/register/otp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
          onPressed: () => context.go('/onboarding'),
        ),
        title: const PondyLogo(size: 28, showText: true, isHorizontal: true),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Create Your Profile',
                  style: AppTypography.titleLarge(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                Text(
                  'Join thousands of verified brides & grooms in Puducherry',
                  style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                // "Profile created for" section
                Text(
                  'This profile is for',
                  style: AppTypography.sectionTitle(),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _profileForOptions.map((option) {
                    final isSelected = _selectedProfileFor == option;
                    return PillChip(
                      label: option,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedProfileFor = option;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Mobile number field
                Text(
                  'Mobile Number',
                  style: AppTypography.sectionTitle(),
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _mobileError != null ? AppColors.errorRed : AppColors.fieldBorder,
                      width: _mobileError != null ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBg,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(9),
                            bottomLeft: Radius.circular(9),
                          ),
                          border: Border(
                            right: BorderSide(color: AppColors.fieldBorder.withOpacity(0.5)),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              '🇮🇳 +91',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: 'Enter 10-digit mobile number',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (_) {
                            if (_mobileError != null) {
                              setState(() {
                                _mobileError = null;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                if (_mobileError != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      _mobileError!,
                      style: AppTypography.caption(color: AppColors.errorRed),
                    ),
                  ),

                const SizedBox(height: 28),

                // Terms disclaimer
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.shield_outlined, size: 18, color: AppColors.chipSelectedStart),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'By continuing, you agree to our Terms of Service & Privacy Policy. We never share your phone number without your consent.',
                        style: AppTypography.caption(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 36),

                // Action Button
                AppButton(
                  text: 'Continue with OTP',
                  onPressed: _validateAndSubmit,
                  isLoading: authState.isLoading,
                ),

                const SizedBox(height: 20),

                // Login link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                      ),
                      InkWell(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Login here',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
