import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:auren_connect/app/app.dart';
import 'package:auren_connect/features/landing/presentation/screens/landing_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AurenConnectApp renders public SaaS landing entry page with branding and CTAs', (tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const AurenConnectApp());
    await tester.pump(const Duration(milliseconds: 100));
    tester.takeException();

    // Verify that the public SaaS landing entry page is displayed initially
    expect(find.byType(LandingScreen), findsOneWidget);
    expect(find.text('Automate Conversations.\nAccelerate Growth.'), findsOneWidget);
    expect(find.text('Get Started'), findsWidgets);
    expect(find.text('Explore Pricing'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
