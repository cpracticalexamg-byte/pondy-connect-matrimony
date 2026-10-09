import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../providers/auth_state_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendSeconds = 30;
  Timer? _timer;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendSeconds = AppConfig.otpResendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        if (mounted) {
          setState(() {
            _resendSeconds--;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final k in _keyboardFocusNodes) {
      k.dispose();
    }
    super.dispose();
  }

  String get _currentOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        _verifyOtp();
      }
    }
  }

  void _verifyOtp() async {
    final otp = _currentOtp;
    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the OTP';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    final mobile = ref.read(authStateProvider).currentMobile;
    final success = await ref.read(authStateProvider.notifier).verifyOtpAndRegister(mobile, otp);

    if (mounted) {
      if (success) {
        final profile = ref.read(authStateProvider).profile;
        if (profile != null) {
          context.go('/home');
        } else {
          context.go('/register/step1');
        }
      } else {
        setState(() {
          _errorMessage = ref.read(authStateProvider).error ?? 'Invalid OTP. Please try again.';
        });
      }
    }
  }

  void _resendOtp() async {
    final mobile = ref.read(authStateProvider).currentMobile;
    final newOtp = await ref.read(authStateProvider.notifier).requestOtp(mobile);
    _startTimer();

    if (mounted && AppConfig.devOtp && newOtp != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF065F46),
          content: Text('New DEV OTP: $newOtp'),
        ),
      );
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Your Mobile',
                style: AppTypography.titleLarge(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'OTP sent to ',
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                  ),
                  Text(
                    authState.currentMobile.isNotEmpty ? authState.currentMobile : '+91 98400 12345',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => context.pop(),
                    child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // 6 OTP Digit input boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (idx) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: RawKeyboardListener(
                      focusNode: _keyboardFocusNodes[idx],
                      onKey: (event) {
                        if (event is RawKeyDownEvent &&
                            event.logicalKey == LogicalKeyboardKey.backspace &&
                            _controllers[idx].text.isEmpty &&
                            idx > 0) {
                          _focusNodes[idx - 1].requestFocus();
                        }
                      },
                      child: TextField(
                        controller: _controllers[idx],
                        focusNode: _focusNodes[idx],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.scaffoldBg,
                          contentPadding: EdgeInsets.zero,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.fieldBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.fieldActiveBorder, width: 2),
                          ),
                        ),
                        onChanged: (val) => _onDigitChanged(idx, val),
                      ),
                    ),
                  );
                }),
              ),

              if (AppConfig.showOtpTestHint) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0x80F59E0B)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline, size: 14, color: Color(0xFFB45309)),
                        SizedBox(width: 6),
                        Text(
                          'Test Mode: Use code ${AppConfig.testOtpCode}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: AppTypography.caption(color: AppColors.errorRed),
                ),
              ],

              const SizedBox(height: 24),

              // Resend OTP countdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_resendSeconds > 0) ...[
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Resend OTP in ${_resendSeconds}s',
                      style: AppTypography.bodyMedium(color: AppColors.textMuted),
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: _resendOtp,
                      child: const Text(
                        'Resend OTP Now',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 36),

              AppButton(
                text: 'Verify & Proceed',
                onPressed: _verifyOtp,
                isLoading: authState.isLoading,
                isEnabled: _currentOtp.length == 6,
              ),

              const SizedBox(height: 24),

              // Dev hint banner
              if (AppConfig.devOtp)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Dev Mode: Any OTP or "123456" is accepted.',
                          style: AppTypography.caption(color: const Color(0xFF166534)),
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
