import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:flutter/material.dart';

class GhostButtonState extends State<GhostButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _hover
                ? Colors.white.withValues(alpha: .06)
                : Colors.white.withValues(alpha: .02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hover
                  ? AppColors.primary.withValues(alpha: .5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
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
