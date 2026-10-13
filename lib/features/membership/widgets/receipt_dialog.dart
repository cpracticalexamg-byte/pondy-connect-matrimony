import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/services/payment/payment_gateway.dart';

class ReceiptDialog extends StatelessWidget {
  final PaymentReceipt receipt;

  const ReceiptDialog({super.key, required this.receipt});

  static void show(BuildContext context, PaymentReceipt receipt) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReceiptDialog(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success checkmark animation container
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1B5E20)),
            ),
            const SizedBox(height: 4),
            const Text(
              'Your membership is now active',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Receipt Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  _receiptRow('Invoice No.', receipt.invoiceNumber),
                  const SizedBox(height: 6),
                  _receiptRow('Plan', receipt.planName),
                  const SizedBox(height: 6),
                  _receiptRow('Date', dateFormat.format(receipt.paidAt)),
                  const SizedBox(height: 6),
                  _receiptRow('Base Amount', '₹${receipt.baseAmount}'),
                  const SizedBox(height: 6),
                  _receiptRow('GST (18%)', '₹${receipt.gstAmount}'),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(
                        '₹${receipt.totalAmount}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            AppButton(
              text: 'Done & Continue',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
