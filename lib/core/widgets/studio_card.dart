import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StudioCard extends StatelessWidget {
  const StudioCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.gradient,
    this.hoverable = false,
    this.radius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final bool hoverable;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isInteractive = hoverable || onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        hoverColor: isInteractive
            ? AppColors.primary.withValues(alpha: .04)
            : Colors.transparent,
        splashColor: onTap != null
            ? AppColors.primary.withValues(alpha: .08)
            : Colors.transparent,
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ?? AppColors.hydroGlassGradient,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                blurRadius: 24,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
