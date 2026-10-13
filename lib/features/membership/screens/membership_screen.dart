import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/repositories/repository_providers.dart';
import '../../../domain/entitlements/entitlements_engine.dart';
import '../../../domain/entitlements/entitlements_model.dart';
import '../../../domain/models/plan_model.dart';
import '../widgets/payment_sheet.dart';
import '../widgets/receipt_dialog.dart';

class MembershipScreen extends ConsumerStatefulWidget {
  final String? source;
  final String? field;
  final String? profileId;

  const MembershipScreen({
    super.key,
    this.source,
    this.field,
    this.profileId,
  });

  @override
  ConsumerState<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends ConsumerState<MembershipScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _regularPageController;
  bool _isLoading = true;
  List<PlanModel> _regularPlans = [];
  List<PlanModel> _exclusivePlans = [];
  int _selectedRegularIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _regularPageController = PageController(viewportFraction: 0.92);
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _regularPageController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(planRepoProvider);
      final regulars = await repo.getRegularPlans();
      final exclusives = await repo.getExclusivePlans();

      if (mounted) {
        setState(() {
          _regularPlans = regulars;
          _exclusivePlans = exclusives;
          _isLoading = false;
        });
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load plans', tag: 'MembershipScreen', error: e, stackTrace: stack);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatFieldName(String? fieldCode) {
    if (fieldCode == null || fieldCode.isEmpty) return 'Locked Details';
    switch (fieldCode) {
      case 'dob':
        return 'Date of Birth';
      case 'star':
        return 'Birth Star (Nakshatra)';
      case 'rasi':
        return 'Raasi Sign';
      case 'horoscope_chart':
      case 'horoscope':
        return 'Detailed Horoscope & Charts';
      case 'institution':
        return 'Education Institution';
      case 'employer':
        return 'Employer / Company';
      case 'contact_number':
        return 'Verified Contact Number';
      case 'verified_photos':
        return 'Verified Prime Photos';
      default:
        return fieldCode.replaceAll('_', ' ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final entitlementsAsync = ref.watch(entitlementsProvider);
    final entitlements = entitlementsAsync.value ?? Entitlements.free();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF9),
      appBar: AppBar(
        title: const Text('Upgrade Membership', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.saffronOrange))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Green-mint gradient header banner with crown tile
                  _buildHeaderBanner(entitlements),

                  // Upgrade source callout if arrived from locked field or contact
                  if (widget.source != null && widget.source!.isNotEmpty)
                    _buildSourceCallout(),

                  // Already Subscribed Status Banner
                  if (entitlements.isPaid)
                    _buildActiveSubscriptionCard(entitlements),

                  // Tabs: Regular Packs | Exclusives
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: const Color(0xFF2E7D32),
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF1B5E20),
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      tabs: const [
                        Tab(text: 'Regular Packs'),
                        Tab(text: 'Exclusives'),
                      ],
                    ),
                  ),

                  // Tab Views
                  SizedBox(
                    height: 580,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRegularPacksTab(),
                        _buildExclusivesTab(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderBanner(Entitlements entitlements) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9), Color(0xFFA5D6A7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF81C784).withAlpha(120)),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2E7D32).withAlpha(25), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.workspace_premium, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 12),
          const Text(
            'Become a paid member now!',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Directly connect with matches across Puducherry with verified contacts',
            textAlign: TextAlign.center,
            style: TextStyle(color: const Color(0xFF2E7D32).withAlpha(220), fontSize: 13, height: 1.3),
          ),
          if (AppConfig.appName.isNotEmpty && (AppConfig.appName.contains('Refund') || false)) ...[
            const SizedBox(height: 6),
            const Text(
              'Money back guarantee as per terms',
              style: TextStyle(color: Color(0xFF1B5E20), fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSourceCallout() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB74D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_open, color: Color(0xFFE65100), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Upgrading unlocks ${_formatFieldName(widget.field)} immediately',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE65100)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSubscriptionCard(Entitlements entitlements) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    entitlements.planName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B5E20)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('ACTIVE', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                entitlements.isUnlimitedContacts
                    ? 'Unlimited contact views (Fair use: 50/day)'
                    : '${entitlements.contactViewsRemaining} contact views left',
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
              if (entitlements.expiry != null)
                Text(
                  'Valid till: ${dateFormat.format(entitlements.expiry!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegularPacksTab() {
    if (_regularPlans.isEmpty) {
      return const Center(child: Text('No plans currently available.'));
    }

    return Column(
      children: [
        // Pill Selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: List.generate(_regularPlans.length, (index) {
              final plan = _regularPlans[index];
              final isSelected = _selectedRegularIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(plan.name),
                      if (plan.isBestValue) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6A1B9A),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'BEST VALUE',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedRegularIndex = index);
                      _regularPageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                  selectedColor: const Color(0xFFC8E6C9),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF1B5E20) : AppColors.textPrimary,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF2E7D32) : AppColors.borderLight,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        // Swipeable Cards
        Expanded(
          child: PageView.builder(
            controller: _regularPageController,
            itemCount: _regularPlans.length,
            onPageChanged: (index) {
              setState(() => _selectedRegularIndex = index);
            },
            itemBuilder: (context, index) {
              final plan = _regularPlans[index];
              return _buildPlanCard(plan);
            },
          ),
        ),

        // Page Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_regularPlans.length, (index) {
            final isSelected = _selectedRegularIndex == index;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              width: isSelected ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: plan.isBestValue ? const Color(0xFF7B1FA2) : AppColors.borderLight,
          width: plan.isBestValue ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Grey title bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: plan.isBestValue ? const Color(0xFFF3E5F5) : const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: plan.isBestValue ? const Color(0xFF4A148C) : AppColors.textPrimary,
                  ),
                ),
                if (plan.isBestValue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7B1FA2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'BEST VALUE',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${plan.priceInr}',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Color(0xFF1B5E20)),
                    ),
                    const SizedBox(width: 8),
                    if (plan.hasActivePromotion) ...[
                      Text(
                        '₹${plan.listPrice}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${plan.discountPercentage}% OFF',
                          style: TextStyle(color: Colors.red.shade900, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),

                // Per month badge
                if (plan.perMonthBadge.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    plan.perMonthBadge,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF388E3C), fontWeight: FontWeight.w600),
                  ),
                ],

                const Divider(height: 20),

                // Checklist of features
                ..._buildFeatureChecklist(plan),
              ],
            ),
          ),

          const Spacer(),

          // Pay Now Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: AppButton(
              text: 'Pay Now (₹${plan.priceInr})',
              onPressed: () => _onSelectPlan(plan),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFeatureChecklist(PlanModel plan) {
    if (plan.code == 'gold_3m') {
      return [
        _featureRow('Valid for 3 months', isIncluded: true),
        _featureRow('View 40 phone numbers', isIncluded: true, isBold: true),
        _featureRow('Send unlimited messages', isIncluded: true),
        _featureRow('Unlimited horoscope views', isIncluded: true),
        _featureRow('View verified profiles with photos', isIncluded: false),
      ];
    } else if (plan.code == 'prime_gold_3m') {
      return [
        _featureRow('Valid for 3 months', isIncluded: true),
        _featureRow('View unlimited phone numbers* (fair-use: 50/day)', isIncluded: true, isBold: true),
        _featureRow('Send unlimited messages', isIncluded: true),
        _featureRow('Unlimited horoscope views', isIncluded: true),
        _featureRow('View verified profiles with photos', isIncluded: true),
      ];
    } else if (plan.code == 'prime_till_marry') {
      return [
        _featureRow('Longest validity plan (until you marry)', isIncluded: true, isBold: true),
        _featureRow('View unlimited phone numbers* (fair-use: 50/day)', isIncluded: true),
        _featureRow('Send unlimited messages', isIncluded: true),
        _featureRow('Unlimited horoscope views', isIncluded: true),
        _featureRow('View verified profiles with photos', isIncluded: true),
      ];
    }

    // Default feature mapping
    return plan.features.map((f) => _featureRow(f, isIncluded: true)).toList();
  }

  Widget _featureRow(String text, {required bool isIncluded, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isIncluded ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: isIncluded ? const Color(0xFF2E7D32) : Colors.grey.shade400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isIncluded ? AppColors.textPrimary : Colors.grey.shade500,
                decoration: isIncluded ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExclusivesTab() {
    if (_exclusivePlans.isEmpty) {
      return const Center(child: Text('No add-on exclusives available right now.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _exclusivePlans.length,
      itemBuilder: (context, index) {
        final plan = _exclusivePlans[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF8BBD0)),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pink-tinted header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE4EC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Color(0xFFC2185B), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          plan.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF880E4F)),
                        ),
                      ],
                    ),
                    Text(
                      '₹${plan.priceInr}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFC2185B)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get your profile featured at the top of matches and search for ${plan.durationDays} days.',
                      style: const TextStyle(fontSize: 13, height: 1.3, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.bolt, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Includes Featured badge on profile cards',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppButton(
                      text: 'Get now (₹${plan.priceInr})',
                      onPressed: () => _onSelectPlan(plan),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onSelectPlan(PlanModel plan) async {
    final receipt = await PaymentSheet.show(context, plan);
    if (receipt != null && mounted) {
      // Invalidate entitlements cache
      ref.invalidate(entitlementsProvider);

      ReceiptDialog.show(context, receipt);

      // If opened from a lock, pop with true so caller unlocks view
      if (widget.source != null && widget.source!.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && Navigator.of(context).canPop()) {
            context.pop(true);
          }
        });
      }
    }
  }
}
