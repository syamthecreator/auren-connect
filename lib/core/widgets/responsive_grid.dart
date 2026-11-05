import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.maxColumns = 4,
    this.spacing = 16,
  });

  final List<Widget> children;
  final double minItemWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final cols = ((box.maxWidth + spacing) / (minItemWidth + spacing))
            .floor()
            .clamp(1, maxColumns);
        final w = ((box.maxWidth - spacing * (cols - 1)) / cols)
            .floorToDouble();
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (final c in children) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}
