import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});
  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.t(16, w: FontWeight.w700, ls: -.2),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle!,
                  style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
