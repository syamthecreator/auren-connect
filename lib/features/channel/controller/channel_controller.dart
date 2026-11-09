import 'package:flutter/foundation.dart';
import '../data/models/instagram_channel_model.dart';
import '../service/channel_api_service.dart';

class ChannelController extends ChangeNotifier {
  ChannelController({required ChannelApiService channelApiService})
      : _apiService = channelApiService;

  final ChannelApiService _apiService;

  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isSyncing = false;
  String? _errorMessage;
  String? _successMessage;
  List<InstagramChannelModel> _instagramAccounts = [];

  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<InstagramChannelModel> get instagramAccounts => _instagramAccounts;

  bool get isInstagramConnected => _instagramAccounts.isNotEmpty;

  InstagramChannelModel? get primaryInstagramAccount =>
      _instagramAccounts.isNotEmpty ? _instagramAccounts.first : null;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  /// Load connected channels from the backend.
  Future<void> loadChannels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _instagramAccounts = await _apiService.getInstagramAccounts();
    } catch (e) {
      debugPrint('ChannelController.loadChannels error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Request the official Meta OAuth authorization URL.
  Future<String?> getInstagramAuthorizationUrl() async {
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = await _apiService.getInstagramConnectUrl();
      return url;
    } catch (e) {
      debugPrint('ChannelController.getInstagramAuthorizationUrl error: $e');
      _errorMessage = e.toString();
      return null;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  /// Disconnect a specific Instagram channel.
  Future<bool> disconnectInstagram(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.disconnectInstagramAccount(channelId);
      _instagramAccounts.removeWhere((acc) => acc.id == channelId);
      _successMessage = 'Instagram channel disconnected successfully';
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('ChannelController.disconnectInstagram error: $e');
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sync Instagram channel state with backend.
  Future<void> syncChannels() async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _instagramAccounts = await _apiService.getInstagramAccounts();
      _successMessage = 'Instagram channel synchronized successfully';
    } catch (e) {
      debugPrint('ChannelController.syncChannels error: $e');
      _errorMessage = 'Synchronization failed: $e';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}

