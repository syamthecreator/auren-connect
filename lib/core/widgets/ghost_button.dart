import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.icon, this.onTap});

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        hoverColor: Colors.white.withValues(alpha: .06),
        splashColor: AppColors.primary.withValues(alpha: .10),
        child: Ink(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTextStyles.t(
                  14,
                  w: FontWeight.w600,
                  c: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDIO CHIPS
// ─────────────────────────────────────────────────────────────────────────────

class StudioChips extends StatelessWidget {
  const StudioChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<String> options;
  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < options.length; i++)
          _StudioChip(
            label: options[i],
            isSelected: i == selected,
            onTap: () => onChanged(i),
          ),
      ],
    );
  }
}

class _StudioChip extends StatelessWidget {
  const _StudioChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        hoverColor: AppColors.primary.withValues(alpha: .06),
        splashColor: AppColors.primary.withValues(alpha: .12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: .16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: .55)
                  : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.t(
              13,
              w: FontWeight.w600,
              c: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
