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

extension AutomationStatusSerialization on AutomationStatus {
  String toBackend() => switch (this) {
    AutomationStatus.active => 'ACTIVE',
    AutomationStatus.paused => 'PAUSED',
    AutomationStatus.draft => 'DRAFT',
  };

  static AutomationStatus fromBackend(String value) => switch (value.toUpperCase()) {
    'ACTIVE' => AutomationStatus.active,
    'PAUSED' => AutomationStatus.paused,
    'DRAFT' => AutomationStatus.draft,
    _ => AutomationStatus.draft,
  };
}

enum TriggerType {
  commentKeyword,
  dmKeyword,
  storyReply,
  storyMention,
  welcomeMessage,
  fallbackDefault,
}

extension TriggerTypeX on TriggerType {
  String get title => switch (this) {
    TriggerType.commentKeyword => 'Comment keyword',
    TriggerType.dmKeyword => 'DM keyword',
    TriggerType.storyReply => 'Story reply',
    TriggerType.storyMention => 'Story mention',
    TriggerType.welcomeMessage => 'Welcome message',
    TriggerType.fallbackDefault => 'Default fallback',
  };

  String get description => switch (this) {
    TriggerType.commentKeyword =>
      'Someone comments a keyword on your post or reel.',
    TriggerType.dmKeyword =>
      'Someone sends you a direct message with a keyword.',
    TriggerType.storyReply => 'Someone replies to one of your stories.',
    TriggerType.storyMention => 'Someone mentions you in their story.',
    TriggerType.welcomeMessage =>
      'Someone sends a direct message for the first time.',
    TriggerType.fallbackDefault =>
      'Runs when no other keyword automation matches.',
  };

  IconData get icon => switch (this) {
    TriggerType.commentKeyword => RemixIcons.chat_3_line,
    TriggerType.dmKeyword => RemixIcons.message_3_line,
    TriggerType.storyReply => RemixIcons.reply_line,
    TriggerType.storyMention => RemixIcons.at_line,
    TriggerType.welcomeMessage => RemixIcons.user_smile_line,
    TriggerType.fallbackDefault => RemixIcons.question_answer_line,
  };

  bool get usesKeywords =>
      this == TriggerType.commentKeyword || this == TriggerType.dmKeyword;
}

extension TriggerTypeSerialization on TriggerType {
  String toBackend() => switch (this) {
    TriggerType.commentKeyword => 'COMMENT_KEYWORD',
    TriggerType.dmKeyword => 'DM_KEYWORD',
    TriggerType.storyReply => 'STORY_REPLY',
    TriggerType.storyMention => 'STORY_MENTION',
    TriggerType.welcomeMessage => 'WELCOME_MESSAGE',
    TriggerType.fallbackDefault => 'FALLBACK_DEFAULT',
  };

  static TriggerType fromBackend(String value) => switch (value.toUpperCase()) {
    'COMMENT_KEYWORD' => TriggerType.commentKeyword,
    'DM_KEYWORD' => TriggerType.dmKeyword,
    'STORY_REPLY' => TriggerType.storyReply,
    'STORY_MENTION' => TriggerType.storyMention,
    'WELCOME_MESSAGE' => TriggerType.welcomeMessage,
    'FALLBACK_DEFAULT' => TriggerType.fallbackDefault,
    _ => TriggerType.commentKeyword,
  };
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

extension StepTypeSerialization on StepType {
  String toBackend() => switch (this) {
    StepType.sendMessage => 'SEND_DM',
    StepType.replyComment => 'REPLY_COMMENT',
    StepType.quickReplies => 'QUICK_REPLIES',
    StepType.delay => 'DELAY',
    StepType.addTag => 'ADD_TAG',
  };

  static StepType fromBackend(String value) => switch (value.toUpperCase()) {
    'SEND_DM' => StepType.sendMessage,
    'REPLY_COMMENT' => StepType.replyComment,
    'QUICK_REPLIES' => StepType.quickReplies,
    'DELAY' => StepType.delay,
    'ADD_TAG' => StepType.addTag,
    _ => StepType.sendMessage,
  };
}
