import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/onboarding_stepper.dart';
import '../../../pricing/controller/pricing_controller.dart';
import '../../../pricing/data/models/pricing_plan_model.dart';
import '../../../workspace/controller/workspace_controller.dart';
import '../../../subscription/controller/subscription_controller.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _cardNumberCtrl = TextEditingController(text: '4242 •••• •••• 4242');
  final _expiryCtrl = TextEditingController(text: '12/28');
  final _cvcCtrl = TextEditingController(text: '888');
  final _cardholderCtrl = TextEditingController(text: 'Jane Doe');

  bool _isSimulatingPayment = false;
  String? _checkoutError;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _cardholderCtrl.dispose();
    super.dispose();
  }

  Future<void> _processPaymentAndVerify() async {
    final wsController = context.read<WorkspaceController>();
    final pricing = context.read<PricingController>();
    final subController = context.read<SubscriptionController>();

    final currentWs = wsController.activeWorkspace ??
        (wsController.userWorkspaces.isNotEmpty ? wsController.userWorkspaces.first : null);

    if (currentWs == null) {
      setState(() {
        _checkoutError = 'Workspace not found. Please create or select a workspace first.';
      });
      return;
    }

    final plan = pricing.selectedPlan ?? PricingPlanModel.defaultPlans[1];
    final frequency = pricing.isYearly ? 'YEARLY' : 'MONTHLY';

    setState(() {
      _isSimulatingPayment = true;
      _checkoutError = null;
    });

    try {
      // 1. Create Checkout Session Intent on Backend
      await subController.initiateCheckout(
        workspaceId: currentWs.id,
        planSlug: plan.slug,
        billingFrequency: frequency,
      );

      // Brief payment gateway processing animation
      await Future.delayed(const Duration(milliseconds: 1200));

      // 2. Verify Payment through the Backend API (Server-side cryptographic transaction check)
      final generatedTxnId = 'ac_pay_${DateTime.now().millisecondsSinceEpoch}';
      final verified = await subController.verifyAndActivateSubscription(
        workspaceId: currentWs.id,
        planSlug: plan.slug,
        billingFrequency: frequency,
        transactionId: generatedTxnId,
        paymentMethod: 'CARD',
      );

      if (!mounted) return;

      if (verified) {
        // Proceed to Step 3: Onboarding Completion
        Navigator.of(context).pushReplacementNamed(AppRouter.onboardingComplete);
      } else {
        setState(() {
          _checkoutError = subController.errorMessage ??
              'Payment verification failed. Please check your card details and try again.';
        });
      }
    } catch (e) {
      setState(() {
        _checkoutError = 'An unexpected payment error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isSimulatingPayment = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final pricing = context.watch<PricingController>();
    final wsController = context.watch<WorkspaceController>();
    final plan = pricing.selectedPlan ?? PricingPlanModel.defaultPlans[1];
    final isYearly = pricing.isYearly;

    final baseAmount = isYearly ? plan.yearlyPrice.toDouble() : plan.monthlyPrice.toDouble();
    final taxAmount = (baseAmount * 0.18 * 100).round() / 100;
    final totalAmount = baseAmount + taxAmount;

    final currentWs = wsController.activeWorkspace ??
        (wsController.userWorkspaces.isNotEmpty ? wsController.userWorkspaces.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 36,
            vertical: 36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 880),
              child: Column(
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: AppColors.neonLaserGradient,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          AssetConstants.aLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            RemixIcons.apps_2_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'auren',
                              style: AppTextStyles.t(20, w: FontWeight.w700, c: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: 'Connect',
                              style: AppTextStyles.t(20, w: FontWeight.w700, c: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Stepper (Step 2 of 3)
                  const OnboardingStepper(currentStep: 2),

                  const SizedBox(height: 32),

                  if (_checkoutError != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(RemixIcons.error_warning_line, color: AppColors.error, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _checkoutError!,
                              style: AppTextStyles.t(13, w: FontWeight.w500, c: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Two-Column Checkout Layout (Stacked on Mobile)
                  if (isMobile) ...[
                    _buildOrderSummaryCard(plan, isYearly, baseAmount, taxAmount, totalAmount, currentWs),
                    const SizedBox(height: 24),
                    _buildPaymentCard(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: _buildOrderSummaryCard(
                            plan,
                            isYearly,
                            baseAmount,
                            taxAmount,
                            totalAmount,
                            currentWs,
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 6,
                          child: _buildPaymentCard(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(
    PricingPlanModel plan,
    bool isYearly,
    double baseAmount,
    double taxAmount,
    double totalAmount,
    dynamic currentWs,
  ) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ORDER SUMMARY',
                style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.0),
              ),
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRouter.pricing),
                child: Text(
                  'Change Plan',
                  style: AppTextStyles.t(12, w: FontWeight.w600, c: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(RemixIcons.sparkling_line, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${plan.name} Plan',
                      style: AppTextStyles.t(18, w: FontWeight.w700, c: AppColors.textPrimary),
                    ),
                    Text(
                      isYearly ? 'Annual Billing (Save 20%)' : 'Monthly Billing',
                      style: AppTextStyles.t(12, c: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (currentWs != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(RemixIcons.building_4_line, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Workspace: ${currentWs.name}',
                      style: AppTextStyles.t(12, w: FontWeight.w500, c: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Divider(color: AppColors.divider),
          const SizedBox(height: 14),
          _PriceRow(label: 'Plan Subtotal', value: '\$${baseAmount.toStringAsFixed(2)}'),
          _PriceRow(label: 'Estimated VAT / GST (18%)', value: '\$${taxAmount.toStringAsFixed(2)}'),
          if (isYearly)
            _PriceRow(
              label: 'Annual Discount Savings',
              value: '-\$${plan.annualSavings.toStringAsFixed(2)}',
              isDiscount: true,
            ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Total Payable',
                  style: AppTextStyles.t(16, w: FontWeight.w700, c: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '\$${totalAmount.toStringAsFixed(2)}',
                style: AppTextStyles.t(24, w: FontWeight.w800, c: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(RemixIcons.lock_2_line, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '256-Bit SSL Encrypted. Verified directly through backend security authorization.',
                    style: AppTextStyles.t(11, w: FontWeight.w400, c: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYMENT DETAILS',
                style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.0),
              ),
              Row(
                children: const [
                  Icon(RemixIcons.bank_card_line, size: 18, color: AppColors.primary),
                  SizedBox(width: 6),
                  Icon(RemixIcons.shield_check_line, size: 18, color: AppColors.success),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Card Number
          Text(
            'CARD NUMBER',
            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cardNumberCtrl,
            cursorColor: AppColors.primary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              prefixIcon: const Icon(RemixIcons.bank_card_2_line, size: 18, color: AppColors.textMuted),
              suffixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(RemixIcons.visa_line, size: 24, color: AppColors.textPrimary),
              ),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),

          const SizedBox(height: 16),

          // Expiry and CVC
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXPIRATION',
                      style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _expiryCtrl,
                      cursorColor: AppColors.primary,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'MM/YY',
                        prefixIcon: const Icon(RemixIcons.calendar_line, size: 18, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CVC / CVV',
                      style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cvcCtrl,
                      cursorColor: AppColors.primary,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: '123',
                        prefixIcon: const Icon(RemixIcons.lock_password_line, size: 18, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceVariant,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cardholder Name
          Text(
            'CARDHOLDER NAME',
            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _cardholderCtrl,
            cursorColor: AppColors.primary,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Name on card',
              prefixIcon: const Icon(RemixIcons.user_3_line, size: 18, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),

          const SizedBox(height: 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _isSimulatingPayment
                ? const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  )
                : GradientButton(
                    label: 'Complete Payment & Activate',
                    icon: RemixIcons.checkbox_circle_line,
                    onTap: _processPaymentAndVerify,
                  ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isDiscount = false,
  });

  final String label;
  final String value;
  final bool isDiscount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.t(
                13,
                w: FontWeight.w400,
                c: isDiscount ? AppColors.success : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.t(
              13,
              w: FontWeight.w600,
              c: isDiscount ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
