import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/utils/helper.dart';
import 'package:auren_connect/core/widgets/studio_avatar.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

import '../../controller/inbox_controller.dart';
import '../../data/models/inbox_conversation_model.dart';
import '../../data/models/inbox_message_model.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<InboxController>();

    final screenHeight = MediaQuery.sizeOf(context).height;
    final containerHeight = (screenHeight - 150).clamp(500.0, 900.0);

    return StudioPage(
      children: [
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
    if (controller.isLoading && controller.conversations.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage != null && controller.conversations.isEmpty) {
      return _buildErrorState(controller);
    }

    final conversations = controller.filteredConversations;

    if (conversations.isEmpty) {
      return _buildEmptyState(controller);
    }

    final conversation = controller.selectedConversation;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final listWidth = width < 900 ? 250.0 : 330.0;
        final showInfo = width > 1150;

        return Row(
          children: [
            // Conversation list
            SizedBox(
              width: listWidth,
              child: _buildConversationList(context, controller, conversations),
            ),

            Container(width: 1, color: AppColors.border),

            // Message panel
            Expanded(
              child: conversation == null
                  ? _buildSelectConversationState()
                  : _buildMessagePanel(context, conversation),
            ),

            // Contact information
            if (showInfo && conversation != null) ...[
              Container(width: 1, color: AppColors.border),
              SizedBox(width: 280, child: _ContactInfo(conversation)),
            ],
          ],
        );
      },
    );
  }

  // Conversation list
  Widget _buildConversationList(
    BuildContext context,
    InboxController controller,
    List<InboxConversationModel> conversations,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: controller.updateSearch,
                style: AppTextStyles.t(14),
                cursorColor: AppColors.primary,
                decoration: AppInputDecorations.dec(
                  'Search conversations',
                  icon: RemixIcons.search_line,
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: StudioChips(
                  options: const ['All', 'WhatsApp', 'Instagram'],
                  selected: [
                    'All',
                    'WhatsApp',
                    'Instagram',
                  ].indexOf(controller.selectedChannel),
                  onChanged: (index) {
                    const channels = ['All', 'WhatsApp', 'Instagram'];

                    controller.selectChannel(channels[index]);
                  },
                ),
              ),
            ],
          ),
        ),

        Container(height: 1, color: AppColors.border),

        Expanded(
          child: ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];

              final active =
                  conversation.id == controller.selectedConversationId;

              return _ConversationTile(
                conversation: conversation,
                active: active,
                onTap: () {
                  controller.selectConversation(conversation.id);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // Message panel
  Widget _buildMessagePanel(
    BuildContext context,
    InboxConversationModel conversation,
  ) {
    final channel = Helper.getChannel(conversation.channel);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              StudioAvatar(conversation.contactName, size: 40),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.t(15, w: FontWeight.w700),
                    ),

                    Row(
                      children: [
                        Icon(channel.icon, size: 13, color: channel.color),

                        const SizedBox(width: 5),

                        Flexible(
                          child: Text(
                            '${conversation.channel} · ${conversation.handle}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.t(12, c: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

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

              const SizedBox(width: 12),

              const Icon(
                RemixIcons.more_2_fill,
                size: 20,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),

        Container(height: 1, color: AppColors.border),

        // Messages
        Expanded(
          child: conversation.messages.isEmpty
              ? const Center(child: Text('No messages in this conversation'))
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: conversation.messages.length,
                  itemBuilder: (context, index) {
                    final message = conversation.messages.reversed
                        .toList()[index];

                    return _InboxMessageBubble(message);
                  },
                ),
        ),

        // Composer placeholder until the real messaging API is connected.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  enabled: false,
                  style: AppTextStyles.t(14),
                  decoration: AppInputDecorations.dec(
                    'Messaging API not connected',
                  ),
                ),
              ),

              const SizedBox(width: 12),

              IconButton(
                onPressed: null,
                icon: const Icon(RemixIcons.send_plane_2_line),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(InboxController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(RemixIcons.chat_3_line, size: 42, color: AppColors.textMuted),

            const SizedBox(height: 16),

            Text(
              'No conversations found',
              style: AppTextStyles.t(17, w: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              controller.searchQuery.isNotEmpty ||
                      controller.selectedChannel != 'All'
                  ? 'Try changing your search or channel filter.'
                  : 'Your conversations will appear here when messages are received.',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(13, c: AppColors.textMuted),
            ),

            if (controller.searchQuery.isNotEmpty ||
                controller.selectedChannel != 'All') ...[
              const SizedBox(height: 16),

              TextButton(
                onPressed: controller.resetFilters,
                child: const Text('Clear filters'),
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
              color: Colors.redAccent,
            ),

            const SizedBox(height: 12),

            Text(
              'Unable to load conversations',
              style: AppTextStyles.t(16, w: FontWeight.w700),
            ),

            const SizedBox(height: 8),

            Text(
              controller.errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: controller.clearError,
              child: const Text('Dismiss'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectConversationState() {
    return const Center(child: Text('Select a conversation'));
  }

  String _responseWindowLabel(InboxConversationModel conversation) {
    final expiry = conversation.responseWindowExpiresAt;

    if (expiry == null) return 'Window unavailable';

    final remaining = expiry.difference(DateTime.now());

    if (remaining.isNegative) {
      return 'Window expired';
    }

    if (remaining.inDays > 0) {
      return '${remaining.inDays}d ${remaining.inHours % 24}h left';
    }

    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m left';
    }

    return '${remaining.inMinutes}m left';
  }
}

// Conversation tile
class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.active,
    required this.onTap,
  });

  final InboxConversationModel conversation;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final channel = Helper.getChannel(conversation.channel);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: .08) : null,
          border: Border(
            left: BorderSide(
              color: active ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                StudioAvatar(conversation.contactName, size: 42),

                Positioned(
                  right: -3,
                  bottom: -3,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(channel.icon, size: 11, color: channel.color),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.contactName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.t(14, w: FontWeight.w600),
                        ),
                      ),

                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.t(
                            12.5,
                            c: conversation.hasUnreadMessages
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),

                      if (conversation.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: AppTextStyles.t(
                              10.5,
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

    return '${local.day}/${local.month}/${local.year}';
  }
}

// Message bubble
class _InboxMessageBubble extends StatelessWidget {
  const _InboxMessageBubble(this.message);

  final InboxMessageModel message;

  @override
  Widget build(BuildContext context) {
    final mine = message.sender != InboxMessageSender.contact;
    final bot = message.sender == InboxMessageSender.automation;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(vertical: 5),
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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (bot)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      RemixIcons.robot_2_line,
                      size: 12,
                      color: AppColors.accent,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      'Automation',
                      style: AppTextStyles.t(
                        11,
                        w: FontWeight.w600,
                        c: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              message.text,
              style: AppTextStyles.t(
                14,
                c: mine && !bot ? Colors.white : AppColors.textPrimary,
                h: 1.4,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              _formatMessageTime(message.createdAt),
              style: AppTextStyles.t(
                10.5,
                c: mine && !bot ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}

// Contact information
class _ContactInfo extends StatelessWidget {
  const _ContactInfo(this.conversation);

  final InboxConversationModel conversation;

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.t(12.5, c: AppColors.textMuted),
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.t(12.5, w: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: StudioAvatar(conversation.contactName, size: 72)),

          const SizedBox(height: 12),

          Center(
            child: Text(
              conversation.contactName,
              textAlign: TextAlign.center,
              style: AppTextStyles.t(16, w: FontWeight.w700),
            ),
          ),

          const SizedBox(height: 4),

          Center(
            child: Text(
              conversation.handle,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
          ),

          const SizedBox(height: 20),

          Container(height: 1, color: AppColors.border),

          const SizedBox(height: 10),

          _infoRow('Channel', conversation.channel),

          _infoRow('Unread messages', '${conversation.unreadCount}'),

          _infoRow('Messages', '${conversation.messages.length}'),

          if (conversation.lastMessageAt != null)
            _infoRow(
              'Last message',
              conversation.lastMessageAt!.toLocal().toString(),
            ),

          if (conversation.responseWindowExpiresAt != null)
            _infoRow(
              'Response window',
              conversation.isResponseWindowExpired ? 'Expired' : 'Active',
            ),
        ],
      ),
    );
  }
}
