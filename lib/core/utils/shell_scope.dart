import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

enum NavDestination { overview, automations, channel, inbox, settings }

extension NavDestinationX on NavDestination {
  String get label => switch (this) {
    NavDestination.overview => 'Overview',
    NavDestination.automations => 'Automations',
    NavDestination.channel => 'Channel',
    NavDestination.inbox => 'Inbox',
    NavDestination.settings => 'Settings',
  };

  IconData get icon => switch (this) {
    NavDestination.overview => RemixIcons.dashboard_line,
    NavDestination.automations => RemixIcons.flow_chart,
    NavDestination.channel => RemixIcons.plug_2_line,
    NavDestination.inbox => RemixIcons.inbox_line,
    NavDestination.settings => RemixIcons.settings_3_line,
  };

  String get blurb => switch (this) {
    NavDestination.overview => 'Your studio at a glance.',
    NavDestination.automations => 'Build and manage automated conversations.',
    NavDestination.channel => 'Connect and manage your Instagram account.',
    NavDestination.inbox => 'Every conversation, one shared inbox.',
    NavDestination.settings => 'Workspace, preferences and access.',
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
