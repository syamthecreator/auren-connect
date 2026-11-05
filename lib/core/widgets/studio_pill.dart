import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StudioPill extends StatelessWidget {
  const StudioPill(
    this.text, {
    super.key,
    required this.color,
    this.dot = true,
    this.icon,
  });
  final String text;
  final Color color;
  final bool dot;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          if (dot && icon == null) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: AppTextStyles.t(12, w: FontWeight.w600, c: color),
          ),
        ],
      ),
    );
  }
}
