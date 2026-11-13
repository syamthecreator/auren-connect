import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/core/constants/asset_constants.dart';
import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:auren_connect/features/inbox/controller/inbox_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.collapsed,
    required this.current,
    required this.onToggle,
    required this.onSelect,
    required this.onLogout,
  });

  static const double expandedWidth = 280;
  static const double collapsedWidth = 76;

  final bool collapsed;
  final NavDestination current;
  final VoidCallback onToggle;
  final ValueChanged<NavDestination> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final inboxController = context.watch<InboxController?>();
    final unreadChats = inboxController?.stats.unreadConversations ?? 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      width: collapsed ? collapsedWidth : expandedWidth,
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 180;

          return ClipRect(
            child: Column(
              children: [
                _Brand(
                  compact: compact,
                  collapsed: collapsed,
                  onToggle: onToggle,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 12 : 14,
                      vertical: 6,
                    ),
                    children: [
                      if (!compact) const _GroupLabel('Workspace'),
                      for (final destination in [
                        NavDestination.automations,
                        NavDestination.inbox,
                        NavDestination.channel,
                        NavDestination.settings,
                      ])
                        _NavItem(
                          destination: destination,
                          active: destination == current,
                          compact: compact,
                          badge: destination == NavDestination.inbox && unreadChats > 0
                              ? '$unreadChats'
                              : null,
                          onTap: () => onSelect(destination),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 14,
                    8,
                    compact ? 12 : 14,
                    14,
                  ),
                  child: _ActionItem(
                    icon: RemixIcons.logout_box_r_line,
                    label: 'Log out',
                    compact: compact,
                    color: AppColors.error,
                    onTap: onLogout,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BRAND
// ─────────────────────────────────────────────────────────────────────────────

class _Brand extends StatelessWidget {
  const _Brand({
    required this.compact,
    required this.collapsed,
    required this.onToggle,
  });

  final bool compact;
  final bool collapsed;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              compact ? 0 : 20,
              22,
              compact ? 0 : 20,
              18,
            ),
            child: compact
                ? Center(child: _buildLogo())
                : Row(
                    children: [
                      _buildLogo(),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auren Connect',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Messaging studio',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        RemixIcons.menu_fold_line,
                        size: 19,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        gradient: AppColors.neonLaserGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: .45),
            blurRadius: 18,
          ),
        ],
      ),
      child: Image.asset(AssetConstants.aLogo, fit: BoxFit.contain),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GROUP LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAVIGATION ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.active,
    required this.compact,
    required this.onTap,
    this.badge,
  });

  final NavDestination destination;
  final bool active;
  final bool compact;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = active
        ? AppColors.primary
        : AppColors.textSecondary;

    Widget item = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: Colors.white.withValues(alpha: .04),
        splashColor: AppColors.primary.withValues(alpha: .10),
        highlightColor: AppColors.primary.withValues(alpha: .06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: active
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: .18),
                      AppColors.primary.withValues(alpha: .04),
                    ],
                  )
                : null,
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: .35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(destination.icon, size: 20, color: foregroundColor),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: .16),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );

    if (compact) {
      item = Tooltip(
        message: destination.label,
        preferBelow: false,
        child: item,
      );
    }

    return item;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTION ITEM
// ─────────────────────────────────────────────────────────────────────────────

class _ActionItem extends StatelessWidget {
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.compact,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final String label;
  final bool compact;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    Widget item = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: color.withValues(alpha: .08),
        splashColor: color.withValues(alpha: .12),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12),
          child: Row(
            mainAxisAlignment: compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(icon, size: 19, color: color),
              if (!compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (compact) {
      item = Tooltip(message: label, preferBelow: false, child: item);
    }

    return item;
  }
}
