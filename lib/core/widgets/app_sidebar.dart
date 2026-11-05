import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/core/constants/asset_constants.dart';
import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:flutter/material.dart';
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
                      for (final d in [
                        NavDestination.overview,
                        NavDestination.automations,
                        NavDestination.inbox,
                        NavDestination.channel,
                        NavDestination.settings,
                      ])
                        _NavItem(
                          destination: d,
                          active: d == current,
                          compact: compact,
                          badge: d == NavDestination.inbox ? '12' : null,
                          onTap: () => onSelect(d),
                        ),
                    ],
                  ),
                ),
                if (!compact) const _UsageCard(),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 12 : 14,
                    8,
                    compact ? 12 : 14,
                    14,
                  ),
                  child: Column(
                    children: [
                      _ActionItem(
                        icon: RemixIcons.logout_box_r_line,
                        label: 'Log out',
                        compact: compact,
                        color: AppColors.error,
                        onTap: onLogout,
                      ),
                    ],
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
                      Icon(
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
      padding: const EdgeInsets.all(7),
      child: Image.asset(AssetConstants.aLogo, fit: BoxFit.contain),
    );
  }
}

class _SidebarToggle extends StatefulWidget {
  const _SidebarToggle({required this.collapsed, required this.onTap});

  final bool collapsed;
  final VoidCallback onTap;

  @override
  State<_SidebarToggle> createState() => _SidebarToggleState();
}

class _SidebarToggleState extends State<_SidebarToggle> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.collapsed ? 'Expand sidebar' : 'Collapse sidebar',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hover
                  ? AppColors.primary.withValues(alpha: .12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.collapsed
                  ? RemixIcons.menu_unfold_line
                  : RemixIcons.menu_fold_line,
              size: 19,
              color: _hover ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
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

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active
        ? AppColors.primary
        : (_hover ? AppColors.textPrimary : AppColors.textSecondary);

    Widget item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 0 : 12),
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
            color: !active && _hover
                ? Colors.white.withValues(alpha: .04)
                : null,
            border: Border.all(
              color: active
                  ? AppColors.primary.withValues(alpha: .35)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            mainAxisAlignment: widget.compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(widget.destination.icon, size: 20, color: fg),
              if (!widget.compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.destination.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (widget.badge != null)
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
                      widget.badge!,
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

    if (widget.compact) {
      item = Tooltip(
        message: widget.destination.label,
        preferBelow: false,
        child: item,
      );
    }
    return item;
  }
}

class _ActionItem extends StatefulWidget {
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
  State<_ActionItem> createState() => _ActionItemState();
}

class _ActionItemState extends State<_ActionItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final item = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 2),
          height: 42,
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 0 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _hover
                ? widget.color.withValues(alpha: .08)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: widget.compact
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              Icon(widget.icon, size: 19, color: widget.color),
              if (!widget.compact) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.color,
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
    return widget.compact
        ? Tooltip(message: widget.label, preferBelow: false, child: item)
        : item;
  }
}

class _UsageCard extends StatelessWidget {
  const _UsageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.hydroGlassGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                RemixIcons.flashlight_line,
                size: 16,
                color: AppColors.accent,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Growth plan',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '74%',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: .9),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                Container(height: 6, color: AppColors.border),
                FractionallySizedBox(
                  widthFactor: .74,
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: AppColors.neonLaserGradient,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '18,420 of 25,000 messages used',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
