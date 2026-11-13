import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_token_manager.dart';

class ApiClient {
  ApiClient({required this.tokenManager, http.Client? client})
    : _client = client ?? http.Client();

  final AuthTokenManager tokenManager;
  final http.Client _client;

  Completer<bool>? _refreshCompleter;

  Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _request('GET', endpoint, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _request('POST', endpoint, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _request('PUT', endpoint, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> patch(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) {
    return _request('PATCH', endpoint, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _request('DELETE', endpoint, requiresAuth: requiresAuth);
  }

  /// Silently refresh the access token using the stored refresh token.
  /// Uses a mutex completer to avoid multiple concurrent refresh calls.
  Future<bool> _refreshToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<bool>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await tokenManager.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(false);
        return false;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.refresh}');
      final response = await _client
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = response.body.isEmpty ? {} : jsonDecode(response.body);
        if (decoded is Map && decoded['data'] is Map) {
          final data = Map<String, dynamic>.from(decoded['data'] as Map);
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken != null &&
              newAccessToken.isNotEmpty &&
              newRefreshToken != null &&
              newRefreshToken.isNotEmpty) {
            await tokenManager.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
            );
            completer.complete(true);
            return true;
          }
        }
      }

      // Clear tokens only if server explicitly rejected the refresh token
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        await tokenManager.clearTokens();
      }
      completer.complete(false);
      return false;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _refreshCompleter = null;
    }
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
    bool isRetry = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        // If a refresh is in progress, wait for it before reading tokens
        if (_refreshCompleter != null) {
          await _refreshCompleter!.future;
        }

        var token = await tokenManager.getAccessToken();

        // If access token is absent but refresh token exists, attempt refresh first
        if ((token == null || token.isEmpty) && !isRetry) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            token = await tokenManager.getAccessToken();
          }
        }

        if (token == null || token.isEmpty) {
          throw ApiException(
            message: 'Authentication required',
            statusCode: 401,
          );
        }

        headers['Authorization'] = 'Bearer $token';
      }

      final encodedBody = body == null ? null : jsonEncode(body);

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
          break;

        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.receiveTimeout);
          break;

        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.receiveTimeout);
          break;

        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.receiveTimeout);
          break;

        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
          break;

        default:
          throw ApiException(message: 'Unsupported HTTP method: $method');
      }

      // Intercept 401 Unauthorized on authenticated requests to transparently refresh
      if (response.statusCode == 401 &&
          requiresAuth &&
          !isRetry &&
          endpoint != ApiConstants.refresh &&
          endpoint != ApiConstants.login &&
          endpoint != ApiConstants.register) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request with the refreshed token
          return await _request(
            method,
            endpoint,
            body: body,
            requiresAuth: requiresAuth,
            isRetry: true,
          );
        }
      }

      final responseBody = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      if (responseBody is! Map) {
        throw ApiException(
          message: 'Invalid server response',
          statusCode: response.statusCode,
        );
      }

      final data = Map<String, dynamic>.from(responseBody);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      throw ApiException(
        message: data['message']?.toString() ?? 'Something went wrong',
        statusCode: response.statusCode,
        errors: data['errors'],
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw ApiException(message: 'Request timed out. Please try again.');
    } on FormatException {
      throw ApiException(message: 'Invalid response received from server.');
    } catch (_) {
      throw ApiException(message: 'Unable to connect to the server.');
    }
  }

  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  ApiException({required this.message, this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final dynamic errors;

  @override
  String toString() => message;
}
