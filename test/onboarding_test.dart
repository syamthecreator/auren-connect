import 'package:flutter_test/flutter_test.dart';
import 'package:auren_connect/features/pricing/data/models/pricing_plan_model.dart';
import 'package:auren_connect/features/workspace/data/models/workspace_model.dart';
import 'package:auren_connect/features/subscription/data/models/subscription_model.dart';

void main() {
  group('SaaS Onboarding & Pricing Plan Model Tests', () {
    test('Default plans contain Starter, Growth, and Pro with correct entitlements', () {
      final plans = PricingPlanModel.defaultPlans;
      expect(plans.length, 3);

      final starter = plans.firstWhere((p) => p.slug == 'starter');
      final growth = plans.firstWhere((p) => p.slug == 'growth');
      final pro = plans.firstWhere((p) => p.slug == 'pro');

      // Starter tests
      expect(starter.name, 'Starter');
      expect(starter.monthlyPrice, 29);
      expect(starter.yearlyPrice, 288);
      expect(starter.yearlyMonthlyEquivalent, 24);
      expect(starter.annualSavings, 60);
      expect(starter.whatsappIncluded, isTrue);
      expect(starter.instagramIncluded, isTrue);
      expect(starter.maxConnectedAccounts, 2);
      expect(starter.maxTeamMembers, 1);
      expect(starter.monthlyMessages, 2500);
      expect(starter.ctaText, 'Get Started');

      // Growth tests
      expect(growth.name, 'Growth');
      expect(growth.isPopular, isTrue);
      expect(growth.monthlyPrice, 79);
      expect(growth.yearlyPrice, 768);
      expect(growth.yearlyMonthlyEquivalent, 64);
      expect(growth.annualSavings, 180);
      expect(growth.maxConnectedAccounts, 5);
      expect(growth.maxTeamMembers, 3);
      expect(growth.monthlyMessages, 15000);
      expect(growth.ctaText, 'Choose Plan');

      // Pro tests
      expect(pro.name, 'Pro');
      expect(pro.monthlyPrice, 199);
      expect(pro.yearlyPrice, 1908);
      expect(pro.yearlyMonthlyEquivalent, 159);
      expect(pro.annualSavings, 480);
      expect(pro.maxConnectedAccounts, 15);
      expect(pro.maxTeamMembers, 10);
      expect(pro.monthlyMessages, 50000);
      expect(pro.ctaText, 'Get Started');
    });

    test('PricingPlanModel serialization and deserialization', () {
      final plan = PricingPlanModel.defaultPlans[1];
      final json = plan.toJson();
      final restored = PricingPlanModel.fromJson(json);

      expect(restored.slug, plan.slug);
      expect(restored.name, plan.name);
      expect(restored.monthlyPrice, plan.monthlyPrice);
      expect(restored.yearlyPrice, plan.yearlyPrice);
      expect(restored.maxConnectedAccounts, plan.maxConnectedAccounts);
      expect(restored.features.length, plan.features.length);
    });
  });

  group('Workspace Model Tests', () {
    test('WorkspaceModel creation and copyWith', () {
      final ws = WorkspaceModel(
        id: 'ws-123',
        name: 'Acme Fleet',
        businessName: 'Acme Media Inc',
        businessCategory: 'Marketing Agency',
        slug: 'acme-fleet',
        timezone: 'UTC',
        country: 'United States',
        ownerId: 'user-456',
        userRole: 'OWNER',
        createdAt: DateTime.now(),
      );

      expect(ws.name, 'Acme Fleet');
      expect(ws.slug, 'acme-fleet');
      expect(ws.userRole, 'OWNER');

      final updated = ws.copyWith(name: 'Acme Global Fleet');
      expect(updated.name, 'Acme Global Fleet');
      expect(updated.id, 'ws-123');
      expect(updated.slug, 'acme-fleet');

      final json = ws.toJson();
      final restored = WorkspaceModel.fromJson(json);
      expect(restored.id, ws.id);
      expect(restored.businessName, ws.businessName);
    });
  });

  group('Subscription & Checkout Models Tests', () {
    test('CheckoutSessionModel parses order breakdown accurately', () {
      final session = CheckoutSessionModel(
        sessionId: 'chk_test_999',
        workspaceId: 'ws_test_1',
        planSlug: 'growth',
        planName: 'Growth',
        billingFrequency: 'YEARLY',
        baseAmount: 768.0,
        taxAmount: 138.24,
        totalAmount: 906.24,
        currency: 'USD',
      );

      expect(session.sessionId, 'chk_test_999');
      expect(session.planSlug, 'growth');
      expect(session.billingFrequency, 'YEARLY');
      expect(session.baseAmount, 768.0);
      expect(session.taxAmount, 138.24);
      expect(session.totalAmount, 906.24);
    });

    test('SubscriptionModel active status verification', () {
      final activeSub = SubscriptionModel(
        id: 'sub-1',
        workspaceId: 'ws-1',
        planId: 'plan-growth',
        planSlug: 'growth',
        planName: 'Growth',
        status: 'ACTIVE',
        billingFrequency: 'YEARLY',
      );

      expect(activeSub.isActive, isTrue);

      final canceledSub = SubscriptionModel(
        id: 'sub-2',
        workspaceId: 'ws-1',
        planId: 'plan-starter',
        planSlug: 'starter',
        planName: 'Starter',
        status: 'CANCELED',
        billingFrequency: 'MONTHLY',
      );

      expect(canceledSub.isActive, isFalse);
    });
  });
}

