import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class StudioAvatar extends StatelessWidget {
  const StudioAvatar(this.name, {super.key, this.size = 38});
  final String name;
  final double size;

  static const _palette = [
    [Color(0xFF0072FF), Color(0xFF00E5FF)],
    [Color(0xFF5B6CFF), Color(0xFF9AA7FF)],
    [Color(0xFF00B4D8), Color(0xFF00E676)],
    [Color(0xFFFF5FA2), Color(0xFFFFB74D)],
    [Color(0xFF1B2D4A), Color(0xFF78B7E8)],
  ];

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ');
    final initials = (parts.first[0] + (parts.length > 1 ? parts.last[0] : ''))
        .toUpperCase();
    final colors =
        _palette[name.codeUnits.fold<int>(0, (a, b) => a + b) %
            _palette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Text(
        initials,
        style: AppTextStyles.t(size * .34, w: FontWeight.w700, c: Colors.white),
      ),
    );
  }
}
