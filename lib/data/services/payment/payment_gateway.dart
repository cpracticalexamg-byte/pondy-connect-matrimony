import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../../core/utils/app_logger.dart';
import '../../csv/csv_schema.dart';
import '../../csv/csv_store.dart';
import '../../../domain/models/plan_model.dart';

class PaymentOrder {
  final String orderId;
  final String planId;
  final String userId;
  final int amountInr;
  final DateTime createdAt;

  const PaymentOrder({
    required this.orderId,
    required this.planId,
    required this.userId,
    required this.amountInr,
    required this.createdAt,
  });
}

class PaymentReceipt {
  final String paymentId;
  final String invoiceNumber;
  final String planName;
  final int baseAmount;
  final int gstAmount;
  final int totalAmount;
  final String paymentMethod;
  final String buyerState;
  final DateTime paidAt;

  const PaymentReceipt({
    required this.paymentId,
    required this.invoiceNumber,
    required this.planName,
    required this.baseAmount,
    required this.gstAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.buyerState,
    required this.paidAt,
  });
}

abstract class PaymentGateway {
  Future<PaymentOrder> createOrder({
    required String planId,
    required int amountInr,
    required String userId,
  });

  Future<PaymentReceipt> confirmPayment({
    required PaymentOrder order,
    required PlanModel plan,
    required String paymentMethod,
    String buyerState = 'Puducherry',
  });

  Future<bool> verifyPayment({required String paymentId});
}

class MockPaymentGateway implements PaymentGateway {
  final CsvStore _store;

  MockPaymentGateway({CsvStore? store}) : _store = store ?? CsvStore.instance;

  @override
  Future<PaymentOrder> createOrder({
    required String planId,
    required int amountInr,
    required String userId,
  }) async {
    final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    return PaymentOrder(
      orderId: orderId,
      planId: planId,
      userId: userId,
      amountInr: amountInr,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaymentReceipt> confirmPayment({
    required PaymentOrder order,
    required PlanModel plan,
    required String paymentMethod,
    String buyerState = 'Puducherry',
  }) async {
    final now = DateTime.now();
    final paymentId = const Uuid().v4();
    final invoiceNumber = 'INV-${now.year}-${Random().nextInt(900000) + 100000}';

    // 18% GST calculation (GST inclusive in price)
    // Base + 18% of Base = Total -> Base = Total / 1.18
    final totalAmount = order.amountInr;
    final baseAmount = (totalAmount / 1.18).round();
    final gstAmount = totalAmount - baseAmount;

    // 1. Record payment
    await _store.insert(CsvSchema.paymentsTable, {
      'payment_id': paymentId,
      'user_id': order.userId,
      'plan_id': plan.planId,
      'amount_inr': totalAmount.toString(),
      'currency': 'INR',
      'gateway': 'mock_gateway',
      'gateway_ref': order.orderId,
      'status': 'success',
      'created_at': now.toIso8601String(),
    });

    // 2. Record invoice
    final invoiceId = const Uuid().v4();
    await _store.insert(CsvSchema.invoicesTable, {
      'invoice_id': invoiceId,
      'payment_id': paymentId,
      'user_profile_id': order.userId,
      'invoice_number': invoiceNumber,
      'base_amount': baseAmount.toString(),
      'gst_amount': gstAmount.toString(),
      'total_amount': totalAmount.toString(),
      'buyer_state': buyerState,
      'created_at': now.toIso8601String(),
    });

    // 3. Record or update subscription
    if (plan.isExclusive) {
      // It's a Profile Highlighter boost
      final boostId = const Uuid().v4();
      final endsAt = now.add(Duration(days: plan.durationDays));
      await _store.insert(CsvSchema.exclusiveBoostsTable, {
        'boost_id': boostId,
        'profile_id': order.userId,
        'plan_id': plan.planId,
        'starts_at': now.toIso8601String(),
        'ends_at': endsAt.toIso8601String(),
      });
      AppLogger.info('Applied Profile Highlighter boost ($boostId) for user ${order.userId} until $endsAt', tag: 'MockPaymentGateway');
    } else {
      // Regular membership subscription
      final subId = const Uuid().v4();
      final expiry = plan.endsOnMarriage
          ? now.add(const Duration(days: 730)) // 24 months inactivity default
          : now.add(Duration(days: plan.durationDays));

      // Expire previous active subscriptions
      await _store.update(
        CsvSchema.subscriptionsTable,
        {'status': 'upgraded', 'updated_at': now.toIso8601String()},
        (r) => r['user_id'] == order.userId && r['status'] == 'active',
      );

      await _store.insert(CsvSchema.subscriptionsTable, {
        'subscription_id': subId,
        'user_id': order.userId,
        'plan_id': plan.planId,
        'started_at': now.toIso8601String(),
        'expires_at': expiry.toIso8601String(),
        'payment_ref': paymentId,
        'status': 'active',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      AppLogger.info('Activated subscription ($subId) for user ${order.userId} on plan ${plan.name}', tag: 'MockPaymentGateway');
    }

    return PaymentReceipt(
      paymentId: paymentId,
      invoiceNumber: invoiceNumber,
      planName: plan.name,
      baseAmount: baseAmount,
      gstAmount: gstAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      buyerState: buyerState,
      paidAt: now,
    );
  }

  @override
  Future<bool> verifyPayment({required String paymentId}) async {
    final rows = await _store.query(
      CsvSchema.paymentsTable,
      (r) => r['payment_id'] == paymentId && r['status'] == 'success',
    );
    return rows.isNotEmpty;
  }
}
