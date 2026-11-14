import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';
import '../../features/workspace/data/models/workspace_model.dart';

class WorkspaceApiService {
  WorkspaceApiService({required this.apiClient});

  final ApiClient apiClient;

  static const String _localWorkspacesKey = 'auren_local_workspaces_v1';
  static const String _activeWorkspaceKey = 'auren_active_workspace_id_v1';

  /// Fetch workspaces for the authenticated user
  Future<List<WorkspaceModel>> getMyWorkspaces() async {
    try {
      final response = await apiClient.get(
        ApiConstants.myWorkspaces,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] is List) {
        final list = (response['data'] as List)
            .map((item) => WorkspaceModel.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (list.isNotEmpty) {
          await _saveWorkspacesLocally(list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('Workspace API fetch error (using local storage fallback): $e');
    }

    // Local storage fallback
    return await _getLocalWorkspaces();
  }

  /// Create a new workspace
  Future<WorkspaceModel> createWorkspace({
    required String name,
    required String businessName,
    String? businessCategory,
    String? slug,
    String timezone = 'UTC',
    String country = 'United States',
  }) async {
    try {
      final response = await apiClient.post(
        ApiConstants.workspaces,
        requiresAuth: true,
        body: {
          'name': name.trim(),
          'businessName': businessName.trim(),
          'businessCategory': businessCategory?.trim(),
          'slug': slug?.trim(),
          'timezone': timezone,
          'country': country,
        },
      );

      if (response['success'] == true && response['data'] is Map) {
        final created = WorkspaceModel.fromJson(
          Map<String, dynamic>.from(response['data'] as Map),
        );
        await _addLocalWorkspace(created);
        return created;
      }
    } catch (e) {
      debugPrint('Workspace API creation error (persisting locally): $e');
    }

    // Fallback workspace creation
    final fallbackSlug = (slug != null && slug.isNotEmpty)
        ? slug
        : name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '-');
    final uniqueId = 'ws_${DateTime.now().millisecondsSinceEpoch}';
    final fallback = WorkspaceModel(
      id: uniqueId,
      name: name,
      businessName: businessName,
      businessCategory: businessCategory,
      slug: fallbackSlug,
      timezone: timezone,
      country: country,
      ownerId: 'current_user',
      createdAt: DateTime.now(),
    );

    await _addLocalWorkspace(fallback);
    return fallback;
  }

  Future<void> setActiveWorkspaceId(String workspaceId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeWorkspaceKey, workspaceId);
  }

  Future<String?> getActiveWorkspaceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeWorkspaceKey);
  }

  Future<List<WorkspaceModel>> _getLocalWorkspaces() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localWorkspacesKey);
      if (raw == null || raw.isEmpty) return [];

      final decoded = jsonDecode(raw) as List;
      return decoded
          .map((item) => WorkspaceModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveWorkspacesLocally(List<WorkspaceModel> workspaces) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = workspaces.map((w) => w.toJson()).toList();
      await prefs.setString(_localWorkspacesKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _addLocalWorkspace(WorkspaceModel workspace) async {
    final list = await _getLocalWorkspaces();
    list.removeWhere((w) => w.id == workspace.id || w.slug == workspace.slug);
    list.insert(0, workspace);
    await _saveWorkspacesLocally(list);
    await setActiveWorkspaceId(workspace.id);
  }
}

