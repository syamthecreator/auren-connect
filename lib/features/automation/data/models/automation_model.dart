import 'automation_enums.dart';
import 'flow_step_model.dart';

class Automation {
  Automation({
    required this.id,
    this.name = '',
    this.description,
    this.channelType = 'INSTAGRAM',
    this.channelId,
    this.channelUsername,
    this.whatsAppChannelId,
    this.whatsAppNumber,
    this.trigger = TriggerType.commentKeyword,
    List<String>? keywords,
    this.exactMatch = false,
    this.oncePerUser = true,
    this.pauseOnHuman = true,
    this.targetPostId,
    List<FlowStep>? steps,
    this.status = AutomationStatus.draft,
    this.messagesSent = 0,
    this.successRuns = 0,
    this.failedRuns = 0,
    this.createdAt,
    this.updatedAt,
  }) : keywords = keywords ?? [],
       steps = steps ?? [];

  final String id;
  String name;
  String? description;
  String channelType; // 'INSTAGRAM' or 'WHATSAPP'
  String? channelId;
  String? channelUsername;
  String? whatsAppChannelId;
  String? whatsAppNumber;
  TriggerType trigger;
  List<String> keywords;
  bool exactMatch;
  bool oncePerUser;
  bool pauseOnHuman;
  String? targetPostId;
  List<FlowStep> steps;
  AutomationStatus status;
  int messagesSent;
  int successRuns;
  int failedRuns;
  DateTime? createdAt;
  DateTime? updatedAt;

  bool get isWhatsApp => channelType == 'WHATSAPP';
  bool get isInstagram => channelType == 'INSTAGRAM';

  Automation copy({
    String? id,
    String? name,
    String? description,
    String? channelType,
    String? channelId,
    String? channelUsername,
    String? whatsAppChannelId,
    String? whatsAppNumber,
  }) {
    return Automation(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      channelType: channelType ?? this.channelType,
      channelId: channelId ?? this.channelId,
      channelUsername: channelUsername ?? this.channelUsername,
      whatsAppChannelId: whatsAppChannelId ?? this.whatsAppChannelId,
      whatsAppNumber: whatsAppNumber ?? this.whatsAppNumber,
      trigger: trigger,
      keywords: List<String>.of(keywords),
      exactMatch: exactMatch,
      oncePerUser: oncePerUser,
      pauseOnHuman: pauseOnHuman,
      targetPostId: targetPostId,
      steps: steps.map((step) => step.copy()).toList(),
      status: status,
      messagesSent: messagesSent,
      successRuns: successRuns,
      failedRuns: failedRuns,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toBackend() {
    return {
      'channelType': channelType,
      if (channelId != null && channelId!.isNotEmpty) 'channelId': channelId,
      if (whatsAppChannelId != null && whatsAppChannelId!.isNotEmpty)
        'whatsAppChannelId': whatsAppChannelId,
      'name': name.trim().isEmpty ? 'Untitled automation' : name.trim(),
      if (description != null) 'description': description,
      'triggerType': trigger.toBackend(),
      'matchType': exactMatch ? 'EXACT' : 'CONTAINS',
      'keywords': keywords,
      if (targetPostId != null && targetPostId!.isNotEmpty)
        'targetPostId': targetPostId,
      'status': status.toBackend(),
      'steps': steps.asMap().entries.map((entry) {
        return entry.value.toBackend(entry.key);
      }).toList(),
    };
  }

  factory Automation.fromBackend(Map<String, dynamic> json) {
    final channelData = json['channel'] as Map<String, dynamic>?;
    final waChannelData = json['whatsAppChannel'] as Map<String, dynamic>?;
    final rawSteps = json['steps'] as List<dynamic>? ?? [];

    final steps = rawSteps
        .map((s) => FlowStep.fromBackend(Map<String, dynamic>.from(s as Map)))
        .toList();

    return Automation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      channelType: json['channelType']?.toString() ?? 'INSTAGRAM',
      channelId: json['channelId']?.toString(),
      channelUsername: channelData?['username']?.toString(),
      whatsAppChannelId: json['whatsAppChannelId']?.toString(),
      whatsAppNumber: waChannelData?['phoneNumber']?.toString() ??
          waChannelData?['name']?.toString(),
      trigger: TriggerTypeSerialization.fromBackend(
        json['triggerType']?.toString() ?? 'COMMENT_KEYWORD',
      ),
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((k) => k.toString())
              .toList() ??
          [],
      exactMatch: json['matchType'] == 'EXACT',
      targetPostId: json['targetPostId']?.toString(),
      status: AutomationStatusSerialization.fromBackend(
        json['status']?.toString() ?? 'DRAFT',
      ),
      messagesSent: (json['totalRuns'] as num?)?.toInt() ?? 0,
      successRuns: (json['successRuns'] as num?)?.toInt() ?? 0,
      failedRuns: (json['failedRuns'] as num?)?.toInt() ?? 0,
      steps: steps,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }
}
