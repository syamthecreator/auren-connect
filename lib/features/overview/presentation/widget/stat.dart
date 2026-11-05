import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/features/overview/presentation/widget/spark.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class Stat {
  const Stat(
    this.label,
    this.value,
    this.delta,
    this.up,
    this.icon,
    this.color,
    this.spark,
  );
  final String label, value, delta;
  final bool up;
  final IconData icon;
  final Color color;
  final List<double> spark;
}

class StatTile extends StatelessWidget {
  const StatTile(this.s, {super.key});
  final Stat s;

  @override
  Widget build(BuildContext context) {
    final dc = s.up ? AppColors.success : AppColors.error;
    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudioIconBox(s.icon, s.color, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  s.label,
                  style: AppTextStyles.t(13.5, c: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            s.value,
            style: AppTextStyles.t(30, w: FontWeight.w700, ls: -.8),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                s.up
                    ? RemixIcons.arrow_right_up_line
                    : RemixIcons.arrow_right_down_line,
                size: 15,
                color: dc,
              ),
              const SizedBox(width: 3),
              Text(
                s.delta,
                style: AppTextStyles.t(12.5, w: FontWeight.w700, c: dc),
              ),
              const SizedBox(width: 6),
              Text(
                'vs last week',
                style: AppTextStyles.t(12, c: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Spark(s.spark, s.color),
        ],
      ),
    );
  }
}
