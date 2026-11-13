class InboxStatsModel {
  final int totalConversations;
  final int unreadConversations;
  final int totalMessagesToday;
  final int totalUnreadMessages;

  const InboxStatsModel({
    this.totalConversations = 0,
    this.unreadConversations = 0,
    this.totalMessagesToday = 0,
    this.totalUnreadMessages = 0,
  });

  factory InboxStatsModel.fromJson(Map<String, dynamic> json) {
    return InboxStatsModel(
      totalConversations: (json['totalConversations'] as num?)?.toInt() ?? 0,
      unreadConversations: (json['unreadConversations'] as num?)?.toInt() ?? 0,
      totalMessagesToday: (json['totalMessagesToday'] as num?)?.toInt() ?? 0,
      totalUnreadMessages: (json['totalUnreadMessages'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalConversations': totalConversations,
      'unreadConversations': unreadConversations,
      'totalMessagesToday': totalMessagesToday,
      'totalUnreadMessages': totalUnreadMessages,
    };
  }
}

