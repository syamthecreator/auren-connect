import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class StudioCard extends StatefulWidget {
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
  State<StudioCard> createState() => _StudioCardState();
}

class _StudioCardState extends State<StudioCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lit = _hover && (widget.hoverable || widget.onTap != null);
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: widget.padding,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppColors.hydroGlassGradient,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(
              color: lit
                  ? AppColors.primary.withValues(alpha: .45)
                  : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
              if (lit)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: .12),
                  blurRadius: 30,
                ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
