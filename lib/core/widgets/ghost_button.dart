import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/ghost_button_state.dart';
import 'package:flutter/material.dart';

class GhostButton extends StatefulWidget {
  const GhostButton({super.key, required this.label, this.icon, this.onTap});
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  State<GhostButton> createState() => GhostButtonState();
}

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
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: i == selected
                      ? AppColors.primary.withValues(alpha: .16)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: i == selected
                        ? AppColors.primary.withValues(alpha: .55)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  options[i],
                  style: AppTextStyles.t(
                    13,
                    w: FontWeight.w600,
                    c: i == selected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
