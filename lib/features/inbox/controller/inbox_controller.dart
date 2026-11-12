import 'package:flutter/foundation.dart';

import '../data/models/inbox_conversation_model.dart';

class InboxController extends ChangeNotifier {
  List<InboxConversationModel> _conversations = [];

  String? _selectedConversationId;
  String _selectedChannel = 'All';
  String _searchQuery = '';

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<InboxConversationModel> get conversations =>
      List.unmodifiable(_conversations);

  String? get selectedConversationId => _selectedConversationId;

  String get selectedChannel => _selectedChannel;

  String get searchQuery => _searchQuery;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  InboxConversationModel? get selectedConversation {
    for (final conversation in _conversations) {
      if (conversation.id == _selectedConversationId) {
        return conversation;
      }
    }

    return null;
  }

  List<InboxConversationModel> get filteredConversations {
    return _conversations.where((conversation) {
      final matchesChannel =
          _selectedChannel == 'All' ||
          conversation.channel.toLowerCase() == _selectedChannel.toLowerCase();

      final query = _searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          conversation.contactName.toLowerCase().contains(query) ||
          conversation.handle.toLowerCase().contains(query) ||
          conversation.preview.toLowerCase().contains(query);

      return matchesChannel && matchesSearch;
    }).toList();
  }

  // Replace conversations with actual API data.
  void setConversations(List<InboxConversationModel> conversations) {
    _conversations = List.of(conversations);

    if (_selectedConversationId != null &&
        !_conversations.any((item) => item.id == _selectedConversationId)) {
      _selectedConversationId = null;
    }

    if (_selectedConversationId == null && filteredConversations.isNotEmpty) {
      _selectedConversationId = filteredConversations.first.id;
    }

    notifyListeners();
  }

  void selectConversation(String conversationId) {
    if (_selectedConversationId == conversationId) return;

    final exists = filteredConversations.any(
      (conversation) => conversation.id == conversationId,
    );

    if (!exists) return;

    _selectedConversationId = conversationId;
    notifyListeners();
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

    if (!visible.any(
      (conversation) => conversation.id == _selectedConversationId,
    )) {
      _selectedConversationId = visible.isNotEmpty ? visible.first.id : null;
    }

    notifyListeners();
  }

  void setLoading(bool value) {
    if (_isLoading == value) return;

    _isLoading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;
    notifyListeners();
  }

  void clearConversations() {
    _conversations = [];
    _selectedConversationId = null;
    notifyListeners();
  }

  void resetFilters() {
    _selectedChannel = 'All';
    _searchQuery = '';
    _updateSelection();
  }
}
