import 'inbox_message_model.dart';

class InboxConversationModel {
  final String id;
  final String channelId;
  final String instagramScopedId;
  final String? username;
  final String? name;
  final String? profilePic;
  final List<String> tags;
  final int unreadCount;
  final String? lastMessageText;
  final String? lastMessageType;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final bool isPinned;
  final String? notes;
  final String? channelUsername;
  final String? channelInstagramUserId;
  final int messagesCount;
  final List<InboxMessageModel> messages;

  const InboxConversationModel({
    required this.id,
    this.channelId = '',
    this.instagramScopedId = '',
    this.username,
    this.name,
    this.profilePic,
    this.tags = const [],
    this.unreadCount = 0,
    this.lastMessageText,
    this.lastMessageType,
    this.lastMessageAt,
    this.isArchived = false,
    this.isPinned = false,
    this.notes,
    this.channelUsername,
    this.channelInstagramUserId,
    this.messagesCount = 0,
    this.messages = const [],
  });

  // Display helpers
  String get contactName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    if (username != null && username!.trim().isNotEmpty) {
      return username!.trim();
    }
    return 'Instagram User';
  }

  String get handle {
    if (username != null && username!.trim().isNotEmpty) {
      return username!.startsWith('@') ? username! : '@$username';
    }
    return '@user';
  }

  String get channel => 'Instagram';

  String get preview {
    if (lastMessageText != null && lastMessageText!.trim().isNotEmpty) {
      return lastMessageText!;
    }
    if (messages.isNotEmpty) {
      return messages.first.displayText;
    }
    if (lastMessageType != null) {
      switch (lastMessageType!.toUpperCase()) {
        case 'IMAGE':
          return '📷 Photo';
        case 'VIDEO':
          return '🎥 Video';
        case 'AUDIO':
        case 'VOICE':
          return '🎤 Voice note';
        case 'STORY_REPLY':
          return '💬 Replied to your story';
        case 'STORY_MENTION':
          return '✨ Mentioned you in story';
        default:
          return lastMessageType!;
      }
    }
    return 'No messages yet';
  }

  bool get hasUnreadMessages => unreadCount > 0;

  /// Meta Graph API 24-hour standard customer service messaging window.
  DateTime? get responseWindowExpiresAt {
    if (lastMessageAt == null) return null;
    return lastMessageAt!.add(const Duration(hours: 24));
  }

  bool get isResponseWindowExpired {
    final expiry = responseWindowExpiresAt;
    if (expiry == null) return false;
    return DateTime.now().isAfter(expiry);
  }

  bool get isUrgent {
    final expiry = responseWindowExpiresAt;
    if (expiry == null) return false;
    final remaining = expiry.difference(DateTime.now());
    return remaining.inHours < 2 && !remaining.isNegative;
  }

  factory InboxConversationModel.fromJson(Map<String, dynamic> json) {
    // Handle channel info
    String? chUsername;
    String? chIgUserId;
    if (json['channel'] is Map) {
      final ch = json['channel'] as Map;
      chUsername = ch['username']?.toString();
      chIgUserId = ch['instagramUserId']?.toString();
    }

    final rawTags = json['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((t) => t.toString()).toList();
    }

    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    final parsedMessages = rawMessages
        .whereType<Map<String, dynamic>>()
        .map(InboxMessageModel.fromJson)
        .toList();

    final countMap = json['_count'] as Map<String, dynamic>?;
    final parsedMessagesCount =
        (countMap?['messages'] as num?)?.toInt() ?? parsedMessages.length;

    return InboxConversationModel(
      id: json['id']?.toString() ?? '',
      channelId: json['channelId']?.toString() ?? '',
      instagramScopedId: json['instagramScopedId']?.toString() ?? '',
      username: json['username']?.toString() ?? json['handle']?.toString(),
      name: json['name']?.toString() ?? json['contactName']?.toString(),
      profilePic: json['profilePic']?.toString(),
      tags: parsedTags,
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      lastMessageText: json['lastMessageText']?.toString() ?? json['preview']?.toString(),
      lastMessageType: json['lastMessageType']?.toString(),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      isArchived: json['isArchived'] == true,
      isPinned: json['isPinned'] == true,
      notes: json['notes']?.toString(),
      channelUsername: chUsername,
      channelInstagramUserId: chIgUserId,
      messagesCount: parsedMessagesCount,
      messages: parsedMessages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'instagramScopedId': instagramScopedId,
      'username': username,
      'name': name,
      'profilePic': profilePic,
      'tags': tags,
      'unreadCount': unreadCount,
      'lastMessageText': lastMessageText,
      'lastMessageType': lastMessageType,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isArchived': isArchived,
      'isPinned': isPinned,
      'notes': notes,
      'channelUsername': channelUsername,
      'channelInstagramUserId': channelInstagramUserId,
      'messagesCount': messagesCount,
      'messages': messages.map((m) => m.toJson()).toList(),
      // Legacy compatibility
      'contactName': contactName,
      'handle': handle,
      'channel': channel,
    };
  }

  InboxConversationModel copyWith({
    String? id,
    String? channelId,
    String? instagramScopedId,
    String? username,
    String? name,
    String? profilePic,
    List<String>? tags,
    int? unreadCount,
    String? lastMessageText,
    String? lastMessageType,
    DateTime? lastMessageAt,
    bool? isArchived,
    bool? isPinned,
    String? notes,
    String? channelUsername,
    String? channelInstagramUserId,
    int? messagesCount,
    List<InboxMessageModel>? messages,
  }) {
    return InboxConversationModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      instagramScopedId: instagramScopedId ?? this.instagramScopedId,
      username: username ?? this.username,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      tags: tags ?? this.tags,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isArchived: isArchived ?? this.isArchived,
      isPinned: isPinned ?? this.isPinned,
      notes: notes ?? this.notes,
      channelUsername: channelUsername ?? this.channelUsername,
      channelInstagramUserId:
          channelInstagramUserId ?? this.channelInstagramUserId,
      messagesCount: messagesCount ?? this.messagesCount,
      messages: messages ?? this.messages,
    );
  }
}
