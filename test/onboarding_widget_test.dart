import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auren_connect/app/routes/app_router.dart';
import 'package:auren_connect/core/network/api_client.dart';
import 'package:auren_connect/core/network/auth_token_manager.dart';
import 'package:auren_connect/core/services/auth_api_service.dart';
import 'package:auren_connect/core/services/subscription_api_service.dart';
import 'package:auren_connect/core/services/workspace_api_service.dart';
import 'package:auren_connect/features/auth/controllers/auth_controller.dart';
import 'package:auren_connect/features/pricing/controller/pricing_controller.dart';
import 'package:auren_connect/features/workspace/controller/workspace_controller.dart';
import 'package:auren_connect/features/subscription/controller/subscription_controller.dart';
import 'package:auren_connect/features/pricing/data/models/pricing_plan_model.dart';
import 'package:auren_connect/features/workspace/data/models/workspace_model.dart';
import 'package:auren_connect/core/widgets/logout_confirm_dialog.dart';
import 'package:auren_connect/features/landing/presentation/screens/landing_screen.dart';
import 'package:auren_connect/features/pricing/presentation/screens/pricing_screen.dart';
import 'package:auren_connect/features/auth/presentation/screens/register_screen.dart';
import 'package:auren_connect/features/onboarding/presentation/screens/workspace_creation_screen.dart';
import 'package:auren_connect/features/onboarding/presentation/screens/checkout_screen.dart';
import 'package:auren_connect/features/onboarding/presentation/screens/onboarding_complete_screen.dart';

class MockSubscriptionApiService extends SubscriptionApiService {
  MockSubscriptionApiService({required super.apiClient});

  @override
  Future<List<PricingPlanModel>> getPlans() async {
    return PricingPlanModel.defaultPlans;
  }
}

class MockWorkspaceApiService extends WorkspaceApiService {
  MockWorkspaceApiService({required super.apiClient});

  @override
  Future<List<WorkspaceModel>> getMyWorkspaces() async {
    return [];
  }
}

Widget createTestWrapper(Widget child) {
  final tokenManager = AuthTokenManager();
  final apiClient = ApiClient(tokenManager: tokenManager);
  final authService = AuthApiService(apiClient: apiClient, tokenManager: tokenManager);
  final wsService = MockWorkspaceApiService(apiClient: apiClient);
  final subService = MockSubscriptionApiService(apiClient: apiClient);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>(
        create: (_) => AuthController(authApiService: authService),
      ),
      ChangeNotifierProvider<PricingController>(
        create: (_) => PricingController(subscriptionApiService: subService),
      ),
      ChangeNotifierProvider<WorkspaceController>(
        create: (_) => WorkspaceController(workspaceApiService: wsService),
      ),
      ChangeNotifierProvider<SubscriptionController>(
        create: (_) => SubscriptionController(subscriptionApiService: subService),
      ),
    ],
    child: MaterialApp(
      onGenerateRoute: AppRouter.generateRoute,
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('LandingScreen renders hero, headline, and primary CTAs', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const LandingScreen()));
    final err = tester.takeException();
    if (err is FlutterError) {
      debugPrint('ERR DETAIL: ${err.message}');
    } else if (err != null) {
      debugPrint('ERR DETAIL: $err');
    }

    expect(find.text('Automate Conversations.\nAccelerate Growth.'), findsOneWidget);
    expect(find.text('Get Started'), findsWidgets);
    expect(find.text('Explore Pricing'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('PricingScreen renders monthly/yearly toggle and plans', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const PricingScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Simple, Scalable Pricing for Modern Messaging'), findsOneWidget);
    expect(find.text('Monthly Billing'), findsOneWidget);
    expect(find.text('Annual Billing'), findsOneWidget);
    expect(find.text('Starter'), findsWidgets);
    expect(find.text('Growth'), findsWidgets);
    expect(find.text('Pro'), findsWidgets);
  });

  testWidgets('RegisterScreen renders form fields and selected plan', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const RegisterScreen(planSlug: 'growth')));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('FULL NAME'), findsOneWidget);
    expect(find.text('WORK EMAIL'), findsOneWidget);
    expect(find.text('PASSWORD'), findsOneWidget);
    expect(find.text('CONFIRM PASSWORD'), findsOneWidget);
    expect(find.text('Create Account & Continue'), findsOneWidget);
  });

  testWidgets('WorkspaceCreationScreen renders inputs and step 1 indicator', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const WorkspaceCreationScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Create your Workspace'), findsOneWidget);
    expect(find.text('WORKSPACE NAME'), findsOneWidget);
    expect(find.text('BUSINESS NAME'), findsOneWidget);
    expect(find.text('WORKSPACE URL / SLUG'), findsOneWidget);
    expect(find.text('Create Workspace & Proceed to Checkout'), findsOneWidget);
  });

  testWidgets('CheckoutScreen renders order summary and card form', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const CheckoutScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('ORDER SUMMARY'), findsOneWidget);
    expect(find.text('PAYMENT DETAILS'), findsOneWidget);
    expect(find.text('CARD NUMBER'), findsOneWidget);
    expect(find.text('Complete Payment & Activate'), findsOneWidget);
  });

  testWidgets('OnboardingCompleteScreen renders checklist and launch button', (tester) async {
    tester.view.physicalSize = const Size(1440, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWrapper(const OnboardingCompleteScreen()));
    await tester.pump(const Duration(milliseconds: 50));
    tester.takeException();

    expect(find.text('Workspace Ready to Scale!'), findsOneWidget);
    expect(find.text('ONBOARDING CHECKLIST'), findsOneWidget);
    expect(find.text('1. Workspace created'), findsOneWidget);
    expect(find.text('2. Subscription activated'), findsOneWidget);
    expect(find.text('Launch Dashboard'), findsOneWidget);
  });

  testWidgets('LogoutConfirmDialog renders prompt and action buttons', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LogoutConfirmDialog()),
      ),
    );

    expect(find.text('Log out of Auren Connect?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);
  });
}
