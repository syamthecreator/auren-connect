import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    required this.destination,
    required this.notificationCount,
    required this.onBellTap,
    this.onNewCampaign,
  });

  final NavDestination destination;
  final int notificationCount;
  final VoidCallback onBellTap;
  final VoidCallback? onNewCampaign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final showSearch = c.maxWidth > 860;
        return SizedBox(
          height: 64,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.blurb,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (showSearch) ...[
                const SizedBox(width: 16),
                const SizedBox(width: 320, child: _SearchBox()),
              ],
              const SizedBox(width: 14),
              _BellButton(count: notificationCount, onTap: onBellTap),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.search_line,
            size: 18,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: TextField(
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search contacts, campaigns, templates',
                hintStyle: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Ctrl K',
              style: TextStyle(color: AppColors.textMuted, fontSize: 10.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                RemixIcons.notification_3_line,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
            if (count > 0)
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
