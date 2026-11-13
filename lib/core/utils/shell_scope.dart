import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

enum NavDestination { automations, channel, inbox }

extension NavDestinationX on NavDestination {
  String get label => switch (this) {
    NavDestination.automations => 'Automations',
    NavDestination.channel => 'Channel',
    NavDestination.inbox => 'Inbox',
  };

  IconData get icon => switch (this) {
    NavDestination.automations => RemixIcons.flow_chart,
    NavDestination.channel => RemixIcons.plug_2_line,
    NavDestination.inbox => RemixIcons.inbox_line,
  };

  String get blurb => switch (this) {
    NavDestination.automations => 'Build and manage automated conversations.',
    NavDestination.channel => 'Connect and manage your Instagram account.',
    NavDestination.inbox => 'Every conversation, one shared inbox.',
  };
}

class ShellScope extends InheritedWidget {
  const ShellScope({super.key, required this.goTo, required super.child});

  final ValueChanged<NavDestination> goTo;

  static ShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ShellScope>();
    assert(scope != null, 'ShellScope not found in widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(ShellScope oldWidget) => goTo != oldWidget.goTo;
}
