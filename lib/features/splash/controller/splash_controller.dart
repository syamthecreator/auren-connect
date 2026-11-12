import 'dart:async';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../../../core/network/auth_token_manager.dart';
import '../../auth/controllers/auth_controller.dart';

enum SplashDestination { auth, dashboard, channel, popupClosed }

class SplashController extends ChangeNotifier {
  SplashController({
    required this._tokenManager,
    required this._authController,
  });

  final AuthTokenManager _tokenManager;
  final AuthController _authController;

  String _statusText = 'Initializing workspace...';

  String get statusText => _statusText;

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Updates splash loading status based on progress.
  void updateProgress(double progress) {
    final String newStatus;

    if (progress > 0.8) {
      newStatus = 'Workspace ready';
    } else if (progress > 0.4) {
      newStatus = 'Connecting Meta Cloud API...';
    } else {
      newStatus = 'Initializing workspace...';
    }

    if (_statusText == newStatus) return;

    _statusText = newStatus;
    notifyListeners();
  }

  /// Detects Instagram OAuth callback.
  bool get isOAuthReturn {
    try {
      final uri = Uri.base;
      final href = html.window.location.href;

      return uri.queryParameters['tab'] == 'channel' ||
          uri.queryParameters.containsKey('connected') ||
          uri.fragment.contains('channel') ||
          href.contains('tab=channel') ||
          href.contains('connected=true');
    } catch (e) {
      debugPrint('Splash OAuth detection error: $e');
      return false;
    }
  }

  /// Handles OAuth popup callback.
  bool handleOAuthPopup() {
    if (!isOAuthReturn) return false;

    try {
      final opener = html.window.opener;

      if (opener != null && !opener.closed!) {
        opener.postMessage('AUREN_INSTAGRAM_CONNECTED', '*');
        html.window.close();
        return true;
      }
    } catch (e) {
      debugPrint('Splash OAuth popup error: $e');
    }

    return false;
  }

  /// Validates authentication and determines the next destination.
  Future<SplashDestination> startFlow({required bool isOAuthReturn}) async {
    if (_isInitialized) {
      return SplashDestination.dashboard;
    }

    _isInitialized = true;

    try {
      final hasToken = await _tokenManager.hasAccessToken();

      // OAuth callback: directly open the Channels page.
      if (isOAuthReturn && hasToken) {
        await _initializeAuth();

        return SplashDestination.channel;
      }

      // Run authentication validation alongside the splash animation.
      await Future.delayed(const Duration(milliseconds: 2000));

      if (hasToken) {
        await _initializeAuth();
        return SplashDestination.dashboard;
      }

      return SplashDestination.auth;
    } catch (e, stackTrace) {
      debugPrint('Splash initialization error: $e');
      debugPrintStack(stackTrace: stackTrace);

      return SplashDestination.auth;
    }
  }

  Future<void> _initializeAuth() async {
    if (!_authController.isAuthenticated) {
      await _authController.initialize();
    }
  }
}
