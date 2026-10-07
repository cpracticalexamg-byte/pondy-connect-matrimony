import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/pondy_logo.dart';
import '../providers/auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final rawNumber = _mobileController.text.trim();
    if (rawNumber.length != 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number';
      });
      return;
    }

    final fullMobile = '+91 $rawNumber';
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
    });

    final success = await ref.read(authStateProvider.notifier).loginWithPassword(fullMobile, password);

    if (mounted) {
      if (success) {
        context.go('/home');
      } else {
        setState(() {
          _errorMessage = ref.read(authStateProvider).error ?? 'Invalid mobile or password. You can also login with OTP.';
        });
      }
    }
  }

  void _loginWithOtp() {
    final rawNumber = _mobileController.text.trim();
    if (rawNumber.length == 10) {
      ref.read(authStateProvider.notifier).setMobile('+91 $rawNumber');
    }
    context.push('/register');
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Welcome Back',
                style: AppTypography.titleLarge(),
              ),
              const SizedBox(height: 6),
              Text(
                'Login to view matches, respond to interests, and chat',
                style: AppTypography.bodyMedium(color: AppColors.textSecondary),
              ),

              const SizedBox(height: 32),

              // Mobile number
              Text(
                'Mobile Number',
                style: AppTypography.sectionTitle(),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.fieldBorder),
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
                      child: const Text(
                        '🇮🇳 +91',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Password
              Text(
                'Password',
                style: AppTypography.sectionTitle(),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppTypography.caption(color: AppColors.errorRed),
                ),
              ],

              const SizedBox(height: 32),

              AppButton(
                text: 'Login',
                onPressed: _handleLogin,
                isLoading: authState.isLoading,
              ),

              const SizedBox(height: 16),

              // Login with OTP option
              Center(
                child: TextButton.icon(
                  onPressed: _loginWithOtp,
                  icon: const Icon(Icons.sms_outlined, size: 18, color: AppColors.chipSelectedStart),
                  label: const Text(
                    'Login with OTP instead',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.chipSelectedStart,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Register CTA
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don’t have an account? ',
                      style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                    ),
                    InkWell(
                      onTap: () => context.go('/register'),
                      child: const Text(
                        'Register Free',
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
    );
  }
}
