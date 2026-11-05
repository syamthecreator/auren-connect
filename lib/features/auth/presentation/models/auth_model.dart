import 'package:flutter/foundation.dart';

enum AuthStep { signIn, forgot, otp, newPassword }

@immutable
class AuthModel {
  const AuthModel({
    this.step = AuthStep.signIn,
    this.isLoading = false,
    this.secondsLeft = 0,
    this.isAuthenticated = false,
    this.userEmail,
    this.userRole,
    this.errorMessage,
    this.successMessage,
  });

  // Default credentials for direct one-tap authentication
  static const String defaultEmail = 'aurenthecreator@gmail.com';
  static const String defaultPassword = 'auren123';

  final AuthStep step;
  final bool isLoading;
  final int secondsLeft;
  final bool isAuthenticated;
  final String? userEmail;
  final String? userRole;
  final String? errorMessage;
  final String? successMessage;

  bool get canResend => secondsLeft == 0;

  String get timeText {
    final minutes = (secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  AuthModel copyWith({
    AuthStep? step,
    bool? isLoading,
    int? secondsLeft,
    bool? isAuthenticated,
    String? userEmail,
    String? userRole,
    String? errorMessage,
    String? successMessage,
    bool clearRole = false,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthModel(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      secondsLeft: secondsLeft ?? this.secondsLeft,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userEmail: userEmail ?? this.userEmail,
      userRole: clearRole ? null : userRole ?? this.userRole,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      successMessage: clearSuccess
          ? null
          : successMessage ?? this.successMessage,
    );
  }
}
