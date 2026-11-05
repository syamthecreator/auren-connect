import 'package:flutter/material.dart';

class StudioIconBox extends StatelessWidget {
  const StudioIconBox(this.icon, this.color, {super.key, this.size = 40});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: .14),
      borderRadius: BorderRadius.circular(size * .3),
      border: Border.all(color: color.withValues(alpha: .25)),
    ),
    child: Icon(icon, size: size * .5, color: color),
  );
}
