enum InboxMessageSender { contact, automation, agent }

class InboxMessageModel {
  final String id;
  final String conversationId;
  final String text;
  final InboxMessageSender sender;
  final DateTime createdAt;
  final bool isRead;

  const InboxMessageModel({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.sender,
    required this.createdAt,
    this.isRead = false,
  });

  factory InboxMessageModel.fromJson(Map<String, dynamic> json) {
    return InboxMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      sender: InboxMessageSender.values.firstWhere(
        (value) => value.name == json['sender'],
        orElse: () => InboxMessageSender.contact,
      ),
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isRead: json['isRead'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'text': text,
      'sender': sender.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }
}
