import 'package:auren_connect/core/network/api_client.dart';
import '../data/models/inbox_conversation_model.dart';
import '../data/models/inbox_message_model.dart';
import '../data/models/inbox_stats_model.dart';

class InboxApiService {
  InboxApiService({required this.apiClient});

  final ApiClient apiClient;

  /// Retrieve real-time inbox statistics (unread counts, today's messages).
  Future<InboxStatsModel> getStats({String? channelId, String? channelType}) async {
    final queryParameters = <String, String>{};
    if (channelId != null && channelId.isNotEmpty) {
      queryParameters['channelId'] = channelId;
    }
    if (channelType != null && channelType.isNotEmpty && channelType != 'All') {
      queryParameters['channelType'] = channelType.toUpperCase();
    }

    final endpoint = Uri(
      path: '/inbox/stats',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();

    final response = await apiClient.get(endpoint, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch inbox stats',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return InboxStatsModel.fromJson(data);
  }

  /// List conversations (Instagram & WhatsApp contacts) with channel, search, status, and tag filters.
  Future<List<InboxConversationModel>> getConversations({
    String? channelType,
    String? channelId,
    String? status,
    String? search,
    String? tag,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParameters = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (channelType != null && channelType.isNotEmpty && channelType != 'All') {
      queryParameters['channelType'] = channelType.toUpperCase();
    }
    if (channelId != null && channelId.isNotEmpty) {
      queryParameters['channelId'] = channelId;
    }
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParameters['status'] = status;
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }
    if (tag != null && tag.trim().isNotEmpty) {
      queryParameters['tag'] = tag.trim();
    }

    final endpoint = Uri(
      path: '/inbox/conversations',
      queryParameters: queryParameters,
    ).toString();

    final response = await apiClient.get(endpoint, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to fetch conversations',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final rawConversations = data['conversations'] as List<dynamic>? ?? [];

    return rawConversations
        .map(
          (e) => InboxConversationModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Get conversation profile details, tags, and CRM notes.
  Future<InboxConversationModel> getConversation(String contactId) async {
    final response = await apiClient.get(
      '/inbox/conversations/$contactId',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to fetch conversation details',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final conversationMap =
        data['conversation'] as Map<String, dynamic>? ?? data;

    return InboxConversationModel.fromJson(conversationMap);
  }

  /// Update conversation flags (archive, pin, CRM tags, notes).
  Future<InboxConversationModel> updateConversation(
    String contactId, {
    bool? isArchived,
    bool? isPinned,
    List<String>? tags,
    String? notes,
  }) async {
    final body = <String, dynamic>{};
    if (isArchived != null) body['isArchived'] = isArchived;
    if (isPinned != null) body['isPinned'] = isPinned;
    if (tags != null) body['tags'] = tags;
    if (notes != null) body['notes'] = notes;

    final response = await apiClient.patch(
      '/inbox/conversations/$contactId',
      body: body,
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to update conversation',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final conversationMap =
        data['conversation'] as Map<String, dynamic>? ?? data;

    return InboxConversationModel.fromJson(conversationMap);
  }

  /// Paginated message history (text, voice, image, video).
  Future<List<InboxMessageModel>> getMessages(
    String contactId, {
    int limit = 50,
    String? before,
  }) async {
    final queryParameters = <String, String>{'limit': limit.toString()};
    if (before != null && before.isNotEmpty) {
      queryParameters['before'] = before;
    }

    final endpoint = Uri(
      path: '/inbox/conversations/$contactId/messages',
      queryParameters: queryParameters,
    ).toString();

    final response = await apiClient.get(endpoint, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch messages',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final rawMessages = data['messages'] as List<dynamic>? ?? [];

    return rawMessages
        .map(
          (e) => InboxMessageModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Send live Instagram DM (text, emoji, voice note, image, video, buttons).
  Future<InboxMessageModel> sendMessage(
    String contactId, {
    String? text,
    String? mediaUrl,
    String? mediaType,
    String? replyToMetaMessageId,
    List<Map<String, String>>? quickReplies,
  }) async {
    final body = <String, dynamic>{};
    if (text != null && text.trim().isNotEmpty) {
      body['text'] = text.trim();
    }
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      body['mediaUrl'] = mediaUrl;
    }
    if (mediaType != null && mediaType.isNotEmpty) {
      body['mediaType'] = mediaType;
    }
    if (replyToMetaMessageId != null && replyToMetaMessageId.isNotEmpty) {
      body['replyToMetaMessageId'] = replyToMetaMessageId;
    }
    if (quickReplies != null && quickReplies.isNotEmpty) {
      body['quickReplies'] = quickReplies;
    }

    final response = await apiClient.post(
      '/inbox/conversations/$contactId/messages',
      body: body,
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to send message',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    final messageMap = data['message'] as Map<String, dynamic>? ?? data;

    return InboxMessageModel.fromJson(messageMap);
  }

  /// Send Meta sender action (`mark_seen`, `typing_on`, `typing_off`).
  Future<bool> sendAction(String contactId, String action) async {
    final response = await apiClient.post(
      '/inbox/conversations/$contactId/action',
      body: {'action': action},
      requiresAuth: true,
    );

    return response['success'] == true;
  }

  /// Upload base64 voice note recording, photo, or video for sending in chat.
  Future<Map<String, dynamic>> uploadMedia({
    required String fileBase64,
    required String filename,
    required String mimeType,
  }) async {
    final response = await apiClient.post(
      '/inbox/upload',
      body: {
        'fileBase64': fileBase64,
        'filename': filename,
        'mimeType': mimeType,
      },
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to upload media',
      );
    }

    final data = response['data'] as Map<String, dynamic>? ?? {};
    return data;
  }
}
