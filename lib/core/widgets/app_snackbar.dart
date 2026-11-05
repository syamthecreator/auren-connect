import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:auren_connect/app/theme/app_colors.dart';

enum _SnackBarType { success, info, error }

class AppSnackBar {
  AppSnackBar._();

  static const double _width = 340;

  static void success(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    type: _SnackBarType.success,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void info(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    type: _SnackBarType.info,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void error(
    BuildContext context,
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) => _show(
    context,
    message,
    type: _SnackBarType.error,
    actionLabel: actionLabel,
    onAction: onAction,
  );

  static void _show(
    BuildContext context,
    String message, {
    required _SnackBarType type,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final Color accentColor;
    final IconData icon;

    switch (type) {
      case _SnackBarType.success:
        accentColor = AppColors.accent;
        icon = RemixIcons.checkbox_circle_fill;
        break;
      case _SnackBarType.info:
        accentColor = AppColors.primary;
        icon = RemixIcons.information_line;
        break;
      case _SnackBarType.error:
        accentColor = AppColors.error;
        icon = RemixIcons.error_warning_fill;
        break;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surface,
          elevation: 0,
          duration: const Duration(seconds: 3),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          margin: isWide
              ? EdgeInsets.only(
                  left: screenWidth - _width - 24,
                  right: 24,
                  bottom: 24,
                )
              : const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(
              color: accentColor.withValues(alpha: 0.30),
              width: 1,
            ),
          ),
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    messenger.hideCurrentSnackBar();
                    onAction();
                  },
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
  }
}
