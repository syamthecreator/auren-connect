import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../app/routes/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../constants/asset_constants.dart';

class PublicFooter extends StatelessWidget {
  const PublicFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 48,
        vertical: 56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              if (isMobile) ...[
                // Mobile stacked layout
                _buildBrandColumn(context),
                const SizedBox(height: 36),
                _buildLinksRow(context),
              ] else ...[
                // Desktop row layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: _buildBrandColumn(context)),
                    Expanded(flex: 2, child: _buildProductLinks(context)),
                    Expanded(flex: 2, child: _buildChannelLinks(context)),
                    Expanded(flex: 2, child: _buildLegalLinks(context)),
                  ],
                ),
              ],
              const SizedBox(height: 48),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 aurenConnect Inc. All rights reserved. Built for modern creators & business messaging fleets.',
                      style: AppTextStyles.t(
                        12,
                        w: FontWeight.w400,
                        c: AppColors.textMuted,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All Systems Operational',
                        style: AppTextStyles.t(
                          12,
                          w: FontWeight.w500,
                          c: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
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
                    style: AppTextStyles.t(
                      18,
                      w: FontWeight.w700,
                      c: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: 'Connect',
                    style: AppTextStyles.t(
                      18,
                      w: FontWeight.w700,
                      c: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Unified WhatsApp & Instagram conversational automation platform. Manage high-converting conversations, AI workflows, and customer journeys at scale.',
          style: AppTextStyles.t(
            13,
            w: FontWeight.w400,
            c: AppColors.textSecondary,
            h: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _SocialIcon(icon: RemixIcons.twitter_x_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.github_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.linkedin_line, onTap: () {}),
            const SizedBox(width: 12),
            _SocialIcon(icon: RemixIcons.instagram_line, onTap: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildLinksRow(BuildContext context) {
    return Wrap(
      spacing: 36,
      runSpacing: 24,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 220),
          child: _buildProductLinks(context),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
          child: _buildChannelLinks(context),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 140, maxWidth: 200),
          child: _buildLegalLinks(context),
        ),
      ],
    );
  }

  Widget _buildProductLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PRODUCT',
          style: AppTextStyles.t(
            12,
            w: FontWeight.w700,
            c: AppColors.textPrimary,
            ls: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'Pricing Plans',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.pricing),
        ),
        _FooterLink(
          label: 'Conversational AI',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
        _FooterLink(
          label: 'Workspaces',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.pricing),
        ),
        _FooterLink(
          label: 'API Reference',
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
      ],
    );
  }

  Widget _buildChannelLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INTEGRATIONS',
          style: AppTextStyles.t(
            12,
            w: FontWeight.w700,
            c: AppColors.textPrimary,
            ls: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'WhatsApp Web Linked Device',
          icon: RemixIcons.whatsapp_line,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
        _FooterLink(
          label: 'Instagram Direct & Stories',
          icon: RemixIcons.instagram_line,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
        _FooterLink(
          label: 'Anti-Ban Shield',
          icon: RemixIcons.shield_check_line,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
        _FooterLink(
          label: 'Unified Inbox',
          icon: RemixIcons.inbox_line,
          onTap: () => Navigator.of(context).pushNamed(AppRouter.landing),
        ),
      ],
    );
  }

  Widget _buildLegalLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LEGAL & PRIVACY',
          style: AppTextStyles.t(
            12,
            w: FontWeight.w700,
            c: AppColors.textPrimary,
            ls: 1.0,
          ),
        ),
        const SizedBox(height: 14),
        _FooterLink(
          label: 'Terms of Service',
          onTap: () {},
        ),
        _FooterLink(
          label: 'Privacy Policy',
          onTap: () {},
        ),
        _FooterLink(
          label: 'Security & Compliance',
          onTap: () {},
        ),
        _FooterLink(
          label: 'Data Processing Agreement',
          onTap: () {},
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  const _FooterLink({
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.t(
                  13,
                  w: FontWeight.w400,
                  c: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  const _SocialIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Icon(icon, size: 16, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
