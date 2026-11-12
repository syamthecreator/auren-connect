import 'package:flutter/material.dart';

import 'package:auren_connect/features/automation/data/models/automation_enums.dart';
import 'package:auren_connect/features/automation/data/models/automation_model.dart';
import 'package:auren_connect/features/automation/data/models/flow_step_model.dart';

class AutomationProvider extends ChangeNotifier {
  static const int maxSteps = 8;
  static const int maxQuickReplies = 3;

  // ---------------------------------------------------------------------------
  // AUTOMATION LIST STATE
  // ---------------------------------------------------------------------------

  final List<Automation> _items = [];

  List<Automation> get items => List.unmodifiable(_items);

  int _selectedFilter = 0;

  int get selectedFilter => _selectedFilter;

  Automation? _builderDraft;

  Automation? get builderDraft => _builderDraft;

  bool _builderIsEdit = false;

  bool get builderIsEdit => _builderIsEdit;

  // ---------------------------------------------------------------------------
  // TEXT CONTROLLERS
  // ---------------------------------------------------------------------------

  final TextEditingController searchController = TextEditingController();
  final TextEditingController keywordController = TextEditingController();

  TextEditingController? _nameController;

  TextEditingController? get nameController => _nameController;

  final Map<String, TextEditingController> _stepTextControllers = {};
  final Map<String, TextEditingController> _optionControllers = {};

  TextEditingController stepTextController(String stepId) {
    final step = _findStep(stepId);

    return _stepTextControllers.putIfAbsent(
      stepId,
      () => TextEditingController(
        text: step == null
            ? ''
            : step.type == StepType.addTag
            ? step.tag
            : step.text,
      ),
    );
  }

  TextEditingController optionController(String stepId) {
    return _optionControllers.putIfAbsent(stepId, TextEditingController.new);
  }

