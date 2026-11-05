import 'package:flutter/material.dart';

class Glow extends StatelessWidget {
  const Glow(this.size, this.color, this.opacity, {super.key});
  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: opacity),
            Colors.transparent,
          ],
        ),
      ),
    ),
  );
}
