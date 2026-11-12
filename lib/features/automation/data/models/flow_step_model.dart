import 'automation_enums.dart';

class FlowStep {
  FlowStep({
    required this.id,
    required this.type,
    this.text = '',
    List<String>? options,
    this.delayMinutes = 5,
    this.tag = '',
  }) : options = options ?? [];

  final String id;
  StepType type;
  String text;
  List<String> options;
  int delayMinutes;
  String tag;

  FlowStep copy() {
    return FlowStep(
      id: id,
      type: type,
      text: text,
      options: List<String>.of(options),
      delayMinutes: delayMinutes,
      tag: tag,
    );
  }

  bool get isValid => switch (type) {
    StepType.sendMessage || StepType.replyComment => text.trim().isNotEmpty,
    StepType.quickReplies => text.trim().isNotEmpty && options.isNotEmpty,
    StepType.delay => delayMinutes > 0,
    StepType.addTag => tag.trim().isNotEmpty,
  };
}
