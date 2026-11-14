import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/public_footer.dart';
import '../../../../core/widgets/public_navbar.dart';
import '../../controller/pricing_controller.dart';
import '../../data/models/pricing_plan_model.dart';
import '../widgets/billing_cycle_toggle.dart';
import '../widgets/compact_pricing_card.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricingController>().loadPlans();
    });
  }

  void _onChoosePlan(PricingPlanModel plan) {
    context.read<PricingController>().selectPlan(plan);
    Navigator.of(context).pushNamed(
      AppRouter.register,
      arguments: plan.slug,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricing = context.watch<PricingController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isDesktop = screenWidth >= 1020;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(currentRoute: '/pricing'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Compact Page Header (Designed to keep pricing cards above the fold)
            Container(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 20 : 40,
                isMobile ? 28 : 40,
                isMobile ? 20 : 40,
                isMobile ? 20 : 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'PLANS & PRICING',
                          style: AppTextStyles.t(
                            10.5,
                            w: FontWeight.w700,
                            c: AppColors.primary,
                            ls: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Simple, Scalable Pricing for Modern Messaging',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.t(
                          isMobile ? 26 : 38,
                          w: FontWeight.w800,
                          c: AppColors.textPrimary,
                          ls: -0.8,
                          h: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Text(
                          'Choose the ideal capacity for your WhatsApp numbers, Instagram pages, and AI automations. Scale up or pause at any time.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.t(
                            isMobile ? 13 : 14.5,
                            w: FontWeight.w400,
                            c: AppColors.textSecondary,
                            h: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Sleek Segmented Billing Cycle Switcher
                      BillingCycleToggle(
                        isYearly: pricing.isYearly,
                        onChanged: (yearly) => pricing.toggleBilling(yearly),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 2. High-Density, Balanced Pricing Cards (Immediately visible above the fold on Desktop)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isDesktop ? 36 : 24),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1140),
                  child: isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final plan in pricing.plans)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: CompactPricingCard(
                                    plan: plan,
                                    isYearly: pricing.isYearly,
                                    onSelect: () => _onChoosePlan(plan),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Column(
                          children: [
                            for (final plan in pricing.plans)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: CompactPricingCard(
                                  plan: plan,
                                  isYearly: pricing.isYearly,
                                  onSelect: () => _onChoosePlan(plan),
                                ),
                              ),
                          ],
                        ),
                ),
              ),
            ),

            const SizedBox(height: 56),

            // 3. Feature Comparison Table
            _FeatureComparisonSection(
              plans: pricing.plans,
              isMobile: isMobile,
              onChoosePlan: _onChoosePlan,
            ),

            const SizedBox(height: 64),

            // 4. FAQ Section
            _FaqSection(isMobile: isMobile),

            const SizedBox(height: 64),

            // 5. Footer
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}

class _FeatureComparisonSection extends StatelessWidget {
  const _FeatureComparisonSection({
    required this.plans,
    required this.isMobile,
    required this.onChoosePlan,
  });

