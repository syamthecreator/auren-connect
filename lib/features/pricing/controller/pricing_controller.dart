import 'package:flutter/foundation.dart';
import '../data/models/pricing_plan_model.dart';
import '../../../core/services/subscription_api_service.dart';

class PricingController extends ChangeNotifier {
  PricingController({required this.subscriptionApiService}) {
    // Default to Growth plan
    _selectedPlan = PricingPlanModel.defaultPlans.firstWhere(
      (p) => p.slug == 'growth',
      orElse: () => PricingPlanModel.defaultPlans[0],
    );
  }

  final SubscriptionApiService subscriptionApiService;

  List<PricingPlanModel> _plans = PricingPlanModel.defaultPlans;
  bool _isLoading = false;
  bool _isYearly = true; // Annual billing by default with discount
  PricingPlanModel? _selectedPlan;

  List<PricingPlanModel> get plans => _plans;
  bool get isLoading => _isLoading;
  bool get isYearly => _isYearly;
  PricingPlanModel? get selectedPlan => _selectedPlan;

  Future<void> loadPlans() async {
    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await subscriptionApiService.getPlans();
      if (fetched.isNotEmpty) {
        _plans = fetched;
        if (_selectedPlan != null) {
          _selectedPlan = _plans.firstWhere(
            (p) => p.slug == _selectedPlan!.slug,
            orElse: () => _plans[0],
          );
        } else {
          _selectedPlan = _plans.firstWhere(
            (p) => p.slug == 'growth',
            orElse: () => _plans[0],
          );
        }
      }
    } catch (e) {
      debugPrint('Error loading pricing plans: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleBilling(bool yearly) {
    if (_isYearly == yearly) return;
    _isYearly = yearly;
    notifyListeners();
  }

  void selectPlan(PricingPlanModel plan) {
    _selectedPlan = plan;
    notifyListeners();
  }

  void selectPlanBySlug(String slug) {
    final match = _plans.firstWhere(
      (p) => p.slug.toLowerCase() == slug.toLowerCase(),
      orElse: () => _plans[0],
    );
    selectPlan(match);
  }
}
