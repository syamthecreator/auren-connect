import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar(this.value, {super.key, this.color});
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        children: [
          Container(height: 6, color: AppColors.border),
          FractionallySizedBox(
            widthFactor: value.clamp(0, 1),
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: color == null
                    ? AppColors.neonLaserGradient
                    : LinearGradient(
                        colors: [color!.withValues(alpha: .6), color!],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
