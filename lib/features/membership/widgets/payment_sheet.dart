import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/services/payment/payment_gateway.dart';
import '../../../data/services/payment/payment_provider.dart';
import '../../../domain/models/plan_model.dart';
import '../../../features/auth/providers/auth_state_provider.dart';

class PaymentSheet extends ConsumerStatefulWidget {
  final PlanModel plan;

  const PaymentSheet({super.key, required this.plan});

  static Future<PaymentReceipt?> show(BuildContext context, PlanModel plan) {
    return showModalBottomSheet<PaymentReceipt>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentSheet(plan: plan),
    );
  }

  @override
  ConsumerState<PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends ConsumerState<PaymentSheet> {
  String _selectedMethod = 'upi'; // 'upi', 'card', 'netbanking'
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.read(authStateProvider).user;
    final userId = user?.userId ?? 'USR_GUEST';
    final plan = widget.plan;

    // GST calculation: 18% inclusive
    final baseAmount = (plan.priceInr / 1.18).round();
    final gstAmount = plan.priceInr - baseAmount;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header handle and close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 0.8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, size: 14, color: Color(0xFF2E7D32)),
                        SizedBox(width: 4),
                        Text('100% SECURE CHECKOUT', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Plan Details Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            plan.isExclusive ? 'Profile Boost' : '${plan.durationMonths} Months Validity',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${plan.priceInr}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Base Price (₹)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('₹$baseAmount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GST (18% inclusive)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text('₹$gstAmount', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₹${plan.priceInr}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.saffronOrange)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Test Mode Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade400),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Test Sandbox Mode: Simulated instant approval',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),

          // Payment Options
          _buildPaymentOption(
            id: 'upi',
            icon: Icons.qr_code_scanner,
            title: 'UPI (GPay / PhonePe / Paytm)',
            subtitle: 'Instant payment via any UPI app',
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            id: 'card',
            icon: Icons.credit_card,
            title: 'Credit / Debit Card',
            subtitle: 'Visa, MasterCard, RuPay',
          ),
          const SizedBox(height: 8),
          _buildPaymentOption(
            id: 'netbanking',
            icon: Icons.account_balance,
            title: 'Net Banking',
            subtitle: 'SBI, HDFC, ICICI, Indian Bank & more',
          ),

          const SizedBox(height: 20),

          AppButton(
            text: _isProcessing ? 'Processing Transaction...' : 'Pay ₹${plan.priceInr} Securely',
            isLoading: _isProcessing,
            onPressed: _isProcessing
                ? null
                : () async {
                    setState(() => _isProcessing = true);
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    try {
                      final gateway = ref.read(paymentGatewayProvider);
                      final order = await gateway.createOrder(
                        planId: plan.planId,
                        amountInr: plan.priceInr,
                        userId: userId,
                      );

                      final receipt = await gateway.confirmPayment(
                        order: order,
                        plan: plan,
                        paymentMethod: _selectedMethod.toUpperCase(),
                        buyerState: 'Puducherry',
                      );

                      if (mounted) {
                        navigator.pop(receipt);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isProcessing = false);
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Payment simulation failed: $e')),
                        );
                      }
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption({
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F8E9) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : AppColors.borderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF2E7D32) : AppColors.textSecondary, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? const Color(0xFF1B5E20) : AppColors.textPrimary)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
