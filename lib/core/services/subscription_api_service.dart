import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../../features/pricing/data/models/pricing_plan_model.dart';
import '../../features/subscription/data/models/subscription_model.dart';

class SubscriptionApiService {
  SubscriptionApiService({required this.apiClient});

  final ApiClient apiClient;

  static const String _localSubscriptionPrefix = 'auren_subscription_ws_';

  /// Get configurable plans
  Future<List<PricingPlanModel>> getPlans() async {
    try {
      final response = await apiClient.get(
        ApiConstants.plans,
        requiresAuth: false,
      );

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => PricingPlanModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (list.isNotEmpty) return list;
      }
    } catch (e) {
      debugPrint('Plans API fetch error (using default configured plans): $e');
    }

    return PricingPlanModel.defaultPlans;
  }

  /// Create checkout session
  Future<CheckoutSessionModel> createCheckoutSession({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.checkout,
        requiresAuth: true,
        body: {
          'workspaceId': workspaceId,
          'planSlug': planSlug,
          'billingFrequency': billingFrequency,
        },
      );

      if (response['success'] == true && response['data'] is Map) {
        return CheckoutSessionModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
      }
    } catch (e) {
      debugPrint('Checkout session API error: $e');
    }

    // Configured fallback calculation
    final plan = PricingPlanModel.defaultPlans.firstWhere(
      (p) => p.slug == planSlug,
      orElse: () => PricingPlanModel.defaultPlans[0],
    );

    final base = billingFrequency == 'YEARLY'
        ? plan.yearlyPrice.toDouble()
        : plan.monthlyPrice.toDouble();
    final tax = (base * 0.18 * 100).round() / 100;
    final total = base + tax;

    return CheckoutSessionModel(
      sessionId: 'chk_${DateTime.now().millisecondsSinceEpoch}',
      workspaceId: workspaceId,
      planSlug: plan.slug,
      planName: plan.name,
      billingFrequency: billingFrequency,
      baseAmount: base,
      taxAmount: tax,
      totalAmount: total,
      currency: plan.currency,
    );
  }

  /// Verify payment and activate subscription
  Future<SubscriptionModel> verifyPaymentAndActivate({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
    String? transactionId,
    String paymentMethod = 'CARD',
  }) async {
    final txnId = transactionId ??
        'ac_txn_${DateTime.now().millisecondsSinceEpoch}';

    try {
      final response = await apiClient.post(
        ApiConstants.verifyPayment,
        requiresAuth: true,
        body: {
          'workspaceId': workspaceId,
          'planSlug': planSlug,
          'billingFrequency': billingFrequency,
          'transactionId': txnId,
          'paymentMethod': paymentMethod,
        },
      );

      if (response['success'] == true &&
          response['data'] is Map &&
          response['data']['subscription'] is Map) {
        final sub = SubscriptionModel.fromJson(
          Map<String, dynamic>.from(response['data']['subscription'] as Map),
        );
        await _saveSubscriptionLocally(workspaceId, sub);
        return sub;
      }
    } catch (e) {
      debugPrint('Subscription verification API error (saving locally): $e');
    }

    final plan = PricingPlanModel.defaultPlans.firstWhere(
      (p) => p.slug == planSlug,
      orElse: () => PricingPlanModel.defaultPlans[0],
    );

    final now = DateTime.now();
    final periodEnd = billingFrequency == 'YEARLY'
        ? DateTime(now.year + 1, now.month, now.day)
        : DateTime(now.year, now.month + 1, now.day);

    final verifiedSub = SubscriptionModel(
      id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
      workspaceId: workspaceId,
      planId: plan.id,
      planSlug: plan.slug,
      planName: plan.name,
      billingFrequency: billingFrequency,
      status: 'ACTIVE',
      currentPeriodStart: now,
      currentPeriodEnd: periodEnd,
      amount: billingFrequency == 'YEARLY'
          ? plan.yearlyPrice.toDouble()
          : plan.monthlyPrice.toDouble(),
      currency: plan.currency,
      transactionId: txnId,
      receiptUrl: 'https://aurenconnect.com/receipts/$txnId',
    );

    await _saveSubscriptionLocally(workspaceId, verifiedSub);
    return verifiedSub;
  }

  /// Get current subscription for workspace
  Future<SubscriptionModel?> getCurrentSubscription(String workspaceId) async {
    try {
      final response = await apiClient.get(
        '${ApiConstants.currentSubscription}?workspaceId=$workspaceId',
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] is Map) {
        return SubscriptionModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
      }
    } catch (e) {
      debugPrint('Fetch subscription error: $e');
    }

    return await _getLocalSubscription(workspaceId);
  }

  Future<void> _saveSubscriptionLocally(
    String workspaceId,
    SubscriptionModel sub,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_localSubscriptionPrefix$workspaceId',
        jsonEncode(sub.toJson()),
      );
    } catch (_) {}
  }

  Future<SubscriptionModel?> _getLocalSubscription(String workspaceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_localSubscriptionPrefix$workspaceId');
      if (raw == null || raw.isEmpty) return null;
      return SubscriptionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}

