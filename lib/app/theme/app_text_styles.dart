import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle t(
    double size, {
    FontWeight w = FontWeight.w500,
    Color c = AppColors.textPrimary,
    double? ls,
    double? h,
  }) => TextStyle(
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: ls,
    height: h,
  );
}
