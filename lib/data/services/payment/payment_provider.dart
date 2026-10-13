import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_gateway.dart';

final paymentGatewayProvider = Provider<PaymentGateway>((ref) {
  return MockPaymentGateway();
});
