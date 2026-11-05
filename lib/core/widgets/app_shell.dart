import 'package:auren_connect/app/routes/app_router.dart';
import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/core/widgets/app_sidebar.dart';
import 'package:auren_connect/core/widgets/app_top_bar.dart';
import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:auren_connect/features/auth/controllers/auth_controller.dart';
import 'package:auren_connect/features/automation/presentation/screens/automation_screen.dart';
import 'package:auren_connect/features/channel/presentation/screens/channel_screen.dart';
import 'package:auren_connect/features/inbox/presentation/screens/inbox_screen.dart';
import 'package:auren_connect/features/overview/presentation/screens/overview_screen.dart';
import 'package:auren_connect/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  NavDestination _current = NavDestination.overview;

  bool? _collapsedOverride;
  bool _showNotifications = false;

  bool get _collapsed =>
      _collapsedOverride ?? MediaQuery.of(context).size.width < 1000;

  void _goTo(NavDestination destination) {
    if (_current == destination) return;
    setState(() {
      _current = destination;
      _showNotifications = false;
    });
  }

  Widget _page() {
    return switch (_current) {
      NavDestination.overview => const OverviewScreen(),
      NavDestination.automations => const AutomationsScreen(),
      NavDestination.channel => const ChannelScreen(),
      NavDestination.inbox => const InboxScreen(),
      NavDestination.settings => const SettingsScreen(),
    };
  }

  void _toggleSidebar() => setState(() => _collapsedOverride = !_collapsed);

  void _toggleNotifications() =>
      setState(() => _showNotifications = !_showNotifications);

  void _logout() {
    context.read<AuthController>().signOut();

    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRouter.auth, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ShellScope(
      goTo: _goTo,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Ambient glow behind the content
            Positioned(
              top: -180,
              right: -120,
              child: IgnorePointer(
                child: Container(
                  width: 520,
                  height: 520,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: .10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                AppSidebar(
                  collapsed: _collapsed,
                  current: _current,
                  onToggle: _toggleSidebar,
                  onSelect: _goTo,
                  onLogout: _logout,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                        child: AppTopBar(
                          destination: _current,
                          notificationCount: 1,
                          onBellTap: _toggleNotifications,
                        ),
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey(_current),
                            child: _page(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showNotifications) ...[
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggleNotifications,
                  child: const SizedBox.expand(),
                ),
              ),
              const Positioned(top: 76, right: 24, child: _NotificationPanel()),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationPanel extends StatelessWidget {
  const _NotificationPanel();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        RemixIcons.checkbox_circle_line,
        AppColors.success,
        'Spring launch finished',
        '12,480 messages delivered at 98.4%',
        '2m',
      ),
      (
        RemixIcons.error_warning_line,
        AppColors.warning,
        'Template needs changes',
        '“Order shipped” was returned by WhatsApp',
        '1h',
      ),
      (
        RemixIcons.chat_3_line,
        AppColors.primary,
        '12 unread conversations',
        'Three are waiting more than 30 minutes',
        '3h',
      ),
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * -8),
          child: child,
        ),
      ),
      child: Container(
        width: 360,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notifications',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'Mark all as read',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            for (final i in items)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: i.$2.withValues(alpha: .14),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(i.$1, size: 18, color: i.$2),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            i.$3,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            i.$4,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      i.$5,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
