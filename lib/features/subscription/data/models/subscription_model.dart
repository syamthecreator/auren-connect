class SubscriptionModel {
  const SubscriptionModel({
    required this.id,
    required this.workspaceId,
    required this.planId,
    required this.planSlug,
    required this.planName,
    this.billingFrequency = 'MONTHLY',
    this.status = 'ACTIVE',
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.amount,
    this.currency = 'USD',
    this.transactionId,
    this.receiptUrl,
  });

  final String id;
  final String workspaceId;
  final String planId;
  final String planSlug;
  final String planName;
  final String billingFrequency;
  final String status;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final double? amount;
  final String currency;
  final String? transactionId;
  final String? receiptUrl;

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] is Map
        ? Map<String, dynamic>.from(json['plan'] as Map)
        : null;

    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      workspaceId: json['workspaceId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? plan?['id']?.toString() ?? '',
      planSlug: plan?['slug']?.toString() ??
          json['planSlug']?.toString() ??
          'starter',
      planName: plan?['name']?.toString() ??
          json['planName']?.toString() ??
          'Starter',
      billingFrequency: json['billingFrequency']?.toString() ?? 'MONTHLY',
      status: json['status']?.toString() ?? 'ACTIVE',
      currentPeriodStart: json['currentPeriodStart'] != null
          ? DateTime.tryParse(json['currentPeriodStart'].toString())
          : null,
      currentPeriodEnd: json['currentPeriodEnd'] != null
          ? DateTime.tryParse(json['currentPeriodEnd'].toString())
          : null,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency']?.toString() ?? 'USD',
      transactionId: json['transactionId']?.toString(),
      receiptUrl: json['receiptUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'workspaceId': workspaceId,
    'planId': planId,
    'planSlug': planSlug,
    'planName': planName,
    'billingFrequency': billingFrequency,
    'status': status,
    'currentPeriodStart': currentPeriodStart?.toIso8601String(),
    'currentPeriodEnd': currentPeriodEnd?.toIso8601String(),
    'amount': amount,
    'currency': currency,
    'transactionId': transactionId,
    'receiptUrl': receiptUrl,
  };
}

class CheckoutSessionModel {
  const CheckoutSessionModel({
    required this.sessionId,
    required this.workspaceId,
    required this.planSlug,
    required this.planName,
    required this.billingFrequency,
    required this.baseAmount,
    required this.taxAmount,
    required this.totalAmount,
    required this.currency,
  });

  final String sessionId;
  final String workspaceId;
  final String planSlug;
  final String planName;
  final String billingFrequency;
  final double baseAmount;
  final double taxAmount;
  final double totalAmount;
  final String currency;

  factory CheckoutSessionModel.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] is Map ? json['plan'] as Map : {};
    return CheckoutSessionModel(
      sessionId: json['sessionId']?.toString() ?? '',
      workspaceId: json['workspaceId']?.toString() ?? '',
      planSlug: plan['slug']?.toString() ?? 'starter',
      planName: plan['name']?.toString() ?? 'Starter',
      billingFrequency: plan['billingFrequency']?.toString() ?? 'MONTHLY',
      baseAmount: (json['baseAmount'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['taxAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
    );
  }
}

