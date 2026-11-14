import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'routes/app_router.dart';
import 'theme/app_theme.dart';
import '../core/controller/core_ui_provider.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_token_manager.dart';
import '../core/services/auth_api_service.dart';
import '../core/services/subscription_api_service.dart';
import '../core/services/workspace_api_service.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/automation/controller/automation_provider.dart';
import '../features/automation/service/automation_api_service.dart';
import '../features/channel/controller/channel_controller.dart';
import '../features/channel/service/channel_api_service.dart';
import '../features/inbox/controller/inbox_controller.dart';
import '../features/inbox/service/inbox_api_service.dart';
import '../features/pricing/controller/pricing_controller.dart';
import '../features/splash/controller/splash_controller.dart';
import '../features/subscription/controller/subscription_controller.dart';
import '../features/workspace/controller/workspace_controller.dart';

class AurenConnectApp extends StatelessWidget {
  const AurenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthTokenManager>(create: (_) => AuthTokenManager()),
        Provider<ApiClient>(
          create: (context) =>
              ApiClient(tokenManager: context.read<AuthTokenManager>()),
        ),
        Provider<AuthApiService>(
          create: (context) => AuthApiService(
            apiClient: context.read<ApiClient>(),
            tokenManager: context.read<AuthTokenManager>(),
          ),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(authApiService: context.read<AuthApiService>())
                ..initialize(),
        ),
        Provider<WorkspaceApiService>(
          create: (context) => WorkspaceApiService(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider<WorkspaceController>(
          create: (context) => WorkspaceController(
            workspaceApiService: context.read<WorkspaceApiService>(),
          )..loadWorkspaces(),
        ),
        Provider<SubscriptionApiService>(
          create: (context) => SubscriptionApiService(
            apiClient: context.read<ApiClient>(),
          ),
        ),
        ChangeNotifierProvider<SubscriptionController>(
          create: (context) => SubscriptionController(
            subscriptionApiService: context.read<SubscriptionApiService>(),
          ),
        ),
        ChangeNotifierProvider<PricingController>(
          create: (context) => PricingController(
            subscriptionApiService: context.read<SubscriptionApiService>(),
          ),
        ),
        Provider<ChannelApiService>(
          create: (context) =>
              ChannelApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<ChannelController>(
          create: (context) => ChannelController(
            channelApiService: context.read<ChannelApiService>(),
          ),
        ),
        ChangeNotifierProvider<CoreUiProvider>(create: (_) => CoreUiProvider()),
        Provider<InboxApiService>(
          create: (context) =>
              InboxApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<InboxController>(
          create: (context) => InboxController(
            inboxApiService: context.read<InboxApiService>(),
            tokenManager: context.read<AuthTokenManager>(),
          ),
        ),
        ChangeNotifierProvider<SplashController>(
          create: (context) => SplashController(
            tokenManager: context.read<AuthTokenManager>(),
            authController: context.read<AuthController>(),
          ),
        ),
        Provider<AutomationApiService>(
          create: (context) =>
              AutomationApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<AutomationProvider>(
          create: (context) => AutomationProvider(
            automationApiService: context.read<AutomationApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'aurenConnect',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRouter.landing,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
