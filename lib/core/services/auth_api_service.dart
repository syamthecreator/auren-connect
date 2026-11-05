import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthApiService {
  // Flutter Web running on the same computer as the backend.
  static const String baseUrl = 'http://localhost:5001/api/v1';

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      final Map<String, dynamic> responseData =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && responseData['success'] == true) {
        return responseData['data'] as Map<String, dynamic>;
      }

      throw AuthApiException(
        responseData['message']?.toString() ?? 'Login failed',
      );
    } on AuthApiException {
      rethrow;
    } catch (_) {
      throw AuthApiException(
        'Unable to connect to the server. Please try again.',
      );
    }
  }
}

class AuthApiException implements Exception {
  final String message;

  AuthApiException(this.message);

  @override
  String toString() => message;
}
