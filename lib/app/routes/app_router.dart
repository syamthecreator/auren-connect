import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/shell_scope.dart';
import '../../core/widgets/app_shell.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/presentation/models/auth_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/landing/presentation/screens/landing_screen.dart';
import '../../features/onboarding/presentation/screens/checkout_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_complete_screen.dart';
import '../../features/onboarding/presentation/screens/workspace_creation_screen.dart';
import '../../features/pricing/presentation/screens/pricing_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';

class AppRouter {
  AppRouter._();

  // Public routes
  static const String landing = '/';
  static const String pricing = '/pricing';
  static const String login = '/login';
  static const String auth = '/auth'; // Backward compatible alias
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Onboarding routes
  static const String workspaceOnboarding = '/onboarding/workspace';
  static const String checkout = '/onboarding/checkout';
  static const String onboardingComplete = '/onboarding/complete';

  // Protected routes
  static const String dashboard = '/dashboard';
  static const String splash = '/splash';

  /// Detects whether current URL is a Meta OAuth callback popup
  static bool get isOAuthReturn {
    try {
      final uri = Uri.base;
      return uri.queryParameters['tab'] == 'channel' ||
          uri.queryParameters.containsKey('connected') ||
          uri.fragment.contains('channel') ||
          uri.toString().contains('tab=channel') ||
          uri.toString().contains('connected=true');
    } catch (_) {
      return false;
    }
  }

  /// Handles OAuth popup close if opened as a popup window
  static bool handleOAuthPopup() {
    return false;
  }

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    // Check OAuth return first
    if (isOAuthReturn) {
      if (handleOAuthPopup()) {
        return MaterialPageRoute(builder: (_) => const SizedBox.shrink());
      }
    }

    final uri = Uri.parse(routeSettings.name ?? '/');
    final path = uri.path;

    switch (path) {
      case landing:
        // If OAuth return URL was opened in the main tab, redirect to channels in dashboard
        if (isOAuthReturn) {
          return MaterialPageRoute(
            builder: (_) => const AppShell(initialDestination: NavDestination.channel),
          );
        }
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const LandingScreen(),
        );

      case pricing:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const PricingScreen(),
        );

      case login:
      case auth:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const AuthScreen(),
        );

      case register:
        final planSlug = routeSettings.arguments as String? ??
            uri.queryParameters['plan'];
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => RegisterScreen(planSlug: planSlug),
        );

      case forgotPassword:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) {
            // Pre-set forgot step on AuthController
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.read<AuthController>().setStep(AuthStep.forgot);
            });
            return const AuthScreen();
          },
        );

      case workspaceOnboarding:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => _protected(
            context,
            const WorkspaceCreationScreen(),
          ),
        );

      case checkout:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => _protected(
            context,
            const CheckoutScreen(),
          ),
        );

      case onboardingComplete:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => _protected(
            context,
            const OnboardingCompleteScreen(),
          ),
        );

      case dashboard:
        final initialDestination =
            routeSettings.arguments as NavDestination?;
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (context) => _protected(
            context,
            AppShell(initialDestination: initialDestination),
          ),
        );

      case splash:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const SplashScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: routeSettings,
          builder: (_) => const LandingScreen(),
        );
    }
  }

  /// Protects internal onboarding and dashboard routes
  static Widget _protected(BuildContext context, Widget child) {
    final auth = context.watch<AuthController>();
    if (!auth.isAuthenticated) {
      // If user session is not yet loaded, show loading spinner while initializing
      if (auth.isLoading) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      return const AuthScreen();
    }
    return child;
  }
}
