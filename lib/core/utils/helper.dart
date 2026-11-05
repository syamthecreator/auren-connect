import 'dart:math' as math;

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

abstract final class Helper {
  static ({IconData icon, Color color}) getChannel(
    String name,
  ) => switch (name) {
    'WhatsApp' => (icon: RemixIcons.whatsapp_line, color: AppColors.waColor),
    'Instagram' => (icon: RemixIcons.instagram_line, color: AppColors.igColor),
    'SMS' => (icon: RemixIcons.message_2_line, color: const Color(0xFF8C9BFF)),
    'Email' => (icon: RemixIcons.mail_line, color: AppColors.warning),
    _ => (icon: RemixIcons.telegram_line, color: const Color(0xFF29B6F6)),
  };

  static List<double> generateWave({
    required int count,
    required double base,
    required double amplitude,
    required double phase,
  }) {
    return [
      for (var i = 0; i < count; i++)
        base + amplitude * math.sin(i * .55 + phase) + i * amplitude * .12,
    ];
  }
}
