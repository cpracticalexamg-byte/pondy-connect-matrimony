import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/models/plan_model.dart';
import '../../auth/providers/auth_state_provider.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  const MembershipScreen({super.key});

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> {
  bool _isLoading = true;
  List<PlanModel> _plans = [];
  String _selectedPlanId = 'gold';

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(planRepoProvider);
      final plans = await repo.getPlans();
      if (mounted) {
        setState(() {
          _plans = plans;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load membership plans', tag: 'MembershipScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Membership Plans', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Premium Header Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2670A), Color(0xFFC75404)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: AppColors.saffronOrange.withAlpha(60), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.workspace_premium, color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Pondy Connect Premium',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Connect directly with compatible matches across Puducherry',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Plans List
                  ..._plans.map((plan) {
                    final isSelected = _selectedPlanId == plan.planId;
                    final isPopular = plan.planId == 'gold';

                    final List<String> features = plan.features.isNotEmpty
                        ? plan.features
                        : [
                            'View ${plan.contactsViewLimit} verified phone numbers',
                            plan.chatEnabled ? 'Direct instant chat' : 'Limited chat',
                            '10-Porutham horoscope analysis',
                          ];
                    final badge = plan.badge.isNotEmpty ? plan.badge : (isPopular ? 'Most Popular' : '');

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlanId = plan.planId;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppColors.saffronOrange : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected ? AppColors.saffronOrange.withAlpha(20) : Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (badge.toString().isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPopular ? AppColors.saffronOrange : Colors.grey.shade800,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(14),
                                    topRight: Radius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  badge.toString().toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        plan.name,
                                        style: AppTypography.heading3.copyWith(fontSize: 18),
                                      ),
                                      Text(
                                        plan.priceInr == 0 ? 'FREE' : '₹${plan.priceInr}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.saffronOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${plan.durationMonths} Months Duration',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 12),
                                  ...features.map((f) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle, size: 16, color: AppColors.successGreen),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                f.toString(),
                                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  const SizedBox(height: 14),
                                  if (plan.priceInr > 0)
                                    AppButton(
                                      text: 'Choose ${plan.name}',
                                      backgroundColor: isSelected ? AppColors.saffronOrange : Colors.grey.shade100,
                                      textColor: isSelected ? Colors.white : AppColors.textPrimary,
                                      onPressed: () {
                                        _showPaymentSheet(context, plan);
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  void _showPaymentSheet(BuildContext context, PlanModel plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String selectedMethod = 'upi';
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Complete Upgrade to ${plan.name}', style: AppTypography.heading3),
                  Text('Amount: ₹${plan.priceInr} (Inclusive of GST)', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 16),

                  // Mock Payment Options
                  ListTile(
                    leading: const Icon(Icons.qr_code, color: AppColors.saffronOrange),
                    title: const Text('UPI (Google Pay, PhonePe, Paytm)'),
                    trailing: Radio<String>(
                      value: 'upi',
                      groupValue: selectedMethod,
                      activeColor: AppColors.saffronOrange,
                      onChanged: (v) => setModalState(() => selectedMethod = v!),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.credit_card, color: Colors.blue),
                    title: const Text('Credit / Debit Card'),
                    trailing: Radio<String>(
                      value: 'card',
                      groupValue: selectedMethod,
                      activeColor: AppColors.saffronOrange,
                      onChanged: (v) => setModalState(() => selectedMethod = v!),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.account_balance, color: Colors.green),
                    title: const Text('Net Banking'),
                    trailing: Radio<String>(
                      value: 'netbanking',
                      groupValue: selectedMethod,
                      activeColor: AppColors.saffronOrange,
                      onChanged: (v) => setModalState(() => selectedMethod = v!),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (isProcessing)
                    const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
                  else
                    AppButton(
                      text: 'Pay ₹${plan.priceInr}',
                      onPressed: () async {
                        setModalState(() => isProcessing = true);
                        await Future.delayed(const Duration(milliseconds: 1400));

                        final authState = ref.read(authStateProvider);
                        final userId = authState.user?.userId ?? 'USR_DEMO';
                        await ref.read(planRepoProvider).subscribeUser(
                              userId,
                              plan.planId,
                              'MOCK_TXN_${DateTime.now().millisecondsSinceEpoch}',
                            );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          _showSuccessDialog(context, plan);
                        }
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(BuildContext context, PlanModel plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified, color: AppColors.successGreen, size: 64),
            const SizedBox(height: 16),
            Text('Upgrade Successful! 🎉', style: AppTypography.heading3.copyWith(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              'You are now subscribed to ${plan.name} Plan for ${plan.durationMonths} months. Enjoy viewing contact numbers and direct chats!',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.saffronOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                context.pop();
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