  AutomationProvider() {
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // GETTERS / STATISTICS
  // ---------------------------------------------------------------------------

  int get totalCount => _items.length;

  int get activeCount => countByStatus(AutomationStatus.active);

  int get pausedCount => countByStatus(AutomationStatus.paused);

  int get draftCount => countByStatus(AutomationStatus.draft);

  int get totalMessagesSent =>
      _items.fold<int>(0, (total, item) => total + item.messagesSent);

  int countByStatus(AutomationStatus status) {
    return _items.where((item) => item.status == status).length;
  }

  List<Automation> get filteredAutomations {
    final query = searchController.text.trim().toLowerCase();

    return _items.where((automation) {
      final matchesFilter = switch (_selectedFilter) {
        1 => automation.status == AutomationStatus.active,
        2 => automation.status == AutomationStatus.paused,
        3 => automation.status == AutomationStatus.draft,
        _ => true,
      };

      final matchesSearch =
          query.isEmpty ||
          automation.name.toLowerCase().contains(query) ||
          automation.keywords.any(
            (keyword) => keyword.toLowerCase().contains(query),
          );

      return matchesFilter && matchesSearch;
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // ID GENERATOR
  // ---------------------------------------------------------------------------

  String _newId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  // ---------------------------------------------------------------------------
  // FILTER
  // ---------------------------------------------------------------------------

  void changeFilter(int index) {
    if (index < 0 || index > 3) return;

    _selectedFilter = index;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
  }

  // ---------------------------------------------------------------------------
  // BUILDER INITIALIZATION
  // ---------------------------------------------------------------------------

  void openBuilder({Automation? existing, Automation? prefilled}) {
    _disposeBuilderControllers();

    _builderIsEdit = existing != null;

    _builderDraft =
        existing?.copy() ?? prefilled?.copy() ?? Automation(id: _newId());

    if (_builderDraft!.steps.isEmpty) {
      _builderDraft!.steps.add(
        FlowStep(id: _newId(), type: StepType.sendMessage),
      );
    }

    _initializeBuilderControllers();

    notifyListeners();
  }

  void _initializeBuilderControllers() {
    final draft = _builderDraft;
    if (draft == null) return;

    _nameController = TextEditingController(text: draft.name);

    _nameController!.addListener(_onNameChanged);

    keywordController.clear();

    for (final step in draft.steps) {
      _createStepControllers(step);
    }
  }

  void _onNameChanged() {
    if (_builderDraft == null || _nameController == null) return;

    _builderDraft!.name = _nameController!.text;
    notifyListeners();
  }

  void _createStepControllers(FlowStep step) {
    _stepTextControllers[step.id] = TextEditingController(
      text: step.type == StepType.addTag ? step.tag : step.text,
    );

    _optionControllers[step.id] = TextEditingController();
  }

  // ---------------------------------------------------------------------------
  // CLOSE BUILDER
  // ---------------------------------------------------------------------------

  void closeBuilder() {
    _builderDraft = null;
    _builderIsEdit = false;

    _disposeBuilderControllers();

    notifyListeners();
  }

  void _disposeBuilderControllers() {
    _nameController?.removeListener(_onNameChanged);
    _nameController?.dispose();
    _nameController = null;

    keywordController.clear();

    for (final controller in _stepTextControllers.values) {
      controller.dispose();
    }

    for (final controller in _optionControllers.values) {
      controller.dispose();
    }

    _stepTextControllers.clear();
    _optionControllers.clear();
  }

  // ---------------------------------------------------------------------------
  // AUTOMATION SETUP
  // ---------------------------------------------------------------------------

  void updateAutomationName(String value) {
    if (_builderDraft == null) return;

    _builderDraft!.name = value;
    notifyListeners();
  }

  void changeTrigger(TriggerType trigger) {
    if (_builderDraft == null) return;

    _builderDraft!.trigger = trigger;
    notifyListeners();
  }

  void changeExactMatch(bool value) {
    if (_builderDraft == null) return;

    _builderDraft!.exactMatch = value;
    notifyListeners();
  }

  void changeOncePerUser(bool value) {
    if (_builderDraft == null) return;

    _builderDraft!.oncePerUser = value;
    notifyListeners();
  }

  void changePauseOnHuman(bool value) {
    if (_builderDraft == null) return;

    _builderDraft!.pauseOnHuman = value;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // KEYWORDS
  // ---------------------------------------------------------------------------

  List<String> get keywords => List.unmodifiable(_builderDraft?.keywords ?? []);

  void addKeywords(String raw) {
    final draft = _builderDraft;
    if (draft == null) return;

    final parts = raw
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);

    for (final part in parts) {
      final exists = draft.keywords.any(
        (keyword) => keyword.toLowerCase() == part.toLowerCase(),
      );

      if (!exists) {
        draft.keywords.add(part.toUpperCase());
      }
    }

    keywordController.clear();
    notifyListeners();
  }

  void removeKeyword(String keyword) {
    _builderDraft?.keywords.remove(keyword);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // FLOW STEPS
  // ---------------------------------------------------------------------------

  List<FlowStep> get steps => List.unmodifiable(_builderDraft?.steps ?? []);

  int get stepCount => _builderDraft?.steps.length ?? 0;

  FlowStep? _findStep(String stepId) {
    final draft = _builderDraft;
    if (draft == null) return null;

    for (final step in draft.steps) {
      if (step.id == stepId) return step;
    }

    return null;
  }

  void addStep(StepType type) {
    final draft = _builderDraft;
    if (draft == null) return;

    if (draft.steps.length >= maxSteps) return;

    final step = FlowStep(id: _newId(), type: type);

    draft.steps.add(step);
    _createStepControllers(step);

    notifyListeners();
  }

  void removeStep(String stepId) {
    final draft = _builderDraft;
    if (draft == null) return;

    if (draft.steps.length <= 1) return;

    draft.steps.removeWhere((step) => step.id == stepId);

    _stepTextControllers.remove(stepId)?.dispose();
    _optionControllers.remove(stepId)?.dispose();

    notifyListeners();
  }

  void moveStepUp(String stepId) {
    final draft = _builderDraft;
    if (draft == null) return;

    final index = draft.steps.indexWhere((step) => step.id == stepId);

    if (index <= 0) return;

    final step = draft.steps.removeAt(index);
    draft.steps.insert(index - 1, step);

    notifyListeners();
  }

  void moveStepDown(String stepId) {
    final draft = _builderDraft;
    if (draft == null) return;

    final index = draft.steps.indexWhere((step) => step.id == stepId);

    if (index < 0 || index >= draft.steps.length - 1) return;

    final step = draft.steps.removeAt(index);
    draft.steps.insert(index + 1, step);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // STEP CONTENT
  // ---------------------------------------------------------------------------

  void updateStepText(String stepId, String value) {
    final step = _findStep(stepId);
    if (step == null) return;

    if (step.type == StepType.addTag) {
      step.tag = value;
    } else {
      step.text = value;
    }

    notifyListeners();
  }

  void insertVariable(String stepId) {
    final controller = stepTextController(stepId);
    final currentText = controller.text;
    final selection = controller.selection;

    final position = selection.isValid ? selection.end : currentText.length;

    const variable = '{first_name}';

    final nextText = currentText.replaceRange(position, position, variable);

    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: position + variable.length),
    );

    updateStepText(stepId, nextText);
  }

  // ---------------------------------------------------------------------------
  // QUICK REPLIES
  // ---------------------------------------------------------------------------

  void addQuickReply(String stepId, String raw) {
    final step = _findStep(stepId);
    if (step == null) return;

    final value = raw.trim();

    if (value.isEmpty) return;
    if (step.options.length >= maxQuickReplies) return;
    if (step.options.contains(value)) return;

    step.options.add(value);

    _optionControllers[stepId]?.clear();

    notifyListeners();
  }

  void removeQuickReply(String stepId, String option) {
    final step = _findStep(stepId);
    if (step == null) return;

    step.options.remove(option);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DELAY
  // ---------------------------------------------------------------------------

  void updateDelay(String stepId, int minutes) {
    final step = _findStep(stepId);
    if (step == null || step.type != StepType.delay) return;

    step.delayMinutes = minutes;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------

  String? validateForPublish() {
    final draft = _builderDraft;

    if (draft == null) {
      return 'No automation is being edited';
    }

    if (draft.name.trim().isEmpty) {
      return 'Give your automation a name';
    }

    if (draft.trigger.usesKeywords && draft.keywords.isEmpty) {
      return 'Add at least one keyword for this trigger';
    }

    final hasMessage = draft.steps.any(
      (step) =>
          step.type == StepType.sendMessage ||
          step.type == StepType.quickReplies ||
          step.type == StepType.replyComment,
    );

    if (!hasMessage) {
      return 'Add at least one message step';
    }

    final invalidIndex = draft.steps.indexWhere((step) => !step.isValid);

    if (invalidIndex >= 0) {
      final step = draft.steps[invalidIndex];

      return 'Step ${invalidIndex + 1} (${step.type.label}) is incomplete';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // COMPOSE AUTOMATION
  // ---------------------------------------------------------------------------

  Automation? composeAutomation(AutomationStatus status) {
    final draft = _builderDraft;
    if (draft == null) return null;

    return Automation(
      id: draft.id,
      name: draft.name.trim().isEmpty
          ? 'Untitled automation'
          : draft.name.trim(),
      trigger: draft.trigger,
      keywords: List<String>.of(draft.keywords),
      exactMatch: draft.exactMatch,
      oncePerUser: draft.oncePerUser,
      pauseOnHuman: draft.pauseOnHuman,
      steps: draft.steps.map((step) => step.copy()).toList(),
      status: status,
      messagesSent: draft.messagesSent,
    );
  }

  AutomationStatus get draftSaveStatus {
    final currentStatus = _builderDraft?.status ?? AutomationStatus.draft;

    return currentStatus == AutomationStatus.draft
        ? AutomationStatus.draft
        : currentStatus;
  }

  AutomationStatus get publishStatus {
    final currentStatus = _builderDraft?.status ?? AutomationStatus.draft;

    return currentStatus == AutomationStatus.paused
        ? AutomationStatus.paused
        : AutomationStatus.active;
  }

  // ---------------------------------------------------------------------------
  // SAVE AUTOMATION
  // ---------------------------------------------------------------------------

  void saveAutomation(Automation automation) {
    final index = _items.indexWhere((item) => item.id == automation.id);

    if (index >= 0) {
      _items[index] = automation;
    } else {
      _items.insert(0, automation);
    }

    closeBuilder();
  }

  // ---------------------------------------------------------------------------
  // TOGGLE STATUS
  // ---------------------------------------------------------------------------

  void toggleStatus(Automation automation, bool enabled) {
    final index = _items.indexWhere((item) => item.id == automation.id);

    if (index < 0) return;

    _items[index].status = enabled
        ? AutomationStatus.active
        : AutomationStatus.paused;

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DUPLICATE
  // ---------------------------------------------------------------------------

  void duplicateAutomation(Automation automation) {
    final copy = automation.copy(
      id: _newId(),
      name: '${automation.name} (copy)',
    );

    copy.status = AutomationStatus.draft;
    copy.messagesSent = 0;

    _items.insert(0, copy);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DELETE
  // ---------------------------------------------------------------------------

  void deleteAutomation(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // REPLACE LIST (USEFUL WHEN LOADING FROM BACKEND)
  // ---------------------------------------------------------------------------

  void setAutomations(List<Automation> automations) {
    _items
      ..clear()
      ..addAll(automations);

    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);

    searchController.dispose();
    keywordController.dispose();

    _disposeBuilderControllers();

    super.dispose();
  }
}
