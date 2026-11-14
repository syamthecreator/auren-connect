import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/onboarding_stepper.dart';
import '../../../workspace/controller/workspace_controller.dart';
import '../../../pricing/controller/pricing_controller.dart';

class WorkspaceCreationScreen extends StatefulWidget {
  const WorkspaceCreationScreen({super.key});

  @override
  State<WorkspaceCreationScreen> createState() => _WorkspaceCreationScreenState();
}

class _WorkspaceCreationScreenState extends State<WorkspaceCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wsNameCtrl = TextEditingController(text: 'My Growth Fleet');
  final _businessNameCtrl = TextEditingController(text: 'Acme Media');
  final _slugCtrl = TextEditingController(text: 'acme-media');

  String _selectedCategory = 'E-Commerce & Retail';
  String _selectedTimezone = 'UTC (Universal Coordinated Time)';
  String _selectedCountry = 'United States';

  final List<String> _categories = const [
    'E-Commerce & Retail',
    'Creator & Personal Brand',
    'Marketing Agency',
    'SaaS & Software',
    'Education & Coaching',
    'Real Estate & Finance',
    'Healthcare & Wellness',
    'Other Business',
  ];

  final List<String> _timezones = const [
    'UTC (Universal Coordinated Time)',
    'EST (UTC-5) New York, Toronto',
    'CST (UTC-6) Chicago, Mexico City',
    'PST (UTC-8) Los Angeles, Vancouver',
    'GMT (UTC+0) London, Dublin',
    'CET (UTC+1) Paris, Berlin, Rome',
    'IST (UTC+5:30) Mumbai, New Delhi',
    'SGT (UTC+8) Singapore, Hong Kong',
    'JST (UTC+9) Tokyo, Seoul',
    'AEST (UTC+10) Sydney, Melbourne',
  ];

  final List<String> _countries = const [
    'United States',
    'United Kingdom',
    'India',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Singapore',
    'United Arab Emirates',
    'Brazil',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _wsNameCtrl.addListener(_autoGenerateSlug);
  }

  void _autoGenerateSlug() {
    final raw = _wsNameCtrl.text.toLowerCase().trim();
    final slug = raw.replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');
    if (_slugCtrl.text != slug && slug.isNotEmpty) {
      _slugCtrl.text = slug;
    }
  }

  @override
  void dispose() {
    _wsNameCtrl.removeListener(_autoGenerateSlug);
    _wsNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _slugCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleCreateWorkspace() async {
    if (!_formKey.currentState!.validate()) return;

    final wsController = context.read<WorkspaceController>();
    final workspace = await wsController.createWorkspace(
      name: _wsNameCtrl.text.trim(),
      businessName: _businessNameCtrl.text.trim(),
      businessCategory: _selectedCategory,
      slug: _slugCtrl.text.trim(),
      timezone: _selectedTimezone,
      country: _selectedCountry,
    );

    if (!mounted) return;

    if (workspace != null) {
      // Proceed to Step 2: Subscription & Checkout
      Navigator.of(context).pushReplacementNamed(AppRouter.checkout);
    } else if (wsController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(wsController.errorMessage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 680;
    final wsController = context.watch<WorkspaceController>();
    final pricing = context.watch<PricingController>();
    final selectedPlan = pricing.selectedPlan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 18 : 36,
            vertical: 36,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          gradient: AppColors.neonLaserGradient,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Image.asset(
                          AssetConstants.aLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            RemixIcons.apps_2_fill,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'auren',
                              style: AppTextStyles.t(20, w: FontWeight.w700, c: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: 'Connect',
                              style: AppTextStyles.t(20, w: FontWeight.w700, c: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Stepper (Step 1 of 3)
                  const OnboardingStepper(currentStep: 1),

                  const SizedBox(height: 32),

                  // Main Container Card
                  Container(
                    padding: EdgeInsets.all(isMobile ? 22 : 36),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  RemixIcons.building_4_line,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Create your Workspace',
                                      style: AppTextStyles.t(20, w: FontWeight.w700, c: AppColors.textPrimary),
                                    ),
                                    Text(
                                      'A dedicated multi-tenant container for your team and automations.',
                                      style: AppTextStyles.t(12, c: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Divider(color: AppColors.divider),
                          const SizedBox(height: 20),

                          // Workspace Name
                          Text(
                            'WORKSPACE NAME',
                            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _wsNameCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g. Acme Growth Fleet',
                              prefixIcon: const Icon(RemixIcons.community_line, size: 18, color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a workspace name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Business Legal / Trading Name
                          Text(
                            'BUSINESS NAME',
                            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _businessNameCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'e.g. Acme Media Corp',
                              prefixIcon: const Icon(RemixIcons.store_2_line, size: 18, color: AppColors.textMuted),
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your business or brand name';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Workspace Slug URL
                          Text(
                            'WORKSPACE URL / SLUG',
                            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _slugCtrl,
                            cursorColor: AppColors.primary,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              prefixText: 'aurenconnect.app/',
                              prefixStyle: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                              hintText: 'acme-media',
                              filled: true,
                              fillColor: AppColors.surfaceVariant,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter a URL slug';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 18),

                          // Business Category Dropdown
                          Text(
                            'BUSINESS CATEGORY',
                            style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                icon: const Icon(RemixIcons.arrow_down_s_line, size: 18, color: AppColors.textSecondary),
                                dropdownColor: AppColors.surfaceVariant,
                                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                                items: _categories.map((c) {
                                  return DropdownMenuItem(value: c, child: Text(c));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedCategory = val);
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          // Time Zone & Country
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PRIMARY TIMEZONE',
                                      style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedTimezone,
                                          isExpanded: true,
                                          icon: const Icon(RemixIcons.arrow_down_s_line, size: 16, color: AppColors.textSecondary),
                                          dropdownColor: AppColors.surfaceVariant,
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                          items: _timezones.map((tz) {
                                            return DropdownMenuItem(
                                              value: tz,
                                              child: Text(tz, maxLines: 1, overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _selectedTimezone = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COUNTRY',
                                      style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.border),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          value: _selectedCountry,
                                          isExpanded: true,
                                          icon: const Icon(RemixIcons.arrow_down_s_line, size: 16, color: AppColors.textSecondary),
                                          dropdownColor: AppColors.surfaceVariant,
                                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                                          items: _countries.map((c) {
                                            return DropdownMenuItem(
                                              value: c,
                                              child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _selectedCountry = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Selected Plan Badge
                          if (selectedPlan != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(RemixIcons.shield_check_line, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Plan to link: ${selectedPlan.name} (${selectedPlan.maxConnectedAccounts} accounts, ${selectedPlan.monthlyMessages} msgs/mo)',
                                      style: AppTextStyles.t(12, w: FontWeight.w500, c: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: wsController.isCreating
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                    ),
                                  )
                                : GradientButton(
                                    label: 'Create Workspace & Proceed to Checkout',
                                    icon: RemixIcons.arrow_right_line,
                                    onTap: _handleCreateWorkspace,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
