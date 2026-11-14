class PricingPlanModel {
  const PricingPlanModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.tagline,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.currency,
    required this.whatsappIncluded,
    required this.instagramIncluded,
    required this.aiAutomationIncluded,
    required this.maxConnectedAccounts,
    required this.maxTeamMembers,
    required this.monthlyMessages,
    required this.features,
    this.isPopular = false,
    this.ctaText = 'Get Started',
  });

  final String id;
  final String slug;
  final String name;
  final String tagline;
  final int monthlyPrice;
  final int yearlyPrice;
  final String currency;
  final bool whatsappIncluded;
  final bool instagramIncluded;
  final bool aiAutomationIncluded;
  final int maxConnectedAccounts;
  final int maxTeamMembers;
  final int monthlyMessages;
  final List<String> features;
  final bool isPopular;
  final String ctaText;

  /// Effective price per month when billed annually
  int get yearlyMonthlyEquivalent => (yearlyPrice / 12).round();

  /// Annual savings amount
  int get annualSavings => (monthlyPrice * 12) - yearlyPrice;

  factory PricingPlanModel.fromJson(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? 'starter';
    return PricingPlanModel(
      id: json['id']?.toString() ?? 'plan-$slug',
      slug: slug,
      name: json['name']?.toString() ?? 'Starter',
      tagline: json['tagline']?.toString() ?? '',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toInt() ?? 29,
      yearlyPrice: (json['yearlyPrice'] as num?)?.toInt() ?? 288,
      currency: json['currency']?.toString() ?? 'USD',
      whatsappIncluded: json['whatsappIncluded'] == true,
      instagramIncluded: json['instagramIncluded'] == true,
      aiAutomationIncluded: json['aiAutomationIncluded'] == true,
      maxConnectedAccounts:
          (json['maxConnectedAccounts'] as num?)?.toInt() ?? 2,
      maxTeamMembers: (json['maxTeamMembers'] as num?)?.toInt() ?? 1,
      monthlyMessages: (json['monthlyMessages'] as num?)?.toInt() ?? 2500,
      features:
          (json['features'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      isPopular: json['isPopular'] == true,
      ctaText: slug == 'growth' ? 'Choose Plan' : 'Get Started',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'tagline': tagline,
    'monthlyPrice': monthlyPrice,
    'yearlyPrice': yearlyPrice,
    'currency': currency,
    'whatsappIncluded': whatsappIncluded,
    'instagramIncluded': instagramIncluded,
    'aiAutomationIncluded': aiAutomationIncluded,
    'maxConnectedAccounts': maxConnectedAccounts,
    'maxTeamMembers': maxTeamMembers,
    'monthlyMessages': monthlyMessages,
    'features': features,
    'isPopular': isPopular,
    'ctaText': ctaText,
  };

  static const List<PricingPlanModel> defaultPlans = [
    PricingPlanModel(
      id: 'plan-starter',
      slug: 'starter',
      name: 'Starter',
      tagline:
          'For solo creators & growing brands getting started with automation.',
      monthlyPrice: 29,
      yearlyPrice: 288,
      currency: 'USD',
      whatsappIncluded: true,
      instagramIncluded: true,
      aiAutomationIncluded: true,
      maxConnectedAccounts: 2,
      maxTeamMembers: 1,
      monthlyMessages: 2500,
      ctaText: 'Get Started',
      features: [
        '1 WhatsApp & 1 Instagram account',
        '2,500 automated conversations/mo',
        'WhatsApp Web QR multi-device link',
        'Meta Cloud Instagram auto-replies',
        'Keyword triggers for DMs & comments',
        'Automated lead capture & CRM tags',
        'Standard email support',
      ],
      isPopular: false,
    ),
    PricingPlanModel(
      id: 'plan-growth',
      slug: 'growth',
      name: 'Growth',
      tagline:
          'For high-growth businesses scaling customer conversations & sales.',
      monthlyPrice: 79,
      yearlyPrice: 768,
      currency: 'USD',
      whatsappIncluded: true,
      instagramIncluded: true,
      aiAutomationIncluded: true,
      maxConnectedAccounts: 5,
      maxTeamMembers: 3,
      monthlyMessages: 15000,
      ctaText: 'Choose Plan',
      features: [
        'Up to 5 connected accounts across channels',
        '15,000 automated conversations/mo',
        'Official Anti-Ban browser emulation',
        'AI conversational auto-chat & FAQ handling',
        'Story mentions, replies & interactive menu buttons',
        'Live unified multi-channel inbox & agent handover',
        'Advanced conversion analytics & priority support',
      ],
      isPopular: true,
    ),
    PricingPlanModel(
      id: 'plan-pro',
      slug: 'pro',
      name: 'Pro',
      tagline:
          'For established enterprises & agencies demanding high volume and custom AI.',
      monthlyPrice: 199,
      yearlyPrice: 1908,
      currency: 'USD',
      whatsappIncluded: true,
      instagramIncluded: true,
      aiAutomationIncluded: true,
      maxConnectedAccounts: 15,
      maxTeamMembers: 10,
      monthlyMessages: 50000,
      ctaText: 'Get Started',
      features: [
        'Up to 15 connected accounts across channels',
        '50,000 automated conversations/mo',
        'Custom AI fine-tuning & brand voice configuration',
        'Multi-agent team workspace with role permissions',
        'Webhooks, REST APIs & custom workflow integrations',
        'Dedicated account manager & 99.9% uptime SLA',
      ],
      isPopular: false,
    ),
  ];
}

