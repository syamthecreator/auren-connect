import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_text_styles.dart';

class OnboardingStepper extends StatelessWidget {
  const OnboardingStepper({
    super.key,
    required this.currentStep,
  });

  /// 1 = Workspace, 2 = Checkout, 3 = Complete
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Row(
          children: [
            _buildStepItem(
              stepNumber: 1,
              title: 'Workspace',
              subtitle: 'Business profile',
              isActive: currentStep == 1,
              isCompleted: currentStep > 1,
              isMobile: isMobile,
            ),
            _buildConnector(isCompleted: currentStep > 1),
            _buildStepItem(
              stepNumber: 2,
              title: 'Subscription',
              subtitle: 'Plan & checkout',
              isActive: currentStep == 2,
              isCompleted: currentStep > 2,
              isMobile: isMobile,
            ),
            _buildConnector(isCompleted: currentStep > 2),
            _buildStepItem(
              stepNumber: 3,
              title: 'Ready',
              subtitle: 'Start automating',
              isActive: currentStep == 3,
              isCompleted: currentStep >= 3,
              isMobile: isMobile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    required bool isMobile,
  }) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.primary
                  : isActive
                      ? AppColors.surfaceVariant
                      : AppColors.surface,
              border: Border.all(
                color: isCompleted || isActive
                    ? AppColors.primary
                    : AppColors.border,
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(
                      RemixIcons.check_line,
                      size: 16,
                      color: AppColors.onPrimary,
                    )
                  : Text(
                      '$stepNumber',
                      style: AppTextStyles.t(
                        13,
                        w: FontWeight.w700,
                        c: isActive ? AppColors.primary : AppColors.textMuted,
                      ),
                    ),
            ),
          ),
          if (!isMobile) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.t(
                      13,
                      w: isActive || isCompleted
                          ? FontWeight.w600
                          : FontWeight.w500,
                      c: isActive || isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.t(
                      10,
                      w: FontWeight.w400,
                      c: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnector({required bool isCompleted}) {
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isCompleted ? AppColors.primary : AppColors.border,
    );
  }
}

