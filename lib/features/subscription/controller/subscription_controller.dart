import 'package:flutter/foundation.dart';
import '../data/models/subscription_model.dart';
import '../../../core/services/subscription_api_service.dart';

class SubscriptionController extends ChangeNotifier {
  SubscriptionController({required this.subscriptionApiService});

  final SubscriptionApiService subscriptionApiService;

  SubscriptionModel? _activeSubscription;
  CheckoutSessionModel? _checkoutSession;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _successMessage;

  SubscriptionModel? get activeSubscription => _activeSubscription;
  CheckoutSessionModel? get checkoutSession => _checkoutSession;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasActiveSubscription =>
      _activeSubscription != null && _activeSubscription!.isActive;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadCurrentSubscription(String workspaceId) async {
    try {
      final sub = await subscriptionApiService.getCurrentSubscription(workspaceId);
      _activeSubscription = sub;
      notifyListeners();
    } catch (e) {
      debugPrint('Load subscription error: $e');
    }
  }

  Future<CheckoutSessionModel?> initiateCheckout({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = await subscriptionApiService.createCheckoutSession(
        workspaceId: workspaceId,
        planSlug: planSlug,
        billingFrequency: billingFrequency,
      );
      _checkoutSession = session;
      return session;
    } catch (e) {
      _errorMessage = 'Failed to initiate checkout session';
      debugPrint('Checkout error: $e');
      return null;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> verifyAndActivateSubscription({
    required String workspaceId,
    required String planSlug,
    required String billingFrequency,
    String? transactionId,
    String paymentMethod = 'CARD',
  }) async {
    _isProcessing = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final sub = await subscriptionApiService.verifyPaymentAndActivate(
        workspaceId: workspaceId,
        planSlug: planSlug,
        billingFrequency: billingFrequency,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );

      _activeSubscription = sub;
      _successMessage = 'Subscription activated successfully';
      return true;
    } catch (e) {
      _errorMessage = 'Payment verification failed. Please try again.';
      debugPrint('Payment verification error: $e');
      return false;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}

