import 'dart:async';

import 'package:auren_connect/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/constants/asset_constants.dart';
import '../../../../core/utils/shell_scope.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _pulseScale;

  late final SplashController _splashController;

  @override
  void initState() {
    super.initState();

    _splashController = context.read<SplashController>();

    // Entry animation.
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );

    _logoScale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );

    // Continuous ambient pulse.
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    // Progress animation.
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Status updates are managed by SplashController.
    _progressController.addListener(() {
      _splashController.updateProgress(_progressController.value);
    });

    _startFlow();
  }

  /// Starts splash and authentication flow.
  Future<void> _startFlow() async {
    // Handle OAuth popup.
    if (_splashController.handleOAuthPopup()) return;

    final isOAuthReturn = _splashController.isOAuthReturn;

    // Start animations.
    _entryController.forward();
    _progressController.forward();

    // Validate authentication.
    final destination = await _splashController.startFlow(
      isOAuthReturn: isOAuthReturn,
    );

    if (!mounted) return;

    switch (destination) {
      case SplashDestination.popupClosed:
        return;

      case SplashDestination.channel:
        Navigator.of(context).pushReplacementNamed(
          AppRouter.dashboard,
          arguments: NavDestination.channel,
        );
        break;

      case SplashDestination.dashboard:
        Navigator.of(context).pushReplacementNamed(
          AppRouter.dashboard,
          arguments: isOAuthReturn ? NavDestination.channel : null,
        );
        break;

      case SplashDestination.auth:
        Navigator.of(context).pushReplacementNamed(AppRouter.auth);
        break;
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    _progressController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Grid Background
          const CustomPaint(painter: _SplashGridPainter()),

          // 2. Ambient Dual Radial Glow
          Positioned(
            top: -120,
            left: -80,
            child: IgnorePointer(
              child: Container(
                width: 480,
                height: 480,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.paletteNeonCyan.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -140,
            right: -100,
            child: IgnorePointer(
              child: Container(
                width: 520,
                height: 520,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0066FF).withValues(alpha: 0.10),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Centerpiece: Logo + Badges + Loading
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing Aura behind Logo
                ScaleTransition(
                  scale: _pulseScale,
                  child: Container(
                    width: 240,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.paletteNeonCyan.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 70,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Animated Logo
                FadeTransition(
                  opacity: _logoFade,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          AssetConstants.aurenLogo,
                          fit: BoxFit.contain,
                          width: 260,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              'auren',
                              style: AppTextStyles.t(
                                38,
                                w: FontWeight.w800,
                                c: AppColors.textPrimary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.paletteNeonCyan.withValues(
                              alpha: 0.12,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.paletteNeonCyan.withValues(
                                alpha: 0.4,
                              ),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.paletteNeonCyan.withValues(
                                  alpha: 0.15,
                                ),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: const Text(
                            'MESSAGING AUTOMATION',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.2,
                              color: AppColors.paletteNeonCyan,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Progress Bar & Status
                FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sleek Neon Progress Bar
                      Container(
                        width: 220,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: _progressController.value.clamp(
                                  0.02,
                                  1.0,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppColors.neonLaserGradient,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.paletteNeonCyan
                                            .withValues(alpha: 0.6),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      Selector<SplashController, String>(
                        selector: (_, controller) => controller.statusText,
                        builder: (context, statusText, child) {
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              statusText,
                              key: ValueKey(statusText),
                              style: AppTextStyles.t(
                                12.5,
                                c: AppColors.textSecondary,
                                w: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. Subtle footer watermark
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'AUREN STUDIO · META CLOUD ENGINE',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashGridPainter extends CustomPainter {
  const _SplashGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider.withValues(alpha: 0.45)
      ..strokeWidth = 1;

    const step = 32.0;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
