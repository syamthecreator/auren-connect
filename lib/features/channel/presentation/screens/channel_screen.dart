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
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_page_heading.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

import '../../controller/channel_controller.dart';
import '../../data/models/instagram_channel_model.dart';

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

    final accounts = channelController.instagramAccounts;
    final isIgConnected = accounts.isNotEmpty;
    final primaryAccount = channelController.primaryInstagramAccount;
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
              onTap: channelController.openInstagramConnectView,
            ),
          ],
        ),

        // 2. Real Channel Hero Overview Banner
        _ChannelHeroBanner(
          igConnected: isIgConnected,
          igHandle: primaryAccount?.displayHandle ?? 'Not connected',
          accountCount: accounts.length,
          isSyncing: isSyncing,
          onConnectTap: channelController.openInstagramConnectView,
          onSyncTap: isSyncing ? null : syncChannels,
        ),

        // 3. Filter Chips
        StudioChips(
          options: [
            'All channels (${accounts.length})',
            'Instagram (${accounts.length})',
            'WhatsApp (0)',
          ],
          selected: channelController.selectedFilter,
          onChanged: channelController.selectFilter,
        ),

        // 4. Main Connected Channel Cards (Real values only)
        if (channelController.isLoading && accounts.isEmpty)
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

              // WhatsApp Card (Honest "Coming Soon", zero dummy toggles or fake metrics)
              if (channelController.selectedFilter == 0 ||
                  channelController.selectedFilter == 2)
                const _WhatsAppComingSoonCard(),
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
    required this.isSyncing,
    required this.onConnectTap,
    required this.onSyncTap,
  });

  final bool igConnected;
  final String igHandle;
  final int accountCount;
  final bool isSyncing;
  final VoidCallback onConnectTap;
  final VoidCallback? onSyncTap;

  @override
  Widget build(BuildContext context) {
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
                    igConnected
                        ? '$accountCount Instagram Connected'
                        : 'No Channels Connected',
                    color: igConnected
                        ? AppColors.igColor
                        : AppColors.textMuted,
                    icon: igConnected
                        ? RemixIcons.instagram_line
                        : RemixIcons.links_line,
                  ),
                  const StudioPill(
                    'Meta Cloud Platform',
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
//  WHATSAPP CARD (HONEST "COMING SOON" - NO DUMMY VALUES OR METRICS)
// ════════════════════════════════════════════════════════════════════════════

class _WhatsAppComingSoonCard extends StatelessWidget {
  const _WhatsAppComingSoonCard();

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
                      'WhatsApp Business API',
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Cloud API · WhatsApp Business Platform',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill(
                'Coming Soon',
                color: AppColors.waColor,
                icon: RemixIcons.time_line,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Official Meta WhatsApp Business Cloud API integration is currently in development for aurenConnect v2.0. Instagram messaging automation is fully operational.',
            style: AppTextStyles.t(13.5, c: AppColors.textSecondary, h: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  RemixIcons.information_line,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 8),
                Text(
                  'Integration will support Cloud WABA templates & bot workflows.',
                  style: AppTextStyles.t(12, c: AppColors.textMuted),
                ),
              ],
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
