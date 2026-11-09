import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_constants.dart';
import 'auth_token_manager.dart';

class ApiClient {
  ApiClient({required this._tokenManager, http.Client? client})
    : _client = client ?? http.Client();

  final AuthTokenManager _tokenManager;
  final http.Client _client;

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

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = false,
  }) {
    return _request('DELETE', endpoint, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (requiresAuth) {
        final token = await _tokenManager.getAccessToken();

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

        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers)
              .timeout(ApiConstants.receiveTimeout);
          break;

        default:
          throw ApiException(message: 'Unsupported HTTP method: $method');
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
