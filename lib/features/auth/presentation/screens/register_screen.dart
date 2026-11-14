import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../controllers/auth_controller.dart';
import '../../../pricing/controller/pricing_controller.dart';
import '../../../pricing/data/models/pricing_plan_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.planSlug});

  final String? planSlug;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.planSlug != null) {
        context.read<PricingController>().selectPlanBySlug(widget.planSlug!);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  String _passwordStrengthLabel(double strength) {
    if (strength <= 0.0) return 'Too short';
    if (strength < 0.5) return 'Weak';
    if (strength < 0.8) return 'Good';
    return 'Strong';
  }

  Color _passwordStrengthColor(double strength) {
    if (strength < 0.5) return AppColors.error;
    if (strength < 0.8) return AppColors.warning;
    return AppColors.success;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('Please accept the Terms of Service & Privacy Policy.'),
        ),
      );
      return;
    }

    final auth = context.read<AuthController>();
    final success = await auth.signUp(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      // Continue directly to Workspace creation flow
      Navigator.of(context).pushReplacementNamed(AppRouter.workspaceOnboarding);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error,
          content: Text(auth.errorMessage!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final pricing = context.watch<PricingController>();
    final selectedPlan = pricing.selectedPlan ?? PricingPlanModel.defaultPlans[1];
    final auth = context.watch<AuthController>();

    final passwordStrength = _calculatePasswordStrength(_passwordCtrl.text);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 36,
            vertical: 40,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Brand Logo
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed(AppRouter.landing),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: AppColors.neonLaserGradient,
                        ),
                        padding: const EdgeInsets.all(7),
                        child: Image.asset(
                          AssetConstants.aLogo,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            RemixIcons.apps_2_fill,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'auren',
                              style: AppTextStyles.t(22, w: FontWeight.w700, c: AppColors.textPrimary),
                            ),
                            TextSpan(
                              text: 'Connect',
                              style: AppTextStyles.t(22, w: FontWeight.w700, c: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Selected Plan Preview Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(RemixIcons.sparkling_line, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Plan: ${selectedPlan.name}',
                              style: AppTextStyles.t(13, w: FontWeight.w700, c: AppColors.textPrimary),
                            ),
                            Text(
                              pricing.isYearly
                                  ? '\$${selectedPlan.yearlyMonthlyEquivalent}/mo billed annually'
                                  : '\$${selectedPlan.monthlyPrice}/mo billed monthly',
                              style: AppTextStyles.t(11, w: FontWeight.w400, c: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRouter.pricing),
                        child: Text(
                          'Change',
                          style: AppTextStyles.t(12, w: FontWeight.w600, c: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Card Container
                Container(
                  padding: EdgeInsets.all(isMobile ? 24 : 36),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create your account',
                          style: AppTextStyles.t(24, w: FontWeight.w700, c: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start setting up your automated messaging workspace in seconds.',
                          style: AppTextStyles.t(13, w: FontWeight.w400, c: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 28),

                        // Full Name
                        Text(
                          'FULL NAME',
                          style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameCtrl,
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Jane Doe',
                            prefixIcon: const Icon(RemixIcons.user_3_line, size: 18, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().length < 2) {
                              return 'Please enter your full name (at least 2 characters)';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Email Address
                        Text(
                          'WORK EMAIL',
                          style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'jane@company.com',
                            prefixIcon: const Icon(RemixIcons.mail_line, size: 18, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || !val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid work email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Password
                        Text(
                          'PASSWORD',
                          style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'At least 8 characters',
                            prefixIcon: const Icon(RemixIcons.lock_2_line, size: 18, color: AppColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val == null || val.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),

                        // Password Strength Indicator
                        if (_passwordCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: passwordStrength,
                                    backgroundColor: AppColors.border,
                                    valueColor: AlwaysStoppedAnimation(
                                      _passwordStrengthColor(passwordStrength),
                                    ),
                                    minHeight: 4,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _passwordStrengthLabel(passwordStrength),
                                style: AppTextStyles.t(
                                  11,
                                  w: FontWeight.w600,
                                  c: _passwordStrengthColor(passwordStrength),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 18),

                        // Confirm Password
                        Text(
                          'CONFIRM PASSWORD',
                          style: AppTextStyles.t(11, w: FontWeight.w700, c: AppColors.textSecondary, ls: 0.8),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirmPassword,
                          cursorColor: AppColors.primary,
                          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Re-enter your password',
                            prefixIcon: const Icon(RemixIcons.lock_password_line, size: 18, color: AppColors.textMuted),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                          ),
                          validator: (val) {
                            if (val != _passwordCtrl.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Terms Checkbox
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                              activeColor: AppColors.primary,
                              checkColor: AppColors.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            Expanded(
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy',
                                style: AppTextStyles.t(12, w: FontWeight.w400, c: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: auth.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                  ),
                                )
                              : GradientButton(
                                  label: 'Create Account & Continue',
                                  icon: RemixIcons.arrow_right_line,
                                  onTap: _handleRegister,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Already have an account link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      style: AppTextStyles.t(14, w: FontWeight.w400, c: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => Navigator.of(context).pushNamed(AppRouter.login),
                      child: Text(
                        'Log in',
                        style: AppTextStyles.t(14, w: FontWeight.w700, c: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
