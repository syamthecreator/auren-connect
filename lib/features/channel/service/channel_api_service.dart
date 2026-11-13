import 'package:auren_connect/core/network/api_client.dart';

import '../data/models/instagram_channel_model.dart';
import '../data/models/whatsapp_channel_model.dart';

class ChannelApiService {
  ChannelApiService({required this._apiClient});

  final ApiClient _apiClient;

  // ════════════════════════════════════════════════════════════════════════════
  //  INSTAGRAM CHANNELS (100% UNCHANGED)
  // ════════════════════════════════════════════════════════════════════════════

  /// Fetch all connected Instagram channels for the authenticated user.
  Future<List<InstagramChannelModel>> getInstagramAccounts() async {
    final response = await _apiClient.get(
      '/instagram/accounts',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to fetch Instagram accounts',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawAccounts = data?['accounts'] as List<dynamic>? ?? [];

    return rawAccounts
        .map(
          (e) => InstagramChannelModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Start Instagram OAuth flow and get the authorization URL.
  Future<String> getInstagramConnectUrl() async {
    final response = await _apiClient.get(
      '/instagram/connect',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to initialize Instagram connection',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final authorizationUrl = data?['authorizationUrl'] as String?;

    if (authorizationUrl == null || authorizationUrl.isEmpty) {
      throw ApiException(
        message: 'Invalid authorization URL received from server',
      );
    }

    return authorizationUrl;
  }

  /// Disconnect a connected Instagram account.
  Future<void> disconnectInstagramAccount(String channelId) async {
    final response = await _apiClient.delete(
      '/instagram/accounts/$channelId',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to disconnect Instagram account',
      );
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  WHATSAPP CHANNELS (LINKED DEVICE WEB QR CODE & PAIRING CODE)
  // ════════════════════════════════════════════════════════════════════════════

  /// Fetch all connected or pending WhatsApp channels.
  Future<List<WhatsAppChannelModel>> getWhatsAppChannels() async {
    final response = await _apiClient.get(
      '/whatsapp/channels',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to fetch WhatsApp channels',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawChannels = data?['channels'] as List<dynamic>? ?? [];

    return rawChannels
        .map(
          (e) => WhatsAppChannelModel.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  /// Initialize WhatsApp Web QR session or pairing code session.
  Future<Map<String, dynamic>> connectWhatsApp({
    String? channelId,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (channelId != null && channelId.isNotEmpty) {
      body['channelId'] = channelId;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }

    final response = await _apiClient.post(
      '/whatsapp/connect',
      body: body,
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to initialize WhatsApp connection session',
      );
    }

    return Map<String, dynamic>.from(response['data'] as Map? ?? {});
  }

  /// Poll connection status for a WhatsApp session.
  Future<Map<String, dynamic>> getWhatsAppStatus(String channelId) async {
    final response = await _apiClient.get(
      '/whatsapp/status/$channelId',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to fetch WhatsApp status',
      );
    }

    return Map<String, dynamic>.from(response['data'] as Map? ?? {});
  }

  /// Disconnect a WhatsApp channel.
  Future<void> disconnectWhatsApp(String channelId) async {
    final response = await _apiClient.delete(
      '/whatsapp/channels/$channelId',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Failed to disconnect WhatsApp channel',
      );
    }
  }
}
