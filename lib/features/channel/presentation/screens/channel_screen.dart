import 'dart:async';
import 'dart:convert';
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
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_page_heading.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

import '../../controller/channel_controller.dart';
import '../../data/models/instagram_channel_model.dart';
import '../../data/models/whatsapp_channel_model.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  // ── Meta connect flow state (moved here from ManyChatInstagramConnectView) ──
  Timer? _pollingTimer;
  StreamSubscription<html.MessageEvent>? _messageSub;
  dynamic _authPopup;
  bool _connectionHandled = false;

  @override
  void initState() {
    super.initState();

    _listenForMetaCallback();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ChannelController>().loadChannels();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageSub?.cancel();
    _authPopup?.close();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════════════
  //  META CONNECT LOGIC (unchanged behaviour)
  // ════════════════════════════════════════════════════════════════════════

  void _handleBack() {
    _pollingTimer?.cancel();

    try {
      _authPopup?.close();
    } catch (_) {}

    final controller = context.read<ChannelController>();
    controller.setAwaitingMeta(false);
    controller.closeInstagramConnectView();
  }

  void _listenForMetaCallback() {
    try {
      _messageSub = html.window.onMessage.listen((event) {
        final data = event.data;
        bool isConnected = false;
        try {
          if (data == 'AUREN_INSTAGRAM_CONNECTED') {
            isConnected = true;
          } else if (data is Map &&
              data['type'] == 'AUREN_INSTAGRAM_CONNECTED') {
            isConnected = true;
          } else if (data != null &&
              data.toString().contains('AUREN_INSTAGRAM_CONNECTED')) {
            isConnected = true;
          }
        } catch (_) {}

        if (isConnected) {
          _handleConnectionSuccess();
        }
      });
    } catch (_) {}
  }

  Future<void> _handleConnectionSuccess() async {
    if (_connectionHandled) return;
    _connectionHandled = true;

    _pollingTimer?.cancel();

    try {
      _authPopup?.close();
    } catch (_) {}

    final controller = context.read<ChannelController>();

    controller.setAwaitingMeta(false);

    await controller.loadChannels();

    if (!mounted) return;

    AppSnackBar.success(context, 'Instagram account connected successfully!');

    // Previously widget.onConnected() from the separate screen.
    controller.closeInstagramConnectView();
    controller.loadChannels();
  }

  Future<void> _connectViaMeta() async {
    _connectionHandled = false;

    // Open popup immediately to avoid browser popup blockers.
    try {
      _authPopup = html.window.open(
        'about:blank',
        'auren_meta_oauth',
        'width=650,height=820,left=250,top=80,resizable=yes,scrollbars=yes',
      );
    } catch (_) {}

    final controller = context.read<ChannelController>();

    controller.setAwaitingMeta(true);

    final url = await controller.getInstagramAuthorizationUrl();

    if (!mounted) {
      _authPopup?.close();
      return;
    }

    if (url == null || url.isEmpty) {
      _authPopup?.close();

      controller.setAwaitingMeta(false);

      AppSnackBar.error(
        context,
        controller.errorMessage ?? 'Failed to initialize Meta connection.',
      );

      return;
    }

    // Redirect popup to Meta authorization.
    try {
      _authPopup?.location.href = url;
    } catch (_) {
      html.window.open(url, '_blank');
    }

    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    int count = 0;
    final initialCount = context
        .read<ChannelController>()
        .instagramAccounts
        .length;

    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      count++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      final controller = context.read<ChannelController>();
      await controller.loadChannels();

      if (!mounted) return;

      final currentCount = controller.instagramAccounts.length;
      if ((initialCount == 0 && controller.isInstagramConnected) ||
          currentCount > initialCount) {
        timer.cancel();
        _handleConnectionSuccess();
      } else if (count >= 120) {
        // Stop polling after 4 minutes
        timer.cancel();
        context.read<ChannelController>().setAwaitingMeta(false);
      }
    });
  }

  // ════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final channelController = context.watch<ChannelController>();

    // Connect flow now lives INSIDE this screen (no separate view).
    if (channelController.showInstagramConnectView) {
      return _buildConnectView(channelController);
    }

    Future<void> syncChannels() async {
      final controller = context.read<ChannelController>();

      await controller.syncChannels();

      if (!mounted) return;

      if (controller.errorMessage != null) {
        // ignore: use_build_context_synchronously
        AppSnackBar.error(context, controller.errorMessage!);
      } else {
        AppSnackBar.success(
          // ignore: use_build_context_synchronously
          context,
          controller.successMessage ?? 'Channels synchronized successfully',
        );
      }
    }

    void copyToClipboard(String text, String label) {
      Clipboard.setData(ClipboardData(text: text));

      AppSnackBar.info(context, '$label copied to clipboard');
    }

    void showInstagramDisconnectDialog(String channelId, String handle) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              const StudioIconBox(
                RemixIcons.error_warning_line,
                AppColors.error,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Disconnect Channel',
                  style: AppTextStyles.t(18, w: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to unlink $handle? '
            'Automated message flows and triggers for this account will stop running.',
            style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.t(14, c: AppColors.textSecondary),
              ),
            ),
            GradientButton(
              label: 'Disconnect',
              icon: RemixIcons.shut_down_line,
              onTap: () async {
                Navigator.of(dialogContext).pop();

                final success = await context
                    .read<ChannelController>()
                    .disconnectInstagram(channelId);

                if (!mounted) return;

                if (success) {
                  // ignore: use_build_context_synchronously
                  AppSnackBar.success(context, 'Channel disconnected');
                } else {
                  AppSnackBar.error(
                    // ignore: use_build_context_synchronously
                    context,
                    // ignore: use_build_context_synchronously
                    context.read<ChannelController>().errorMessage ??
                        'Failed to disconnect channel',
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    void showWhatsAppDisconnectDialog(String channelId, String name) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Row(
            children: [
              const StudioIconBox(
                RemixIcons.error_warning_line,
                AppColors.error,
                size: 38,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Disconnect WhatsApp',
                  style: AppTextStyles.t(18, w: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to disconnect $name? '
            'This will gracefully unlink the session from your WhatsApp account.',
            style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: AppTextStyles.t(14, c: AppColors.textSecondary),
              ),
            ),
            GradientButton(
              label: 'Disconnect',
              icon: RemixIcons.shut_down_line,
              onTap: () async {
                Navigator.of(dialogContext).pop();

                final success = await context
                    .read<ChannelController>()
                    .disconnectWhatsApp(channelId);

                if (!mounted) return;

                if (success) {
                  // ignore: use_build_context_synchronously
                  AppSnackBar.success(context, 'WhatsApp channel disconnected');
                } else {
                  AppSnackBar.error(
                    // ignore: use_build_context_synchronously
                    context,
                    // ignore: use_build_context_synchronously
                    context.read<ChannelController>().errorMessage ??
                        'Failed to disconnect WhatsApp channel',
                  );
                }
              },
            ),
          ],
        ),
      );
    }

    void showWhatsAppConnectModal() {
      showDialog(
        context: context,
        builder: (dialogContext) => const WhatsAppConnectDialog(),
      );
    }

    void onConnectChannelPressed() {
      if (channelController.selectedFilter == 1) {
        channelController.openInstagramConnectView();
      } else if (channelController.selectedFilter == 2) {
        showWhatsAppConnectModal();
      } else {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                const StudioIconBox(
                  RemixIcons.links_line,
                  AppColors.primary,
                  size: 38,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select Channel to Connect',
                    style: AppTextStyles.t(18, w: FontWeight.w700),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const StudioIconBox(
                      RemixIcons.instagram_line,
                      AppColors.igColor,
                      size: 40,
                    ),
                    title: Text(
                      'Instagram Professional',
                      style: AppTextStyles.t(14, w: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'OAuth flow for DMs, reels, posts & story triggers',
                      style: AppTextStyles.t(12, c: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      RemixIcons.arrow_right_s_line,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      channelController.openInstagramConnectView();
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: const StudioIconBox(
                      RemixIcons.whatsapp_line,
                      AppColors.waColor,
                      size: 40,
                    ),
                    title: Text(
                      'WhatsApp (Linked Device)',
                      style: AppTextStyles.t(14, w: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Instant QR scan, zero fees & 10 anti-ban protections',
                      style: AppTextStyles.t(12, c: AppColors.textSecondary),
                    ),
                    trailing: const Icon(
                      RemixIcons.arrow_right_s_line,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onTap: () {
                      Navigator.of(dialogContext).pop();
                      showWhatsAppConnectModal();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    final accounts = channelController.instagramAccounts;
    final isIgConnected = accounts.isNotEmpty;
    final primaryAccount = channelController.primaryInstagramAccount;

    final whatsAppAccounts = channelController.whatsAppAccounts;
    final isWaConnected = channelController.isWhatsAppConnected;
    final primaryWaAccount = channelController.primaryWhatsAppAccount;

    final isSyncing = channelController.isSyncing;

    return StudioPage(
      children: [
        // 1. Top Action Bar
        StudioPageHeading(
          actions: [
            GhostButton(
              label: isSyncing ? 'Syncing...' : 'Sync Channels',
              icon: RemixIcons.refresh_line,
              onTap: isSyncing ? null : syncChannels,
            ),
            GradientButton(
              label: 'Connect Channel',
              icon: RemixIcons.add_line,
              onTap: onConnectChannelPressed,
            ),
          ],
        ),

        // 2. Real Channel Hero Overview Banner
        _ChannelHeroBanner(
          igConnected: isIgConnected,
          igHandle: primaryAccount?.displayHandle ?? 'Not connected',
          accountCount: accounts.length,
          waConnected: isWaConnected,
          waHandle: primaryWaAccount?.displayPhoneNumber ?? 'Not connected',
          waCount: whatsAppAccounts.length,
          isSyncing: isSyncing,
          onConnectTap: onConnectChannelPressed,
          onSyncTap: isSyncing ? null : syncChannels,
        ),

        // 3. Filter Chips
        StudioChips(
          options: [
            'All channels (${accounts.length + whatsAppAccounts.length})',
            'Instagram (${accounts.length})',
            'WhatsApp (${whatsAppAccounts.length})',
          ],
          selected: channelController.selectedFilter,
          onChanged: channelController.selectFilter,
        ),

        // 4. Main Connected Channel Cards (Real values only)
        if (channelController.isLoading && accounts.isEmpty && whatsAppAccounts.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else
          ResponsiveGrid(
            minItemWidth: 440,
            maxColumns: 2,
            spacing: 20,
            children: [
              // Instagram Accounts (Show each real connected account or empty state)
              if (channelController.selectedFilter == 0 ||
                  channelController.selectedFilter == 1) ...[
                if (accounts.isNotEmpty)
                  ...accounts.map(
                    (account) => _InstagramChannelCard(
                      account: account,
                      onDisconnect: () => showInstagramDisconnectDialog(
                        account.id,
                        account.displayHandle,
                      ),
                      onCopyId: (id) =>
                          copyToClipboard(id, 'Instagram User ID'),
                      onSync: isSyncing ? null : syncChannels,
                    ),
                  )
                else
                  _EmptyInstagramChannelCard(
                    onConnect: channelController.openInstagramConnectView,
                  ),
              ],

              // WhatsApp Accounts (Show each real connected account or empty state)
              if (channelController.selectedFilter == 0 ||
                  channelController.selectedFilter == 2) ...[
                if (whatsAppAccounts.isNotEmpty)
                  ...whatsAppAccounts.map(
                    (waChannel) => _WhatsAppChannelCard(
                      channel: waChannel,
                      onDisconnect: () => showWhatsAppDisconnectDialog(
                        waChannel.id,
                        waChannel.displayName,
                      ),
                      onCopyId: (id) => copyToClipboard(id, 'WhatsApp ID'),
                      onSync: isSyncing ? null : syncChannels,
                    ),
                  )
                else
                  _EmptyWhatsAppChannelCard(
                    onConnect: showWhatsAppConnectModal,
                  ),
              ],
            ],
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  //  INLINE CONNECT VIEW  (replaces ManyChatInstagramConnectView)
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildConnectView(ChannelController controller) {
    return StudioPage(
      children: [
        StudioPageHeading(
          actions: [
            GhostButton(
              label: 'Back to channels',
              icon: RemixIcons.arrow_left_line,
              onTap: _handleBack,
            ),
          ],
        ),
        StudioCard(
          hoverable: false,
          padding: const EdgeInsets.all(32),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.igColor.withValues(alpha: .10),
              const Color(0xFF0E1726),
              const Color(0xFF070C15),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final isDesktop = c.maxWidth >= 900;
              return isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: _buildLeftHero()),
                        const SizedBox(width: 56),
                        Flexible(child: _buildRightCard(controller)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLeftHero(),
                        const SizedBox(height: 32),
                        _buildRightCard(controller),
                      ],
                    );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeftHero() {
    const steps = [
      (
        'Authorize on Meta',
        'Sign in and approve access to your Instagram Professional account.',
      ),
      (
        'Set your permissions',
        'Allow messages, comments and story access for automation.',
      ),
      (
        'Start automating',
        'Build comment, DM and story flows in Automation Studio.',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            StudioPill(
              'Instagram',
              color: AppColors.igColor,
              icon: RemixIcons.instagram_line,
            ),
            StudioPill(
              'Meta Cloud Platform',
              color: AppColors.accent,
              icon: RemixIcons.cloud_line,
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildStarburstGraphic(),
        const SizedBox(height: 26),
        Text(
          'Connect Instagram',
          style: AppTextStyles.t(36, w: FontWeight.w800, h: 1.15, ls: -.8),
        ),
        const SizedBox(height: 12),
        Text(
          'Use your Instagram account to connect to aurenConnect.',
          style: AppTextStyles.t(15.5, c: AppColors.textSecondary, h: 1.4),
        ),
        const SizedBox(height: 28),
        for (int i = 0; i < steps.length; i++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '${i + 1}',
                  style: AppTextStyles.t(
                    12.5,
                    w: FontWeight.w700,
                    c: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      steps[i].$1,
                      style: AppTextStyles.t(13.5, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      steps[i].$2,
                      style: AppTextStyles.t(
                        12.5,
                        c: AppColors.textMuted,
                        h: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (i != steps.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildStarburstGraphic() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C6FF).withValues(alpha: .2),
            const Color(0xFF0072FF).withValues(alpha: .2),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38EF7D).withValues(alpha: .25),
            ),
          ),
          // Ring badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0866FF), width: 7),
              color: const Color(0xFF0E1726),
            ),
            child: const Center(
              child: Icon(
                RemixIcons.instagram_fill,
                size: 34,
                color: Color(0xFFE1306C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── "A few steps in" card ──────────────────────────────────────────────────

  Widget _buildRightCard(ChannelController controller) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.links_line,
                AppColors.primary,
                size: 40,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'A few steps in',
                  style: AppTextStyles.t(20, w: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'We\'ll take you to Meta to connect. Just set your permissions, and your Instagram account will be linked to aurenConnect.',
            style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
          ),
          const SizedBox(height: 24),

          // Primary Blue "Connect Via Meta" Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isConnecting ? null : _connectViaMeta,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0866FF), // Meta Blue
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: controller.isConnecting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(RemixIcons.facebook_circle_fill, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          controller.isAwaitingMeta
                              ? 'Connecting on Meta...'
                              : 'Connect Via Meta',
                          style: AppTextStyles.t(15, w: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),

          if (controller.isAwaitingMeta) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0866FF).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF0866FF).withValues(alpha: .3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Complete authorization in the Meta window...',
                      style: AppTextStyles.t(12.5, c: const Color(0xFF0866FF)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Trust Badge Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'aurenConnect is a trusted Meta Business Partner',
                    style: AppTextStyles.t(
                      12.5,
                      c: AppColors.textSecondary,
                      w: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      RemixIcons.meta_line,
                      size: 22,
                      color: Color(0xFF0866FF),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta',
                          style: AppTextStyles.t(
                            11,
                            w: FontWeight.w800,
                            c: Colors.white,
                          ),
                        ),
                        Text(
                          'Business Partner',
                          style: AppTextStyles.t(9, c: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // See More Options Expandable
          InkWell(
            onTap: controller.toggleMoreOptions,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See More Options',
                    style: AppTextStyles.t(
                      13,
                      c: AppColors.textMuted,
                      w: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    controller.showMoreOptions
                        ? RemixIcons.arrow_up_s_line
                        : RemixIcons.arrow_down_s_line,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          if (controller.showMoreOptions) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prerequisites checklist:',
                    style: AppTextStyles.t(
                      12,
                      w: FontWeight.w600,
                      c: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Must be an Instagram Professional (Creator or Business) account.\n'
                    '• Must have a linked Facebook Page in Meta Accounts Center.\n'
                    '• "Allow access to messages" enabled in Instagram mobile app settings.',
                    style: AppTextStyles.t(
                      11.5,
                      c: AppColors.textSecondary,
                      h: 1.45,
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
}

// ════════════════════════════════════════════════════════════════════════════
//  CHANNEL HERO OVERVIEW BANNER (REAL DATA ONLY)
// ════════════════════════════════════════════════════════════════════════════

class _ChannelHeroBanner extends StatelessWidget {
  const _ChannelHeroBanner({
    required this.igConnected,
    required this.igHandle,
    required this.accountCount,
    this.waConnected = false,
    this.waHandle = 'Not connected',
    this.waCount = 0,
    required this.isSyncing,
    required this.onConnectTap,
    required this.onSyncTap,
  });

  final bool igConnected;
  final String igHandle;
  final int accountCount;
  final bool waConnected;
  final String waHandle;
  final int waCount;
  final bool isSyncing;
  final VoidCallback onConnectTap;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
    final totalConnected = accountCount + waCount;

    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(26),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .14),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 880;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StudioPill(
                    totalConnected > 0
                        ? '$totalConnected Channels Connected'
                        : 'No Channels Connected',
                    color: totalConnected > 0
                        ? AppColors.primary
                        : AppColors.textMuted,
                    icon: totalConnected > 0
                        ? RemixIcons.checkbox_circle_line
                        : RemixIcons.links_line,
                  ),
                  if (igConnected)
                    StudioPill(
                      '$accountCount Instagram Active',
                      color: AppColors.igColor,
                      icon: RemixIcons.instagram_line,
                    ),
                  if (waConnected)
                    StudioPill(
                      '$waCount WhatsApp Active',
                      color: AppColors.waColor,
                      icon: RemixIcons.whatsapp_line,
                    ),
                  const StudioPill(
                    'Multi-Channel Studio',
                    color: AppColors.accent,
                    icon: RemixIcons.cloud_line,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Channel Management',
                style: AppTextStyles.t(28, w: FontWeight.w700, ls: -.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Connect and manage your authorized Instagram messaging channels to automate conversations, lead qualification, and customer support in real time.',
                style: AppTextStyles.t(
                  14.5,
                  c: AppColors.textSecondary,
                  h: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GradientButton(
                    label: 'Connect Instagram',
                    icon: RemixIcons.add_circle_line,
                    onTap: onConnectTap,
                  ),
                  GhostButton(
                    label: isSyncing ? 'Syncing...' : 'Sync Channels',
                    icon: RemixIcons.refresh_line,
                    onTap: onSyncTap,
                  ),
                ],
              ),
            ],
          );

          final summaryBox = Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Channel Status',
                      style: AppTextStyles.t(14, w: FontWeight.w700),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: igConnected
                            ? AppColors.success
                            : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: igConnected
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: .7,
                                  ),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusMiniRow(
                  icon: RemixIcons.instagram_line,
                  color: AppColors.igColor,
                  label: 'Instagram',
                  value: igConnected ? igHandle : 'Disconnected',
                ),
                const SizedBox(height: 10),
                const _StatusMiniRow(
                  icon: RemixIcons.whatsapp_line,
                  color: AppColors.waColor,
                  label: 'WhatsApp',
                  value: 'Coming Soon',
                ),
                const SizedBox(height: 10),
                _StatusMiniRow(
                  icon: RemixIcons.shield_check_line,
                  color: AppColors.primary,
                  label: 'Auth Method',
                  value: 'Meta Unified Login',
                ),
              ],
            ),
          );

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 32),
                    summaryBox,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 20), summaryBox],
                );
        },
      ),
    );
  }
}

class _StatusMiniRow extends StatelessWidget {
  const _StatusMiniRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.t(12.5, c: AppColors.textSecondary)),
        const Spacer(),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.t(12.5, w: FontWeight.w600),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  INSTAGRAM CHANNEL CARD (REAL DATA ONLY)
// ════════════════════════════════════════════════════════════════════════════

class _InstagramChannelCard extends StatelessWidget {
  const _InstagramChannelCard({
    required this.account,
    required this.onDisconnect,
    required this.onCopyId,
    required this.onSync,
  });

  final InstagramChannelModel account;
  final VoidCallback onDisconnect;
  final ValueChanged<String> onCopyId;
  final VoidCallback? onSync;

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final connectedDateStr = account.connectedAt != null
        ? _formatDate(account.connectedAt!)
        : 'Active Session';

    return StudioCard(
      hoverable: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.igColor.withValues(alpha: .14),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.instagram_line,
                AppColors.igColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            account.displayHandle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.t(17, w: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          RemixIcons.verified_badge_fill,
                          size: 16,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 8),
                        StudioPill(
                          account.isActive ? 'Connected' : 'Offline',
                          color: account.isActive
                              ? AppColors.igColor
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Graph API · Instagram Professional Account',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Real Business Details Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _IdCopyItem(
                        label: 'Instagram User ID',
                        value: account.instagramUserId.isNotEmpty
                            ? account.instagramUserId
                            : 'Linked',
                        onCopy: () => onCopyId(account.instagramUserId),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Connected Date',
                            style: AppTextStyles.t(
                              11.5,
                              c: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                RemixIcons.calendar_line,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                connectedDateStr,
                                style: AppTextStyles.t(
                                  12.5,
                                  w: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (account.scopes.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    'Granted Meta Permissions',
                    style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: account.scopes.map((scope) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.igColor.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.igColor.withValues(alpha: .25),
                          ),
                        ),
                        child: Text(
                          scope,
                          style: AppTextStyles.t(
                            11,
                            w: FontWeight.w600,
                            c: AppColors.igColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Real Actions
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GhostButton(
                label: 'Sync Status',
                icon: RemixIcons.refresh_line,
                onTap: onSync,
              ),
              GhostButton(
                label: 'Disconnect',
                icon: RemixIcons.shut_down_line,
                onTap: onDisconnect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EMPTY INSTAGRAM CARD (WHEN NO INSTAGRAM ACCOUNT IS CONNECTED)
// ════════════════════════════════════════════════════════════════════════════

class _EmptyInstagramChannelCard extends StatelessWidget {
  const _EmptyInstagramChannelCard({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.igColor.withValues(alpha: .08),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.instagram_line,
                AppColors.igColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instagram Professional',
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Graph API · Direct Messages & Comments',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill('Disconnected', color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'No Instagram account connected yet. Link your Instagram Professional or Creator account via Meta to automate direct messages, replies, and lead qualification.',
            style: AppTextStyles.t(13.5, c: AppColors.textSecondary, h: 1.5),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Connect Instagram Account',
            icon: RemixIcons.add_circle_line,
            onTap: onConnect,
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP CONNECTED CHANNEL CARD
// ════════════════════════════════════════════════════════════════════════════

class _WhatsAppChannelCard extends StatelessWidget {
  const _WhatsAppChannelCard({
    required this.channel,
    required this.onDisconnect,
    required this.onCopyId,
    required this.onSync,
  });

  final WhatsAppChannelModel channel;
  final VoidCallback onDisconnect;
  final void Function(String) onCopyId;
  final VoidCallback? onSync;

  @override
  Widget build(BuildContext context) {
    final isConnected = channel.isConnected;

    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .08),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              if (channel.profilePic != null && channel.profilePic!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    channel.profilePic!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const StudioIconBox(
                      RemixIcons.whatsapp_line,
                      AppColors.waColor,
                      size: 48,
                    ),
                  ),
                )
              else
                const StudioIconBox(
                  RemixIcons.whatsapp_line,
                  AppColors.waColor,
                  size: 48,
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.displayName,
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          channel.displayPhoneNumber,
                          style: AppTextStyles.t(
                            12.5,
                            c: AppColors.textSecondary,
                            w: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppColors.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Linked Device',
                          style: AppTextStyles.t(12, c: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StudioPill(
                isConnected ? 'Active' : channel.status,
                color: isConnected ? AppColors.waColor : AppColors.accent,
                icon: isConnected
                    ? RemixIcons.checkbox_circle_fill
                    : RemixIcons.loader_4_line,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Metadata Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _IdCopyItem(
                        label: 'Phone JID',
                        value:
                            channel.jid ?? channel.phoneNumber ?? channel.id,
                        onCopy: () => onCopyId(
                          channel.jid ?? channel.phoneNumber ?? channel.id,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Device Fingerprint',
                            style: AppTextStyles.t(
                              11.5,
                              c: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'macOS · Chrome',
                            style: AppTextStyles.t(
                              12.5,
                              w: FontWeight.w600,
                              c: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      RemixIcons.shield_check_line,
                      size: 15,
                      color: AppColors.waColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '10 Anti-Ban Safeguards Active · Rate Limited · Natural Typing Jitter',
                        style: AppTextStyles.t(
                          11.5,
                          c: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Footer Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                channel.connectedAt != null
                    ? 'Connected ${_formatDate(channel.connectedAt!)}'
                    : 'Active session',
                style: AppTextStyles.t(12, c: AppColors.textMuted),
              ),
              Row(
                children: [
                  GhostButton(
                    label: 'Sync',
                    icon: RemixIcons.refresh_line,
                    onTap: onSync,
                  ),
                  const SizedBox(width: 8),
                  GhostButton(
                    label: 'Disconnect',
                    icon: RemixIcons.shut_down_line,
                    onTap: onDisconnect,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP EMPTY STATE CARD
// ════════════════════════════════════════════════════════════════════════════

class _EmptyWhatsAppChannelCard extends StatelessWidget {
  const _EmptyWhatsAppChannelCard({required this.onConnect});

  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .06),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.whatsapp_line,
                AppColors.waColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp (Linked Device)',
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Multi-Device QR Code · Instant Connection',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill(
                'Instant',
                color: AppColors.waColor,
                icon: RemixIcons.flashlight_line,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Connect any personal or business WhatsApp number in under 15 seconds by scanning a QR code with your phone. Zero Meta API fees, no business verification required.',
            style: AppTextStyles.t(13.5, c: AppColors.textSecondary, h: 1.5),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _featureChip('QR Code Scan'),
              _featureChip('100% Free'),
              _featureChip('10 Anti-Ban Safeguards'),
              _featureChip('Auto-Recovery'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              GradientButton(
                label: 'Connect WhatsApp',
                icon: RemixIcons.qr_code_line,
                onTap: onConnect,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            RemixIcons.check_line,
            size: 12,
            color: AppColors.waColor,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: AppTextStyles.t(
              11.5,
              c: AppColors.textSecondary,
              w: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP CONNECT MODAL (QR CODE & PAIRING CODE)
// ════════════════════════════════════════════════════════════════════════════

class WhatsAppConnectDialog extends StatefulWidget {
  const WhatsAppConnectDialog({super.key});

  @override
  State<WhatsAppConnectDialog> createState() => _WhatsAppConnectDialogState();
}

class _WhatsAppConnectDialogState extends State<WhatsAppConnectDialog> {
  int _selectedTab = 0; // 0 = QR Code, 1 = Phone Pairing Code
  bool _isLoading = true;
  String? _errorMessage;
  String? _channelId;
  String? _status;
  String? _qrCodeBase64;
  String? _pairingCode;
  Timer? _pollTimer;
  WhatsAppChannelModel? _connectedChannel;

  final _phoneController = TextEditingController();
  bool _isRequestingPairing = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _startSession({String? phoneNumber}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final controller = context.read<ChannelController>();
      final res = await controller.connectWhatsApp(
        channelId: _channelId,
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _channelId = res['channelId'] as String?;
        _status = res['status'] as String? ?? 'SCAN_QR';
        _qrCodeBase64 = res['qrCodeBase64'] as String?;
        _pairingCode = res['pairingCode'] as String?;
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceAll('ApiException: ', '');
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_channelId == null || !mounted) {
        timer.cancel();
        return;
      }

      try {
        final controller = context.read<ChannelController>();
        final res = await controller.getWhatsAppStatus(_channelId!);

        if (!mounted) return;

        final status = res['status'] as String?;
        final qr = res['qrCodeBase64'] as String?;
        final pair = res['pairingCode'] as String?;

        if (qr != null && qr != _qrCodeBase64) {
          setState(() => _qrCodeBase64 = qr);
        }
        if (pair != null && pair != _pairingCode) {
          setState(() => _pairingCode = pair);
        }

        if (status == 'CONNECTED') {
          timer.cancel();
          setState(() {
            _status = 'CONNECTED';
            if (res['channel'] != null) {
              _connectedChannel = WhatsAppChannelModel.fromJson(
                Map<String, dynamic>.from(res['channel'] as Map),
              );
            }
          });

          // Refresh channel state in background
          controller.loadChannels();

          // Gracefully close dialog after 1.5s
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop(true);
              AppSnackBar.success(
                context,
                'WhatsApp connected successfully as ${_connectedChannel?.displayName ?? 'Device'}!',
              );
            }
          });
        }
      } catch (_) {}
    });
  }

  Uint8List? _decodeQrBytes(String? dataUrl) {
    if (dataUrl == null || dataUrl.isEmpty) return null;
    try {
      final commaIdx = dataUrl.indexOf(',');
      final cleanBase64 =
          commaIdx != -1 ? dataUrl.substring(commaIdx + 1) : dataUrl;
      return base64Decode(cleanBase64.replaceAll(RegExp(r'\s+'), ''));
    } catch (e) {
      debugPrint('QR decode error: $e');
      return null;
    }
  }

  Future<void> _requestPairingCode() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      AppSnackBar.error(
        context,
        'Please enter your phone number with country code',
      );
      return;
    }

    setState(() => _isRequestingPairing = true);
    await _startSession(phoneNumber: phone);
    if (mounted) {
      setState(() => _isRequestingPairing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = _status == 'CONNECTED';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: const Color(0xFF0D1420),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .6),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 20, 20),
              child: Row(
                children: [
                  const StudioIconBox(
                    RemixIcons.whatsapp_line,
                    AppColors.waColor,
                    size: 42,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Link WhatsApp Account',
                          style: AppTextStyles.t(18, w: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'WhatsApp Web Linked Device · Multi-Device Protocol',
                          style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      RemixIcons.close_line,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.border, height: 1),

            if (isConnected) ...[
              // Connected Success View
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.waColor.withValues(alpha: .15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.waColor, width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          RemixIcons.checkbox_circle_fill,
                          size: 42,
                          color: AppColors.waColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'WhatsApp Connected!',
                      style: AppTextStyles.t(20, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _connectedChannel != null
                          ? 'Linked as ${_connectedChannel!.displayName} (${_connectedChannel!.displayPhoneNumber})'
                          : 'Your device session is now active and ready for automation.',
                      style: AppTextStyles.t(13.5, c: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const StudioPill(
                      '🛡️ Anti-Ban Shield Active',
                      color: AppColors.waColor,
                      icon: RemixIcons.shield_check_line,
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Tab Switcher (QR Code vs Phone Number)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 16, 28, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _tabButton(
                          index: 0,
                          icon: RemixIcons.qr_code_line,
                          label: 'Scan QR Code',
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: _tabButton(
                          index: 1,
                          icon: RemixIcons.phone_line,
                          label: 'Pair with Phone',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tab Content
              Padding(
                padding: const EdgeInsets.all(28),
                child: _selectedTab == 0 ? _buildQrTab() : _buildPairingTab(),
              ),

              // Bottom Security Banner
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF090E17),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      RemixIcons.shield_keyhole_line,
                      size: 16,
                      color: AppColors.waColor,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '10 Anti-Ban Rules Enforced · Real macOS Chrome Fingerprint · No bulk scraping',
                        style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final active = _selectedTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedTab = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.waColor.withValues(alpha: .15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? Border.all(color: AppColors.waColor.withValues(alpha: .4))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: active ? AppColors.waColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.t(
                12.5,
                w: active ? FontWeight.w700 : FontWeight.w500,
                c: active ? AppColors.waColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrTab() {
    final qrBytes = _decodeQrBytes(_qrCodeBase64);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // QR Code Box
        Container(
          width: 220,
          height: 220,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .4),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppColors.waColor),
                      SizedBox(height: 12),
                      Text(
                        'Generating QR...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            RemixIcons.error_warning_line,
                            color: AppColors.error,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 11,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _startSession(),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : qrBytes != null
                      ? Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.memory(
                              qrBytes,
                              width: 196,
                              height: 196,
                              fit: BoxFit.contain,
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                RemixIcons.whatsapp_fill,
                                color: AppColors.waColor,
                                size: 28,
                              ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.waColor,
                          ),
                        ),
        ),

        const SizedBox(width: 24),

        // Steps instructions
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How to scan with phone:',
                style: AppTextStyles.t(14, w: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              _instructionStep('1', 'Open WhatsApp on your phone'),
              _instructionStep('2', 'Tap Settings (iOS) or Menu ⋮ (Android)'),
              _instructionStep('3', 'Tap Linked Devices > Link a Device'),
              _instructionStep('4', 'Point camera at the QR code to scan'),
              const SizedBox(height: 14),
              Row(
                children: [
                  GhostButton(
                    label: 'Refresh QR',
                    icon: RemixIcons.refresh_line,
                    onTap: _isLoading ? null : () => _startSession(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPairingTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Link with phone number instead:',
          style: AppTextStyles.t(14, w: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Enter your WhatsApp number including country code to receive an 8-digit pairing code.',
          style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _phoneController,
                style: AppTextStyles.t(14),
                decoration: InputDecoration(
                  hintText: 'e.g. +91 98765 43210',
                  hintStyle: AppTextStyles.t(13, c: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: .5),
                  prefixIcon: const Icon(
                    RemixIcons.phone_line,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.waColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GradientButton(
              label: _isRequestingPairing ? 'Generating...' : 'Get Code',
              icon: RemixIcons.key_line,
              onTap: _isRequestingPairing ? null : _requestPairingCode,
            ),
          ],
        ),
        if (_pairingCode != null) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.waColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.waColor.withValues(alpha: .3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Your 8-Digit Pairing Code:',
                  style: AppTextStyles.t(
                    12,
                    c: AppColors.waColor,
                    w: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  _pairingCode!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'A notification has been sent to your phone. Tap it or open WhatsApp > Linked Devices > Link with phone number instead, and enter this code.',
                  style: AppTextStyles.t(12, c: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _instructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.waColor.withValues(alpha: .15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: AppColors.waColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.t(12.5, c: AppColors.textSecondary, h: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELPER ITEM
// ════════════════════════════════════════════════════════════════════════════

class _IdCopyItem extends StatelessWidget {
  const _IdCopyItem({
    required this.label,
    required this.value,
    required this.onCopy,
  });

  final String label;
  final String value;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.t(11.5, c: AppColors.textMuted)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.t(12.5, w: FontWeight.w600),
              ),
            ),
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  RemixIcons.file_copy_line,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
