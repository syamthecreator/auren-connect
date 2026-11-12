import 'inbox_message_model.dart';

class InboxConversationModel {
  final String id;
  final String contactName;
  final String handle;
  final String channel;
  final int unreadCount;
  final DateTime? responseWindowExpiresAt;
  final DateTime? lastMessageAt;
  final List<InboxMessageModel> messages;

  const InboxConversationModel({
    required this.id,
    required this.contactName,
    required this.handle,
    required this.channel,
    this.unreadCount = 0,
    this.responseWindowExpiresAt,
    this.lastMessageAt,
    this.messages = const [],
  });

  InboxMessageModel? get latestMessage {
    if (messages.isEmpty) return null;

    return messages.reduce((a, b) => a.createdAt.isAfter(b.createdAt) ? a : b);
  }

  String get preview => latestMessage?.text ?? '';

  bool get hasUnreadMessages => unreadCount > 0;

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
    return InboxConversationModel(
      id: json['id']?.toString() ?? '',
      contactName: json['contactName']?.toString() ?? '',
      handle: json['handle']?.toString() ?? '',
      channel: json['channel']?.toString() ?? '',
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      responseWindowExpiresAt: DateTime.tryParse(
        json['responseWindowExpiresAt']?.toString() ?? '',
      ),
      lastMessageAt: DateTime.tryParse(json['lastMessageAt']?.toString() ?? ''),
      messages: (json['messages'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(InboxMessageModel.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contactName': contactName,
      'handle': handle,
      'channel': channel,
      'unreadCount': unreadCount,
      'responseWindowExpiresAt': responseWindowExpiresAt?.toIso8601String(),
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
