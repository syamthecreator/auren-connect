import 'package:auren_connect/app/routes/app_router.dart';
import 'package:auren_connect/core/network/auth_token_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../../core/constants/asset_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../models/auth_model.dart';
import '../../controllers/auth_controller.dart';
import '../widgets/auth_widget.dart';

/// Senior-designed, complete authentication screen for aurenConnect.
/// Pre-filled with default credentials for instant one-tap sign-in,
/// managed end-to-end with Provider state management.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Pre-filled with requested default credentials for immediate one-tap login
  final _usernameCtrl = TextEditingController(
    text: "aurenthecreator@gmail.com",
  );
  final _passwordCtrl = TextEditingController(text: "auren123");

  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _hidePassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _goTo(AuthStep step) {
    context.read<AuthController>().setStep(step);
  }

  Future<void> _signIn() async {
    final auth = context.read<AuthController>();

    final ok = await auth.signIn(_usernameCtrl.text.trim(), _passwordCtrl.text);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          content: Text(
            auth.errorMessage!,
            style: const TextStyle(color: AppColors.onError),
          ),
        ),
      );
    }
  }

  Future<void> _requestOtp() async {
    final auth = context.read<AuthController>();
    final ok = await auth.requestOtp(_usernameCtrl.text.trim());

    if (!mounted) return;
    if (!ok && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          content: Text(
            auth.errorMessage!,
            style: const TextStyle(color: AppColors.onError),
          ),
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final auth = context.read<AuthController>();
    final ok = await auth.verifyOtp(_otpCtrl.text.trim());

    if (!mounted) return;
    if (!ok && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          content: Text(
            auth.errorMessage!,
            style: const TextStyle(color: AppColors.onError),
          ),
        ),
      );
    }
  }

  Future<void> _resetPassword() async {
    final auth = context.read<AuthController>();
    final ok = await auth.resetPassword(
      _newPasswordCtrl.text,
      _confirmPasswordCtrl.text,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.surfaceVariant,
          content: Text(
            auth.successMessage ?? 'Password reset successfully!',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
          content: Text(
            auth.errorMessage!,
            style: const TextStyle(color: AppColors.onError),
          ),
        ),
      );
    }
  }

  Widget _eyeButton(bool hidden, VoidCallback onTap) => IconButton(
    onPressed: onTap,
    splashRadius: 18,
    icon: Icon(
      hidden ? RemixIcons.eye_line : RemixIcons.eye_off_line,
      size: 20,
      color: AppColors.textSecondary,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    height: isWide ? 590 : null,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 60,
                          offset: const Offset(0, 24),
                        ),
                        BoxShadow(
                          color: AppColors.paletteNeonCyan.withValues(
                            alpha: 0.06,
                          ),
                          blurRadius: 40,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isWide
                        ? Row(
                            children: [
                              const Expanded(child: _LogoPanel()),
                              Expanded(child: _formPanel()),
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 200, child: _LogoPanel()),
                              _formPanel(),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _formPanel() {
    final auth = context.watch<AuthController>();

    // If authenticated, display loading while entering workspace
    if (auth.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
        }
      });
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final step = auth.step;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOut,
          child: KeyedSubtree(
            key: ValueKey(step),
            child: switch (step) {
              AuthStep.signIn => _signInContent(),
              AuthStep.forgot => _forgotContent(),
              AuthStep.otp => _otpContent(),
              AuthStep.newPassword => _newPasswordContent(),
            },
          ),
        ),
      ),
    );
  }

  Widget _signInContent() {
    final auth = context.watch<AuthController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.shield_line,
          title: 'Welcome Back',
          subtitle: 'Sign in to access your aurenConnect workspace.',
        ),
        const SizedBox(height: 32),
        const AuthFieldLabel('Work Email / Mobile Number'),
        AuthTextField(
          controller: _usernameCtrl,
          prefixIcon: RemixIcons.mail_line,
          hint: 'name@company.com or phone',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        const AuthFieldLabel('Password'),
        AuthTextField(
          controller: _passwordCtrl,
          prefixIcon: RemixIcons.lock_line,
          hint: 'Enter your password',
          obscureText: _hidePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _signIn(),
          suffix: _eyeButton(
            _hidePassword,
            () => setState(() => _hidePassword = !_hidePassword),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: AuthTextLink(
            label: 'Forgot Password?',
            onTap: () => _goTo(AuthStep.forgot),
          ),
        ),
        const SizedBox(height: 16),
        AuthButton(
          label: 'Sign In to Workspace',
          icon: RemixIcons.login_box_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Signing in...',
          onPressed: _signIn,
        ),
      ],
    );
  }

  Widget _forgotContent() {
    final auth = context.watch<AuthController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.key_line,
          title: 'Forgot Password',
          subtitle: 'Enter your registered email or phone to receive a verification code.',
        ),
        const SizedBox(height: 32),
        const AuthFieldLabel('Registered Email / Phone'),
        AuthTextField(
          controller: _usernameCtrl,
          prefixIcon: RemixIcons.mail_line,
          hint: 'Enter your email or phone',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _requestOtp(),
        ),
        const SizedBox(height: 20),
        AuthButton(
          label: 'Send Verification Code',
          icon: RemixIcons.mail_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Sending code...',
          onPressed: _requestOtp,
        ),
        const SizedBox(height: 14),
        Center(
          child: AuthTextLink(
            icon: RemixIcons.arrow_left_line,
            label: 'Back to Sign In',
            onTap: () => _goTo(AuthStep.signIn),
          ),
        ),
      ],
    );
  }

  Widget _otpContent() {
    final auth = context.watch<AuthController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.smartphone_line,
          title: 'Verification Code',
          subtitle: 'Enter the 4-digit code sent to your email or phone.',
        ),
        const SizedBox(height: 32),
        const AuthFieldLabel('4-Digit Code'),
        AuthTextField(
          controller: _otpCtrl,
          prefixIcon: RemixIcons.shield_line,
          hint: '••••',
          maxLength: 4,
          letterSpacing: 8,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _verifyOtp(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              auth.canResend
                  ? 'Didn\'t receive code?'
                  : 'Resend in ${auth.timeText}',
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            if (auth.canResend)
              AuthTextLink(label: 'Resend OTP', onTap: auth.resendOtp),
          ],
        ),
        const SizedBox(height: 18),
        AuthButton(
          label: 'Verify & Proceed',
          icon: RemixIcons.check_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Verifying...',
          onPressed: _verifyOtp,
        ),
        const SizedBox(height: 14),
        Center(
          child: AuthTextLink(
            icon: RemixIcons.arrow_left_line,
            label: 'Back to Sign In',
            onTap: () => _goTo(AuthStep.signIn),
          ),
        ),
      ],
    );
  }

  Widget _newPasswordContent() {
    final auth = context.watch<AuthController>();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthHeader(
          icon: RemixIcons.lock_line,
          title: 'New Password',
          subtitle: 'Create a secure new password for your account.',
        ),
        const SizedBox(height: 28),
        const AuthFieldLabel('New Password'),
        AuthTextField(
          controller: _newPasswordCtrl,
          prefixIcon: RemixIcons.lock_line,
          hint: 'Minimum 6 characters',
          obscureText: _hideNewPassword,
          textInputAction: TextInputAction.next,
          suffix: _eyeButton(
            _hideNewPassword,
            () => setState(() => _hideNewPassword = !_hideNewPassword),
          ),
        ),
        const SizedBox(height: 14),
        const AuthFieldLabel('Confirm Password'),
        AuthTextField(
          controller: _confirmPasswordCtrl,
          prefixIcon: RemixIcons.lock_line,
          hint: 'Re-enter your password',
          obscureText: _hideConfirmPassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resetPassword(),
          suffix: _eyeButton(
            _hideConfirmPassword,
            () => setState(() => _hideConfirmPassword = !_hideConfirmPassword),
          ),
        ),
        const SizedBox(height: 20),
        AuthButton(
          label: 'Update Password',
          icon: RemixIcons.check_line,
          iconAfter: true,
          gradient: AppColors.darkGradient,
          loading: auth.isLoading,
          loadingLabel: 'Updating...',
          onPressed: _resetPassword,
        ),
        const SizedBox(height: 14),
        Center(
          child: AuthTextLink(
            icon: RemixIcons.arrow_left_line,
            label: 'Cancel',
            onTap: () => _goTo(AuthStep.signIn),
          ),
        ),
      ],
    );
  }
}

class _LogoPanel extends StatelessWidget {
  const _LogoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.hydroGlassGradient),
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Official auren brand logo
            Image.asset(
              AssetConstants.aurenLogo,
              fit: BoxFit.contain,
              width: 260,
              errorBuilder: (context, error, stackTrace) {
                return RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    children: [TextSpan(text: 'auren')],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.paletteNeonCyan.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.paletteNeonCyan.withValues(alpha: 0.35),
                  width: 1,
                ),
              ),
              child: const Text(
                'MESSAGING AUTOMATION',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                  color: AppColors.paletteNeonCyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
