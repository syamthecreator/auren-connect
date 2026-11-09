import 'package:auren_connect/app/routes/app_router.dart';
import 'package:auren_connect/app/theme/app_theme.dart';
import 'package:auren_connect/core/network/api_client.dart';
import 'package:auren_connect/core/network/auth_token_manager.dart';
import 'package:auren_connect/core/services/auth_api_service.dart';
import 'package:auren_connect/features/auth/controllers/auth_controller.dart';
import 'package:auren_connect/features/channel/controller/channel_controller.dart';
import 'package:auren_connect/features/channel/service/channel_api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
        Provider<ChannelApiService>(
          create: (context) =>
              ChannelApiService(apiClient: context.read<ApiClient>()),
        ),
        ChangeNotifierProvider<ChannelController>(
          create: (context) => ChannelController(
            channelApiService: context.read<ChannelApiService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'aurenConnect',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: AppRouter.auth,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
