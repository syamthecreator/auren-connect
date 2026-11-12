import 'automation_enums.dart';
import 'flow_step_model.dart';

class Automation {
  Automation({
    required this.id,
    this.name = '',
    this.trigger = TriggerType.commentKeyword,
    List<String>? keywords,
    this.exactMatch = false,
    this.oncePerUser = true,
    this.pauseOnHuman = true,
    List<FlowStep>? steps,
    this.status = AutomationStatus.draft,
    this.messagesSent = 0,
  }) : keywords = keywords ?? [],
       steps = steps ?? [];

  final String id;
  String name;
  TriggerType trigger;
  List<String> keywords;
  bool exactMatch;
  bool oncePerUser;
  bool pauseOnHuman;
  List<FlowStep> steps;
  AutomationStatus status;
  int messagesSent;

  Automation copy({String? id, String? name}) {
    return Automation(
      id: id ?? this.id,
      name: name ?? this.name,
      trigger: trigger,
      keywords: List<String>.of(keywords),
      exactMatch: exactMatch,
      oncePerUser: oncePerUser,
      pauseOnHuman: pauseOnHuman,
      steps: steps.map((step) => step.copy()).toList(),
      status: status,
      messagesSent: messagesSent,
    );
  }
}
