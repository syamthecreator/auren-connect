import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppInputDecorations {
  static InputDecoration dec(String hint, {IconData? icon}) => InputDecoration(
    isDense: true,
    filled: true,
    fillColor: AppColors.surfaceVariant.withValues(alpha: .6),
    hintText: hint,
    hintStyle: AppTextStyles.t(13.5, c: AppColors.textMuted),
    prefixIcon: icon == null
        ? null
        : Icon(icon, size: 18, color: AppColors.textMuted),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary),
    ),
  );
}
