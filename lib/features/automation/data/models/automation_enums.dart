import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import 'package:auren_connect/app/theme/app_colors.dart';

enum AutomationStatus { draft, active, paused }

extension AutomationStatusX on AutomationStatus {
  String get label => switch (this) {
    AutomationStatus.draft => 'Draft',
    AutomationStatus.active => 'Active',
    AutomationStatus.paused => 'Paused',
  };
}

enum TriggerType { commentKeyword, dmKeyword, storyReply, storyMention }

extension TriggerTypeX on TriggerType {
  String get title => switch (this) {
    TriggerType.commentKeyword => 'Comment keyword',
    TriggerType.dmKeyword => 'DM keyword',
    TriggerType.storyReply => 'Story reply',
    TriggerType.storyMention => 'Story mention',
  };

  String get description => switch (this) {
    TriggerType.commentKeyword =>
      'Someone comments a keyword on your post or reel.',
    TriggerType.dmKeyword =>
      'Someone sends you a direct message with a keyword.',
    TriggerType.storyReply => 'Someone replies to one of your stories.',
    TriggerType.storyMention => 'Someone mentions you in their story.',
  };

  IconData get icon => switch (this) {
    TriggerType.commentKeyword => RemixIcons.chat_3_line,
    TriggerType.dmKeyword => RemixIcons.message_3_line,
    TriggerType.storyReply => RemixIcons.reply_line,
    TriggerType.storyMention => RemixIcons.at_line,
  };

  bool get usesKeywords =>
      this == TriggerType.commentKeyword || this == TriggerType.dmKeyword;
}

enum StepType { sendMessage, replyComment, quickReplies, delay, addTag }

extension StepTypeX on StepType {
  String get label => switch (this) {
    StepType.sendMessage => 'Send message',
    StepType.replyComment => 'Reply to comment',
    StepType.quickReplies => 'Ask with buttons',
    StepType.delay => 'Wait',
    StepType.addTag => 'Add tag',
  };

  IconData get icon => switch (this) {
    StepType.sendMessage => RemixIcons.send_plane_2_line,
    StepType.replyComment => RemixIcons.reply_line,
    StepType.quickReplies => RemixIcons.list_check,
    StepType.delay => RemixIcons.timer_line,
    StepType.addTag => RemixIcons.price_tag_3_line,
  };

  Color get color => switch (this) {
    StepType.sendMessage => AppColors.primary,
    StepType.replyComment => AppColors.igColor,
    StepType.quickReplies => AppColors.accent,
    StepType.delay => AppColors.warning,
    StepType.addTag => AppColors.success,
  };
}
