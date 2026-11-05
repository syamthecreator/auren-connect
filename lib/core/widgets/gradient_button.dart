import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  const GradientButton({super.key, required this.label, this.icon, this.onTap});
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
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
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            gradient: AppColors.darkGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: _hover ? .55 : .3),
                blurRadius: _hover ? 26 : 16,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: AppTextStyles.t(14, w: FontWeight.w600, c: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
