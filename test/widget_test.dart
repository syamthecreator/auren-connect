import 'package:auren_connect/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:auren_connect/features/auth/presentation/screens/login_screen.dart';

void main() {
  testWidgets(
    'App renders authentication with default credentials and transitions to Dashboard',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const AurenConnectApp());
      await tester.pumpAndSettle();

      // Verify that the login screen is displayed initially
      expect(find.byType(AuthScreen), findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);

      // Verify default credentials are pre-filled
      expect(find.text('syamthecreator@gmail.com'), findsOneWidget);
      expect(find.text('syam123'), findsOneWidget);

      // Tap Sign In to Workspace directly without typing manually
      final signInButton = find.text('Sign In to Workspace');
      expect(signInButton, findsOneWidget);
      await tester.ensureVisible(signInButton);
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Verify transition to DashboardScreen
      expect(find.text('AUTOMATION STUDIO'), findsOneWidget);
      expect(find.text('Messages sent'), findsOneWidget);
      expect(find.text('Active flows'), findsOneWidget);
      expect(find.text('Delivery rate'), findsOneWidget);
      expect(find.text('Message volume'), findsOneWidget);
      expect(find.text('Channel split'), findsOneWidget);
      expect(find.text('Top automations'), findsOneWidget);
      expect(find.text('Recent activity'), findsOneWidget);
    },
  );
}