  final List<PricingPlanModel> plans;
  final bool isMobile;
  final ValueChanged<PricingPlanModel> onChoosePlan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            children: [
              Text(
                'DETAILED BREAKDOWN',
                style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Compare All Features Across Tiers',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(
                  isMobile ? 22 : 30,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: isMobile ? 650 : 1060),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                        horizontalMargin: 22,
                        columnSpacing: 26,
                        columns: [
                          DataColumn(
                            label: Text(
                              'Feature & Capability',
                              style: AppTextStyles.t(13.5, w: FontWeight.w700, c: AppColors.textPrimary),
                            ),
                          ),
                          for (final p in plans)
                            DataColumn(
                              label: Center(
                                child: Text(
                                  p.name,
                                  style: AppTextStyles.t(
                                    13.5,
                                    w: FontWeight.w700,
                                    c: p.isPopular ? AppColors.primary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        rows: [
                          _buildRow('WhatsApp Web QR Code Sync', ['1 Number', 'Up to 3 Numbers', 'Up to 10 Numbers']),
                          _buildRow('Meta Instagram Cloud API', ['1 Account', 'Up to 2 Accounts', 'Up to 5 Accounts']),
                          _buildRow('Monthly Automation Messages', ['5,000 /mo', '25,000 /mo', 'Unlimited']),
                          _buildRow('Team Collaboration Seats', ['1 Seat', '3 Seats', 'Unlimited']),
                          _buildCheckRow('Anti-Ban Browser Emulation', [true, true, true]),
                          _buildCheckRow('Keyword DM Auto-Responder', [true, true, true]),
                          _buildCheckRow('Story Mentions & Auto-Replies', [false, true, true]),
                          _buildCheckRow('Interactive Quick Menu Buttons', [false, true, true]),
                          _buildCheckRow('Unified Multi-Channel Live Inbox', [true, true, true]),
                          _buildCheckRow('AI Contextual Reasoning & FAQs', [false, true, true]),
                          _buildCheckRow('Custom AI Fine-Tuning & Persona', [false, false, true]),
                          _buildCheckRow('Webhooks & Developer REST API', [false, false, true]),
                          _buildRow('Support SLA', ['Standard Email', 'Priority Chat & Email', 'Dedicated Account Manager']),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  DataRow _buildRow(String title, List<String> values) {
    return DataRow(
      cells: [
        DataCell(Text(title, style: AppTextStyles.t(12.5, w: FontWeight.w500, c: AppColors.textPrimary))),
        for (final val in values)
          DataCell(Text(val, style: AppTextStyles.t(12.5, w: FontWeight.w400, c: AppColors.textSecondary))),
      ],
    );
  }

  DataRow _buildCheckRow(String title, List<bool> checks) {
    return DataRow(
      cells: [
        DataCell(Text(title, style: AppTextStyles.t(12.5, w: FontWeight.w500, c: AppColors.textPrimary))),
        for (final check in checks)
          DataCell(
            Center(
              child: Icon(
                check ? RemixIcons.check_line : RemixIcons.close_line,
                size: 16,
                color: check ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            children: [
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Everything You Need to Know',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(
                  isMobile ? 22 : 30,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 28),
              const _FaqTile(
                question: 'Can I keep using WhatsApp on my physical phone?',
                answer:
                    'Yes, 100%! Auren Connect connects via official WhatsApp Web multi-device protocol. Your personal or business WhatsApp continues working on your phone without interruption.',
              ),
              const _FaqTile(
                question: 'How does Anti-Ban protection work?',
                answer:
                    'Our engine identifies to WhatsApp servers using genuine Mac OS Google Chrome signatures, implements randomized natural human typing pauses (1.0–1.8s), and verifies recipient JIDs before dispatching messages.',
              ),
              const _FaqTile(
                question: 'Can I switch or cancel my plan at any time?',
                answer:
                    'Yes. Upgrades and downgrades are prorated immediately. You can cancel with a single click in your workspace settings with no lock-in.',
              ),
              const _FaqTile(
                question: 'Do you offer custom enterprise limits?',
                answer:
                    'Yes. If your messaging fleet exceeds 50,000 conversations/mo or requires multiple dedicated WhatsApp multi-device sockets, contact our team for custom infrastructure.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _expanded ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            onExpansionChanged: (v) => setState(() => _expanded = v),
            trailing: Icon(
              _expanded ? RemixIcons.subtract_line : RemixIcons.add_line,
              color: _expanded ? AppColors.primary : AppColors.textSecondary,
              size: 18,
            ),
            title: Text(
              widget.question,
              style: AppTextStyles.t(
                14.5,
                w: FontWeight.w600,
                c: AppColors.textPrimary,
              ),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Text(
                  widget.answer,
                  style: AppTextStyles.t(
                    13,
                    w: FontWeight.w400,
                    c: AppColors.textSecondary,
                    h: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
