// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/studio_avatar.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

import '../../controller/inbox_controller.dart';
import '../../data/models/inbox_conversation_model.dart';
import '../../data/models/inbox_message_model.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<InboxController>();
      controller.loadStats();
      controller.loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InboxController>();
    final screenHeight = MediaQuery.sizeOf(context).height;
    final containerHeight = (screenHeight - 170).clamp(550.0, 920.0);

    return StudioPage(
      children: [
        // Top stats bar
        _InboxStatsBar(controller: controller),

        const SizedBox(height: 14),

        // Main inbox card
        SizedBox(
          height: containerHeight,
          width: double.infinity,
          child: StudioCard(
            padding: EdgeInsets.zero,
            child: _buildInboxContent(context, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildInboxContent(BuildContext context, InboxController controller) {
    if (controller.isLoadingConversations && controller.conversations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (controller.errorMessage != null && controller.conversations.isEmpty) {
      return _buildErrorState(controller);
    }

    final conversations = controller.filteredConversations;
    final conversation = controller.selectedConversation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final listWidth = width < 900 ? 260.0 : 330.0;
        final showInfo = width > 1150;

        return Row(
          children: [
            // Left: Conversation list
            SizedBox(
              width: listWidth,
              child: _buildConversationList(context, controller, conversations),
            ),

            Container(width: 1, color: AppColors.border),

            // Middle: Active live message thread
            Expanded(
              child: conversation == null
                  ? _buildSelectConversationState(conversations.isEmpty)
                  : _MessagePanel(
                      key: ValueKey(conversation.id),
                      conversation: conversation,
                      controller: controller,
                    ),
            ),

            // Right: Contact info & CRM details
            if (showInfo && conversation != null) ...[
              Container(width: 1, color: AppColors.border),
              SizedBox(
                width: 290,
                child: _ContactDetailsSidebar(
                  key: ValueKey('sidebar_${conversation.id}'),
                  conversation: conversation,
                  controller: controller,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Conversation list column
  Widget _buildConversationList(
    BuildContext context,
    InboxController controller,
    List<InboxConversationModel> conversations,
  ) {
    return Column(
      children: [
        // Search & Filter header
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              TextField(
                onChanged: controller.updateSearch,
                style: AppTextStyles.t(13.5),
                cursorColor: AppColors.primary,
                decoration: AppInputDecorations.dec(
                  'Search Instagram DMs...',
                  icon: RemixIcons.search_line,
                ),
              ),

              const SizedBox(height: 10),

              // Filter pills: All, Unread, Archived
              Row(
                children: [
                  _FilterTab(
                    label: 'All',
                    active: controller.statusFilter == 'all',
                    onTap: () => controller.setStatusFilter('all'),
                  ),
                  const SizedBox(width: 6),
                  _FilterTab(
                    label: 'Unread',
                    count: controller.stats.unreadConversations > 0
                        ? controller.stats.unreadConversations
                        : null,
                    active: controller.statusFilter == 'unread',
                    onTap: () => controller.setStatusFilter('unread'),
                  ),
                  const SizedBox(width: 6),
                  _FilterTab(
                    label: 'Archived',
                    active: controller.statusFilter == 'archived',
                    onTap: () => controller.setStatusFilter('archived'),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(RemixIcons.refresh_line, size: 16),
                    tooltip: 'Refresh conversations',
                    color: AppColors.textSecondary,
                    onPressed: () {
                      controller.loadConversations();
                      controller.loadStats();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(height: 1, color: AppColors.border),

        // Conversation items
        Expanded(
          child: conversations.isEmpty
              ? _buildEmptyState(controller)
              : ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    final active = conv.id == controller.selectedConversationId;

                    return _ConversationTile(
                      conversation: conv,
                      active: active,
                      onTap: () => controller.selectConversation(conv.id),
                      onTogglePin: () => controller.togglePin(conv.id),
                      onToggleArchive: () => controller.toggleArchive(conv.id),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(InboxController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              RemixIcons.instagram_line,
              size: 38,
              color: AppColors.igColor.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No conversations found',
              style: AppTextStyles.t(15, w: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              controller.searchQuery.isNotEmpty
                  ? 'Try changing your search term.'
                  : controller.statusFilter == 'unread'
                  ? 'No unread messages right now.'
                  : 'New Instagram messages will automatically appear here.',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
            if (controller.searchQuery.isNotEmpty ||
                controller.statusFilter != 'all') ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: controller.resetFilters,
                child: const Text('Reset filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(InboxController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              RemixIcons.error_warning_line,
              size: 40,
              color: AppColors.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Unable to load conversations',
              style: AppTextStyles.t(16, w: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage ?? 'Please check your connection.',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              onPressed: () {
                controller.loadConversations();
                controller.loadStats();
              },
              icon: const Icon(RemixIcons.refresh_line, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectConversationState(bool emptyList) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                RemixIcons.chat_smile_2_line,
                size: 42,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              emptyList ? 'No Conversations Yet' : 'Select a conversation',
              style: AppTextStyles.t(17, w: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              emptyList
                  ? 'When users message your connected Instagram page, live chats will appear here.'
                  : 'Choose a conversation from the left to read and reply in real time.',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(13, c: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Stats Bar at top of screen
// ---------------------------------------------------------
class _InboxStatsBar extends StatelessWidget {
  const _InboxStatsBar({required this.controller});

  final InboxController controller;

  @override
  Widget build(BuildContext context) {
    final stats = controller.stats;

    return Row(
      children: [
        _StatCard(
          icon: RemixIcons.chat_3_line,
          iconColor: AppColors.primary,
          label: 'Conversations',
          value: '${stats.totalConversations}',
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: RemixIcons.mail_unread_line,
          iconColor: stats.unreadConversations > 0
              ? AppColors.warning
              : AppColors.success,
          label: 'Unread Chats',
          value: '${stats.unreadConversations}',
          highlight: stats.unreadConversations > 0,
        ),
        const SizedBox(width: 12),
        _StatCard(
          icon: RemixIcons.message_3_line,
          iconColor: AppColors.igColor,
          label: "Today's Messages",
          value: '${stats.totalMessagesToday}',
        ),
        const Spacer(),
        // Real-time indicator pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Live Instagram Sync',
                style: AppTextStyles.t(12, w: FontWeight.w600, c: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? iconColor.withValues(alpha: 0.5) : AppColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.t(12, c: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AppTextStyles.t(13.5, w: FontWeight.w700, c: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Filter Tab Chip
// ---------------------------------------------------------
class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.active,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.t(
                12,
                w: active ? FontWeight.w600 : FontWeight.w500,
                c: active ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.t(
                    10,
                    w: FontWeight.w800,
                    c: AppColors.onPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Conversation Tile (List item)
// ---------------------------------------------------------
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.active,
    required this.onTap,
    required this.onTogglePin,
    required this.onToggleArchive,
  });

  final InboxConversationModel conversation;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleArchive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.08) : null,
          border: Border(
            left: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
            bottom: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // Avatar with Instagram badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                _ContactAvatar(
                  name: conversation.contactName,
                  profilePic: conversation.profilePic,
                  size: 42,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      RemixIcons.instagram_fill,
                      size: 10,
                      color: AppColors.igColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 11),

            // Middle info: name, handle, snippet
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (conversation.isPinned) ...[
                        const Icon(
                          RemixIcons.pushpin_fill,
                          size: 11,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          conversation.contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.t(
                            13.5,
                            w: conversation.hasUnreadMessages
                                ? FontWeight.w700
                                : FontWeight.w600,
                            c: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: AppTextStyles.t(
                            11,
                            c: conversation.hasUnreadMessages
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.t(
                            12,
                            c: conversation.hasUnreadMessages
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                            w: conversation.hasUnreadMessages
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: AppTextStyles.t(
                              10,
                              w: FontWeight.w800,
                              c: AppColors.onPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final now = DateTime.now();

    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
      final minute = local.minute.toString().padLeft(2, '0');
      final period = local.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }

    return '${local.day}/${local.month}';
  }
}

// ---------------------------------------------------------
// Active Message Thread Panel (Center)
// ---------------------------------------------------------
class _MessagePanel extends StatefulWidget {
  const _MessagePanel({
    super.key,
    required this.conversation,
    required this.controller,
  });

  final InboxConversationModel conversation;
  final InboxController controller;

  @override
  State<_MessagePanel> createState() => _MessagePanelState();
}

class _MessagePanelState extends State<_MessagePanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    widget.controller.sendMessage(
      contactId: widget.conversation.id,
      text: text,
    );

    _textController.clear();
    _isTyping = false;
    widget.controller.sendAction(widget.conversation.id, 'typing_off');
  }

  void _onTextChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    if (hasText && !_isTyping) {
      _isTyping = true;
      widget.controller.sendAction(widget.conversation.id, 'typing_on');
    } else if (!hasText && _isTyping) {
      _isTyping = false;
      widget.controller.sendAction(widget.conversation.id, 'typing_off');
    }
  }

  void _pickAndUploadMedia({String? type}) {
    final uploadInput = html.FileUploadInputElement();
    if (type == 'audio') {
      uploadInput.accept = 'audio/*';
    } else if (type == 'image') {
      uploadInput.accept = 'image/*';
    } else if (type == 'video') {
      uploadInput.accept = 'video/*';
    } else {
      uploadInput.accept = 'image/*,video/*,audio/*';
    }
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          final result = reader.result as String?;
          if (result != null && result.isNotEmpty) {
            final mime = file.type.isNotEmpty ? file.type : 'application/octet-stream';
            widget.controller.uploadAndSendMedia(
              contactId: widget.conversation.id,
              fileBase64: result,
              filename: file.name,
              mimeType: mime,
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = widget.conversation;
    final messages = widget.controller.currentMessages;

    return Column(
      children: [
        // Thread header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Row(
            children: [
              _ContactAvatar(
                name: conversation.contactName,
                profilePic: conversation.profilePic,
                size: 38,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            conversation.contactName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.t(14.5, w: FontWeight.w700),
                          ),
                        ),
                        if (conversation.username != null &&
                            conversation.username!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              final url =
                                  'https://instagram.com/${conversation.username}';
                              html.window.open(url, '_blank');
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  conversation.handle,
                                  style: AppTextStyles.t(
                                    12,
                                    c: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(
                                  RemixIcons.external_link_line,
                                  size: 11,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          RemixIcons.instagram_line,
                          size: 12,
                          color: AppColors.igColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          conversation.channelUsername != null
                              ? 'Via @${conversation.channelUsername}'
                              : 'Instagram Direct',
                          style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 24-hr Response window pill
              if (conversation.responseWindowExpiresAt != null)
                StudioPill(
                  _responseWindowLabel(conversation),
                  color: conversation.isUrgent
                      ? AppColors.warning
                      : conversation.isResponseWindowExpired
                      ? AppColors.textMuted
                      : AppColors.success,
                  icon: RemixIcons.time_line,
                ),

              const SizedBox(width: 8),

              // Pin toggle button
              IconButton(
                icon: Icon(
                  conversation.isPinned
                      ? RemixIcons.pushpin_fill
                      : RemixIcons.pushpin_line,
                  size: 18,
                  color: conversation.isPinned
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                tooltip: conversation.isPinned ? 'Unpin' : 'Pin conversation',
                onPressed: () =>
                    widget.controller.togglePin(conversation.id),
              ),

              // Archive toggle button
              IconButton(
                icon: Icon(
                  conversation.isArchived
                      ? RemixIcons.inbox_unarchive_line
                      : RemixIcons.inbox_archive_line,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                tooltip: conversation.isArchived ? 'Unarchive' : 'Archive',
                onPressed: () =>
                    widget.controller.toggleArchive(conversation.id),
              ),

              // Refresh thread button
              IconButton(
                icon: const Icon(
                  RemixIcons.refresh_line,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Refresh messages',
                onPressed: () =>
                    widget.controller.loadMessages(conversation.id),
              ),
            ],
          ),
        ),

        Container(height: 1, color: AppColors.border),

        // Message bubbles list
        Expanded(
          child: widget.controller.isLoadingMessages && messages.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        RemixIcons.chat_voice_line,
                        size: 36,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No messages yet',
                        style: AppTextStyles.t(14, w: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Send an Instagram DM below to start the conversation.',
                        style: AppTextStyles.t(12, c: AppColors.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages.reversed.toList()[index];
                    return _MessageBubble(
                      message: message,
                      onReply: () =>
                          widget.controller.setReplyingTo(message),
                    );
                  },
                ),
        ),

        // Quoted reply banner if active
        if (widget.controller.replyingToMessage != null)
          _ReplyingToBanner(
            message: widget.controller.replyingToMessage!,
            onCancel: () => widget.controller.setReplyingTo(null),
          ),

        // Uploading indicator if in progress
        if (widget.controller.isUploading)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceVariant,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Uploading media attachment...',
                  style: AppTextStyles.t(12, c: AppColors.textSecondary),
                ),
              ],
            ),
          ),

        // Composer bar
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Media attachment button
              PopupMenuButton<String>(
                icon: const Icon(
                  RemixIcons.attachment_2,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                tooltip: 'Attach media',
                color: AppColors.surface,
                onSelected: (val) => _pickAndUploadMedia(type: val),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'image',
                    child: Row(
                      children: [
                        Icon(RemixIcons.image_line, size: 18, color: AppColors.primary),
                        SizedBox(width: 10),
                        Text('Send Photo / Image'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'video',
                    child: Row(
                      children: [
                        Icon(RemixIcons.video_line, size: 18, color: AppColors.secondary),
                        SizedBox(width: 10),
                        Text('Send Video Clip'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'audio',
                    child: Row(
                      children: [
                        Icon(RemixIcons.mic_line, size: 18, color: AppColors.warning),
                        SizedBox(width: 10),
                        Text('Send Voice Note / Audio'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 6),

              // Text input field
              Expanded(
                child: TextField(
                  controller: _textController,
                  onChanged: _onTextChanged,
                  maxLines: 4,
                  minLines: 1,
                  style: AppTextStyles.t(13.5),
                  cursorColor: AppColors.primary,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: AppInputDecorations.dec(
                    'Write an Instagram reply... (Enter to send)',
                  ).copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Send button
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: widget.controller.isSending ? null : _sendMessage,
                icon: widget.controller.isSending
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : const Icon(RemixIcons.send_plane_2_fill, size: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _responseWindowLabel(InboxConversationModel conversation) {
    final expiry = conversation.responseWindowExpiresAt;
    if (expiry == null) return '24h Window';
    final remaining = expiry.difference(DateTime.now());

    if (remaining.isNegative) {
      return 'Window expired';
    }
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    }
    return '${remaining.inMinutes}m left';
  }
}

// ---------------------------------------------------------
// Quoted Reply Banner
// ---------------------------------------------------------
class _ReplyingToBanner extends StatelessWidget {
  const _ReplyingToBanner({
    required this.message,
    required this.onCancel,
  });

  final InboxMessageModel message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          top: BorderSide(color: AppColors.border),
          left: BorderSide(color: AppColors.primary, width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.reply_line,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${message.isInbound ? "Customer" : "You"}',
                  style: AppTextStyles.t(
                    11.5,
                    w: FontWeight.w600,
                    c: AppColors.primary,
                  ),
                ),
                Text(
                  message.displayText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.t(12, c: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(RemixIcons.close_line, size: 16),
            color: AppColors.textMuted,
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Message Bubble Widget
// ---------------------------------------------------------
class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onReply,
  });

  final InboxMessageModel message;
  final VoidCallback onReply;

  @override
  Widget build(BuildContext context) {
    final mine = message.isOutbound;
    final bot = message.sender == InboxMessageSender.automation;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mine)
            IconButton(
              icon: const Icon(RemixIcons.reply_line, size: 14),
              color: AppColors.textMuted.withValues(alpha: 0.5),
              tooltip: 'Quote reply',
              onPressed: onReply,
            ),

          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 480),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                gradient: mine && !bot ? AppColors.darkGradient : null,
                color: bot
                    ? AppColors.paletteCyberNavy
                    : mine
                    ? null
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(mine ? 16 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 16),
                ),
                border: bot ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bot badge
                  if (bot)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            RemixIcons.robot_2_line,
                            size: 13,
                            color: AppColors.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Automation Bot',
                            style: AppTextStyles.t(
                              11,
                              w: FontWeight.w700,
                              c: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Quoted preview if message has replyToMetaMessageId
                  if (message.replyToMetaMessageId != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: const Border(
                          left: BorderSide(color: AppColors.primary, width: 2),
                        ),
                      ),
                      child: Text(
                        'Quoted message',
                        style: AppTextStyles.t(11, c: Colors.white70),
                      ),
                    ),

                  // Media content renderer
                  if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
                    _MediaRenderer(message: message),

                  // Text content
                  if (message.text != null && message.text!.isNotEmpty)
                    SelectableText(
                      message.text!,
                      style: AppTextStyles.t(
                        13.5,
                        c: mine && !bot ? Colors.white : AppColors.textPrimary,
                        h: 1.4,
                      ),
                    ),

                  // Quick replies pills if inbound or outbound
                  if (message.rawPayload?['quickReplies'] is List)
                    _QuickRepliesPills(
                      items: message.rawPayload!['quickReplies'] as List,
                    ),

                  const SizedBox(height: 4),

                  // Timestamp & Delivery status checkmarks
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _formatTime(message.sentAt),
                        style: AppTextStyles.t(
                          10.5,
                          c: mine && !bot
                              ? Colors.white.withValues(alpha: 0.75)
                              : AppColors.textMuted,
                        ),
                      ),
                      if (mine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead
                              ? RemixIcons.check_double_line
                              : RemixIcons.check_line,
                          size: 13,
                          color: message.isRead
                              ? AppColors.onPrimary
                              : Colors.white70,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          if (!mine)
            IconButton(
              icon: const Icon(RemixIcons.reply_line, size: 14),
              color: AppColors.textMuted.withValues(alpha: 0.5),
              tooltip: 'Quote reply',
              onPressed: onReply,
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

// ---------------------------------------------------------
// Media Renderer for Images, Videos, Voice notes
// ---------------------------------------------------------
class _MediaRenderer extends StatelessWidget {
  const _MediaRenderer({required this.message});

  final InboxMessageModel message;

  @override
  Widget build(BuildContext context) {
    final url = message.mediaUrl!;

    // Image
    if (message.isImage) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: const BoxConstraints(maxHeight: 280),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    height: 180,
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => _mediaFallback(
                  RemixIcons.image_line,
                  'Photo attachment',
                  url,
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: InkWell(
                  onTap: () => html.window.open(url, '_blank'),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      RemixIcons.fullscreen_line,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Video
    if (message.isVideo) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                RemixIcons.play_fill,
                size: 18,
                color: AppColors.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Video Attachment',
                    style: AppTextStyles.t(13, w: FontWeight.w600),
                  ),
                  Text(
                    'Click to play in player',
                    style: AppTextStyles.t(11, c: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(RemixIcons.external_link_line, size: 16),
              color: AppColors.primary,
              onPressed: () => html.window.open(url, '_blank'),
            ),
          ],
        ),
      );
    }

    // Audio / Voice note
    if (message.isAudio) {
      return _AudioMessagePlayer(url: url);
    }

    // Fallback file attachment
    return _mediaFallback(RemixIcons.file_line, 'Attachment', url);
  }

  Widget _mediaFallback(IconData icon, String title, String url) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: AppTextStyles.t(12.5, w: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: const Icon(RemixIcons.download_line, size: 16),
            color: AppColors.primary,
            onPressed: () => html.window.open(url, '_blank'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Inline Audio Voice Note Player for Flutter Web
// ---------------------------------------------------------
class _AudioMessagePlayer extends StatefulWidget {
  const _AudioMessagePlayer({required this.url});

  final String url;

  @override
  State<_AudioMessagePlayer> createState() => _AudioMessagePlayerState();
}

class _AudioMessagePlayerState extends State<_AudioMessagePlayer> {
  html.AudioElement? _audio;
  bool _isPlaying = false;

  @override
  void dispose() {
    _audio?.pause();
    super.dispose();
  }

  void _togglePlay() {
    if (_audio == null) {
      _audio = html.AudioElement(widget.url);
      _audio!.onEnded.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
      _audio!.onError.listen((_) {
        if (mounted) setState(() => _isPlaying = false);
      });
    }

    if (_isPlaying) {
      _audio?.pause();
      setState(() => _isPlaying = false);
    } else {
      _audio?.play();
      setState(() => _isPlaying = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              padding: const EdgeInsets.all(8),
            ),
            icon: Icon(
              _isPlaying ? RemixIcons.pause_fill : RemixIcons.play_fill,
              size: 16,
            ),
            onPressed: _togglePlay,
          ),
          const SizedBox(width: 10),
          const Icon(
            RemixIcons.voiceprint_line,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Voice Note',
            style: AppTextStyles.t(12.5, w: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(RemixIcons.external_link_line, size: 14),
            color: AppColors.textMuted,
            onPressed: () => html.window.open(widget.url, '_blank'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Quick Replies Pills
// ---------------------------------------------------------
class _QuickRepliesPills extends StatelessWidget {
  const _QuickRepliesPills({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: items.map((item) {
          final title = item is Map ? item['title']?.toString() ?? '' : item.toString();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary),
            ),
            child: Text(
              title,
              style: AppTextStyles.t(11.5, w: FontWeight.w600, c: AppColors.primary),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------
// Contact Details Sidebar (Right Pane)
// ---------------------------------------------------------
class _ContactDetailsSidebar extends StatefulWidget {
  const _ContactDetailsSidebar({
    super.key,
    required this.conversation,
    required this.controller,
  });

  final InboxConversationModel conversation;
  final InboxController controller;

  @override
  State<_ContactDetailsSidebar> createState() => _ContactDetailsSidebarState();
}

class _ContactDetailsSidebarState extends State<_ContactDetailsSidebar> {
  late TextEditingController _notesController;
  final TextEditingController _tagInputController = TextEditingController();
  bool _isSavingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.conversation.notes ?? '');
  }

  @override
  void didUpdateWidget(covariant _ContactDetailsSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation.id != widget.conversation.id ||
        oldWidget.conversation.notes != widget.conversation.notes) {
      _notesController.text = widget.conversation.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Future<void> _saveNotes() async {
    setState(() => _isSavingNotes = true);
    await widget.controller.updateNotes(
      widget.conversation.id,
      _notesController.text.trim(),
    );
    if (mounted) {
      setState(() => _isSavingNotes = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Staff notes saved successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.dialog,
        title: Text(
          'Add CRM Tag',
          style: AppTextStyles.t(16, w: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tagInputController,
              autofocus: true,
              style: AppTextStyles.t(14),
              decoration: AppInputDecorations.dec('Tag name (e.g. VIP, Lead, Sale)'),
            ),
            const SizedBox(height: 12),
            Text(
              'Quick suggestions:',
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: ['VIP', 'Lead', 'Customer', 'Follow-up', 'Closed']
                  .map(
                    (tag) => ActionChip(
                      label: Text(tag, style: AppTextStyles.t(11)),
                      backgroundColor: AppColors.surfaceVariant,
                      onPressed: () {
                        widget.controller.addTag(widget.conversation.id, tag);
                        Navigator.of(dialogCtx).pop();
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
            ),
            onPressed: () {
              final newTag = _tagInputController.text.trim();
              if (newTag.isNotEmpty) {
                widget.controller.addTag(widget.conversation.id, newTag);
                _tagInputController.clear();
              }
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Add Tag'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conv = widget.conversation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Center(
            child: _ContactAvatar(
              name: conv.contactName,
              profilePic: conv.profilePic,
              size: 68,
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              conv.contactName,
              textAlign: TextAlign.center,
              style: AppTextStyles.t(15.5, w: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: Text(
              conv.handle,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
          ),

          const SizedBox(height: 12),

          // External Instagram link button
          if (conv.username != null && conv.username!.isNotEmpty)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.igColor),
                  foregroundColor: AppColors.igColor,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final url = 'https://instagram.com/${conv.username}';
                  html.window.open(url, '_blank');
                },
                icon: const Icon(RemixIcons.instagram_line, size: 16),
                label: const Text('View Instagram Profile'),
              ),
            ),

          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Conversation Meta
          _infoRow('Channel', conv.channel),
          _infoRow('Unread DMs', '${conv.unreadCount}'),
          _infoRow('Total Messages', '${conv.messagesCount}'),
          if (conv.channelUsername != null)
            _infoRow('Target Page', '@${conv.channelUsername}'),
          if (conv.lastMessageAt != null)
            _infoRow(
              'Last Active',
              '${conv.lastMessageAt!.toLocal().day}/${conv.lastMessageAt!.toLocal().month} ${conv.lastMessageAt!.toLocal().hour}:${conv.lastMessageAt!.toLocal().minute.toString().padLeft(2, '0')}',
            ),

          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // CRM Tags Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CRM Tags',
                style: AppTextStyles.t(13, w: FontWeight.w700),
              ),
              InkWell(
                onTap: _showAddTagDialog,
                child: Row(
                  children: [
                    const Icon(
                      RemixIcons.add_line,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: AppTextStyles.t(
                        12,
                        w: FontWeight.w600,
                        c: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Tag chips
          if (conv.tags.isEmpty)
            Text(
              'No tags assigned yet. Click +Add to categorize.',
              style: AppTextStyles.t(11.5, c: AppColors.textMuted),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: conv.tags.map((tag) {
                return Chip(
                  label: Text(tag, style: AppTextStyles.t(11.5)),
                  backgroundColor: AppColors.surfaceVariant,
                  deleteIcon: const Icon(RemixIcons.close_line, size: 12),
                  onDeleted: () =>
                      widget.controller.removeTag(conv.id, tag),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.border),
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 18),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 14),

          // Internal Notes
          Text(
            'Internal Staff Notes',
            style: AppTextStyles.t(13, w: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: AppTextStyles.t(12.5),
            decoration: AppInputDecorations.dec(
              'Record customer background, preferences, follow-up dates...',
            ).copyWith(
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              onPressed: _isSavingNotes ? null : _saveNotes,
              icon: _isSavingNotes
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.onPrimary,
                      ),
                    )
                  : const Icon(RemixIcons.save_line, size: 14),
              label: const Text('Save Note'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.t(12, c: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.t(12, w: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Contact Avatar with network photo support
// ---------------------------------------------------------
class _ContactAvatar extends StatelessWidget {
  const _ContactAvatar({
    required this.name,
    this.profilePic,
    this.size = 40,
  });

  final String name;
  final String? profilePic;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (profilePic != null && profilePic!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          profilePic!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => StudioAvatar(name, size: size),
        ),
      );
    }
    return StudioAvatar(name, size: size);
  }
}
