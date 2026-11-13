import 'dart:async';

import 'package:auren_connect/core/network/api_client.dart';
import 'package:flutter/foundation.dart';

import 'package:auren_connect/core/services/auth_api_service.dart';

import '../presentation/models/auth_model.dart';

class AuthController extends ChangeNotifier {
  AuthController({required this._authApiService}) : _model = const AuthModel();

  final AuthApiService _authApiService;

  AuthModel _model;

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

  Future<void> initialize() async {
    try {
      final hasSession = await _authApiService.hasValidSession();

      debugPrint('AUTH INIT: Has session = $hasSession');

      if (!hasSession) {
        _model = const AuthModel();
        notifyListeners();
        return;
      }

      final response = await _authApiService.getProfile();
      final user = response['user'] as Map<String, dynamic>;

      debugPrint('AUTH INIT: Profile restored = ${user['email']}');

      _model = _model.copyWith(
        isAuthenticated: true,
        userEmail: user['email'] as String?,
        userRole: 'Creator',
        clearError: true,
        clearSuccess: true,
      );
    } on ApiException catch (error) {
      debugPrint('AUTH INIT API ERROR: ${error.message}');
      debugPrint('AUTH INIT STATUS: ${error.statusCode}');

      if (error.statusCode == 401) {
        await _authApiService.clearLocalSession();
      }

      _model = const AuthModel();
    } catch (error, stackTrace) {
      debugPrint('AUTH INIT ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
    }

    notifyListeners();
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

      _model = _model.copyWith(
        isLoading: false,
        isAuthenticated: true,
        userEmail: user['email'] as String?,
        userRole: 'Creator',
        successMessage: 'Welcome to aurenConnect workspace!',
      );

      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _model = _model.copyWith(isLoading: false, errorMessage: error.message);
    } catch (_) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }

    notifyListeners();
    return false;
  }

  Future<void> signOut() async {
    _model = _model.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      await _authApiService.logout();
    } catch (_) {
      // Local credentials are cleared even if the server is unavailable.
    }

    _model = const AuthModel();
    notifyListeners();
  }

  // Temporary UI-only OTP flow.
  // Connect to real backend endpoints when they are implemented.

  Future<bool> requestOtp(String identifier) async {
    _model = _model.copyWith(
      isLoading: true,
      clearError: true,
      clearSuccess: true,
    );
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final normalized = identifier.trim().toLowerCase();

    if (normalized.isEmpty || !normalized.contains('@')) {
      _model = _model.copyWith(
        isLoading: false,
        errorMessage: 'Please enter a valid email address.',
      );
      notifyListeners();
      return false;
    }

    _model = _model.copyWith(
      isLoading: false,
      step: AuthStep.otp,
      successMessage: 'Demo mode: OTP flow is not connected yet.',
    );

    _startTimer();
    notifyListeners();
    return true;
  }

  Future<bool> verifyOtp(String otp) async {
    _model = _model.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    if (otp.length != 4) {
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

  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();

    _model = _model.copyWith(secondsLeft: 60);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_model.secondsLeft > 1) {
        _model = _model.copyWith(secondsLeft: _model.secondsLeft - 1);
      } else {
        _model = _model.copyWith(secondsLeft: 0);
        timer.cancel();
      }

      notifyListeners();
    });
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

  // Password visibility states
  bool _hidePassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;

  bool get hidePassword => _hidePassword;
  bool get hideNewPassword => _hideNewPassword;
  bool get hideConfirmPassword => _hideConfirmPassword;

  void togglePasswordVisibility() {
    _hidePassword = !_hidePassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _hideNewPassword = !_hideNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _hideConfirmPassword = !_hideConfirmPassword;
    notifyListeners();
  }
}
