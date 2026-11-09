import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:auren_connect/core/widgets/app_shell.dart';
import 'package:auren_connect/features/auth/presentation/screens/login_screen.dart';
import 'package:auren_connect/features/splash/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String auth = '/auth';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());

      case dashboard:
        final initialDestination =
            routeSettings.arguments as NavDestination?;
        return MaterialPageRoute(
          builder: (_) => AppShell(initialDestination: initialDestination),
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
