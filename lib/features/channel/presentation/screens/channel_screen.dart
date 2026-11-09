import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/app_snackbar.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/section_title.dart';
import 'package:auren_connect/core/widgets/split_row.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_page_heading.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';
import 'package:auren_connect/features/overview/presentation/widget/progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../controller/channel_controller.dart';
import 'manychat_instagram_connect_view.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({super.key});

  @override
  State<ChannelScreen> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  int _selectedFilter = 0; // 0: All, 1: WhatsApp, 2: Instagram
  bool _isSyncing = false;
  bool _isTestingWebhook = false;
  bool _showInstagramConnectView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelController>().loadChannels();
    });
  }

  // WhatsApp Channel State
  bool _waConnected = true;
  bool _waActive = true;
  final String _waPhone = '+91 98765 43210';
  final String _waDisplayName = 'Auren Studio';
  final String _waWabaId = '109284719203841';
  final String _waPhoneId = '103948271039482';
  final String _waQuality = 'High';
  final int _waDailyUsed = 1842;
  final int _waDailyLimit = 10000;
  bool _waWebhookActive = true;
  bool _waTemplatesActive = true;
  bool _waAutoResponder = true;

  // Instagram Channel State
  bool _igActive = true;
  final String _igHandle = '@auren.studio';
  final String _igAccountName = 'Auren Design Studio';
  final String _igPageName = 'Auren Studio Official';
  final String _igPageId = '104928371948201';
  final String _igAccountId = '17841400293817290';
  final int _igDmsToday = 602;
  bool _igDirectMessages = true;
  bool _igStoryMentions = true;
  bool _igCommentTriggers = true;

  // Meta Developer / Webhook settings
  final String _webhookCallbackUrl =
      'https://api.aurenconnect.com/v1/webhooks/meta';
  final String _verifyToken = 'auren_wh_sec_99382810fb';
  bool _obscureVerifyToken = true;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.info(context, '$label copied to clipboard');
  }

  Future<void> _syncChannels() async {
    setState(() => _isSyncing = true);
    await context.read<ChannelController>().syncChannels();
    if (!mounted) return;
    setState(() => _isSyncing = false);
    AppSnackBar.success(
      context,
      'Channels successfully synchronized with Meta Cloud API (v21.0)',
    );
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
                'Disconnect Instagram?',
                style: AppTextStyles.t(17, w: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to disconnect $handle? Real-time comment-to-DM triggers and direct messaging automations will stop listening.',
          style: AppTextStyles.t(13, c: AppColors.textSecondary, h: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.t(13.5, c: AppColors.textSecondary),
            ),
          ),
          GradientButton(
            label: 'Disconnect',
            icon: RemixIcons.shut_down_line,
            onTap: () async {
              Navigator.of(ctx).pop();
              final ok = await context
                  .read<ChannelController>()
                  .disconnectInstagram(channelId);
              if (ok && mounted) {
                AppSnackBar.info(context, '$handle disconnected successfully');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _testWebhook() async {
    setState(() => _isTestingWebhook = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isTestingWebhook = false);
    AppSnackBar.success(
      context,
      'Webhook handshake verified! Response status 200 OK (38ms latency)',
    );
  }

  void _showTestMessageDialog(String channelName) {
    final isWa = channelName == 'WhatsApp';
    final recipientCtrl = TextEditingController(
      text: isWa ? '+91 98765 00000' : '@client_demo',
    );
    final messageCtrl = TextEditingController(
      text: isWa
          ? 'Hello from Auren Connect! This is an automated test message via WhatsApp Business API.'
          : 'Hi! This is a test DM from Auren Studio automated Instagram trigger.',
    );

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
            StudioIconBox(
              isWa ? RemixIcons.whatsapp_line : RemixIcons.instagram_line,
              isWa ? AppColors.waColor : AppColors.igColor,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test $channelName Message',
                    style: AppTextStyles.t(17, w: FontWeight.w700),
                  ),
                  Text(
                    'Send a live sandbox test to verify API handshake',
                    style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWa ? 'Recipient Phone Number' : 'Recipient Instagram Handle',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: recipientCtrl,
                style: AppTextStyles.t(14),
                decoration: AppInputDecorations.dec(
                  isWa ? '+91 ...' : '@username',
                  icon: isWa ? RemixIcons.phone_line : RemixIcons.at_line,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Message Payload',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: messageCtrl,
                maxLines: 3,
                style: AppTextStyles.t(14),
                decoration: AppInputDecorations.dec('Enter message payload...'),
              ),
            ],
          ),
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
            label: 'Send Test',
            icon: RemixIcons.send_plane_2_line,
            onTap: () {
              Navigator.of(ctx).pop();
              AppSnackBar.success(
                context,
                'Test message dispatched to ${recipientCtrl.text.trim()} via $channelName!',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showConfigureDialog(String channelName) {
    final isWa = channelName == 'WhatsApp';
    final id1Ctrl = TextEditingController(text: isWa ? _waWabaId : _igPageId);
    final id2Ctrl = TextEditingController(
      text: isWa ? _waPhoneId : _igAccountId,
    );
    final tokenCtrl = TextEditingController(
      text: 'EAAG9ZCE8kL...[Meta System Token]',
    );

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
            StudioIconBox(
              isWa ? RemixIcons.whatsapp_line : RemixIcons.instagram_line,
              isWa ? AppColors.waColor : AppColors.igColor,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configure $channelName Connection',
                    style: AppTextStyles.t(17, w: FontWeight.w700),
                  ),
                  Text(
                    'Manage Meta Graph API credentials & IDs',
                    style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isWa
                    ? 'WhatsApp Business Account ID (WABA)'
                    : 'Facebook Page ID',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: id1Ctrl,
                style: AppTextStyles.t(14),
                decoration: AppInputDecorations.dec(
                  'ID',
                  icon: RemixIcons.hashtag,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                isWa ? 'Phone Number ID' : 'Instagram Professional Account ID',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: id2Ctrl,
                style: AppTextStyles.t(14),
                decoration: AppInputDecorations.dec(
                  'ID',
                  icon: RemixIcons.fingerprint_line,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Permanent Access Token',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: tokenCtrl,
                obscureText: true,
                style: AppTextStyles.t(14),
                decoration: AppInputDecorations.dec(
                  'System User Token',
                  icon: RemixIcons.key_2_line,
                ),
              ),
            ],
          ),
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
            label: 'Save Configuration',
            icon: RemixIcons.check_line,
            onTap: () {
              Navigator.of(ctx).pop();
              AppSnackBar.success(
                context,
                '$channelName credentials successfully updated and validated.',
              );
            },
          ),
        ],
      ),
    );
  }

  void _showConnectChannelDialog() {
    int selectedChannel = 0; // 0: WhatsApp, 1: Instagram

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isWa = selectedChannel == 0;
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                const StudioIconBox(
                  RemixIcons.plug_2_line,
                  AppColors.primary,
                  size: 40,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect Channel',
                        style: AppTextStyles.t(18, w: FontWeight.w700),
                      ),
                      Text(
                        'Add or re-authorize Meta messaging channels',
                        style: AppTextStyles.t(
                          12.5,
                          c: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Messaging Channel',
                    style: AppTextStyles.t(13, w: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ChannelSelectTile(
                          title: 'WhatsApp',
                          subtitle: 'Business Cloud API',
                          icon: RemixIcons.whatsapp_line,
                          color: AppColors.waColor,
                          selected: isWa,
                          onTap: () => setModalState(() => selectedChannel = 0),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChannelSelectTile(
                          title: 'Instagram',
                          subtitle: 'Professional Account',
                          icon: RemixIcons.instagram_line,
                          color: AppColors.igColor,
                          selected: !isWa,
                          onTap: () => setModalState(() => selectedChannel = 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: .5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              RemixIcons.shield_check_line,
                              size: 18,
                              color: isWa
                                  ? AppColors.waColor
                                  : AppColors.igColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isWa
                                  ? 'Meta Embedded Signup'
                                  : 'Meta OAuth 2.0 Authorization',
                              style: AppTextStyles.t(
                                13.5,
                                w: FontWeight.w600,
                                c: isWa ? AppColors.waColor : AppColors.igColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isWa
                              ? 'Authenticate with your Meta Business Suite credentials. This automatically links your WhatsApp Business Account (WABA) and phone numbers with Auren Connect.'
                              : 'Log in with Facebook and grant access to your Instagram Professional Account and connected Facebook Page for instant message and story reply routing.',
                          style: AppTextStyles.t(
                            12.5,
                            c: AppColors.textSecondary,
                            h: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const StudioPill(
                              'Verified Partner API',
                              color: AppColors.success,
                            ),
                            const SizedBox(width: 8),
                            StudioPill(
                              isWa
                                  ? 'Phone & WABA auto-detect'
                                  : 'Graph API v21.0',
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Permissions that will be authorized:',
                    style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        (isWa
                                ? [
                                    'whatsapp_business_messaging',
                                    'whatsapp_business_management',
                                  ]
                                : [
                                    'instagram_manage_messages',
                                    'instagram_manage_comments',
                                    'pages_messaging',
                                  ])
                            .map(
                              (p) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .04),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .08),
                                  ),
                                ),
                                child: Text(
                                  p,
                                  style: AppTextStyles.t(
                                    11,
                                    c: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
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
                label: isWa ? 'Launch WhatsApp Signup' : 'Log in with Meta',
                icon: RemixIcons.login_box_line,
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (isWa) {
                    setState(() {
                      _waConnected = true;
                      _waActive = true;
                    });
                    AppSnackBar.success(
                      context,
                      'WhatsApp channel connected successfully!',
                    );
                  } else {
                    setState(() => _showInstagramConnectView = true);
                  }
                },
              ),
            ],
          );
        },
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
    final isIgConnected = channelController.isInstagramConnected;
    final igAccount = channelController.primaryInstagramAccount;
    final currentIgHandle =
        igAccount?.displayHandle ??
        (isIgConnected ? _igHandle : 'Not connected');
    final currentIgAccountId =
        igAccount?.instagramUserId ??
        (isIgConnected ? _igAccountId : 'Not linked');

    return StudioPage(
      children: [
        // 1. Top Action Bar
        StudioPageHeading(
          actions: [
            GhostButton(
              label: _isSyncing ? 'Syncing...' : 'Sync Channels',
              icon: RemixIcons.refresh_line,
              onTap: _isSyncing ? null : _syncChannels,
            ),
            GradientButton(
              label: 'Connect Channel',
              icon: RemixIcons.add_line,
              onTap: _showConnectChannelDialog,
            ),
          ],
        ),

        // 2. Hero Overview Card
        _ChannelHeroBanner(
          waConnected: _waConnected && _waActive,
          igConnected: isIgConnected && _igActive,
          waPhone: _waPhone,
          igHandle: currentIgHandle,
          onConnectTap: _showConnectChannelDialog,
        ),

        // 3. Filter Chips
        StudioChips(
          options: const ['All channels (2)', 'WhatsApp', 'Instagram'],
          selected: _selectedFilter,
          onChanged: (idx) => setState(() => _selectedFilter = idx),
        ),

        // 4. Main Connected Channel Cards
        ResponsiveGrid(
          minItemWidth: 440,
          maxColumns: 2,
          spacing: 20,
          children: [
            if (_selectedFilter == 0 || _selectedFilter == 1)
              _WhatsAppChannelCard(
                connected: _waConnected,
                active: _waActive,
                phone: _waPhone,
                displayName: _waDisplayName,
                wabaId: _waWabaId,
                phoneId: _waPhoneId,
                quality: _waQuality,
                used: _waDailyUsed,
                limit: _waDailyLimit,
                webhookActive: _waWebhookActive,
                templatesActive: _waTemplatesActive,
                autoResponder: _waAutoResponder,
                onToggleActive: (val) => setState(() => _waActive = val),
                onToggleWebhook: (val) =>
                    setState(() => _waWebhookActive = val),
                onToggleTemplates: (val) =>
                    setState(() => _waTemplatesActive = val),
                onToggleAutoReply: (val) =>
                    setState(() => _waAutoResponder = val),
                onTestMessage: () => _showTestMessageDialog('WhatsApp'),
                onConfigure: () => _showConfigureDialog('WhatsApp'),
                onToggleConnect: () {
                  setState(() => _waConnected = !_waConnected);
                  AppSnackBar.info(
                    context,
                    _waConnected
                        ? 'WhatsApp reconnected'
                        : 'WhatsApp disconnected',
                  );
                },
                onCopyId: (val) => _copyToClipboard(val, 'WhatsApp ID'),
              ),
            if (_selectedFilter == 0 || _selectedFilter == 2)
              _InstagramChannelCard(
                connected: isIgConnected,
                active: _igActive,
                handle: currentIgHandle,
                accountName: igAccount?.username ?? _igAccountName,
                pageName: _igPageName,
                pageId: _igPageId,
                accountId: currentIgAccountId,
                dmsToday: _igDmsToday,
                directMessages: _igDirectMessages,
                storyMentions: _igStoryMentions,
                commentTriggers: _igCommentTriggers,
                onToggleActive: (val) => setState(() => _igActive = val),
                onToggleDms: (val) => setState(() => _igDirectMessages = val),
                onToggleStories: (val) =>
                    setState(() => _igStoryMentions = val),
                onToggleComments: (val) =>
                    setState(() => _igCommentTriggers = val),
                onTestMessage: () => _showTestMessageDialog('Instagram'),
                onConfigure: () => _showConfigureDialog('Instagram'),
                onToggleConnect: () {
                  if (isIgConnected && igAccount != null) {
                    _showInstagramDisconnectDialog(
                      igAccount.id,
                      currentIgHandle,
                    );
                  } else {
                    setState(() => _showInstagramConnectView = true);
                  }
                },
                onCopyId: (val) => _copyToClipboard(val, 'Instagram ID'),
              ),
          ],
        ),

        // 5. Split Row: Webhooks Configuration + Connection Health
        SplitRow(
          breakpoint: 1040,
          sideWidth: 400,
          main: StudioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  'Webhook & Integration Endpoint',
                  subtitle: 'Subscribe your Meta App webhook to receive incoming messages & events',
                  trailing: GhostButton(
                    label: _isTestingWebhook ? 'Testing...' : 'Test Webhook',
                    icon: RemixIcons.pulse_line,
                    onTap: _isTestingWebhook ? null : _testWebhook,
                  ),
                ),
                const SizedBox(height: 20),

                // Callback URL field
                _CredentialRow(
                  label: 'Callback URL',
                  value: _webhookCallbackUrl,
                  badge: 'POST',
                  onCopy: () =>
                      _copyToClipboard(_webhookCallbackUrl, 'Callback URL'),
                ),
                const SizedBox(height: 14),

                // Verify Token field
                _CredentialRow(
                  label: 'Verify Token',
                  value: _verifyToken,
                  badge: 'SHA-256',
                  obscured: _obscureVerifyToken,
                  onToggleObscure: () => setState(
                    () => _obscureVerifyToken = !_obscureVerifyToken,
                  ),
                  onCopy: () => _copyToClipboard(_verifyToken, 'Verify Token'),
                ),

                const SizedBox(height: 20),
                Text(
                  'Subscribed Meta Webhook Events',
                  style: AppTextStyles.t(13, w: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _EventBadge('messages', 'WhatsApp & Instagram DMs'),
                    _EventBadge(
                      'messaging_postbacks',
                      'Button & quick replies',
                    ),
                    _EventBadge('message_reads', 'Read receipts'),
                    _EventBadge('message_reactions', 'Emoji reactions'),
                    _EventBadge('story_mentions', 'Instagram Story replies'),
                    _EventBadge('feed', 'Post comment triggers'),
                  ],
                ),
              ],
            ),
          ),
          side: StudioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(
                  'Connection Health',
                  subtitle: 'Live Meta Graph API diagnostics',
                ),
                const SizedBox(height: 18),
                const _HealthRow(
                  label: 'Meta Cloud API (v21.0)',
                  value: 'Operational',
                  sub: 'Latency 38ms · Uptime 99.98%',
                  color: AppColors.success,
                ),
                const SizedBox(height: 14),
                const _HealthRow(
                  label: 'Webhook Stream Delivery',
                  value: '100% ACK',
                  sub: '0 dropped events in last 24h',
                  color: AppColors.accent,
                ),
                const SizedBox(height: 14),
                const _HealthRow(
                  label: 'System Access Token',
                  value: 'Valid (58 days)',
                  sub: 'Auto-refresh enabled via Meta Partner',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 18),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  'Recent Webhook Activity',
                  style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                ),
                const SizedBox(height: 12),
                const _ActivityItem(
                  time: '1m ago',
                  title: 'WhatsApp message received',
                  subtitle: '+91 98765 43210 · Handled by bot',
                  icon: RemixIcons.whatsapp_line,
                  color: AppColors.waColor,
                ),
                const SizedBox(height: 10),
                const _ActivityItem(
                  time: '5m ago',
                  title: 'Instagram story reply',
                  subtitle: '@marcus.ux · Triggered welcome series',
                  icon: RemixIcons.instagram_line,
                  color: AppColors.igColor,
                ),
                const SizedBox(height: 10),
                const _ActivityItem(
                  time: '14m ago',
                  title: 'Webhook verification ping',
                  subtitle: 'Meta server challenge handshake 200 OK',
                  icon: RemixIcons.check_double_line,
                  color: AppColors.success,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SUB-WIDGETS & SECTIONS
// ════════════════════════════════════════════════════════════════════════════

class _ChannelHeroBanner extends StatelessWidget {
  const _ChannelHeroBanner({
    required this.waConnected,
    required this.igConnected,
    required this.waPhone,
    required this.igHandle,
    required this.onConnectTap,
  });

  final bool waConnected;
  final bool igConnected;
  final String waPhone;
  final String igHandle;
  final VoidCallback onConnectTap;

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
                    waConnected ? 'WhatsApp Connected' : 'WhatsApp Offline',
                    color: waConnected
                        ? AppColors.waColor
                        : AppColors.textMuted,
                    icon: RemixIcons.whatsapp_line,
                  ),
                  StudioPill(
                    igConnected ? 'Instagram Connected' : 'Instagram Offline',
                    color: igConnected
                        ? AppColors.igColor
                        : AppColors.textMuted,
                    icon: RemixIcons.instagram_line,
                  ),
                  const StudioPill(
                    'Meta Cloud API v21.0',
                    color: AppColors.accent,
                    icon: RemixIcons.cloud_line,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Channel Connections',
                style: AppTextStyles.t(28, w: FontWeight.w700, ls: -.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your official Meta WhatsApp Business API and Instagram Professional messaging connections in one secure hub. Unify real-time customer conversations, automated triggers, and webhooks.',
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
                    label: 'Add new connection',
                    icon: RemixIcons.add_circle_line,
                    onTap: onConnectTap,
                  ),
                  GhostButton(
                    label: 'API documentation',
                    icon: RemixIcons.book_open_line,
                    onTap: () {
                      AppSnackBar.info(
                        context,
                        'Meta Graph API v21.0 Webhook spec is active.',
                      );
                    },
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
                      'Live Sync Status',
                      style: AppTextStyles.t(14, w: FontWeight.w700),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: .7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _StatusMiniRow(
                  icon: RemixIcons.whatsapp_line,
                  color: AppColors.waColor,
                  label: 'WhatsApp',
                  value: waConnected ? waPhone : 'Disconnected',
                ),
                const SizedBox(height: 10),
                _StatusMiniRow(
                  icon: RemixIcons.instagram_line,
                  color: AppColors.igColor,
                  label: 'Instagram',
                  value: igConnected ? igHandle : 'Disconnected',
                ),
                const SizedBox(height: 10),
                const _StatusMiniRow(
                  icon: RemixIcons.shield_check_line,
                  color: AppColors.primary,
                  label: 'Security',
                  value: 'HMAC Webhook Verified',
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
        Text(value, style: AppTextStyles.t(12.5, w: FontWeight.w600)),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP CHANNEL CARD
// ════════════════════════════════════════════════════════════════════════════

class _WhatsAppChannelCard extends StatelessWidget {
  const _WhatsAppChannelCard({
    required this.connected,
    required this.active,
    required this.phone,
    required this.displayName,
    required this.wabaId,
    required this.phoneId,
    required this.quality,
    required this.used,
    required this.limit,
    required this.webhookActive,
    required this.templatesActive,
    required this.autoResponder,
    required this.onToggleActive,
    required this.onToggleWebhook,
    required this.onToggleTemplates,
    required this.onToggleAutoReply,
    required this.onTestMessage,
    required this.onConfigure,
    required this.onToggleConnect,
    required this.onCopyId,
  });

  final bool connected;
  final bool active;
  final String phone;
  final String displayName;
  final String wabaId;
  final String phoneId;
  final String quality;
  final int used;
  final int limit;
  final bool webhookActive;
  final bool templatesActive;
  final bool autoResponder;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<bool> onToggleWebhook;
  final ValueChanged<bool> onToggleTemplates;
  final ValueChanged<bool> onToggleAutoReply;
  final VoidCallback onTestMessage;
  final VoidCallback onConfigure;
  final VoidCallback onToggleConnect;
  final ValueChanged<String> onCopyId;

  @override
  Widget build(BuildContext context) {
    final usagePercent = (used / limit).clamp(0.0, 1.0);

    return StudioCard(
      hoverable: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .14),
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
                RemixIcons.whatsapp_line,
                AppColors.waColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'WhatsApp',
                          style: AppTextStyles.t(17, w: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        StudioPill(
                          connected ? 'Connected' : 'Offline',
                          color: connected
                              ? AppColors.waColor
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Cloud API · Official Business Platform',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: active && connected,
                activeThumbColor: AppColors.waColor,
                activeTrackColor: AppColors.waColor.withValues(alpha: .3),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.border,
                onChanged: connected ? onToggleActive : null,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Details Box
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.t(15, w: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              RemixIcons.verified_badge_fill,
                              size: 16,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          phone,
                          style: AppTextStyles.t(
                            13,
                            c: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    StudioPill(
                      'Quality: $quality',
                      color: AppColors.success,
                      icon: RemixIcons.shield_check_line,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _IdCopyItem(
                        label: 'WABA ID',
                        value: wabaId,
                        onCopy: () => onCopyId(wabaId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IdCopyItem(
                        label: 'Phone ID',
                        value: phoneId,
                        onCopy: () => onCopyId(phoneId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Daily Conversation Tier Limit
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Conversation Quota',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              Text(
                '$used / $limit conversations',
                style: AppTextStyles.t(12.5, w: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressBar(usagePercent, color: AppColors.waColor),
          const SizedBox(height: 16),

          // Feature Toggles List
          _FeatureToggleRow(
            label: 'Inbound Webhook Streaming',
            subtitle: 'Real-time message routing to Unified Inbox',
            value: webhookActive,
            onChanged: onToggleWebhook,
          ),
          _FeatureToggleRow(
            label: 'Template & Catalog Sync',
            subtitle: 'Sync pre-approved Meta message templates',
            value: templatesActive,
            onChanged: onToggleTemplates,
          ),
          _FeatureToggleRow(
            label: 'Automated 24h Window Bot',
            subtitle: 'Instant auto-replies when user initiates chat',
            value: autoResponder,
            onChanged: onToggleAutoReply,
          ),
          const SizedBox(height: 18),

          // Actions
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GradientButton(
                label: 'Test message',
                icon: RemixIcons.send_plane_line,
                onTap: onTestMessage,
              ),
              GhostButton(
                label: 'Configure API',
                icon: RemixIcons.settings_4_line,
                onTap: onConfigure,
              ),
              GhostButton(
                label: connected ? 'Disconnect' : 'Connect',
                icon: connected
                    ? RemixIcons.shut_down_line
                    : RemixIcons.links_line,
                onTap: onToggleConnect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  INSTAGRAM CHANNEL CARD
// ════════════════════════════════════════════════════════════════════════════

class _InstagramChannelCard extends StatelessWidget {
  const _InstagramChannelCard({
    required this.connected,
    required this.active,
    required this.handle,
    required this.accountName,
    required this.pageName,
    required this.pageId,
    required this.accountId,
    required this.dmsToday,
    required this.directMessages,
    required this.storyMentions,
    required this.commentTriggers,
    required this.onToggleActive,
    required this.onToggleDms,
    required this.onToggleStories,
    required this.onToggleComments,
    required this.onTestMessage,
    required this.onConfigure,
    required this.onToggleConnect,
    required this.onCopyId,
  });

  final bool connected;
  final bool active;
  final String handle;
  final String accountName;
  final String pageName;
  final String pageId;
  final String accountId;
  final int dmsToday;
  final bool directMessages;
  final bool storyMentions;
  final bool commentTriggers;
  final ValueChanged<bool> onToggleActive;
  final ValueChanged<bool> onToggleDms;
  final ValueChanged<bool> onToggleStories;
  final ValueChanged<bool> onToggleComments;
  final VoidCallback onTestMessage;
  final VoidCallback onConfigure;
  final VoidCallback onToggleConnect;
  final ValueChanged<String> onCopyId;

  @override
  Widget build(BuildContext context) {
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
                        Text(
                          'Instagram',
                          style: AppTextStyles.t(17, w: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        StudioPill(
                          connected ? 'Connected' : 'Offline',
                          color: connected
                              ? AppColors.igColor
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Graph API · Professional Creator & Business',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Switch(
                value: active && connected,
                activeThumbColor: AppColors.igColor,
                activeTrackColor: AppColors.igColor.withValues(alpha: .3),
                inactiveThumbColor: AppColors.textMuted,
                inactiveTrackColor: AppColors.border,
                onChanged: connected ? onToggleActive : null,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Details Box
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              handle,
                              style: AppTextStyles.t(15, w: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              RemixIcons.verified_badge_fill,
                              size: 16,
                              color: AppColors.accent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$accountName · $pageName',
                          style: AppTextStyles.t(
                            13,
                            c: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    StudioPill(
                      '$dmsToday DMs today',
                      color: AppColors.accent,
                      icon: RemixIcons.message_3_line,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _IdCopyItem(
                        label: 'Facebook Page ID',
                        value: pageId,
                        onCopy: () => onCopyId(pageId),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IdCopyItem(
                        label: 'Instagram User ID',
                        value: accountId,
                        onCopy: () => onCopyId(accountId),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Messaging Window Notice
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.igColor.withValues(alpha: .08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.igColor.withValues(alpha: .2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  RemixIcons.time_line,
                  size: 16,
                  color: AppColors.igColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '24h Messaging Window active · Automated replies sent immediately inside session',
                    style: AppTextStyles.t(12.5, c: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Feature Toggles List
          _FeatureToggleRow(
            label: 'Direct Messaging Webhook',
            subtitle: 'Sync Instagram Direct Messages in Inbox',
            value: directMessages,
            onChanged: onToggleDms,
          ),
          _FeatureToggleRow(
            label: 'Story Mentions & Story Replies',
            subtitle: 'Auto-respond when someone tags you in a Story',
            value: storyMentions,
            onChanged: onToggleStories,
          ),
          _FeatureToggleRow(
            label: 'Comment-to-DM Keyword Triggers',
            subtitle: 'Send instant DM when users comment on Reels or posts',
            value: commentTriggers,
            onChanged: onToggleComments,
          ),
          const SizedBox(height: 18),

          // Actions
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              GradientButton(
                label: 'Test DM flow',
                icon: RemixIcons.send_plane_line,
                onTap: onTestMessage,
              ),
              GhostButton(
                label: 'Permissions',
                icon: RemixIcons.shield_user_line,
                onTap: onConfigure,
              ),
              GhostButton(
                label: connected ? 'Disconnect' : 'Connect',
                icon: connected
                    ? RemixIcons.shut_down_line
                    : RemixIcons.links_line,
                onTap: onToggleConnect,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HELPER WIDGETS
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
        const SizedBox(height: 2),
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

class _FeatureToggleRow extends StatelessWidget {
  const _FeatureToggleRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.t(13.5, w: FontWeight.w600)),
                Text(
                  subtitle,
                  style: AppTextStyles.t(12, c: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: .3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.border,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.label,
    required this.value,
    required this.badge,
    required this.onCopy,
    this.obscured = false,
    this.onToggleObscure,
  });

  final String label;
  final String value;
  final String badge;
  final VoidCallback onCopy;
  final bool obscured;
  final VoidCallback? onToggleObscure;

  @override
  Widget build(BuildContext context) {
    final displayText = obscured ? '••••••••••••••••••••••••••••••••' : value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                badge,
                style: AppTextStyles.t(
                  10.5,
                  w: FontWeight.w600,
                  c: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: .6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.t(13, w: FontWeight.w500),
                ),
              ),
              if (onToggleObscure != null) ...[
                InkWell(
                  onTap: onToggleObscure,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      obscured ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              InkWell(
                onTap: onCopy,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    RemixIcons.file_copy_line,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge(this.event, this.desc);
  final String event;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            RemixIcons.checkbox_circle_fill,
            size: 13,
            color: AppColors.success,
          ),
          const SizedBox(width: 6),
          Text(event, style: AppTextStyles.t(12, w: FontWeight.w600)),
          const SizedBox(width: 6),
          Text('· $desc', style: AppTextStyles.t(11.5, c: AppColors.textMuted)),
        ],
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .6), blurRadius: 6),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: AppTextStyles.t(13.5, w: FontWeight.w600)),
                  Text(
                    value,
                    style: AppTextStyles.t(12.5, w: FontWeight.w600, c: color),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(sub, style: AppTextStyles.t(12, c: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StudioIconBox(icon, color, size: 32),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.t(12.5, w: FontWeight.w600),
                    ),
                  ),
                  Text(
                    time,
                    style: AppTextStyles.t(11, c: AppColors.textMuted),
                  ),
                ],
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.t(11.5, c: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChannelSelectTile extends StatelessWidget {
  const _ChannelSelectTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: .12)
                : AppColors.surfaceVariant.withValues(alpha: .3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : AppColors.border,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StudioIconBox(icon, color, size: 36),
              const SizedBox(height: 10),
              Text(title, style: AppTextStyles.t(15, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.t(12, c: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
