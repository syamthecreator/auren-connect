import 'package:flutter/foundation.dart';
import '../data/models/workspace_model.dart';
import '../../../core/services/workspace_api_service.dart';

class WorkspaceController extends ChangeNotifier {
  WorkspaceController({required this.workspaceApiService});

  final WorkspaceApiService workspaceApiService;

  List<WorkspaceModel> _userWorkspaces = [];
  WorkspaceModel? _activeWorkspace;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _successMessage;

  List<WorkspaceModel> get userWorkspaces => _userWorkspaces;
  WorkspaceModel? get activeWorkspace => _activeWorkspace;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasWorkspace => _userWorkspaces.isNotEmpty || _activeWorkspace != null;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<void> loadWorkspaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final list = await workspaceApiService.getMyWorkspaces();
      _userWorkspaces = list;

      final savedActiveId = await workspaceApiService.getActiveWorkspaceId();
      if (savedActiveId != null && list.any((w) => w.id == savedActiveId)) {
        _activeWorkspace = list.firstWhere((w) => w.id == savedActiveId);
      } else if (list.isNotEmpty) {
        _activeWorkspace = list.first;
      }
    } catch (e) {
      _errorMessage = 'Failed to load workspaces';
      debugPrint('Load workspaces error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WorkspaceModel?> createWorkspace({
    required String name,
    required String businessName,
    String? businessCategory,
    String? slug,
    String timezone = 'UTC',
    String country = 'United States',
  }) async {
    _isCreating = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final workspace = await workspaceApiService.createWorkspace(
        name: name,
        businessName: businessName,
        businessCategory: businessCategory,
        slug: slug,
        timezone: timezone,
        country: country,
      );

      _activeWorkspace = workspace;
      if (!_userWorkspaces.any((w) => w.id == workspace.id)) {
        _userWorkspaces.insert(0, workspace);
      }

      await workspaceApiService.setActiveWorkspaceId(workspace.id);
      _successMessage = 'Workspace created successfully';
      return workspace;
    } catch (e) {
      _errorMessage = 'Failed to create workspace. Please check the details and try again.';
      debugPrint('Create workspace error: $e');
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  Future<void> setActiveWorkspace(WorkspaceModel workspace) async {
    _activeWorkspace = workspace;
    await workspaceApiService.setActiveWorkspaceId(workspace.id);
    notifyListeners();
  }
}

