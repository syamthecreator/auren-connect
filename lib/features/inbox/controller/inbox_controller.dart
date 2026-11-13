import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

import '../data/models/inbox_conversation_model.dart';
import '../data/models/inbox_message_model.dart';
import '../data/models/inbox_stats_model.dart';
import '../service/inbox_api_service.dart';

class InboxController extends ChangeNotifier {
  InboxController({this.inboxApiService}) {
    _startPolling();
  }

  final InboxApiService? inboxApiService;

  List<InboxConversationModel> _conversations = [];
  final Map<String, List<InboxMessageModel>> _messagesByContact = {};

  String? _selectedConversationId;
  String _selectedChannel = 'All';
  String _statusFilter = 'all'; // 'all', 'unread', 'archived'
  String _searchQuery = '';
  String? _tagFilter;

  InboxStatsModel _stats = const InboxStatsModel();

  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  bool _isUploading = false;
  String? _errorMessage;

  InboxMessageModel? _replyingToMessage;
  Timer? _pollingTimer;

  // UI state managed by this controller.
  bool _isSavingNotes = false;
  final Map<String, html.AudioElement> _audioPlayers = {};
  final Map<String, bool> _audioPlaying = {};

  // Getters
  List<InboxConversationModel> get conversations =>
      List.unmodifiable(_conversations);

  int get instagramCount => _conversations.where((c) => c.isInstagram).length;

  int get whatsAppCount => _conversations.where((c) => c.isWhatsApp).length;

  String? get selectedConversationId => _selectedConversationId;
  String get selectedChannel => _selectedChannel;
  String get statusFilter => _statusFilter;
  String get searchQuery => _searchQuery;
  String? get tagFilter => _tagFilter;
  InboxStatsModel get stats => _stats;

  bool get isLoading => _isLoadingConversations;
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  InboxMessageModel? get replyingToMessage => _replyingToMessage;
  bool get isSavingNotes => _isSavingNotes;

  bool isAudioPlaying(String url) => _audioPlaying[url] ?? false;

  void toggleAudioPlayback(String url) {
    final player = _audioPlayers.putIfAbsent(url, () {
      final audio = html.AudioElement(url);
      audio.onEnded.listen((_) {
        _audioPlaying[url] = false;
        notifyListeners();
      });
      audio.onError.listen((_) {
        _audioPlaying[url] = false;
        notifyListeners();
      });
      return audio;
    });

    if (_audioPlaying[url] ?? false) {
      player.pause();
      _audioPlaying[url] = false;
    } else {
      player.play();
      _audioPlaying[url] = true;
    }
    notifyListeners();
  }

  Future<void> saveNotes(String contactId, String notes) async {
    _isSavingNotes = true;
    notifyListeners();
    try {
      await updateNotes(contactId, notes);
    } finally {
      _isSavingNotes = false;
      notifyListeners();
    }
  }

  InboxConversationModel? get selectedConversation {
    if (_selectedConversationId == null) return null;
    for (final conv in _conversations) {
      if (conv.id == _selectedConversationId) {
        final msgs = _messagesByContact[_selectedConversationId];
        if (msgs != null) {
          return conv.copyWith(messages: msgs);
        }
        return conv;
      }
    }
    return null;
  }

  List<InboxMessageModel> get currentMessages {
    if (_selectedConversationId == null) return const [];
    return _messagesByContact[_selectedConversationId] ??
        selectedConversation?.messages ??
        const [];
  }

