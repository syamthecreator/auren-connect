abstract final class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://auren-backend-5weg.onrender.com/api/v1',
  );

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String refresh = '$auth/refresh';
  static const String logout = '$auth/logout';
  static const String me = '$auth/me';
}
