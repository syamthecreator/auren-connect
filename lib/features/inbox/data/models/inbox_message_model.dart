enum InboxMessageSender { contact, automation, agent }

class InboxMessageModel {
  final String id;
  final String channelId;
  final String contactId;
  final String direction; // 'INBOUND' or 'OUTBOUND'
  final String messageType; // TEXT, IMAGE, VIDEO, AUDIO, VOICE, FILE, SHARE, STORY_REPLY, STORY_MENTION, QUICK_REPLY, COMMENT
  final String? text;
  final String? mediaUrl;
  final String? mediaType;
  final String status; // PENDING, SENT, DELIVERED, READ, FAILED
  final String? metaMessageId;
  final String? replyToMetaMessageId;
  final Map<String, dynamic>? rawPayload;
  final DateTime? readAt;
  final DateTime sentAt;

  const InboxMessageModel({
    required this.id,
    this.channelId = '',
    this.contactId = '',
    this.direction = 'INBOUND',
    this.messageType = 'TEXT',
    this.text,
    this.mediaUrl,
    this.mediaType,
    this.status = 'DELIVERED',
    this.metaMessageId,
    this.replyToMetaMessageId,
    this.rawPayload,
    this.readAt,
    required this.sentAt,
  });

  // Backward compatibility getters
  String get conversationId => contactId;
  DateTime get createdAt => sentAt;
  bool get isRead => status == 'READ' || readAt != null;
  bool get isOutbound => direction.toUpperCase() == 'OUTBOUND';
  bool get isInbound => direction.toUpperCase() == 'INBOUND';

  bool get isAudio =>
      messageType == 'AUDIO' ||
      messageType == 'VOICE' ||
      mediaType == 'audio' ||
      mediaType == 'voice';

  bool get isImage => messageType == 'IMAGE' || mediaType == 'image';

  bool get isVideo => messageType == 'VIDEO' || mediaType == 'video';

  bool get isStoryReply => messageType == 'STORY_REPLY';

  bool get isStoryMention => messageType == 'STORY_MENTION';

  bool get isQuickReply => messageType == 'QUICK_REPLY';

  InboxMessageSender get sender {
    if (isInbound) {
      return InboxMessageSender.contact;
    }
    final isBot = rawPayload?['isAutomation'] == true ||
        rawPayload?['triggeredBy'] == 'AUTOMATION';
    return isBot ? InboxMessageSender.automation : InboxMessageSender.agent;
  }

  String get displayText {
    if (text != null && text!.trim().isNotEmpty) {
      return text!;
    }
    if (isAudio) return '🎤 Voice note';
    if (isImage) return '📷 Photo';
    if (isVideo) return '🎥 Video';
    if (isStoryReply) return '💬 Replied to your story';
    if (isStoryMention) return '✨ Mentioned you in a story';
    return 'Message';
  }

  factory InboxMessageModel.fromJson(Map<String, dynamic> json) {
    // Handle both legacy and backend payloads
    final sentAtStr = json['sentAt']?.toString() ??
        json['createdAt']?.toString() ??
        '';
    final sentAtDate = DateTime.tryParse(sentAtStr) ?? DateTime.now();

    final directionStr = json['direction']?.toString() ??
        (json['sender'] == 'contact' ? 'INBOUND' : 'OUTBOUND');

    return InboxMessageModel(
      id: json['id']?.toString() ?? '',
      channelId: json['channelId']?.toString() ?? '',
      contactId: json['contactId']?.toString() ??
          json['conversationId']?.toString() ??
          '',
      direction: directionStr,
      messageType: (json['messageType']?.toString() ?? 'TEXT').toUpperCase(),
      text: json['text']?.toString(),
      mediaUrl: json['mediaUrl']?.toString(),
      mediaType: json['mediaType']?.toString(),
      status: json['status']?.toString() ??
          (json['isRead'] == true ? 'READ' : 'DELIVERED'),
      metaMessageId: json['metaMessageId']?.toString(),
      replyToMetaMessageId: json['replyToMetaMessageId']?.toString(),
      rawPayload: json['rawPayload'] is Map
          ? Map<String, dynamic>.from(json['rawPayload'] as Map)
          : null,
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
      sentAt: sentAtDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'channelId': channelId,
      'contactId': contactId,
      'direction': direction,
      'messageType': messageType,
      'text': text,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'status': status,
      'metaMessageId': metaMessageId,
      'replyToMetaMessageId': replyToMetaMessageId,
      'rawPayload': rawPayload,
      'readAt': readAt?.toIso8601String(),
      'sentAt': sentAt.toIso8601String(),
      // Legacy compatibility fields
      'conversationId': contactId,
      'createdAt': sentAt.toIso8601String(),
      'sender': sender.name,
      'isRead': isRead,
    };
  }

  InboxMessageModel copyWith({
    String? id,
    String? channelId,
    String? contactId,
    String? direction,
    String? messageType,
    String? text,
    String? mediaUrl,
    String? mediaType,
    String? status,
    String? metaMessageId,
    String? replyToMetaMessageId,
    Map<String, dynamic>? rawPayload,
    DateTime? readAt,
    DateTime? sentAt,
  }) {
    return InboxMessageModel(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      contactId: contactId ?? this.contactId,
      direction: direction ?? this.direction,
      messageType: messageType ?? this.messageType,
      text: text ?? this.text,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaType: mediaType ?? this.mediaType,
      status: status ?? this.status,
      metaMessageId: metaMessageId ?? this.metaMessageId,
      replyToMetaMessageId: replyToMetaMessageId ?? this.replyToMetaMessageId,
      rawPayload: rawPayload ?? this.rawPayload,
      readAt: readAt ?? this.readAt,
      sentAt: sentAt ?? this.sentAt,
    );
  }
}
