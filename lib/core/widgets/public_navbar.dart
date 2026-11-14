import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../app/routes/app_router.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';
import '../constants/asset_constants.dart';
import '../../features/auth/controllers/auth_controller.dart';
import 'gradient_button.dart';

class PublicNavbar extends StatelessWidget implements PreferredSizeWidget {
  const PublicNavbar({
    super.key,
    this.currentRoute = '/',
  });

  final String currentRoute;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final isAuth = auth.isAuthenticated;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 36),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand Logo & Title
              InkWell(
                onTap: () {
                  if (currentRoute != AppRouter.landing) {
                    Navigator.of(context).pushReplacementNamed(AppRouter.landing);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: AppColors.neonLaserGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Image.asset(
                          AssetConstants.aLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            RemixIcons.apps_2_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'auren',
                              style: AppTextStyles.t(
                                20,
                                w: FontWeight.w700,
                                c: AppColors.textPrimary,
                                ls: -0.5,
                              ),
                            ),
                            TextSpan(
                              text: 'Connect',
                              style: AppTextStyles.t(
                                20,
                                w: FontWeight.w700,
                                c: AppColors.primary,
                                ls: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'SaaS',
                          style: AppTextStyles.t(
                            10,
                            w: FontWeight.w600,
                            c: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Desktop Center Navigation Links
              if (screenWidth >= 1024)
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _NavLink(
                          label: 'Features',
                          active: false,
                          onTap: () {
                            if (currentRoute != AppRouter.landing) {
                              Navigator.of(context).pushReplacementNamed(AppRouter.landing);
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        _NavLink(
                          label: 'Pricing',
                          active: currentRoute == AppRouter.pricing,
                          onTap: () {
                            if (currentRoute != AppRouter.pricing) {
                              Navigator.of(context).pushNamed(AppRouter.pricing);
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        _NavLink(
                          label: 'WhatsApp Automation',
                          active: false,
                          icon: RemixIcons.whatsapp_line,
                          onTap: () {
                            if (currentRoute != AppRouter.landing) {
                              Navigator.of(context).pushReplacementNamed(AppRouter.landing);
                            }
                          },
                        ),
                        const SizedBox(width: 24),
                        _NavLink(
                          label: 'Instagram DM',
                          active: false,
                          icon: RemixIcons.instagram_line,
                          onTap: () {
                            if (currentRoute != AppRouter.landing) {
                              Navigator.of(context).pushReplacementNamed(AppRouter.landing);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else if (screenWidth >= 768)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NavLink(
                      label: 'Features',
                      active: false,
                      onTap: () {
                        if (currentRoute != AppRouter.landing) {
                          Navigator.of(context).pushReplacementNamed(AppRouter.landing);
                        }
                      },
                    ),
                    const SizedBox(width: 20),
                    _NavLink(
                      label: 'Pricing',
                      active: currentRoute == AppRouter.pricing,
                      onTap: () {
                        if (currentRoute != AppRouter.pricing) {
                          Navigator.of(context).pushNamed(AppRouter.pricing);
                        }
                      },
                    ),
                  ],
                ),

              // Right Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAuth) ...[
                    GradientButton(
                      label: 'Dashboard',
                      icon: RemixIcons.dashboard_line,
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
                      },
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () {
                        if (currentRoute != AppRouter.login) {
                          Navigator.of(context).pushNamed(AppRouter.login);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: AppTextStyles.t(14, w: FontWeight.w600, c: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GradientButton(
                      label: isMobile ? 'Start' : 'Get Started',
                      icon: RemixIcons.arrow_right_line,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.pricing);
                      },
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.onTap,
    this.active = false,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 15,
                color: active ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.t(
                14,
                w: active ? FontWeight.w600 : FontWeight.w500,
                c: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