  List<InboxConversationModel> get filteredConversations {
    return _conversations.where((conversation) {
      // Channel filter
      final matchesChannel =
          _selectedChannel == 'All' ||
          conversation.channel.toLowerCase() == _selectedChannel.toLowerCase();

      // Status filter
      final matchesStatus = switch (_statusFilter) {
        'unread' => conversation.unreadCount > 0,
        'archived' => conversation.isArchived,
        _ => !conversation.isArchived,
      };

      // Tag filter
      final matchesTag =
          _tagFilter == null ||
          _tagFilter!.isEmpty ||
          conversation.tags.contains(_tagFilter);

      // Search query
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          conversation.contactName.toLowerCase().contains(query) ||
          conversation.handle.toLowerCase().contains(query) ||
          conversation.preview.toLowerCase().contains(query);

      return matchesChannel && matchesStatus && matchesTag && matchesSearch;
    }).toList();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (inboxApiService != null) {
        loadConversations(silent: true);
        if (_selectedConversationId != null) {
          loadMessages(_selectedConversationId!, silent: true);
        }
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    for (final player in _audioPlayers.values) {
      player.pause();
    }
    _audioPlayers.clear();
    _audioPlaying.clear();
    super.dispose();
  }

  // Load stats
  Future<void> loadStats() async {
    final api = inboxApiService;
    if (api == null) return;
    try {
      final res = await api.getStats();
      _stats = res;
      notifyListeners();
    } catch (e) {
      debugPrint('InboxController loadStats error: $e');
    }
  }

  // Load conversations from backend
  Future<void> loadConversations({bool silent = false}) async {
    final api = inboxApiService;
    if (api == null) return;

    if (!silent) {
      _isLoadingConversations = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final list = await api.getConversations(
        status: _statusFilter,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        tag: _tagFilter,
      );

      _conversations = list;

      if (_selectedConversationId == null && filteredConversations.isNotEmpty) {
        _selectedConversationId = filteredConversations.first.id;
        loadMessages(_selectedConversationId!, silent: true);
      } else if (_selectedConversationId != null &&
          !_conversations.any((c) => c.id == _selectedConversationId)) {
        if (filteredConversations.isNotEmpty) {
          _selectedConversationId = filteredConversations.first.id;
          loadMessages(_selectedConversationId!, silent: true);
        } else {
          _selectedConversationId = null;
        }
      }

      // Ensure open/selected conversation has 0 unread in local state
      if (_selectedConversationId != null) {
        final activeIdx = _conversations.indexWhere(
          (c) => c.id == _selectedConversationId,
        );
        if (activeIdx != -1 && _conversations[activeIdx].unreadCount > 0) {
          _conversations[activeIdx] = _conversations[activeIdx].copyWith(
            unreadCount: 0,
          );
        }
      }

      _errorMessage = null;
    } catch (e) {
      if (!silent) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      debugPrint('InboxController loadConversations error: $e');
    } finally {
      if (!silent) {
        _isLoadingConversations = false;
        notifyListeners();
      }
    }
  }

  // Load message history for contact
  Future<void> loadMessages(String contactId, {bool silent = false}) async {
    final api = inboxApiService;
    if (api == null) return;

    if (!silent) {
      _isLoadingMessages = true;
      notifyListeners();
    }

    try {
      final messages = await api.getMessages(contactId);
      _messagesByContact[contactId] = messages;

      // When messages are loaded for the open thread, reset unread count and refresh stats
      final convIndex = _conversations.indexWhere((c) => c.id == contactId);
      if (convIndex != -1 && _conversations[convIndex].unreadCount > 0) {
        _conversations[convIndex] = _conversations[convIndex].copyWith(
          unreadCount: 0,
        );
        loadStats();
      }
    } catch (e) {
      debugPrint('InboxController loadMessages error: $e');
    } finally {
      if (!silent) {
        _isLoadingMessages = false;
        notifyListeners();
      } else {
        notifyListeners();
      }
    }
  }

  // Select a conversation
  void selectConversation(String conversationId) {
    _replyingToMessage = null;

    final index = _conversations.indexWhere((c) => c.id == conversationId);
    if (index != -1 && _conversations[index].unreadCount > 0) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
    }

    if (_selectedConversationId != conversationId) {
      _selectedConversationId = conversationId;
      loadMessages(conversationId);
    }

    notifyListeners();
    sendAction(conversationId, 'mark_seen');
  }

  // Send a message
  Future<bool> sendMessage({
    required String contactId,
    String? text,
    String? mediaUrl,
    String? mediaType,
    List<Map<String, String>>? quickReplies,
  }) async {
    final api = inboxApiService;
    if (api == null) return false;
    if ((text == null || text.trim().isEmpty) &&
        (mediaUrl == null || mediaUrl.isEmpty)) {
      return false;
    }

    _isSending = true;
    notifyListeners();

    final replyId = _replyingToMessage?.metaMessageId;

    try {
      final sentMessage = await api.sendMessage(
        contactId,
        text: text,
        mediaUrl: mediaUrl,
        mediaType: mediaType,
        replyToMetaMessageId: replyId,
        quickReplies: quickReplies,
      );

      final existing = _messagesByContact[contactId] ?? [];
      _messagesByContact[contactId] = [...existing, sentMessage];

      final convIndex = _conversations.indexWhere((c) => c.id == contactId);
      if (convIndex != -1) {
        final updatedConv = _conversations[convIndex].copyWith(
          lastMessageText: sentMessage.displayText,
          lastMessageType: sentMessage.messageType,
          lastMessageAt: sentMessage.sentAt,
        );
        _conversations.removeAt(convIndex);
        _conversations.insert(0, updatedConv);
      }

      _replyingToMessage = null;
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
      return false;
    }
  }

  // Upload media and send message
  Future<bool> uploadAndSendMedia({
    required String contactId,
    required String fileBase64,
    required String filename,
    required String mimeType,
    String? caption,
  }) async {
    final api = inboxApiService;
    if (api == null) return false;

    _isUploading = true;
    notifyListeners();

    try {
      final uploadRes = await api.uploadMedia(
        fileBase64: fileBase64,
        filename: filename,
        mimeType: mimeType,
      );

      final url = uploadRes['url']?.toString();
      final mediaType = uploadRes['mediaType']?.toString() ?? 'image';

      if (url == null || url.isEmpty) {
        throw Exception('Upload did not return a valid URL');
      }

      _isUploading = false;
      notifyListeners();

      return await sendMessage(
        contactId: contactId,
        mediaUrl: url,
        mediaType: mediaType,
        text: caption,
      );
    } catch (e) {
      _isUploading = false;
      _errorMessage = 'Upload failed: $e';
      notifyListeners();
      return false;
    }
  }

