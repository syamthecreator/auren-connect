import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/app_snackbar.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

import '../../controller/channel_controller.dart';

enum WizardStep { checklist, authorize, success }

class ManyChatInstagramWizardDialog extends StatefulWidget {
  const ManyChatInstagramWizardDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ManyChatInstagramWizardDialog(),
    );
  }

  @override
  State<ManyChatInstagramWizardDialog> createState() =>
      _ManyChatInstagramWizardDialogState();
}

class _ManyChatInstagramWizardDialogState
    extends State<ManyChatInstagramWizardDialog> {
  WizardStep _step = WizardStep.checklist;
  dynamic _authPopup;
  String? _authUrl;
  bool _isLoading = false;
  Timer? _pollingTimer;
  int _pollCount = 0;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _authPopup?.close();
    super.dispose();
  }

  Future<void> _startOAuth() async {
    // Open the popup immediately from the user's click.
    // This helps avoid browser popup blockers.
    _authPopup = html.window.open(
      'about:blank',
      'auren_instagram_auth',
      'width=600,height=750,left=200,top=100,resizable=yes,scrollbars=yes',
    );

    if (_authPopup == null) {
      AppSnackBar.error(
        context,
        'Popup blocked. Please allow popups for Auren Connect.',
      );
      return;
    }

    setState(() => _isLoading = true);

    final controller = context.read<ChannelController>();
    final url = await controller.getInstagramAuthorizationUrl();

    if (!mounted) {
      _authPopup?.close();
      return;
    }

    setState(() => _isLoading = false);

    if (url == null || url.isEmpty) {
      _authPopup?.close();

      AppSnackBar.error(
        context,
        controller.errorMessage ??
            'Failed to generate Meta authorization link.',
      );
      return;
    }

    setState(() {
      _authUrl = url;
      _step = WizardStep.authorize;
    });

    // Navigate the already-opened popup to Meta.
    _authPopup?.location.href = url;

    // Check backend until authorization is completed.
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollCount = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      _pollCount++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      final controller = context.read<ChannelController>();
      await controller.loadChannels();

      if (!mounted) return;

      if (controller.isInstagramConnected) {
        timer.cancel();
        _authPopup?.close();

        setState(() => _step = WizardStep.success);
      } else if (_pollCount >= 60) {
        // Stop polling after 3 minutes of inactivity
        timer.cancel();
      }
    });
  }

  void _copyAuthUrl() {
    if (_authUrl == null) return;
    Clipboard.setData(ClipboardData(text: _authUrl!));
    AppSnackBar.info(context, 'Meta Authorization URL copied to clipboard');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 520,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (_step) {
            WizardStep.checklist => _buildChecklistStep(),
            WizardStep.authorize => _buildAuthorizeStep(),
            WizardStep.success => _buildSuccessStep(),
          },
        ),
      ),
    );
  }

  Widget _buildChecklistStep() {
    return Column(
      key: const ValueKey('checklist'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StudioIconBox(
              RemixIcons.instagram_line,
              AppColors.igColor,
              size: 42,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connect Instagram Account',
                    style: AppTextStyles.t(18, w: FontWeight.w700),
                  ),
                  Text(
                    'Step 1 of 3: ManyChat Pre-Connection Checklist',
                    style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(RemixIcons.close_line, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          'Before authorizing, ensure your Instagram meets Meta\'s 3 requirements to guarantee seamless message and comment automation:',
          style: AppTextStyles.t(13, c: AppColors.textSecondary, h: 1.45),
        ),
        const SizedBox(height: 16),
        _buildChecklistItem(
          icon: RemixIcons.user_star_line,
          title: '1. Professional Account (Creator or Business)',
          description: 'Personal accounts do not support Meta Graph API messaging. Switch for free inside Instagram App > Settings > Account.',
        ),
        const SizedBox(height: 10),
        _buildChecklistItem(
          icon: RemixIcons.pages_line,
          title: '2. Facebook Page Linked',
          description: 'Meta routes Instagram APIs via an associated Facebook Page. Ensure your Instagram account is linked to a Page in Meta Accounts Center.',
        ),
        const SizedBox(height: 10),
        _buildChecklistItem(
          icon: RemixIcons.message_3_line,
          title: '3. "Allow Access to Messages" Enabled',
          description: 'Inside Instagram App > Settings > Messages > Connected Tools > toggle "Allow access to messages" to ON.',
          isWarning: true,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GhostButton(
              label: 'Cancel',
              onTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 10),
            GradientButton(
              label: _isLoading ? 'Generating Link...' : 'Continue to Meta',
              icon: RemixIcons.arrow_right_line,
              onTap: _isLoading ? null : _startOAuth,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistItem({
    required IconData icon,
    required String title,
    required String description,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isWarning
              ? AppColors.warning.withValues(alpha: .3)
              : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: isWarning ? AppColors.warning : AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.t(13, w: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: AppTextStyles.t(
                    11.5,
                    c: AppColors.textSecondary,
                    h: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorizeStep() {
    return Column(
      key: const ValueKey('authorize'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const StudioIconBox(
              RemixIcons.shield_check_line,
              AppColors.primary,
              size: 42,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Authorize on Meta',
                    style: AppTextStyles.t(18, w: FontWeight.w700),
                  ),
                  Text(
                    'Step 2 of 3: Complete authorization in Meta dialog',
                    style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(RemixIcons.close_line, size: 20),
              onPressed: () {
                _pollingTimer?.cancel();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Open the official Meta Authorization dialog to grant permissions to aurenConnect. Once approved, this window will detect it automatically.',
          style: AppTextStyles.t(13, c: AppColors.textSecondary, h: 1.45),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meta OAuth URL',
                    style: AppTextStyles.t(
                      12,
                      w: FontWeight.w600,
                      c: AppColors.textMuted,
                    ),
                  ),
                  InkWell(
                    onTap: _copyAuthUrl,
                    child: Row(
                      children: [
                        const Icon(
                          RemixIcons.file_copy_line,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Copy Link',
                          style: AppTextStyles.t(
                            12,
                            c: AppColors.primary,
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SelectableText(
                _authUrl ?? '',
                maxLines: 2,
                style: AppTextStyles.t(11.5, c: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withValues(alpha: .3)),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Waiting for authorization callback from Meta...',
                  style: AppTextStyles.t(12.5, c: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GhostButton(
              label: 'Copy Auth Link',
              icon: RemixIcons.file_copy_line,
              onTap: _copyAuthUrl,
            ),
            GradientButton(
              label: 'Check Status Now',
              icon: RemixIcons.refresh_line,
              onTap: () async {
                final controller = context.read<ChannelController>();
                await controller.loadChannels();
                if (controller.isInstagramConnected && mounted) {
                  setState(() => _step = WizardStep.success);
                } else if (mounted) {
                  AppSnackBar.info(
                    context,
                    'Waiting for authorization to complete on Meta...',
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    final controller = context.watch<ChannelController>();
    final account = controller.primaryInstagramAccount;

    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.success.withValues(alpha: .15),
            border: Border.all(color: AppColors.success, width: 2),
          ),
          child: const Icon(
            RemixIcons.checkbox_circle_fill,
            color: AppColors.success,
            size: 34,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Instagram Connected Successfully!',
          style: AppTextStyles.t(19, w: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Your Instagram account is now linked to aurenConnect. Real-time DMs and comment webhooks are active.',
          style: AppTextStyles.t(12.5, c: AppColors.textSecondary, h: 1.45),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        if (account != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const StudioIconBox(
                  RemixIcons.instagram_line,
                  AppColors.igColor,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        account.displayHandle,
                        style: AppTextStyles.t(14.5, w: FontWeight.w700),
                      ),
                      Text(
                        'ID: ${account.instagramUserId}',
                        style: AppTextStyles.t(12, c: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                const StudioPill('Listening', color: AppColors.success),
              ],
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: GradientButton(
            label: 'Done & Return to Channels',
            icon: RemixIcons.check_line,
            onTap: () {
              Navigator.of(context).pop();
              AppSnackBar.success(context, 'Instagram channel ready!');
            },
          ),
        ),
      ],
    );
  }
}
