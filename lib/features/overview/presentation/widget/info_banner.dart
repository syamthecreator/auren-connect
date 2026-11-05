import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class InfoBanner extends StatelessWidget {
  const InfoBanner(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.primary.withValues(alpha: .07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.primary.withValues(alpha: .25)),
    ),
    child: Row(
      children: [
        const Icon(
          RemixIcons.information_line,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.t(13, c: AppColors.textSecondary, h: 1.45),
          ),
        ),
      ],
    ),
  );
}