  // Send Meta sender action (typing_on, typing_off, mark_seen)
  Future<void> sendAction(String contactId, String action) async {
    final api = inboxApiService;
    if (api == null) return;
    try {
      await api.sendAction(contactId, action);
    } catch (e) {
      debugPrint('InboxController sendAction ($action) error: $e');
    }
  }

  // Toggle Pin
  Future<void> togglePin(String contactId) async {
    final api = inboxApiService;
    if (api == null) return;

    final convIndex = _conversations.indexWhere((c) => c.id == contactId);
    if (convIndex == -1) return;

    final currentPinned = _conversations[convIndex].isPinned;
    final newPinned = !currentPinned;

    _conversations[convIndex] = _conversations[convIndex].copyWith(
      isPinned: newPinned,
    );
    _sortConversations();
    notifyListeners();

    try {
      await api.updateConversation(contactId, isPinned: newPinned);
    } catch (e) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        isPinned: currentPinned,
      );
      _sortConversations();
      notifyListeners();
    }
  }

  // Toggle Archive
  Future<void> toggleArchive(String contactId) async {
    final api = inboxApiService;
    if (api == null) return;

    final convIndex = _conversations.indexWhere((c) => c.id == contactId);
    if (convIndex == -1) return;

    final currentArchived = _conversations[convIndex].isArchived;
    final newArchived = !currentArchived;

    _conversations[convIndex] = _conversations[convIndex].copyWith(
      isArchived: newArchived,
    );
    notifyListeners();

    try {
      await api.updateConversation(contactId, isArchived: newArchived);
      loadConversations();
    } catch (e) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        isArchived: currentArchived,
      );
      notifyListeners();
    }
  }

  // Update Notes
  Future<void> updateNotes(String contactId, String notes) async {
    final api = inboxApiService;
    if (api == null) return;

    final convIndex = _conversations.indexWhere((c) => c.id == contactId);
    if (convIndex != -1) {
      _conversations[convIndex] = _conversations[convIndex].copyWith(
        notes: notes,
      );
      notifyListeners();
    }

    try {
      await api.updateConversation(contactId, notes: notes);
    } catch (e) {
      debugPrint('InboxController updateNotes error: $e');
    }
  }

  // Add Tag
  Future<void> addTag(String contactId, String tag) async {
    final api = inboxApiService;
    if (api == null) return;

    final convIndex = _conversations.indexWhere((c) => c.id == contactId);
    if (convIndex == -1) return;

    final currentTags = List<String>.from(_conversations[convIndex].tags);
    if (currentTags.contains(tag)) return;

    currentTags.add(tag);
    _conversations[convIndex] = _conversations[convIndex].copyWith(
      tags: currentTags,
    );
    notifyListeners();

    try {
      await api.updateConversation(contactId, tags: currentTags);
    } catch (e) {
      debugPrint('InboxController addTag error: $e');
    }
  }

  // Remove Tag
  Future<void> removeTag(String contactId, String tag) async {
    final api = inboxApiService;
    if (api == null) return;

    final convIndex = _conversations.indexWhere((c) => c.id == contactId);
    if (convIndex == -1) return;

    final currentTags = List<String>.from(_conversations[convIndex].tags);
    currentTags.remove(tag);
    _conversations[convIndex] = _conversations[convIndex].copyWith(
      tags: currentTags,
    );
    notifyListeners();

    try {
      await api.updateConversation(contactId, tags: currentTags);
    } catch (e) {
      debugPrint('InboxController removeTag error: $e');
    }
  }

  void _sortConversations() {
    _conversations.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      final aDate = a.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b.lastMessageAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
  }

  void setReplyingTo(InboxMessageModel? message) {
    _replyingToMessage = message;
    notifyListeners();
  }

  void setStatusFilter(String status) {
    if (_statusFilter == status) return;
    _statusFilter = status;
    loadConversations();
  }

  void setTagFilter(String? tag) {
    if (_tagFilter == tag) return;
    _tagFilter = tag;
    loadConversations();
  }

  void selectChannel(String channel) {
    if (_selectedChannel == channel) return;
    _selectedChannel = channel;
    _updateSelection();
  }

  void updateSearch(String value) {
    if (_searchQuery == value) return;
    _searchQuery = value;
    _updateSelection();
  }

  void _updateSelection() {
    final visible = filteredConversations;
    if (!visible.any((c) => c.id == _selectedConversationId)) {
      _selectedConversationId = visible.isNotEmpty ? visible.first.id : null;
      if (_selectedConversationId != null) {
        loadMessages(_selectedConversationId!);
      }
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetFilters() {
    _selectedChannel = 'All';
    _statusFilter = 'all';
    _searchQuery = '';
    _tagFilter = null;
    loadConversations();
  }

  // Backward compatibility methods
  void setConversations(List<InboxConversationModel> list) {
    _conversations = List.of(list);
    _sortConversations();
    _updateSelection();
  }

  void setLoading(bool val) {
    _isLoadingConversations = val;
    notifyListeners();
  }

  void setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void clearConversations() {
    _conversations = [];
    _selectedConversationId = null;
    notifyListeners();
  }
}
