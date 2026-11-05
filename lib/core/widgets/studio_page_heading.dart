import 'package:flutter/material.dart';

class StudioPageHeading extends StatelessWidget {
  const StudioPageHeading({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerRight,
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: actions,
    ),
  );
}
