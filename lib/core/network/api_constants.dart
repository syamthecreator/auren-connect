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

  static const String plans = '/plans';
  static const String workspaces = '/workspaces';
  static const String myWorkspaces = '$workspaces/me';
  static const String subscriptions = '/subscriptions';
  static const String checkout = '$subscriptions/checkout';
  static const String verifyPayment = '$subscriptions/verify';
  static const String currentSubscription = '$subscriptions/current';
}
