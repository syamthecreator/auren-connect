import 'package:auren_connect/core/network/api_client.dart';
import 'package:auren_connect/core/network/api_constants.dart';
import 'package:auren_connect/core/network/auth_token_manager.dart';

class AuthApiService {
  AuthApiService({required this._apiClient, required this._tokenManager});

  final ApiClient _apiClient;
  final AuthTokenManager _tokenManager;

  /// Login using backend credentials.
  /// Saves access and refresh tokens after successful authentication.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.login,
      body: {'email': email.trim().toLowerCase(), 'password': password},
    );

    if (response['success'] != true) {
      throw ApiException(
        message: response['message']?.toString() ?? 'Login failed',
      );
    }

    final data = Map<String, dynamic>.from(response['data'] as Map);

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;

    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      throw ApiException(
        message: 'Authentication tokens were not received from the server.',
      );
    }

    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return data;
  }

  /// Check whether an access token is stored locally.
  Future<bool> hasAccessToken() {
    return _tokenManager.hasAccessToken();
  }

  /// Check whether a valid session (access token or refresh token) exists.
  Future<bool> hasValidSession() {
    return _tokenManager.hasValidSession();
  }

  /// Retrieve the authenticated user's profile.
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(ApiConstants.me, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ??
            'Unable to retrieve user profile',
      );
    }

    final data = response['data'];

    if (data is! Map || data['user'] is! Map) {
      throw ApiException(message: 'Invalid user profile response from server.');
    }

    return Map<String, dynamic>.from(data);
  }

  /// Retrieve the saved refresh token.
  Future<String?> getRefreshToken() {
    return _tokenManager.getRefreshToken();
  }

  /// Clear locally stored authentication tokens.
  Future<void> clearLocalSession() {
    return _tokenManager.clearTokens();
  }

  /// Logout from the backend and clear the local session.
  Future<void> logout() async {
    final refreshToken = await _tokenManager.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _apiClient.post(
          ApiConstants.logout,
          body: {'refreshToken': refreshToken},
        );
      }
    } finally {
      await clearLocalSession();
    }
  }
}
