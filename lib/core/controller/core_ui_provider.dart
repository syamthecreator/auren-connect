import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:flutter/foundation.dart';

/// Shared UI state for the application shell and core widgets.
class CoreUiProvider extends ChangeNotifier {
  CoreUiProvider({NavDestination? initialDestination})
    : _currentDestination = initialDestination ?? NavDestination.automations;

  NavDestination _currentDestination;
  bool? _collapsedOverride;
  bool _showNotifications = false;

  NavDestination get currentDestination => _currentDestination;
  bool get showNotifications => _showNotifications;
  bool? get collapsedOverride => _collapsedOverride;

  bool isSidebarCollapsed(double screenWidth) =>
      _collapsedOverride ?? screenWidth < 1000;

  void goTo(NavDestination destination) {
    if (_currentDestination == destination) return;

    _currentDestination = destination;
    _showNotifications = false;
    notifyListeners();
  }

  void toggleSidebar(double screenWidth) {
    _collapsedOverride = !isSidebarCollapsed(screenWidth);
    notifyListeners();
  }

  void toggleNotifications() {
    _showNotifications = !_showNotifications;
    notifyListeners();
  }

  void closeNotifications() {
    if (!_showNotifications) return;

    _showNotifications = false;
    notifyListeners();
  }
}
