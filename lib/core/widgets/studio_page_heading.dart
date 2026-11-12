import 'package:flutter/material.dart';

class StudioPageHeading extends StatelessWidget {
  const StudioPageHeading({super.key, required this.actions});

  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: actions,
      ),
    );
  }
}
