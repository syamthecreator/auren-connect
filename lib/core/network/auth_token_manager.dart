import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setString(_accessTokenKey, accessToken);
    await preferences.setString(_refreshTokenKey, refreshToken);
  }

  Future<String?> getAccessToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_refreshTokenKey);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearTokens() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_accessTokenKey);
    await preferences.remove(_refreshTokenKey);
  }
}
