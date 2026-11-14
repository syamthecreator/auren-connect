import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class BillingCycleToggle extends StatelessWidget {
  const BillingCycleToggle({
    super.key,
    required this.isYearly,
    required this.onChanged,
  });

  final bool isYearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            label: 'Monthly Billing',
            isSelected: !isYearly,
            onTap: () => onChanged(false),
          ),
          const SizedBox(width: 4),
          _ToggleItem(
            label: 'Annual Billing',
            badgeText: 'SAVE 20%',
            badgeIcon: RemixIcons.percent_line,
            isSelected: isYearly,
            onTap: () => onChanged(true),
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeText,
    this.badgeIcon,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badgeText;
  final IconData? badgeIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      hoverColor: Colors.white.withValues(alpha: 0.04),
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceVariant : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.t(
                13,
                w: isSelected ? FontWeight.w700 : FontWeight.w500,
                c: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            if (badgeText != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (badgeIcon != null) ...[
                      Icon(badgeIcon, size: 10, color: AppColors.primary),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      badgeText!,
                      style: AppTextStyles.t(
                        10,
                        w: FontWeight.w700,
                        c: AppColors.primary,
                        ls: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
