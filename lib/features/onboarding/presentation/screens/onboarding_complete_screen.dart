import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/shell_scope.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/onboarding_stepper.dart';
import '../../../workspace/controller/workspace_controller.dart';
import '../../../subscription/controller/subscription_controller.dart';

class OnboardingCompleteScreen extends StatefulWidget {
  const OnboardingCompleteScreen({super.key});

  @override
  State<OnboardingCompleteScreen> createState() => _OnboardingCompleteScreenState();
}

class _OnboardingCompleteScreenState extends State<OnboardingCompleteScreen> {
  final bool _waConnected = false;
  final bool _igConnected = false;
  final bool _autoChatConfigured = false;

  void _goToDashboard({NavDestination? destination}) {
    Navigator.of(context).pushReplacementNamed(
      AppRouter.dashboard,
      arguments: destination,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 680;
    final wsController = context.watch<WorkspaceController>();
    final subController = context.watch<SubscriptionController>();

    final ws = wsController.activeWorkspace;
    final sub = subController.activeSubscription;

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
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                children: [
                  // Brand Logo
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

                  // Stepper (Step 3 of 3)
                  const OnboardingStepper(currentStep: 3),

                  const SizedBox(height: 32),

                  // Celebration Card
                  Container(
                    padding: EdgeInsets.all(isMobile ? 22 : 36),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Success Header
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.success.withValues(alpha: 0.15),
                                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                              ),
                              child: const Icon(RemixIcons.checkbox_circle_fill, color: AppColors.success, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Workspace Ready to Scale!',
                                    style: AppTextStyles.t(22, w: FontWeight.w800, c: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    ws != null
                                        ? '${ws.name} (${sub?.planName ?? 'Active'} Subscription)'
                                        : 'Subscription activated & workspace configured.',
                                    style: AppTextStyles.t(13, c: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(color: AppColors.divider),
                        const SizedBox(height: 20),

                        Text(
                          'ONBOARDING CHECKLIST',
                          style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.primary, ls: 1.0),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete these steps now to start automating inbound DMs and customer leads, or skip and configure later.',
                          style: AppTextStyles.t(13, w: FontWeight.w400, c: AppColors.textSecondary),
                        ),

                        const SizedBox(height: 24),

                        // 1. Workspace created
                        _ChecklistTile(
                          isCompleted: true,
                          title: '1. Workspace created',
                          subtitle: ws != null ? 'Named "${ws.name}" with owner privileges' : 'Tenant configured',
                          icon: RemixIcons.building_4_line,
                        ),

                        // 2. Subscription activated
                        _ChecklistTile(
                          isCompleted: true,
                          title: '2. Subscription activated',
                          subtitle: sub != null
                              ? '${sub.planName} tier active with verified payment receipt'
                              : 'Active subscription attached',
                          icon: RemixIcons.shield_check_line,
                        ),

                        // 3. Connect WhatsApp
                        _ChecklistTile(
                          isCompleted: _waConnected,
                          title: '3. Connect WhatsApp Channel',
                          subtitle: 'Pair WhatsApp Web via official QR code to keep your phone active',
                          icon: RemixIcons.whatsapp_line,
                          accentColor: AppColors.waColor,
                          actionLabel: _waConnected ? 'Connected' : 'Connect Now',
                          onAction: () => _goToDashboard(destination: NavDestination.channel),
                        ),

                        // 4. Connect Instagram
                        _ChecklistTile(
                          isCompleted: _igConnected,
                          title: '4. Connect Instagram Channel',
                          subtitle: 'Link Meta Instagram Professional account for direct Cloud API access',
                          icon: RemixIcons.instagram_line,
                          accentColor: AppColors.igColor,
                          actionLabel: _igConnected ? 'Connected' : 'Connect Now',
                          onAction: () => _goToDashboard(destination: NavDestination.channel),
                        ),

                        // 5. Configure Auto Chat
                        _ChecklistTile(
                          isCompleted: _autoChatConfigured,
                          title: '5. Configure Auto-Chat Automation',
                          subtitle: 'Create keyword triggers, comment auto-responders & quick replies',
                          icon: RemixIcons.magic_line,
                          accentColor: AppColors.primary,
                          actionLabel: 'Create Rule',
                          onAction: () => _goToDashboard(destination: NavDestination.automations),
                        ),

                        // 6. Start Automating
                        _ChecklistTile(
                          isCompleted: false,
                          title: '6. Live Unified Inbox & Conversions',
                          subtitle: 'Monitor real-time messages, manage tags & handover to agents',
                          icon: RemixIcons.inbox_line,
                          accentColor: AppColors.secondary,
                          actionLabel: 'Open Inbox',
                          onAction: () => _goToDashboard(destination: NavDestination.inbox),
                        ),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: GradientButton(
                                label: 'Launch Dashboard',
                                icon: RemixIcons.arrow_right_line,
                                onTap: () => _goToDashboard(),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton(
                                onPressed: () => _goToDashboard(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.textSecondary,
                                  side: const BorderSide(color: AppColors.border),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  'Skip for now',
                                  style: AppTextStyles.t(14, w: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.isCompleted,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.accentColor,
    this.actionLabel,
    this.onAction,
  });

  final bool isCompleted;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? accentColor;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.surface,
              border: Border.all(
                color: isCompleted ? AppColors.success : AppColors.border,
              ),
            ),
            child: Icon(
              isCompleted ? RemixIcons.check_line : icon,
              size: 16,
              color: isCompleted
                  ? AppColors.success
                  : accentColor ?? AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.t(
                    14,
                    w: FontWeight.w600,
                    c: isCompleted ? AppColors.textPrimary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.t(
                    12,
                    w: FontWeight.w400,
                    c: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && !isCompleted) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: accentColor ?? AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              child: Text(
                actionLabel!,
                style: AppTextStyles.t(12, w: FontWeight.w600, c: accentColor ?? AppColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
