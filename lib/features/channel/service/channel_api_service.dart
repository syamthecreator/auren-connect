import 'package:auren_connect/core/network/api_client.dart';

import '../data/models/instagram_channel_model.dart';

class ChannelApiService {
  ChannelApiService({required this._apiClient});

  final ApiClient _apiClient;

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
}
