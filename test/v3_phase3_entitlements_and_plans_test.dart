import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_schema.dart';
import 'package:pondy_connect_matrimony/data/csv/csv_store.dart';
import 'package:pondy_connect_matrimony/data/repositories/plan_repository.dart';
import 'package:pondy_connect_matrimony/data/services/payment/payment_gateway.dart';
import 'package:pondy_connect_matrimony/domain/entitlements/entitlements_engine.dart';
import 'package:pondy_connect_matrimony/domain/entitlements/entitlements_model.dart';
import 'package:pondy_connect_matrimony/domain/models/plan_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late CsvStore testStore;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('v3_phase3_test_');
    testStore = CsvStore.instance;
    await testStore.initialize(customDir: tempDir);

    await testStore.delete(CsvSchema.plansTable, (r) => true);
    await testStore.delete(CsvSchema.fieldVisibilityTable, (r) => true);
    await testStore.delete(CsvSchema.subscriptionsTable, (r) => true);
    await testStore.delete(CsvSchema.paymentsTable, (r) => true);
    await testStore.delete(CsvSchema.invoicesTable, (r) => true);
    await testStore.delete(CsvSchema.contactViewsTable, (r) => true);

    // Populate plans
    final plans = [
      {
        'plan_id': 'plan_gold_3m',
        'code': 'gold_3m',
        'name': 'Gold · 3 Months',
        'tier': 'gold',
        'price_inr': '999',
        'list_price': '0',
        'promo_start': '',
        'promo_end': '',
        'duration_days': '90',
        'duration_months': '3',
        'contact_view_limit': '40',
        'daily_contact_cap': '40',
        'unlimited_messages': '1',
        'unlimited_horoscope': '1',
        'verified_photo_access': '0',
        'is_best_value': '0',
        'is_exclusive': '0',
        'ends_on_marriage': '0',
        'features_json': '["40 contacts","Unlimited chat","Horoscope"]',
        'sort_order': '1',
        'is_active': '1',
      },
      {
        'plan_id': 'plan_prime_gold_3m',
        'code': 'prime_gold_3m',
        'name': 'Prime Gold · 3 Months',
        'tier': 'prime_gold',
        'price_inr': '1999',
        'list_price': '0',
        'promo_start': '',
        'promo_end': '',
        'duration_days': '90',
        'duration_months': '3',
        'contact_view_limit': '-1',
        'daily_contact_cap': '50',
        'unlimited_messages': '1',
        'unlimited_horoscope': '1',
        'verified_photo_access': '1',
        'is_best_value': '0',
        'is_exclusive': '0',
        'ends_on_marriage': '0',
        'features_json': '["Unlimited contacts*","Unlimited chat","Horoscope","Verified photos"]',
        'sort_order': '2',
        'is_active': '1',
      },
      {
        'plan_id': 'plan_prime_till_marry',
        'code': 'prime_till_marry',
        'name': 'Prime – Till U Marry',
        'tier': 'till_u_marry',
        'price_inr': '4999',
        'list_price': '0',
        'promo_start': '',
        'promo_end': '',
        'duration_days': '730',
        'duration_months': '24',
        'contact_view_limit': '-1',
        'daily_contact_cap': '50',
        'unlimited_messages': '1',
        'unlimited_horoscope': '1',
        'verified_photo_access': '1',
        'is_best_value': '1',
        'is_exclusive': '0',
        'ends_on_marriage': '1',
        'features_json': '["Longest validity","Unlimited contacts*","Unlimited chat","Horoscope","Verified photos"]',
        'sort_order': '3',
        'is_active': '1',
      },
      {
        'plan_id': 'plan_boost_15',
        'code': 'highlighter_15d',
        'name': 'Profile Highlighter · 15 Days',
        'tier': 'highlighter',
        'price_inr': '199',
        'list_price': '0',
        'promo_start': '',
        'promo_end': '',
        'duration_days': '15',
        'duration_months': '0',
        'contact_view_limit': '0',
        'daily_contact_cap': '0',
        'unlimited_messages': '0',
        'unlimited_horoscope': '0',
        'verified_photo_access': '0',
        'is_best_value': '0',
        'is_exclusive': '1',
        'ends_on_marriage': '0',
        'features_json': '["Featured at top for 15 days"]',
        'sort_order': '4',
        'is_active': '1',
      },
    ];

    for (final p in plans) {
      await testStore.insert(CsvSchema.plansTable, p);
    }

    // Populate field_visibility
    final visibilityRules = [
      {'field_code': 'caste', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'sub_caste', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'gothram', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'employment_type', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'annual_income', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'education_level', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'occupation', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'family_status', 'free': '1', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'dob', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'star', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'rasi', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'horoscope_chart', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'institution', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'employer', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'verified_photos', 'free': '0', 'gold': '0', 'prime_gold': '1', 'till_u_marry': '1'},
      {'field_code': 'contact_number', 'free': '0', 'gold': '1', 'prime_gold': '1', 'till_u_marry': '1'},
    ];

    for (final v in visibilityRules) {
      await testStore.insert(CsvSchema.fieldVisibilityTable, v);
    }
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Phase 3: Entitlements Matrix Tests', () {
    test('Free tier entitlements restrict sensitive fields and messaging', () {
      final free = Entitlements.free();
      expect(free.tier, equals('free'));
      expect(free.isPaid, isFalse);
      expect(free.isPrime, isFalse);
      expect(free.canMessage, isFalse);
      expect(free.canViewHoroscope, isFalse);
      expect(free.canViewVerifiedPhotos, isFalse);
      expect(free.contactViewsRemaining, equals(0));
      expect(free.maxInterestsPerDay, equals(10));

      // Free visible
      expect(free.fieldVisible('caste'), isTrue);
      expect(free.fieldVisible('occupation'), isTrue);
      expect(free.fieldVisible('annual_income'), isTrue);

      // Free locked
      expect(free.fieldVisible('dob'), isFalse);
      expect(free.fieldVisible('star'), isFalse);
      expect(free.fieldVisible('rasi'), isFalse);
      expect(free.fieldVisible('horoscope_chart'), isFalse);
      expect(free.fieldVisible('institution'), isFalse);
      expect(free.fieldVisible('employer'), isFalse);
      expect(free.fieldVisible('verified_photos'), isFalse);
      expect(free.fieldVisible('contact_number'), isFalse);
    });

    test('Gold tier entitlements unlock horoscope, DOB and contacts but NOT verified photos', () {
      final gold = Entitlements.gold(contactViewsRemaining: 35);
      expect(gold.tier, equals('gold'));
      expect(gold.isPaid, isTrue);
      expect(gold.isPrime, isFalse);
      expect(gold.canMessage, isTrue);
      expect(gold.canViewHoroscope, isTrue);
      expect(gold.canViewVerifiedPhotos, isFalse);
      expect(gold.contactViewsRemaining, equals(35));

      // Unlocked
      expect(gold.fieldVisible('dob'), isTrue);
      expect(gold.fieldVisible('star'), isTrue);
      expect(gold.fieldVisible('horoscope_chart'), isTrue);
      expect(gold.fieldVisible('institution'), isTrue);
      expect(gold.fieldVisible('employer'), isTrue);
      expect(gold.fieldVisible('contact_number'), isTrue);

      // Still locked for Gold
      expect(gold.fieldVisible('verified_photos'), isFalse);
    });

    test('Prime Gold and Till U Marry unlock everything including verified photos', () {
      final prime = Entitlements.primeGold();
      expect(prime.tier, equals('prime_gold'));
      expect(prime.isPaid, isTrue);
      expect(prime.isPrime, isTrue);
      expect(prime.canMessage, isTrue);
      expect(prime.canViewHoroscope, isTrue);
      expect(prime.canViewVerifiedPhotos, isTrue);
      expect(prime.isUnlimitedContacts, isTrue);
      expect(prime.fieldVisible('verified_photos'), isTrue);

      final tillMarry = Entitlements.primeTillMarry();
      expect(tillMarry.tier, equals('till_u_marry'));
      expect(tillMarry.isPrime, isTrue);
      expect(tillMarry.isUnlimitedContacts, isTrue);
      expect(tillMarry.fieldVisible('verified_photos'), isTrue);
    });
  });

  group('Phase 3: Plan Pricing and Promo Specification Tests', () {
    test('Plans have exact prices 999, 1999, 4999 and proper per-month badges', () async {
      final repo = CsvPlanRepository(store: testStore);
      final regularPlans = await repo.getRegularPlans();
      expect(regularPlans.length, equals(3));

      final gold = regularPlans.firstWhere((p) => p.code == 'gold_3m');
      expect(gold.priceInr, equals(999));
      expect(gold.durationMonths, equals(3));
      expect(gold.perMonthBadge, equals('~₹333 per month'));
      expect(gold.hasActivePromotion, isFalse);

      final prime = regularPlans.firstWhere((p) => p.code == 'prime_gold_3m');
      expect(prime.priceInr, equals(1999));
      expect(prime.durationMonths, equals(3));
      expect(prime.perMonthBadge, equals('~₹666 per month'));

      final tillMarry = regularPlans.firstWhere((p) => p.code == 'prime_till_marry');
      expect(tillMarry.priceInr, equals(4999));
      expect(tillMarry.endsOnMarriage, isTrue);
      expect(tillMarry.perMonthBadge, isEmpty); // Omitted for Till U Marry
    });

    test('Promo discount calculation activates strictly on genuine promo date window', () {
      final now = DateTime.now();
      final promoStart = now.subtract(const Duration(days: 1)).toIso8601String();
      final promoEnd = now.add(const Duration(days: 2)).toIso8601String();

      final promoPlan = PlanModel(
        planId: 'plan_promo',
        code: 'promo',
        name: 'Special Promo',
        tier: 'gold',
        priceInr: 999,
        listPrice: 1499,
        promoStart: promoStart,
        promoEnd: promoEnd,
      );

      expect(promoPlan.hasActivePromotion, isTrue);
      expect(promoPlan.discountPercentage, equals(33));

      // Expired promo
      final expiredPlan = PlanModel(
        planId: 'plan_expired',
        code: 'expired',
        name: 'Expired Promo',
        tier: 'gold',
        priceInr: 999,
        listPrice: 1499,
        promoStart: now.subtract(const Duration(days: 5)).toIso8601String(),
        promoEnd: now.subtract(const Duration(days: 1)).toIso8601String(),
      );
      expect(expiredPlan.hasActivePromotion, isFalse);
    });
  });

  group('Phase 3: Payment Gateway and Invoices Integration', () {
    test('MockPaymentGateway creates order, confirms payment and generates invoice with 18% GST', () async {
      final gateway = MockPaymentGateway(store: testStore);
      final repo = CsvPlanRepository(store: testStore);
      final goldPlan = (await repo.getPlanByCode('gold_3m'))!;

      final order = await gateway.createOrder(
        planId: goldPlan.planId,
        amountInr: goldPlan.priceInr,
        userId: 'USR_TEST_101',
      );

      expect(order.orderId.isNotEmpty, isTrue);
      expect(order.amountInr, equals(999));

      final receipt = await gateway.confirmPayment(
        order: order,
        plan: goldPlan,
        paymentMethod: 'UPI',
        buyerState: 'Puducherry',
      );

      expect(receipt.totalAmount, equals(999));
      expect(receipt.baseAmount + receipt.gstAmount, equals(999));
      expect(receipt.invoiceNumber.startsWith('INV-'), isTrue);
      expect(receipt.buyerState, equals('Puducherry'));

      // Verify payment was recorded in store
      final isVerified = await gateway.verifyPayment(paymentId: receipt.paymentId);
      expect(isVerified, isTrue);

      // Verify EntitlementsEngine now computes Gold for user
      final engine = EntitlementsEngine(store: testStore);
      final entitlements = await engine.getEntitlements('USR_TEST_101');
      expect(entitlements.isPaid, isTrue);
      expect(entitlements.tier, equals('gold'));
      expect(entitlements.contactViewsRemaining, equals(40));
    });

    test('Subscription expiry automatically downgrades to Free tier', () async {
      // Insert an expired subscription
      final past = DateTime.now().subtract(const Duration(days: 10));
      await testStore.insert(CsvSchema.subscriptionsTable, {
        'subscription_id': 'SUB_EXPIRED_01',
        'user_id': 'USR_EXPIRED',
        'plan_id': 'plan_gold_3m',
        'started_at': past.subtract(const Duration(days: 90)).toIso8601String(),
        'expires_at': past.toIso8601String(),
        'payment_ref': 'PAY_OLD',
        'status': 'active',
        'created_at': past.toIso8601String(),
        'updated_at': past.toIso8601String(),
      });

      final engine = EntitlementsEngine(store: testStore);
      final entitlements = await engine.getEntitlements('USR_EXPIRED');

      // Auto-downgraded to free
      expect(entitlements.isPaid, isFalse);
      expect(entitlements.tier, equals('free'));
      expect(entitlements.fieldVisible('dob'), isFalse);
    });
  });
}
