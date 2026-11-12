import 'package:flutter/foundation.dart';

import '../data/models/instagram_channel_model.dart';
import '../service/channel_api_service.dart';

class ChannelController extends ChangeNotifier {
  ChannelController({required ChannelApiService channelApiService})
    : _apiService = channelApiService;

  final ChannelApiService _apiService;

  // Channel states
  bool _isLoading = false;
  bool _isConnecting = false;
  bool _isSyncing = false;

  String? _errorMessage;

  bool _isAwaitingMeta = false;
  bool _showMoreOptions = false;
  String? _successMessage;

  List<InstagramChannelModel> _instagramAccounts = [];

  // Channel screen UI states
  int _selectedFilter = 0;
  bool _showInstagramConnectView = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isConnecting => _isConnecting;
  bool get isSyncing => _isSyncing;

  bool get isAwaitingMeta => _isAwaitingMeta;
  bool get showMoreOptions => _showMoreOptions;

  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<InstagramChannelModel> get instagramAccounts =>
      List.unmodifiable(_instagramAccounts);

  bool get isInstagramConnected => _instagramAccounts.isNotEmpty;

  InstagramChannelModel? get primaryInstagramAccount =>
      _instagramAccounts.isNotEmpty ? _instagramAccounts.first : null;

  int get selectedFilter => _selectedFilter;

  bool get showInstagramConnectView => _showInstagramConnectView;

  // UI actions

  void selectFilter(int index) {
    if (_selectedFilter == index) return;

    _selectedFilter = index;
    notifyListeners();
  }

  void openInstagramConnectView() {
    if (_showInstagramConnectView) return;

    _showInstagramConnectView = true;
    notifyListeners();
  }

  void closeInstagramConnectView() {
    if (!_showInstagramConnectView) return;

    _showInstagramConnectView = false;
    notifyListeners();
  }

  // Message handling

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Load connected channels

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

  // Instagram authorization

  Future<String?> getInstagramAuthorizationUrl() async {
    _isConnecting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _apiService.getInstagramConnectUrl();
    } catch (e) {
      debugPrint('ChannelController.getInstagramAuthorizationUrl error: $e');
      _errorMessage = e.toString();
      return null;
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  // Disconnect Instagram

  Future<bool> disconnectInstagram(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.disconnectInstagramAccount(channelId);

      _instagramAccounts = _instagramAccounts
          .where((account) => account.id != channelId)
          .toList();

      _successMessage = 'Instagram channel disconnected successfully';

      return true;
    } catch (e) {
      debugPrint('ChannelController.disconnectInstagram error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sync Instagram channels

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

  void setAwaitingMeta(bool value) {
    if (_isAwaitingMeta == value) return;

    _isAwaitingMeta = value;
    notifyListeners();
  }

  void toggleMoreOptions() {
    _showMoreOptions = !_showMoreOptions;
    notifyListeners();
  }
}
