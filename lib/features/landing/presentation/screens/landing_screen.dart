import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/public_footer.dart';
import '../../../../core/widgets/public_navbar.dart';
import '../../../../core/widgets/studio_card.dart';
import '../../../pricing/controller/pricing_controller.dart';
import '../../../pricing/presentation/widgets/billing_cycle_toggle.dart';
import '../../../pricing/presentation/widgets/compact_pricing_card.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PublicNavbar(currentRoute: '/'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Above-The-Fold Hero Section (Complete, Compact & Balanced)
            _HeroSection(isMobile: isMobile),

            // 2. Interactive Channel Preview Showcase
            _ChannelShowcaseSection(isMobile: isMobile),

            // 3. Key Core Features Grid
            _FeaturesSection(isMobile: isMobile),

            // 4. Multi-Tenant Workspace & Safety Architecture Highlights
            _EnterpriseHighlightsSection(isMobile: isMobile),

            // 5. Refined Pricing Preview (Reusing CompactPricingCard)
            _PricingPreviewSection(isMobile: isMobile),

            // 6. Final Call to Action
            _FinalCtaSection(isMobile: isMobile),

            // 7. Footer
            const PublicFooter(),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 18 : 36,
        isMobile ? 32 : 52,
        isMobile ? 18 : 36,
        isMobile ? 24 : 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: Column(
            children: [
              // 1. Badge Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      RemixIcons.sparkling_fill,
                      size: 13,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      'Next-Gen WhatsApp & Instagram Automation',
                      style: AppTextStyles.t(
                        11.5,
                        w: FontWeight.w600,
                        c: AppColors.textPrimary,
                        ls: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Headline
              Text(
                'Automate Conversations.\nAccelerate Growth.',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(
                  isMobile ? 32 : 50,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                  ls: -1.2,
                  h: 1.15,
                ),
              ),

              const SizedBox(height: 14),

              // 3. Supporting Text
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Text(
                  'One powerful platform to automate WhatsApp and Instagram conversations, capture leads, and scale customer engagement.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.t(
                    isMobile ? 14 : 16,
                    w: FontWeight.w400,
                    c: AppColors.textSecondary,
                    h: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // 4. Primary & Secondary CTAs
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 14,
                runSpacing: 12,
                children: [
                  AppButton.primary(
                    label: 'Get Started',
                    trailingIcon: RemixIcons.arrow_right_line,
                    height: 44,
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.pricing);
                    },
                  ),
                  AppButton.secondary(
                    label: 'Explore Pricing',
                    icon: RemixIcons.price_tag_3_line,
                    height: 44,
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRouter.pricing);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 5. Existing Customer Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already an active customer? ',
                    style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRouter.login);
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.t(
                          12.5,
                          w: FontWeight.w600,
                          c: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // 6. Above-The-Fold Channel Capability Cards
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: isMobile
                    ? Column(
                        children: const [
                          _ChannelQuickPill(
                            icon: RemixIcons.whatsapp_line,
                            accentColor: AppColors.waColor,
                            title: 'WhatsApp Automation',
                            subtitle: 'Multi-Device QR Sync • Zero Delay Auto-Chat',
                          ),
                          SizedBox(height: 10),
                          _ChannelQuickPill(
                            icon: RemixIcons.instagram_line,
                            accentColor: AppColors.igColor,
                            title: 'Instagram Automation',
                            subtitle: 'Meta Cloud API Direct • Story Replies & DM Flows',
                          ),
                        ],
                      )
                    : Row(
                        children: const [
                          Expanded(
                            child: _ChannelQuickPill(
                              icon: RemixIcons.whatsapp_line,
                              accentColor: AppColors.waColor,
                              title: 'WhatsApp Automation',
                              subtitle: 'Multi-Device QR Sync • Zero Delay Auto-Chat',
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: _ChannelQuickPill(
                              icon: RemixIcons.instagram_line,
                              accentColor: AppColors.igColor,
                              title: 'Instagram Automation',
                              subtitle: 'Meta Cloud API Direct • Story Replies & DM Flows',
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelQuickPill extends StatelessWidget {
  const _ChannelQuickPill({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: accentColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTextStyles.t(13, w: FontWeight.w700, c: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.t(11, c: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelShowcaseSection extends StatelessWidget {
  const _ChannelShowcaseSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 36,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 18 : 32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                // Browser simulation bar
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF5F56))),
                    const SizedBox(width: 8),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFFBD2E))),
                    const SizedBox(width: 8),
                    Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF27C93F))),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'https://app.aurenconnect.com/workspace/live-stream',
                          style: AppTextStyles.t(11, c: AppColors.textMuted),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Channels Simulated Side-by-Side or Stacked
                if (isMobile) ...[
                  _ChannelCard(
                    title: 'WhatsApp Automation',
                    badge: 'Multi-Device Linked',
                    icon: RemixIcons.whatsapp_line,
                    accentColor: AppColors.waColor,
                    chats: const [
                      ('Hi! Do you have pricing details for the Pro tier?', false),
                      ('Hello! Yes, our Pro plan includes unlimited WhatsApp accounts & AI auto-chat. Would you like a checkout link?', true),
                      ('Yes please send the link', false),
                      ('Here is your instant checkout link: https://aurenconnect.app/pricing/pro. Enjoy 20% off annually!', true),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _ChannelCard(
                    title: 'Instagram DM & Story Automation',
                    badge: 'Meta Cloud API',
                    icon: RemixIcons.instagram_line,
                    accentColor: AppColors.igColor,
                    chats: const [
                      ('Replied to your Story: "Loved this workflow!"', false),
                      ('Thank you! Want me to send you our top 5 automation templates for creators?', true),
                      ('Send templates', false),
                      ('Done! 🚀 Sent direct to your DM. Check out the guide button below.', true),
                    ],
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Expanded(
                        child: _ChannelCard(
                          title: 'WhatsApp Automation',
                          badge: 'Multi-Device Linked',
                          icon: RemixIcons.whatsapp_line,
                          accentColor: AppColors.waColor,
                          chats: [
                            ('Hi! Do you have pricing details for the Pro tier?', false),
                            ('Hello! Yes, our Pro plan includes unlimited WhatsApp accounts & AI auto-chat. Would you like a checkout link?', true),
                            ('Yes please send the link', false),
                            ('Here is your instant checkout link: https://aurenconnect.app/pricing/pro. Enjoy 20% off annually!', true),
                          ],
                        ),
                      ),
                      SizedBox(width: 24),
                      Expanded(
                        child: _ChannelCard(
                          title: 'Instagram DM & Story Automation',
                          badge: 'Meta Cloud API',
                          icon: RemixIcons.instagram_line,
                          accentColor: AppColors.igColor,
                          chats: [
                            ('Replied to your Story: "Loved this workflow!"', false),
                            ('Thank you! Want me to send you our top 5 automation templates for creators?', true),
                            ('Send templates', false),
                            ('Done! 🚀 Sent direct to your DM. Check out the guide button below.', true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.title,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.chats,
  });

  final String title;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final List<(String, bool)> chats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.t(14, w: FontWeight.w700, c: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  badge,
                  style: AppTextStyles.t(10, w: FontWeight.w600, c: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),
          for (final chat in chats) ...[
            Align(
              alignment: chat.$2 ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: const BoxConstraints(maxWidth: 320),
                decoration: BoxDecoration(
                  color: chat.$2
                      ? accentColor.withValues(alpha: 0.18)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: chat.$2
                        ? accentColor.withValues(alpha: 0.35)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  chat.$1,
                  style: AppTextStyles.t(
                    12,
                    w: FontWeight.w400,
                    c: AppColors.textPrimary,
                    h: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(
                'EVERYTHING YOU NEED TO SCALE',
                style: AppTextStyles.t(
                  11,
                  w: FontWeight.w700,
                  c: AppColors.primary,
                  ls: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Built for High-Growth Conversational Businesses',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(
                  isMobile ? 24 : 36,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                  ls: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'From solo creators to enterprise sales fleets, Auren Connect combines AI automation with direct messaging protocols.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.t(
                    14,
                    w: FontWeight.w400,
                    c: AppColors.textSecondary,
                    h: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 38),

              // 6 Features Grid
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  _FeatureCard(
                    icon: RemixIcons.whatsapp_line,
                    accentColor: AppColors.waColor,
                    title: 'WhatsApp Auto Chat',
                    description:
                        'Connect via official WhatsApp Web QR code. Keeps your physical phone active while automating customer FAQs and product catalogs.',
                    width: isMobile ? double.infinity : 360,
                  ),
                  _FeatureCard(
                    icon: RemixIcons.instagram_line,
                    accentColor: AppColors.igColor,
                    title: 'Instagram Auto Replies',
                    description:
                        'Auto-reply to Instagram Direct messages, comments on Posts & Reels, and Story mentions in real time via official Meta Cloud APIs.',
                    width: isMobile ? double.infinity : 360,
                  ),
                  _FeatureCard(
                    icon: RemixIcons.magic_line,
                    accentColor: AppColors.primary,
                    title: 'AI-Powered Conversations',
                    description:
                        'Smart context-aware AI conversational engine that qualifies leads, handles objections, and schedules calls automatically.',
                    width: isMobile ? double.infinity : 360,
                  ),
                  _FeatureCard(
                    icon: RemixIcons.user_follow_line,
                    accentColor: AppColors.secondary,
                    title: 'Automated Lead Management',
                    description:
                        'Capture customer phone numbers, emails, and tags on the fly. Build targeted segments and sync leads directly to your workspace.',
                    width: isMobile ? double.infinity : 360,
                  ),
                  _FeatureCard(
                    icon: RemixIcons.flow_chart,
                    accentColor: AppColors.accent,
                    title: 'Smart Messaging Workflows',
                    description:
                        'Drag-and-drop conversational decision trees. Send text, interactive quick buttons, audio notes, and media catalogs with rate limiting.',
                    width: isMobile ? double.infinity : 360,
                  ),
                  _FeatureCard(
                    icon: RemixIcons.building_4_line,
                    accentColor: AppColors.primary,
                    title: 'Centralized Workspace Management',
                    description:
                        'Strict multi-tenant workspace isolation. Assign team roles, manage connected accounts, and monitor cross-channel analytics.',
                    width: isMobile ? double.infinity : 360,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    required this.width,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: StudioCard(
        radius: 16,
        padding: const EdgeInsets.all(22),
        hoverable: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accentColor.withValues(alpha: 0.25)),
              ),
              child: Center(child: Icon(icon, size: 20, color: accentColor)),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTextStyles.t(16, w: FontWeight.w700, c: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: AppTextStyles.t(
                12.5,
                w: FontWeight.w400,
                c: AppColors.textSecondary,
                h: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnterpriseHighlightsSection extends StatelessWidget {
  const _EnterpriseHighlightsSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Container(
            padding: EdgeInsets.all(isMobile ? 22 : 36),
            decoration: BoxDecoration(
              gradient: AppColors.hydroGlassGradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(RemixIcons.shield_star_line, color: AppColors.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'SAFETY & PRIVACY FIRST',
                      style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Golden Anti-Ban Architecture & Verified Infrastructure',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.t(
                    isMobile ? 20 : 28,
                    w: FontWeight.w800,
                    c: AppColors.textPrimary,
                    ls: -0.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We simulate official Google Chrome Mac OS signatures with jittered typing delays, pre-flight registration checks, and strict rate limits to protect your brand accounts 24/7.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.t(13.5, w: FontWeight.w400, c: AppColors.textSecondary, h: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PricingPreviewSection extends StatelessWidget {
  const _PricingPreviewSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final pricing = context.watch<PricingController>();
    final plans = pricing.plans;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1020;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1140),
          child: Column(
            children: [
              Text(
                'TRANSPARENT SAAS PRICING',
                style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Choose the Right Plan for Your Scale',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(
                  isMobile ? 24 : 34,
                  w: FontWeight.w800,
                  c: AppColors.textPrimary,
                  ls: -0.8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No hidden fees. Switch plans or cancel anytime.',
                style: AppTextStyles.t(13.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 22),

              // Segmented Billing Toggle
              BillingCycleToggle(
                isYearly: pricing.isYearly,
                onChanged: (yearly) => pricing.toggleBilling(yearly),
              ),

              const SizedBox(height: 32),

              // Reusable Compact Pricing Cards
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final plan in plans)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: CompactPricingCard(
                            plan: plan,
                            isYearly: pricing.isYearly,
                            onSelect: () {
                              pricing.selectPlan(plan);
                              Navigator.of(context).pushNamed(
                                AppRouter.register,
                                arguments: plan.slug,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                )
              else
                Column(
                  children: [
                    for (final plan in plans)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: CompactPricingCard(
                          plan: plan,
                          isYearly: pricing.isYearly,
                          onSelect: () {
                            pricing.selectPlan(plan);
                            Navigator.of(context).pushNamed(
                              AppRouter.register,
                              arguments: plan.slug,
                            );
                          },
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 28),

              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.pricing);
                },
                icon: const Icon(RemixIcons.arrow_right_line, size: 15),
                label: const Text('Compare detailed feature breakdown →'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.t(13.5, w: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 48,
              vertical: isMobile ? 36 : 48,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.neonLaserGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 36,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Start Automating Conversations Today',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.t(
                    isMobile ? 24 : 34,
                    w: FontWeight.w800,
                    c: Colors.white,
                    ls: -0.6,
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 580),
                  child: Text(
                    'Connect WhatsApp in 30 seconds via QR Code and hook into Instagram Meta Cloud API with zero code required.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.t(
                      14,
                      w: FontWeight.w400,
                      c: Colors.white.withValues(alpha: 0.9),
                      h: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.pricing);
                  },
                  icon: const Icon(RemixIcons.rocket_line, size: 18),
                  label: const Text('Get Started Free'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: AppTextStyles.t(14.5, w: FontWeight.w700),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
