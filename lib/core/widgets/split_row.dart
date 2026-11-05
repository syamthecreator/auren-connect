import 'package:flutter/material.dart';

class SplitRow extends StatelessWidget {
  const SplitRow({
    super.key,
    required this.main,
    required this.side,
    this.sideWidth = 380,
    this.breakpoint = 1000,
  });
  final Widget main;
  final Widget side;
  final double sideWidth;
  final double breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        if (box.maxWidth >= breakpoint) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: main),
              const SizedBox(width: 20),
              SizedBox(width: sideWidth, child: side),
            ],
          );
        }
        return Column(children: [main, const SizedBox(height: 20), side]);
      },
    );
  }
}
