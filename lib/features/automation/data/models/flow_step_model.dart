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

  Map<String, dynamic> toBackend(int order) {
    final Map<String, dynamic> content = {};
    switch (type) {
      case StepType.sendMessage:
        content['text'] = text;
      case StepType.replyComment:
        content['text'] = text;
        content['replies'] = [text];
      case StepType.quickReplies:
        content['text'] = text;
        content['buttons'] = options
            .map((opt) => {'title': opt, 'payload': opt.toUpperCase()})
            .toList();
      case StepType.delay:
        content['delaySeconds'] = delayMinutes * 60;
      case StepType.addTag:
        content['tag'] = tag;
    }

    return {
      'order': order,
      'stepType': type.toBackend(),
      'content': content,
    };
  }

  factory FlowStep.fromBackend(Map<String, dynamic> json) {
    final id =
        json['id']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final type = StepTypeSerialization.fromBackend(
      json['stepType']?.toString() ?? 'SEND_DM',
    );
    final content = json['content'] as Map<String, dynamic>? ?? {};

    String text = '';
    List<String> options = [];
    int delayMinutes = 5;
    String tag = '';

    switch (type) {
      case StepType.sendMessage:
        text = content['text']?.toString() ?? '';
      case StepType.replyComment:
        if (content['replies'] is List &&
            (content['replies'] as List).isNotEmpty) {
          text = (content['replies'] as List).first.toString();
        } else {
          text = content['text']?.toString() ?? '';
        }
      case StepType.quickReplies:
        text = content['text']?.toString() ?? '';
        if (content['buttons'] is List) {
          options = (content['buttons'] as List)
              .map(
                (b) => b is Map ? b['title']?.toString() ?? '' : b.toString(),
              )
              .where((t) => t.isNotEmpty)
              .toList();
        }
      case StepType.delay:
        final seconds = (content['delaySeconds'] as num?)?.toInt() ?? 300;
        delayMinutes = (seconds / 60).round().clamp(1, 1440);
      case StepType.addTag:
        tag = content['tag']?.toString() ?? '';
    }

    return FlowStep(
      id: id,
      type: type,
      text: text,
      options: options,
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
