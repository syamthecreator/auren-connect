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
import 'manychat_instagram_connect_view.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  int _selectedFilter = 0; // 0: All, 1: Instagram, 2: WhatsApp
  bool _showInstagramConnectView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelController>().loadChannels();
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.info(context, '$label copied to clipboard');
  }

  Future<void> _syncChannels() async {
    final controller = context.read<ChannelController>();
    await controller.syncChannels();
    if (!mounted) return;
    if (controller.errorMessage != null) {
      AppSnackBar.error(context, controller.errorMessage!);
    } else {
      AppSnackBar.success(
        context,
        controller.successMessage ?? 'Channels synchronized successfully',
      );
    }
  }

  void _showInstagramDisconnectDialog(String channelId, String handle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
          'Are you sure you want to unlink $handle? Automated message flows and triggers for this account will stop running.',
          style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.t(14, c: AppColors.textSecondary),
            ),
          ),
          GradientButton(
            label: 'Disconnect',
            icon: RemixIcons.shut_down_line,
            onTap: () async {
              Navigator.of(ctx).pop();
              final success = await context
                  .read<ChannelController>()
                  .disconnectInstagram(channelId);
              if (!mounted) return;
              if (success) {
                AppSnackBar.success(context, 'Channel disconnected');
              } else {
                AppSnackBar.error(
                  context,
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

  @override
  Widget build(BuildContext context) {
    if (_showInstagramConnectView) {
      return ManyChatInstagramConnectView(
        onBack: () => setState(() => _showInstagramConnectView = false),
        onConnected: () => setState(() => _showInstagramConnectView = false),
      );
    }

    final channelController = context.watch<ChannelController>();
    final accounts = channelController.instagramAccounts;
    final isIgConnected = accounts.isNotEmpty;
    final primaryAccount = isIgConnected ? accounts.first : null;
    final isSyncing = channelController.isSyncing;

    return StudioPage(
      children: [
        // 1. Top Action Bar
        StudioPageHeading(
          actions: [
            GhostButton(
              label: isSyncing ? 'Syncing...' : 'Sync Channels',
              icon: RemixIcons.refresh_line,
              onTap: isSyncing ? null : _syncChannels,
            ),
            GradientButton(
              label: 'Connect Channel',
              icon: RemixIcons.add_line,
              onTap: () => setState(() => _showInstagramConnectView = true),
            ),
          ],
        ),

        // 2. Real Channel Hero Overview Banner
        _ChannelHeroBanner(
          igConnected: isIgConnected,
          igHandle: primaryAccount?.displayHandle ?? 'Not connected',
          accountCount: accounts.length,
          isSyncing: isSyncing,
          onConnectTap: () => setState(() => _showInstagramConnectView = true),
          onSyncTap: isSyncing ? null : _syncChannels,
        ),

        // 3. Filter Chips
        StudioChips(
          options: [
            'All channels (${accounts.length})',
            'Instagram (${accounts.length})',
            'WhatsApp (0)',
          ],
          selected: _selectedFilter,
          onChanged: (idx) => setState(() => _selectedFilter = idx),
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
              if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                if (accounts.isNotEmpty)
                  ...accounts.map(
                    (account) => _InstagramChannelCard(
                      account: account,
                      onDisconnect: () => _showInstagramDisconnectDialog(
                        account.id,
                        account.displayHandle,
                      ),
                      onCopyId: (id) =>
                          _copyToClipboard(id, 'Instagram User ID'),
                      onSync: isSyncing ? null : _syncChannels,
                    ),
                  )
                else
                  _EmptyInstagramChannelCard(
                    onConnect: () =>
                        setState(() => _showInstagramConnectView = true),
                  ),
              ],

              // WhatsApp Card (Honest "Coming Soon", zero dummy toggles or fake metrics)
              if (_selectedFilter == 0 || _selectedFilter == 2)
                const _WhatsAppComingSoonCard(),
            ],
          ),
      ],
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
                    color: igConnected ? AppColors.igColor : AppColors.textMuted,
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
                        color: igConnected ? AppColors.success : AppColors.textMuted,
                        shape: BoxShape.circle,
                        boxShadow: igConnected
                            ? [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: .7),
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
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
                            style: AppTextStyles.t(11.5, c: AppColors.textMuted),
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
                                style: AppTextStyles.t(12.5, w: FontWeight.w600),
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
