import 'package:flutter/foundation.dart';

import '../data/models/instagram_channel_model.dart';
import '../data/models/whatsapp_channel_model.dart';
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

  // Instagram Accounts
  List<InstagramChannelModel> _instagramAccounts = [];

  // WhatsApp Accounts (Linked Device Web QR & Pairing Code)
  List<WhatsAppChannelModel> _whatsAppAccounts = [];

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

  // Instagram Getters (100% Preserved)
  List<InstagramChannelModel> get instagramAccounts =>
      List.unmodifiable(_instagramAccounts);

  bool get isInstagramConnected => _instagramAccounts.isNotEmpty;

  InstagramChannelModel? get primaryInstagramAccount =>
      _instagramAccounts.isNotEmpty ? _instagramAccounts.first : null;

  // WhatsApp Getters
  List<WhatsAppChannelModel> get whatsAppAccounts =>
      List.unmodifiable(_whatsAppAccounts);

  bool get isWhatsAppConnected =>
      _whatsAppAccounts.any((c) => c.status == 'CONNECTED');

  WhatsAppChannelModel? get primaryWhatsAppAccount {
    final connected = _whatsAppAccounts.where((c) => c.status == 'CONNECTED');
    if (connected.isNotEmpty) return connected.first;
    return _whatsAppAccounts.isNotEmpty ? _whatsAppAccounts.first : null;
  }

  int get totalConnectedChannels =>
      _instagramAccounts.length +
      _whatsAppAccounts.where((c) => c.status == 'CONNECTED').length;

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

  // Load connected channels (both Instagram and WhatsApp)

  Future<void> loadChannels() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getInstagramAccounts().catchError((e) {
          debugPrint('ChannelController: load Instagram accounts error: $e');
          return <InstagramChannelModel>[];
        }),
        _apiService.getWhatsAppChannels().catchError((e) {
          debugPrint('ChannelController: load WhatsApp channels error: $e');
          return <WhatsAppChannelModel>[];
        }),
      ]);

      _instagramAccounts = results[0] as List<InstagramChannelModel>;
      _whatsAppAccounts = results[1] as List<WhatsAppChannelModel>;
    } catch (e) {
      debugPrint('ChannelController.loadChannels error: $e');
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  INSTAGRAM METHODS (100% UNCHANGED)
  // ════════════════════════════════════════════════════════════════════════════

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

  // ════════════════════════════════════════════════════════════════════════════
  //  WHATSAPP METHODS (LINKED DEVICE WEB QR CODE & PAIRING CODE)
  // ════════════════════════════════════════════════════════════════════════════

  /// Initialize a new WhatsApp connection session (returns QR code or Pairing code).
  Future<Map<String, dynamic>> connectWhatsApp({
    String? channelId,
    String? phoneNumber,
  }) async {
    try {
      return await _apiService.connectWhatsApp(
        channelId: channelId,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      debugPrint('ChannelController.connectWhatsApp error: $e');
      rethrow;
    }
  }

  /// Poll status for WhatsApp session.
  Future<Map<String, dynamic>> getWhatsAppStatus(String channelId) async {
    try {
      return await _apiService.getWhatsAppStatus(channelId);
    } catch (e) {
      debugPrint('ChannelController.getWhatsAppStatus error: $e');
      rethrow;
    }
  }

  /// Disconnect a WhatsApp channel.
  Future<bool> disconnectWhatsApp(String channelId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.disconnectWhatsApp(channelId);

      _whatsAppAccounts = _whatsAppAccounts
          .where((account) => account.id != channelId)
          .toList();

      _successMessage = 'WhatsApp channel disconnected successfully';
      return true;
    } catch (e) {
      debugPrint('ChannelController.disconnectWhatsApp error: $e');
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SYNC ALL CHANNELS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> syncChannels() async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getInstagramAccounts(),
        _apiService.getWhatsAppChannels(),
      ]);

      _instagramAccounts = results[0] as List<InstagramChannelModel>;
      _whatsAppAccounts = results[1] as List<WhatsAppChannelModel>;
      _successMessage = 'Channels synchronized successfully';
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
