import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/pricing_plan_model.dart';

class CompactPricingCard extends StatelessWidget {
  const CompactPricingCard({
    super.key,
    required this.plan,
    required this.isYearly,
    required this.onSelect,
    this.width,
  });

  final PricingPlanModel plan;
  final bool isYearly;
  final VoidCallback onSelect;
  final double? width;

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}M';
    }
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyMonthlyEquivalent : plan.monthlyPrice;

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: plan.isPopular
              ? AppColors.primary
              : AppColors.border,
          width: plan.isPopular ? 1.8 : 1.0,
        ),
        boxShadow: plan.isPopular
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Plan Name & Popular Badge Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                plan.name,
                style: AppTextStyles.t(
                  19,
                  w: FontWeight.w700,
                  c: AppColors.textPrimary,
                ),
              ),
              if (plan.isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    gradient: AppColors.neonLaserGradient,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        RemixIcons.sparkling_fill,
                        size: 11,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'MOST POPULAR',
                        style: AppTextStyles.t(
                          9.5,
                          w: FontWeight.w700,
                          c: Colors.white,
                          ls: 0.6,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.8),
                  ),
                  child: Text(
                    plan.slug == 'starter' ? 'STARTER TIER' : 'ENTERPRISE',
                    style: AppTextStyles.t(
                      9.5,
                      w: FontWeight.w600,
                      c: AppColors.textSecondary,
                      ls: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // 2. Short Plan Description (fixed 2 lines for vertical alignment)
          SizedBox(
            height: 36,
            child: Text(
              plan.tagline,
              style: AppTextStyles.t(
                12.5,
                w: FontWeight.w400,
                c: AppColors.textSecondary,
                h: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(height: 16),

          // 3 & 4. Price & Billing Frequency
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$$price',
                style: AppTextStyles.t(
                  36,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                  ls: -1.0,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '/month',
                style: AppTextStyles.t(
                  13,
                  w: FontWeight.w500,
                  c: AppColors.textMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Billing Cycle Note
          Text(
            isYearly
                ? 'Billed annually at \$${plan.yearlyPrice}/yr (Save \$${plan.annualSavings})'
                : 'Billed monthly, cancel anytime',
            style: AppTextStyles.t(
              11,
              w: isYearly ? FontWeight.w600 : FontWeight.w400,
              c: isYearly ? AppColors.success : AppColors.textMuted,
            ),
          ),

          const SizedBox(height: 18),

          // 5. Primary CTA Button (Strictly aligned across all 3 cards)
          plan.isPopular
              ? AppButton.primary(
                  label: plan.ctaText,
                  trailingIcon: RemixIcons.arrow_right_line,
                  fullWidth: true,
                  height: 42,
                  onPressed: onSelect,
                )
              : AppButton.secondary(
                  label: plan.ctaText,
                  fullWidth: true,
                  height: 42,
                  onPressed: onSelect,
                ),

          const SizedBox(height: 18),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 16),

          // 6. Most Important Included Features
          Text(
            'KEY CAPABILITIES',
            style: AppTextStyles.t(
              10,
              w: FontWeight.w700,
              c: AppColors.primary,
              ls: 1.0,
            ),
          ),

          const SizedBox(height: 12),

          _FeatureItem(
            icon: RemixIcons.message_3_line,
            title: '${_formatNumber(plan.monthlyMessages)} Messages / month',
            isHighlighted: true,
          ),
          _FeatureItem(
            icon: RemixIcons.smartphone_line,
            title: plan.maxConnectedAccounts >= 999
                ? 'Unlimited connected channels'
                : '${plan.maxConnectedAccounts} Connected account${plan.maxConnectedAccounts > 1 ? 's' : ''}',
          ),
          _FeatureItem(
            icon: RemixIcons.whatsapp_line,
            title: plan.whatsappIncluded
                ? 'WhatsApp Web QR Multi-Device'
                : 'WhatsApp not included',
            isEnabled: plan.whatsappIncluded,
          ),
          _FeatureItem(
            icon: RemixIcons.instagram_line,
            title: plan.instagramIncluded
                ? 'Instagram Meta Cloud API Direct'
                : 'Instagram not included',
            isEnabled: plan.instagramIncluded,
          ),
          _FeatureItem(
            icon: RemixIcons.magic_line,
            title: plan.aiAutomationIncluded
                ? 'AI-Powered Auto Chat Assistant'
                : 'Standard keyword auto-replies',
            isEnabled: plan.aiAutomationIncluded,
            isHighlighted: plan.aiAutomationIncluded,
          ),
          _FeatureItem(
            icon: RemixIcons.team_line,
            title: plan.maxTeamMembers >= 999
                ? 'Unlimited team workspace seats'
                : '${plan.maxTeamMembers} Team member seat${plan.maxTeamMembers > 1 ? 's' : ''}',
          ),

          const SizedBox(height: 6),
        ],
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: card);
    }
    return card;
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({
    required this.icon,
    required this.title,
    this.isEnabled = true,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String title;
  final bool isEnabled;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isEnabled
                  ? (isHighlighted
                      ? AppColors.primary.withValues(alpha: 0.18)
                      : AppColors.surfaceVariant)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Icon(
              isEnabled ? RemixIcons.check_line : RemixIcons.close_line,
              size: 12,
              color: isEnabled
                  ? (isHighlighted ? AppColors.primary : AppColors.success)
                  : AppColors.textMuted.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.t(
                12,
                w: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                c: isEnabled
                    ? (isHighlighted ? AppColors.textPrimary : AppColors.textSecondary)
                    : AppColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
