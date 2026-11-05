import 'dart:async';

import 'package:auren_connect/core/services/auth_api_service.dart';
import 'package:flutter/foundation.dart';

import '../presentation/models/auth_model.dart';

class AuthController extends ChangeNotifier {
  AuthController() : _model = const AuthModel();
  final AuthApiService _authApiService = AuthApiService();

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  AuthModel _model;
  Timer? _timer;

  AuthModel get model => _model;
  AuthStep get step => _model.step;
  bool get isLoading => _model.isLoading;
  int get secondsLeft => _model.secondsLeft;
  bool get isAuthenticated => _model.isAuthenticated;
  String? get userEmail => _model.userEmail;
  String? get userRole => _model.userRole;
  String? get errorMessage => _model.errorMessage;
  String? get successMessage => _model.successMessage;
  bool get canResend => _model.canResend;
  String get timeText => _model.timeText;

  void setStep(AuthStep step) {
    _model = _model.copyWith(step: step, clearError: true, clearSuccess: true);
    notifyListeners();
  }

  void clearMessages() {
    _model = _model.copyWith(clearError: true, clearSuccess: true);
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _model = _model.copyWith(secondsLeft: 60);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_model.secondsLeft > 1) {
        _model = _model.copyWith(secondsLeft: _model.secondsLeft - 1);
        notifyListeners();
      } else {
        _model = _model.copyWith(secondsLeft: 0);
        timer.cancel();
        notifyListeners();
      }
    });
  }

  Future<bool> signIn(String identifier, String password) async {
    _model = _model.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    try {
      final result = await _authApiService.login(
        email: identifier,
        password: password,
      );

      final user = result['user'] as Map<String, dynamic>;

      _accessToken = result['accessToken'] as String;
      _refreshToken = result['refreshToken'] as String;

      _model = _model.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: user['email'] as String,
        userRole: 'Creator',
        successMessage: 'Welcome to aurenConnect workspace!',
      );

      notifyListeners();
      return true;
    } on AuthApiException catch (error) {
      _model = _model.copyWith(isLoading: false, errorMessage: error.message);

      notifyListeners();
      return false;
    } catch (_) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );

      notifyListeners();
      return false;
    }
  }

  void signOut() {
    _accessToken = null;
    _refreshToken = null;

    _model = const AuthModel();
    notifyListeners();
  }

  Future<bool> requestOtp(String identifier) async {
    _model = _model.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final normalized = identifier.trim().toLowerCase();
    if (normalized != AuthModel.defaultEmail.toLowerCase()) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Email not found. Please use ${AuthModel.defaultEmail}.',
      );
      notifyListeners();
      return false;
    }

    _model = _model.copyWith(
      isLoading: false,
      step: AuthStep.otp,
      successMessage: 'OTP verification code sent.',
    );
    _startTimer();
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    _model = _model.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    if (otp.length < 4) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Please enter a valid 4-digit code.',
      );
      notifyListeners();
      return false;
    }

    _model = _model.copyWith(
      isLoading: false,
      step: AuthStep.newPassword,
      successMessage: 'Code verified successfully.',
    );
    notifyListeners();
    return true;
  }

  Future<bool> resetPassword(String newPassword, String confirmPassword) async {
    _model = _model.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    if (newPassword.length < 6) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Password must be at least 6 characters.',
      );
      notifyListeners();
      return false;
    }

    if (newPassword != confirmPassword) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Passwords do not match.',
      );
      notifyListeners();
      return false;
    }

    _model = _model.copyWith(
      isLoading: false,
      step: AuthStep.signIn,
      successMessage: 'Password reset successfully! Please sign in.',
    );
    notifyListeners();
    return true;
  }

  void resendOtp() {
    if (!canResend) return;
    _startTimer();
    _model = _model.copyWith(successMessage: 'New OTP sent.');
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
