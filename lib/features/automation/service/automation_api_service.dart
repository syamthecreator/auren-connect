import 'package:auren_connect/core/network/api_client.dart';
import '../data/models/automation_enums.dart';
import '../data/models/automation_model.dart';

class AutomationApiService {
  AutomationApiService({required this.apiClient});

  final ApiClient apiClient;

  /// Fetch all automations for the authenticated user, with optional filters.
  Future<List<Automation>> getAutomations({
    String? channelId,
    String? status,
    String? triggerType,
    String? search,
  }) async {
    final queryParameters = <String, String>{};
    if (channelId != null && channelId.isNotEmpty) {
      queryParameters['channelId'] = channelId;
    }
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (triggerType != null && triggerType.isNotEmpty) {
      queryParameters['triggerType'] = triggerType;
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    final endpoint = Uri(
      path: '/automations',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    ).toString();

    final response = await apiClient.get(endpoint, requiresAuth: true);

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch automations',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawList = data?['automations'] as List<dynamic>? ?? [];

    return rawList
        .map(
          (e) => Automation.fromBackend(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  /// Retrieve full details of a single automation by ID.
  Future<Automation> getAutomationById(String id) async {
    final response = await apiClient.get(
      '/automations/$id',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch automation',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawAutomation = data?['automation'] as Map<String, dynamic>?;

    if (rawAutomation == null) {
      throw ApiException(message: 'Automation not found');
    }

    return Automation.fromBackend(rawAutomation);
  }

  /// Create a new automation workflow.
  Future<Automation> createAutomation(Automation automation) async {
    final response = await apiClient.post(
      '/automations',
      body: automation.toBackend(),
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to create automation',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawAutomation = data?['automation'] as Map<String, dynamic>?;

    if (rawAutomation == null) {
      throw ApiException(message: 'Failed to parse created automation');
    }

    return Automation.fromBackend(rawAutomation);
  }

  /// Update an existing automation workflow.
  Future<Automation> updateAutomation(
    String id,
    Automation automation,
  ) async {
    final response = await apiClient.put(
      '/automations/$id',
      body: automation.toBackend(),
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to update automation',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final rawAutomation = data?['automation'] as Map<String, dynamic>?;

    if (rawAutomation == null) {
      throw ApiException(message: 'Failed to parse updated automation');
    }

    return Automation.fromBackend(rawAutomation);
  }

  /// Toggle an automation between ACTIVE and PAUSED.
  Future<AutomationStatus> toggleAutomation(String id) async {
    final response = await apiClient.patch(
      '/automations/$id/toggle',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to toggle automation',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final statusStr = data?['status']?.toString() ?? 'ACTIVE';

    return AutomationStatusSerialization.fromBackend(statusStr);
  }

  /// Permanently delete an automation.
  Future<void> deleteAutomation(String id) async {
    final response = await apiClient.delete(
      '/automations/$id',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to delete automation',
      );
    }
  }

  /// Get aggregated analytics overview for automations.
  Future<Map<String, dynamic>> getAnalyticsOverview() async {
    final response = await apiClient.get(
      '/automations/analytics/overview',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch analytics',
      );
    }

    return (response['data'] as Map<String, dynamic>?) ?? {};
  }

  /// Get execution logs for a specific automation.
  Future<List<Map<String, dynamic>>> getAutomationLogs(
    String id, {
    int limit = 50,
    int offset = 0,
  }) async {
    final response = await apiClient.get(
      '/automations/$id/logs?limit=$limit&offset=$offset',
      requiresAuth: true,
    );

    if (response['success'] != true) {
      throw ApiException(
        message:
            response['message']?.toString() ?? 'Failed to fetch logs',
      );
    }

    final data = response['data'] as Map<String, dynamic>?;
    final logs = data?['logs'] as List<dynamic>? ?? [];

    return logs.map((l) => Map<String, dynamic>.from(l as Map)).toList();
  }
}
