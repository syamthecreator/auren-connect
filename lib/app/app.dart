import 'package:auren_connect/app/routes/app_router.dart';
import 'package:auren_connect/app/theme/app_theme.dart';
import 'package:auren_connect/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AurenConnectApp extends StatelessWidget {
  const AurenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>(create: (_) => AuthController()),
      ],
      child: MaterialApp(
        title: 'Auren Connect',
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
