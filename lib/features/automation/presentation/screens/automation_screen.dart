import 'package:auren_connect/features/automation/controller/automation_provider.dart';
import 'package:auren_connect/features/automation/data/models/automation_enums.dart';
import 'package:auren_connect/features/automation/data/models/automation_model.dart';
import 'package:auren_connect/features/automation/data/models/flow_step_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/app_snackbar.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_page_heading.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';

String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

// ════════════════════════════════════════════════════════════════════════════
//  RECIPES
// ════════════════════════════════════════════════════════════════════════════

class _Recipe {
  const _Recipe({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.build,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Automation Function() build;
}

List<_Recipe> _recipes() => [
  _Recipe(
    title: 'Comment-to-DM lead magnet',
    description:
        'Reply to a keyword comment and deliver your guide or link in DMs.',
    icon: RemixIcons.chat_3_line,
    color: AppColors.igColor,
    build: () => Automation(
      id: _newId(),
      name: 'Comment-to-DM lead magnet',
      trigger: TriggerType.commentKeyword,
      keywords: ['GUIDE', 'LINK'],
      steps: [
        FlowStep(
          id: '${_newId()}a',
          type: StepType.replyComment,
          text: 'Just sent you a DM! Check your inbox.',
        ),
        FlowStep(
          id: '${_newId()}b',
          type: StepType.sendMessage,
          text: 'Hey {first_name}! Here is the guide you asked for: https://your-link.com',
        ),
      ],
    ),
  ),
  _Recipe(
    title: 'Price & product enquiry',
    description:
        'Answer pricing DMs instantly, qualify the lead and tag the contact.',
    icon: RemixIcons.price_tag_3_line,
    color: AppColors.primary,
    build: () => Automation(
      id: _newId(),
      name: 'Price & product enquiry',
      trigger: TriggerType.dmKeyword,
      keywords: ['PRICE', 'COST'],
      steps: [
        FlowStep(
          id: '${_newId()}a',
          type: StepType.sendMessage,
          text: 'Hi {first_name}, thanks for your interest!',
        ),
        FlowStep(
          id: '${_newId()}b',
          type: StepType.quickReplies,
          text: 'What would you like to do next?',
          options: ['See pricing', 'Book a call', 'Talk to a human'],
        ),
        FlowStep(
          id: '${_newId()}c',
          type: StepType.addTag,
          tag: 'Price enquiry',
        ),
      ],
    ),
  ),
  _Recipe(
    title: 'Story mention thank-you',
    description: 'Thank people who tag you in their story and reward them with an offer.',
    icon: RemixIcons.at_line,
    color: AppColors.accent,
    build: () => Automation(
      id: _newId(),
      name: 'Story mention thank-you',
      trigger: TriggerType.storyMention,
      steps: [
        FlowStep(
          id: '${_newId()}a',
          type: StepType.sendMessage,
          text: 'Thanks for the mention, {first_name}! You made our day.',
        ),
        FlowStep(id: '${_newId()}b', type: StepType.delay, delayMinutes: 5),
        FlowStep(
          id: '${_newId()}c',
          type: StepType.sendMessage,
          text: 'Here is a little thank-you: use code THANKS10 for 10% off.',
        ),
      ],
    ),
  ),
  _Recipe(
    title: 'Story reply nurture',
    description:
        'Turn story replies into real conversations with a follow-up question.',
    icon: RemixIcons.reply_line,
    color: AppColors.success,
    build: () => Automation(
      id: _newId(),
      name: 'Story reply nurture',
      trigger: TriggerType.storyReply,
      steps: [
        FlowStep(
          id: '${_newId()}a',
          type: StepType.sendMessage,
          text: 'Love that you replied! Can I help you with anything?',
        ),
        FlowStep(id: '${_newId()}b', type: StepType.delay, delayMinutes: 30),
        FlowStep(
          id: '${_newId()}c',
          type: StepType.quickReplies,
          text: 'Want to see what we have been working on?',
          options: ['Yes, show me', 'Maybe later'],
        ),
      ],
    ),
  ),
];

// ════════════════════════════════════════════════════════════════════════════
//  AUTOMATIONS SCREEN
// ════════════════════════════════════════════════════════════════════════════

class AutomationsScreen extends StatefulWidget {
  const AutomationsScreen({super.key});

  @override
  State<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends State<AutomationsScreen> {
  AutomationProvider get _provider => context.read<AutomationProvider>();

  void _openBuilder({Automation? existing, Automation? prefilled}) {
    _provider.openBuilder(existing: existing, prefilled: prefilled);
  }

  void _closeBuilder() => _provider.closeBuilder();

  void _saveAutomation(Automation automation) {
    _provider.saveAutomation(automation);

    AppSnackBar.success(
      context,
      automation.status == AutomationStatus.active
          ? 'Automation published and running'
          : 'Draft saved',
    );
  }

  void _toggleStatus(Automation automation, bool enabled) {
    _provider.toggleStatus(automation, enabled);

    AppSnackBar.info(
      context,
      enabled
          ? '"${automation.name}" is now active'
          : '"${automation.name}" paused',
    );
  }

  void _duplicate(Automation automation) {
    _provider.duplicateAutomation(automation);
    AppSnackBar.success(context, 'Automation duplicated as draft');
  }

  void _confirmDelete(Automation automation) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const StudioIconBox(
              RemixIcons.delete_bin_line,
              AppColors.error,
              size: 38,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete automation',
                style: AppTextStyles.t(18, w: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Delete "${automation.name}"? Its flow will stop running and this cannot be undone.',
          style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: AppTextStyles.t(14, c: AppColors.textSecondary),
            ),
          ),
          GradientButton(
            label: 'Delete',
            icon: RemixIcons.delete_bin_line,
            onTap: () {
              Navigator.of(ctx).pop();
              _provider.deleteAutomation(automation.id);
              AppSnackBar.success(context, 'Automation deleted');
            },
          ),
        ],
      ),
    );
  }

  void _showRecipesDialog() {
    final recipes = _recipes();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.card,
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const StudioIconBox(
                      RemixIcons.magic_line,
                      AppColors.accent,
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ready-made recipes',
                            style: AppTextStyles.t(18, w: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Start from a proven flow and edit anything.',
                            style: AppTextStyles.t(
                              12.5,
                              c: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(
                        RemixIcons.close_line,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: recipes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _RecipeCard(
                      recipe: recipes[i],
                      onUse: () {
                        Navigator.of(ctx).pop();
                        _openBuilder(prefilled: recipes[i].build());
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AutomationProvider>(
      builder: (context, provider, _) {
        if (provider.builderDraft != null) {
          return _AutomationBuilder(
            key: ValueKey(provider.builderDraft!.id),
            initial: provider.builderDraft!,
            isEdit: provider.builderIsEdit,
            onBack: _closeBuilder,
            onSave: _saveAutomation,
          );
        }

        final active = provider.activeCount;
        final paused = provider.pausedCount;
        final drafts = provider.draftCount;
        final totalSent = provider.totalMessagesSent;
        final items = provider.items;
        final list = provider.filteredAutomations;

        return StudioPage(
          children: [
            StudioPageHeading(
              actions: [
                GhostButton(
                  label: 'Browse recipes',
                  icon: RemixIcons.magic_line,
                  onTap: _showRecipesDialog,
                ),
                GradientButton(
                  label: 'New automation',
                  icon: RemixIcons.add_line,
                  onTap: () => _openBuilder(),
                ),
              ],
            ),
            _AutomationHeroBanner(
              activeCount: active,
              totalCount: provider.totalCount,
              onCreate: () => _openBuilder(),
              onRecipes: _showRecipesDialog,
            ),
            ResponsiveGrid(
              minItemWidth: 230,
              maxColumns: 4,
              spacing: 16,
              children: [
                _StatCard(
                  icon: RemixIcons.git_branch_line,
                  label: 'Total automations',
                  value: '${provider.totalCount}',
                  subtitle: 'All created workflows',
                  accent: AppColors.primary,
                ),
                _StatCard(
                  icon: RemixIcons.checkbox_circle_line,
                  label: 'Active',
                  value: '$active',
                  subtitle: 'Currently running',
                  accent: AppColors.success,
                ),
                _StatCard(
                  icon: RemixIcons.pause_circle_line,
                  label: 'Paused & drafts',
                  value: '${paused + drafts}',
                  subtitle: 'Not running yet',
                  accent: AppColors.warning,
                ),
                _StatCard(
                  icon: RemixIcons.chat_3_line,
                  label: 'Messages triggered',
                  value: '$totalSent',
                  subtitle: 'Automated conversations',
                  accent: AppColors.igColor,
                ),
              ],
            ),
            StudioCard(
              hoverable: false,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final wide = c.maxWidth > 760;
                        final titleBlock = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your automations',
                              style: AppTextStyles.t(17, w: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Manage all your Instagram workflows.',
                              style: AppTextStyles.t(
                                12.5,
                                c: AppColors.textMuted,
                              ),
                            ),
                          ],
                        );

                        final search = SizedBox(
                          width: wide ? 260 : double.infinity,
                          child: TextField(
                            controller: provider.searchController,
                            style: AppTextStyles.t(13.5),
                            decoration: AppInputDecorations.dec(
                              'Search name or keyword...',
                              icon: RemixIcons.search_line,
                            ),
                          ),
                        );

                        return wide
                            ? Row(
                                children: [
                                  Expanded(child: titleBlock),
                                  search,
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  titleBlock,
                                  const SizedBox(height: 14),
                                  search,
                                ],
                              );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 18),
                    child: StudioChips(
                      options: [
                        'All (${provider.totalCount})',
                        'Active ($active)',
                        'Paused ($paused)',
                        'Drafts ($drafts)',
                      ],
                      selected: provider.selectedFilter,
                      onChanged: provider.changeFilter,
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),
                  if (items.isEmpty)
                    _EmptyState(
                      onCreate: () => _openBuilder(),
                      onRecipes: _showRecipesDialog,
                    )
                  else if (list.isEmpty)
                    const _NoResults()
                  else
                    Padding(
                      padding: const EdgeInsets.all(22),
                      child: ResponsiveGrid(
                        minItemWidth: 440,
                        maxColumns: 2,
                        spacing: 20,
                        children: list
                            .map(
                              (automation) => _AutomationCard(
                                automation: automation,
                                onEdit: () =>
                                    _openBuilder(existing: automation),
                                onDuplicate: () => _duplicate(automation),
                                onDelete: () => _confirmDelete(automation),
                                onToggle: (value) =>
                                    _toggleStatus(automation, value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
            // WhatsApp is retained as a coming-soon feature in this screen.
            const _WhatsAppAutomationSoonCard(),
          ],
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  HERO BANNER
// ════════════════════════════════════════════════════════════════════════════

class _AutomationHeroBanner extends StatelessWidget {
  const _AutomationHeroBanner({
    required this.activeCount,
    required this.totalCount,
    required this.onCreate,
    required this.onRecipes,
  });

  final int activeCount;
  final int totalCount;
  final VoidCallback onCreate;
  final VoidCallback onRecipes;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(26),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primary.withValues(alpha: .14),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth > 880;
          final left = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  StudioPill(
                    activeCount > 0
                        ? '$activeCount Running'
                        : 'No Active Automations',
                    color: activeCount > 0
                        ? AppColors.success
                        : AppColors.textMuted,
                    icon: RemixIcons.flashlight_line,
                  ),
                  const StudioPill(
                    'Instagram Live',
                    color: AppColors.igColor,
                    icon: RemixIcons.instagram_line,
                  ),
                  const StudioPill(
                    'WhatsApp Soon',
                    color: AppColors.waColor,
                    icon: RemixIcons.time_line,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Automation Studio',
                style: AppTextStyles.t(28, w: FontWeight.w700, ls: -.8),
              ),
              const SizedBox(height: 8),
              Text(
                'Build conversation flows that reply to comments, keywords and story activity instantly, qualify leads, and hand over to your team when it matters.',
                style: AppTextStyles.t(
                  14.5,
                  c: AppColors.textSecondary,
                  h: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  GradientButton(
                    label: 'Create automation',
                    icon: RemixIcons.add_circle_line,
                    onTap: onCreate,
                  ),
                  GhostButton(
                    label: 'Browse recipes',
                    icon: RemixIcons.magic_line,
                    onTap: onRecipes,
                  ),
                ],
              ),
            ],
          );

          final summaryBox = Container(
            width: 320,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .03),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: .08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Flow Engine',
                      style: AppTextStyles.t(14, w: FontWeight.w700),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: .7),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _MiniStatusRow(
                  icon: RemixIcons.instagram_line,
                  color: AppColors.igColor,
                  label: 'Instagram',
                  value: '$totalCount flows',
                ),
                const SizedBox(height: 10),
                const _MiniStatusRow(
                  icon: RemixIcons.whatsapp_line,
                  color: AppColors.waColor,
                  label: 'WhatsApp',
                  value: 'Coming Soon',
                ),
                const SizedBox(height: 10),
                const _MiniStatusRow(
                  icon: RemixIcons.flashlight_line,
                  color: AppColors.primary,
                  label: 'Triggers',
                  value: '4 available',
                ),
                const SizedBox(height: 10),
                const _MiniStatusRow(
                  icon: RemixIcons.shield_check_line,
                  color: AppColors.accent,
                  label: 'Policy',
                  value: '24h messaging window',
                ),
              ],
            ),
          );

          return isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: left),
                    const SizedBox(width: 32),
                    summaryBox,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 20), summaryBox],
                );
        },
      ),
    );
  }
}

class _MiniStatusRow extends StatelessWidget {
  const _MiniStatusRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.t(12.5, c: AppColors.textSecondary)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.t(12.5, w: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  STAT CARD
// ════════════════════════════════════════════════════════════════════════════

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudioIconBox(icon, accent, size: 40),
          const SizedBox(height: 18),
          Text(value, style: AppTextStyles.t(30, w: FontWeight.w700, ls: -1)),
          const SizedBox(height: 4),
          Text(label, style: AppTextStyles.t(13.5, w: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(subtitle, style: AppTextStyles.t(12, c: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  EMPTY / NO RESULTS
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate, required this.onRecipes});

  final VoidCallback onCreate;
  final VoidCallback onRecipes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: .22),
                      AppColors.primary.withValues(alpha: .06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: .25),
                  ),
                ),
                child: const Icon(
                  RemixIcons.git_branch_line,
                  size: 34,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'No automations yet',
                style: AppTextStyles.t(20, w: FontWeight.w700),
              ),
              const SizedBox(height: 9),
              Text(
                'Create your first Instagram automation to automatically respond to comments, keywords and story activity.',
                textAlign: TextAlign.center,
                style: AppTextStyles.t(14, c: AppColors.textSecondary, h: 1.6),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  GradientButton(
                    label: 'Create your first automation',
                    icon: RemixIcons.add_line,
                    onTap: onCreate,
                  ),
                  GhostButton(
                    label: 'Use a recipe',
                    icon: RemixIcons.magic_line,
                    onTap: onRecipes,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const Icon(
              RemixIcons.search_line,
              size: 28,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'No automations match your filters',
              style: AppTextStyles.t(14, c: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  AUTOMATION CARD
// ════════════════════════════════════════════════════════════════════════════

class _AutomationCard extends StatelessWidget {
  const _AutomationCard({
    required this.automation,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onToggle,
  });

  final Automation automation;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final a = automation;
    final isActive = a.status == AutomationStatus.active;
    final isDraft = a.status == AutomationStatus.draft;

    return StudioCard(
      hoverable: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.igColor.withValues(alpha: .10),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.instagram_line,
                AppColors.igColor,
                size: 44,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            a.name.isEmpty ? 'Untitled automation' : a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.t(16.5, w: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        StudioPill(
                          a.status.label,
                          color: AppColors.statusColor(a.status.label),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Instagram · ${a.trigger.title}',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                icon: const Icon(
                  RemixIcons.more_2_fill,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'duplicate') onDuplicate();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  _menuItem('edit', RemixIcons.edit_line, 'Edit flow'),
                  _menuItem(
                    'duplicate',
                    RemixIcons.file_copy_line,
                    'Duplicate',
                  ),
                  _menuItem(
                    'delete',
                    RemixIcons.delete_bin_line,
                    'Delete',
                    color: AppColors.error,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Flow summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withValues(alpha: .45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Flow',
                  style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 8,
                  children: [
                    _FlowNode(icon: a.trigger.icon, color: AppColors.igColor),
                    ...a.steps
                        .take(5)
                        .expand(
                          (s) => [
                            const Icon(
                              RemixIcons.arrow_right_s_line,
                              size: 16,
                              color: AppColors.textMuted,
                            ),
                            _FlowNode(icon: s.type.icon, color: s.type.color),
                          ],
                        ),
                    if (a.steps.length > 5)
                      Text(
                        '+${a.steps.length - 5}',
                        style: AppTextStyles.t(
                          12,
                          w: FontWeight.w600,
                          c: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                if (a.trigger.usesKeywords && a.keywords.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(height: 1, color: AppColors.border),
                  const SizedBox(height: 12),
                  Text(
                    a.exactMatch ? 'Exact keywords' : 'Keywords (contains)',
                    style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: a.keywords
                        .map((k) => _KeywordChip(label: k))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              const Icon(
                RemixIcons.chat_3_line,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${a.messagesSent} sent · ${a.steps.length} steps',
                style: AppTextStyles.t(12.5, c: AppColors.textSecondary),
              ),
              const Spacer(),
              if (isDraft)
                GhostButton(
                  label: 'Continue editing',
                  icon: RemixIcons.edit_line,
                  onTap: onEdit,
                )
              else ...[
                Text(
                  isActive ? 'Running' : 'Paused',
                  style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: isActive,
                  onChanged: onToggle,
                  thumbColor: const WidgetStatePropertyAll(Colors.white),
                  trackColor: WidgetStateProperty.resolveWith(
                    (s) => s.contains(WidgetState.selected)
                        ? AppColors.success
                        : AppColors.border,
                  ),
                  trackOutlineColor: const WidgetStatePropertyAll(
                    Colors.transparent,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    String value,
    IconData icon,
    String label, {
    Color color = AppColors.textPrimary,
  }) => PopupMenuItem(
    value: value,
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.t(13, c: color)),
      ],
    ),
  );
}

class _FlowNode extends StatelessWidget {
  const _FlowNode({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }
}

class _KeywordChip extends StatelessWidget {
  const _KeywordChip({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(9, 4, onRemove == null ? 9 : 5, 4),
      decoration: BoxDecoration(
        color: AppColors.igColor.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.igColor.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.t(
              11.5,
              w: FontWeight.w600,
              c: AppColors.igColor,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 4),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.all(2),
                child: Icon(
                  RemixIcons.close_line,
                  size: 13,
                  color: AppColors.igColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  RECIPE CARD
// ════════════════════════════════════════════════════════════════════════════

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onUse});

  final _Recipe recipe;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: true,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StudioIconBox(recipe.icon, recipe.color, size: 44),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipe.title,
                  style: AppTextStyles.t(14.5, w: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.description,
                  style: AppTextStyles.t(
                    12.5,
                    c: AppColors.textSecondary,
                    h: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                GhostButton(
                  label: 'Use recipe',
                  icon: RemixIcons.arrow_right_line,
                  onTap: onUse,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  WHATSAPP COMING SOON
// ════════════════════════════════════════════════════════════════════════════

class _WhatsAppAutomationSoonCard extends StatelessWidget {
  const _WhatsAppAutomationSoonCard();

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(26),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.waColor.withValues(alpha: .07),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const StudioIconBox(
                RemixIcons.whatsapp_line,
                AppColors.waColor,
                size: 46,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WhatsApp Automations',
                      style: AppTextStyles.t(17, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Meta Cloud API · WhatsApp Business Platform',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill(
                'Coming Soon',
                color: AppColors.waColor,
                icon: RemixIcons.time_line,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Template messages, keyword replies and broadcast flows for WhatsApp are in development for aurenConnect v2.0. Instagram automation is fully operational today.',
            style: AppTextStyles.t(13.5, c: AppColors.textSecondary, h: 1.5),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _SoonFeature(label: 'Approved templates'),
              _SoonFeature(label: 'Keyword auto-replies'),
              _SoonFeature(label: 'Broadcast flows'),
              _SoonFeature(label: 'Human handover'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoonFeature extends StatelessWidget {
  const _SoonFeature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            RemixIcons.lock_line,
            size: 13,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 7),
          Text(label, style: AppTextStyles.t(12, c: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  BUILDER  (create / edit flow)
// ════════════════════════════════════════════════════════════════════════════

class _AutomationBuilder extends StatefulWidget {
  const _AutomationBuilder({
    super.key,
    required this.initial,
    required this.isEdit,
    required this.onBack,
    required this.onSave,
  });

  final Automation initial;
  final bool isEdit;
  final VoidCallback onBack;
  final ValueChanged<Automation> onSave;

  @override
  State<_AutomationBuilder> createState() => _AutomationBuilderState();
}

class _AutomationBuilderState extends State<_AutomationBuilder> {
  AutomationProvider get _provider => context.read<AutomationProvider>();

  Automation get _automation => _provider.builderDraft ?? widget.initial;

  TextEditingController get _name => _provider.nameController!;
  TextEditingController get _kw => _provider.keywordController;

  TriggerType get _trigger => _automation.trigger;
  List<String> get _keywords => _provider.keywords;
  bool get _exact => _automation.exactMatch;
  List<FlowStep> get _steps => _provider.steps;

  void _addKeywords(String raw) => _provider.addKeywords(raw);

  void _addStep(StepType type) {
    if (_provider.stepCount >= AutomationProvider.maxSteps) {
      AppSnackBar.info(
        context,
        'You can add up to ${AutomationProvider.maxSteps} steps',
      );
      return;
    }
    _provider.addStep(type);
  }

  void _moveStep(int index, int delta) {
    if (index < 0 || index >= _steps.length) return;
    final id = _steps[index].id;
    if (delta < 0) {
      _provider.moveStepUp(id);
    } else if (delta > 0) {
      _provider.moveStepDown(id);
    }
  }

  void _removeStep(int index) {
    if (_steps.length <= 1) {
      AppSnackBar.info(context, 'A flow needs at least one step');
      return;
    }
    _provider.removeStep(_steps[index].id);
  }

  void _saveDraft() {
    final automation = _provider.composeAutomation(_provider.draftSaveStatus);
    if (automation != null) widget.onSave(automation);
  }

  void _publish() {
    final error = _provider.validateForPublish();
    if (error != null) {
      AppSnackBar.error(context, error);
      return;
    }

    final automation = _provider.composeAutomation(_provider.publishStatus);
    if (automation != null) widget.onSave(automation);
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  //  Wide screens : editor scrolls on the left, iPhone preview is FIXED right.
  //  Narrow screens: "Preview" button opens the phone in a dialog.

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) => LayoutBuilder(
        builder: (context, c) {
          final fixedPreview = c.maxWidth > 1100 && c.maxHeight.isFinite;

          final page = StudioPage(
            children: [
              StudioPageHeading(
                actions: [
                  GhostButton(
                    label: 'Back',
                    icon: RemixIcons.arrow_left_line,
                    onTap: widget.onBack,
                  ),
                  if (!fixedPreview)
                    GhostButton(
                      label: 'Preview',
                      icon: RemixIcons.smartphone_line,
                      onTap: _showPreviewDialog,
                    ),
                  GhostButton(
                    label: 'Save draft',
                    icon: RemixIcons.save_line,
                    onTap: _saveDraft,
                  ),
                  GradientButton(
                    label: widget.isEdit ? 'Update & publish' : 'Publish',
                    icon: RemixIcons.rocket_line,
                    onTap: _publish,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSetupCard(),
                  const SizedBox(height: 20),
                  _buildTriggerCard(),
                  const SizedBox(height: 20),
                  _buildFlowCard(),
                ],
              ),
            ],
          );

          if (!fixedPreview) return page;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: page), // only this side scrolls
              _FixedPreviewPanel(
                trigger: _trigger,
                keywords: _keywords,
                steps: _steps,
              ), // this side never scrolls
            ],
          );
        },
      ),
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.sizeOf(ctx).height * .88,
          child: Stack(
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _InstagramPhone(
                    trigger: _trigger,
                    keywords: List.of(_keywords),
                    steps: _steps.map((s) => s.copy()).toList(),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: AppColors.card),
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(
                    RemixIcons.close_line,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 1: Setup ───────────────────────────────────────────────────────

  Widget _buildSetupCard() {
    return _SectionCard(
      number: 1,
      title: 'Setup',
      subtitle: 'Name your automation and choose the channel.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Automation name'),
          TextField(
            controller: _name,
            style: AppTextStyles.t(13.5),
            decoration: AppInputDecorations.dec(
              'e.g. Free guide lead magnet',
              icon: RemixIcons.edit_line,
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Channel'),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ChannelTile(
                icon: RemixIcons.instagram_line,
                color: AppColors.igColor,
                title: 'Instagram',
                subtitle: 'Comments, DMs, stories',
                selected: true,
                onTap: () {},
              ),
              _ChannelTile(
                icon: RemixIcons.whatsapp_line,
                color: AppColors.waColor,
                title: 'WhatsApp',
                subtitle: 'Templates & replies',
                selected: false,
                comingSoon: true,
                onTap: () => AppSnackBar.info(
                  context,
                  'WhatsApp automations are coming soon',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Section 2: Trigger ─────────────────────────────────────────────────────

  Widget _buildTriggerCard() {
    return _SectionCard(
      number: 2,
      title: 'Trigger',
      subtitle: 'Choose what starts this automation.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            minItemWidth: 240,
            maxColumns: 2,
            spacing: 12,
            children: TriggerType.values
                .map(
                  (t) => _TriggerTile(
                    type: t,
                    selected: t == _trigger,
                    onTap: () => _provider.changeTrigger(t),
                  ),
                )
                .toList(),
          ),
          if (_trigger.usesKeywords) ...[
            const SizedBox(height: 22),
            const _FieldLabel('Keywords'),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kw,
                    style: AppTextStyles.t(13.5),
                    onSubmitted: _addKeywords,
                    decoration: AppInputDecorations.dec(
                      'Type a keyword and press enter (comma separated)',
                      icon: RemixIcons.price_tag_3_line,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GhostButton(
                  label: 'Add',
                  icon: RemixIcons.add_line,
                  onTap: () => _addKeywords(_kw.text),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_keywords.isNotEmpty)
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final k in _keywords)
                    _KeywordChip(
                      label: k,
                      onRemove: () => _provider.removeKeyword(k),
                    ),
                ],
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Suggestions:',
                    style: AppTextStyles.t(12, c: AppColors.textMuted),
                  ),
                  for (final s in const ['PRICE', 'INFO', 'LINK', 'GUIDE'])
                    _ChoicePill(
                      label: s,
                      selected: false,
                      onTap: () => _addKeywords(s),
                    ),
                ],
              ),
            const SizedBox(height: 16),
            const _FieldLabel('Match rule'),
            Wrap(
              spacing: 8,
              children: [
                _ChoicePill(
                  label: 'Contains keyword',
                  selected: !_exact,
                  onTap: () => _provider.changeExactMatch(false),
                ),
                _ChoicePill(
                  label: 'Exact match',
                  selected: _exact,
                  onTap: () => _provider.changeExactMatch(true),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 16),
            _InfoStrip(
              text: _trigger == TriggerType.storyMention
                  ? 'Runs whenever someone mentions your account in their story. No keyword needed.'
                  : 'Runs for every reply to your stories. No keyword needed.',
            ),
          ],
        ],
      ),
    );
  }

  // ── Section 3: Flow ────────────────────────────────────────────────────────

  Widget _buildFlowCard() {
    return _SectionCard(
      number: 3,
      title: 'Conversation flow',
      subtitle: 'Steps run in order, top to bottom.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trigger start node
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: StudioIconBox(
                    _trigger.icon,
                    AppColors.igColor,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'When: ${_trigger.title.toLowerCase()}'
                  '${_trigger.usesKeywords && _keywords.isNotEmpty ? ' → ${_keywords.join(', ')}' : ''}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.t(13, w: FontWeight.w600),
                ),
              ),
            ],
          ),
          for (int i = 0; i < _steps.length; i++)
            IntrinsicHeight(
              key: ValueKey(_steps[i].id),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        Container(
                          width: 2,
                          height: 12,
                          color: AppColors.border,
                        ),
                        Container(
                          width: 26,
                          height: 26,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _steps[i].type.color.withValues(alpha: .16),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _steps[i].type.color.withValues(alpha: .5),
                            ),
                          ),
                          child: Text(
                            '${i + 1}',
                            style: AppTextStyles.t(
                              11.5,
                              w: FontWeight.w700,
                              c: _steps[i].type.color,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(width: 2, color: AppColors.border),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: _StepEditor(
                        step: _steps[i],
                        canMoveUp: i > 0,
                        canMoveDown: i < _steps.length - 1,
                        onMoveUp: () => _moveStep(i, -1),
                        onMoveDown: () => _moveStep(i, 1),
                        onDelete: () => _removeStep(i),
                        onChanged: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 50),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add a step',
                      style: AppTextStyles.t(12, c: AppColors.textMuted),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final t in StepType.values)
                          _AddStepChip(type: t, onTap: () => _addStep(t)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  STEP EDITOR
// ════════════════════════════════════════════════════════════════════════════

class _StepEditor extends StatefulWidget {
  const _StepEditor({
    required this.step,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onChanged,
  });

  final FlowStep step;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;
  final VoidCallback onChanged;

  @override
  State<_StepEditor> createState() => _StepEditorState();
}

class _StepEditorState extends State<_StepEditor> {
  AutomationProvider get _provider => context.read<AutomationProvider>();

  FlowStep get s => widget.step;

  TextEditingController get _text => _provider.stepTextController(s.id);

  TextEditingController get _option => _provider.optionController(s.id);

  void _insertVariable() {
    _provider.insertVariable(s.id);
  }

  void _addOption(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return;

    if (s.options.length >= AutomationProvider.maxQuickReplies) {
      AppSnackBar.info(
        context,
        'Instagram allows up to ${AutomationProvider.maxQuickReplies} quick replies',
      );
      return;
    }

    if (s.options.contains(value)) return;
    _provider.addQuickReply(s.id, value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final color = s.type.color;

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StudioIconBox(s.type.icon, color, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      s.type.label,
                      style: AppTextStyles.t(13.5, w: FontWeight.w700),
                    ),
                  ),
                  _IconAction(
                    icon: RemixIcons.arrow_up_s_line,
                    onTap: widget.canMoveUp ? widget.onMoveUp : null,
                  ),
                  _IconAction(
                    icon: RemixIcons.arrow_down_s_line,
                    onTap: widget.canMoveDown ? widget.onMoveDown : null,
                  ),
                  _IconAction(
                    icon: RemixIcons.delete_bin_line,
                    color: AppColors.error,
                    onTap: widget.onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _body(),
            ],
          ),
        );
      },
    );
  }

  Widget _body() {
    switch (s.type) {
      case StepType.sendMessage:
      case StepType.replyComment:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _text,
              minLines: 3,
              maxLines: 5,
              maxLength: 1000,
              style: AppTextStyles.t(13.5, h: 1.4),
              onChanged: (value) => _provider.updateStepText(s.id, value),
              decoration: AppInputDecorations.dec(
                s.type == StepType.replyComment
                    ? 'Public reply under the comment...'
                    : 'Write the message your customer will receive...',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _ChoicePill(
                  label: '{first_name}',
                  selected: false,
                  onTap: _insertVariable,
                ),
                const Spacer(),
                Text(
                  '${_text.text.length}/1000',
                  style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                ),
              ],
            ),
          ],
        );

      case StepType.quickReplies:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 4,
              style: AppTextStyles.t(13.5, h: 1.4),
              onChanged: (value) => _provider.updateStepText(s.id, value),
              decoration: AppInputDecorations.dec('Ask a question...'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _option,
                    style: AppTextStyles.t(13.5),
                    onSubmitted: _addOption,
                    decoration: AppInputDecorations.dec(
                      'Button label (max 3)',
                      icon: RemixIcons.list_check,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GhostButton(
                  label: 'Add',
                  icon: RemixIcons.add_line,
                  onTap: () => _addOption(_option.text),
                ),
              ],
            ),
            if (s.options.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final option in s.options)
                    _KeywordChip(
                      label: option,
                      onRemove: () => _provider.removeQuickReply(s.id, option),
                    ),
                ],
              ),
            ],
          ],
        );

      case StepType.delay:
        const presets = {
          '1 min': 1,
          '5 min': 5,
          '30 min': 30,
          '1 hour': 60,
          '24 hours': 1440,
        };

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pause the flow before the next step.',
              style: AppTextStyles.t(12.5, c: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in presets.entries)
                  _ChoicePill(
                    label: entry.key,
                    selected: s.delayMinutes == entry.value,
                    onTap: () => _provider.updateDelay(s.id, entry.value),
                  ),
              ],
            ),
          ],
        );

      case StepType.addTag:
        return TextField(
          controller: _text,
          style: AppTextStyles.t(13.5),
          onChanged: (value) => _provider.updateStepText(s.id, value),
          decoration: AppInputDecorations.dec(
            'Tag name, e.g. Hot lead',
            icon: RemixIcons.price_tag_3_line,
          ),
        );
    }
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textSecondary,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 17,
          color: onTap == null ? color.withValues(alpha: .3) : color,
        ),
      ),
    );
  }
}

class _AddStepChip extends StatelessWidget {
  const _AddStepChip({required this.type, required this.onTap});

  final StepType type;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: type.color.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: type.color.withValues(alpha: .28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(type.icon, size: 15, color: type.color),
            const SizedBox(width: 7),
            Text(
              type.label,
              style: AppTextStyles.t(12.5, w: FontWeight.w600, c: type.color),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  LIVE PREVIEW  –  fixed iPhone + real Instagram DM view
// ════════════════════════════════════════════════════════════════════════════

// ── Instagram dark-mode tokens ───────────────────────────────────────────────
const Color _igBlack = Color(0xFF000000);
const Color _igBubbleGrey = Color(0xFF262626);
const Color _igBorder = Color(0xFF363636);
const Color _igSubtle = Color(0xFF8E8E8E);
const Color _igBlue = Color(0xFF3797F0);
const LinearGradient _igSentGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF7A4DFF), Color(0xFF3B82F6)],
);
const LinearGradient _igStoryGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [
    Color(0xFF515BD4),
    Color(0xFF8134AF),
    Color(0xFFDD2A7B),
    Color(0xFFF58529),
  ],
);

// ── Fixed side panel (never scrolls) ─────────────────────────────────────────

class _FixedPreviewPanel extends StatelessWidget {
  const _FixedPreviewPanel({
    required this.trigger,
    required this.keywords,
    required this.steps,
  });

  final TriggerType trigger;
  final List<String> keywords;
  final List<FlowStep> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      margin: const EdgeInsets.fromLTRB(0, 24, 24, 24),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                RemixIcons.smartphone_line,
                size: 17,
                color: AppColors.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live preview',
                      style: AppTextStyles.t(13, w: FontWeight.w700),
                    ),
                    Text(
                      'Updates as you edit your flow',
                      style: AppTextStyles.t(10.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill('Instagram', color: AppColors.igColor),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Center(
              child: FittedBox(
                fit: BoxFit.contain,
                child: _InstagramPhone(
                  trigger: trigger,
                  keywords: keywords,
                  steps: steps,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sample data · {first_name} shows as "Alex"',
            style: AppTextStyles.t(10.5, c: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Chat timeline model ──────────────────────────────────────────────────────

enum _RowKind {
  time,
  message,
  publicReply,
  commentCard,
  storyCard,
  quickReplies,
}

class _ChatRow {
  const _ChatRow(
    this.kind, {
    this.text = '',
    this.mine = false,
    this.options = const [],
    this.mention = false,
  });

  final _RowKind kind;
  final String text;
  final bool mine;
  final List<String> options;
  final bool mention;
}

// ── iPhone + Instagram DM ────────────────────────────────────────────────────

class _InstagramPhone extends StatefulWidget {
  const _InstagramPhone({
    required this.trigger,
    required this.keywords,
    required this.steps,
  });

  final TriggerType trigger;
  final List<String> keywords;
  final List<FlowStep> steps;

  @override
  State<_InstagramPhone> createState() => _InstagramPhoneState();
}

class _InstagramPhoneState extends State<_InstagramPhone> {
  static const double _screenW = 393;
  static const double _screenH = 852;
  static const String username = 'aurenessence';

  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollToEnd();
  }

  @override
  void didUpdateWidget(covariant _InstagramPhone oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scrollToEnd();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  String _fill(String s) => s.replaceAll('{first_name}', 'Alex');

  String _timeLabel(int minutes) {
    final h24 = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final h12 = h24 % 12 == 0 ? 12 : h24 % 12;
    final ap = h24 >= 12 ? 'PM' : 'AM';
    return 'Today $h12:${m.toString().padLeft(2, '0')} $ap';
  }

  List<_ChatRow> _timeline() {
    final rows = <_ChatRow>[];
    var clock = 9 * 60 + 41;
    final sample = widget.keywords.isNotEmpty ? widget.keywords.first : 'PRICE';

    rows.add(_ChatRow(_RowKind.time, text: _timeLabel(clock)));

    switch (widget.trigger) {
      case TriggerType.commentKeyword:
        rows.add(_ChatRow(_RowKind.commentCard, text: sample));
      case TriggerType.dmKeyword:
        rows.add(_ChatRow(_RowKind.message, text: sample));
      case TriggerType.storyReply:
        rows.add(const _ChatRow(_RowKind.storyCard));
        rows.add(const _ChatRow(_RowKind.message, text: 'Love this!'));
      case TriggerType.storyMention:
        rows.add(const _ChatRow(_RowKind.storyCard, mention: true));
    }

    for (final s in widget.steps) {
      switch (s.type) {
        case StepType.sendMessage:
          if (s.text.trim().isNotEmpty) {
            rows.add(
              _ChatRow(_RowKind.message, text: _fill(s.text), mine: true),
            );
          }
        case StepType.replyComment:
          if (s.text.trim().isNotEmpty) {
            rows.add(
              _ChatRow(_RowKind.publicReply, text: _fill(s.text), mine: true),
            );
          }
        case StepType.quickReplies:
          if (s.text.trim().isNotEmpty) {
            rows.add(
              _ChatRow(_RowKind.message, text: _fill(s.text), mine: true),
            );
          }
          if (s.options.isNotEmpty) {
            rows.add(_ChatRow(_RowKind.quickReplies, options: s.options));
          }
        case StepType.delay:
          clock += s.delayMinutes;
          rows.add(_ChatRow(_RowKind.time, text: _timeLabel(clock)));
        case StepType.addTag:
          break; // internal CRM action, the customer never sees it
      }
    }
    return rows;
  }

  bool _isMsg(List<_ChatRow> r, int i, bool mine) =>
      i >= 0 &&
      i < r.length &&
      r[i].kind == _RowKind.message &&
      r[i].mine == mine;

  @override
  Widget build(BuildContext context) {
    final rows = _timeline();
    final hasReply = rows.any((r) => r.kind == _RowKind.message && r.mine);
    final lastIsMine =
        rows.isNotEmpty && rows.last.kind == _RowKind.message && rows.last.mine;

    final body = <Widget>[
      const _IgProfileIntro(name: 'aurenessence', username: username),
    ];

    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      switch (r.kind) {
        case _RowKind.time:
          body.add(_IgTimeLabel(r.text));
        case _RowKind.message:
          final joinTop = _isMsg(rows, i - 1, r.mine);
          final joinBottom = _isMsg(rows, i + 1, r.mine);
          body.add(
            Padding(
              padding: EdgeInsets.only(top: joinTop ? 2 : 10),
              child: _IgBubble(
                text: r.text,
                mine: r.mine,
                joinTop: joinTop,
                joinBottom: joinBottom,
                showAvatar: !r.mine && !joinBottom,
              ),
            ),
          );
        case _RowKind.publicReply:
          body.add(
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "You replied to $username's comment",
                    style: AppTextStyles.t(11.5, c: _igSubtle),
                  ),
                  const SizedBox(height: 5),
                  _IgBubble(
                    text: r.text,
                    mine: true,
                    joinTop: false,
                    joinBottom: false,
                    outlined: true,
                  ),
                ],
              ),
            ),
          );
        case _RowKind.commentCard:
          body.add(
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          gradient: _igStoryGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '@syamthecreator commented on your post',
                        style: AppTextStyles.t(11.5, c: _igSubtle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 34),
                    child: _IgBubble(
                      text: r.text,
                      mine: false,
                      joinTop: false,
                      joinBottom: false,
                      showAvatar: false,
                      reserveAvatar: false,
                    ),
                  ),
                ],
              ),
            ),
          );
        case _RowKind.storyCard:
          body.add(
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _IgStoryCard(
                caption: r.mention
                    ? '$username mentioned you in their story'
                    : '$username replied to your story',
                mention: r.mention,
              ),
            ),
          );
        case _RowKind.quickReplies:
          body.add(
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final o in r.options)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _igBlue, width: 1),
                      ),
                      child: Text(
                        o,
                        style: AppTextStyles.t(
                          14,
                          w: FontWeight.w600,
                          c: _igBlue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
      }
    }

    if (lastIsMine) {
      body.add(
        Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text('Seen', style: AppTextStyles.t(11.5, c: _igSubtle)),
          ),
        ),
      );
    }

    if (!hasReply) {
      body.add(
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Center(
            child: Text(
              'Add a message step to see\nyour automated reply here',
              textAlign: TextAlign.center,
              style: AppTextStyles.t(13, c: _igSubtle, h: 1.5),
            ),
          ),
        ),
      );
    }

    // Device sizing: bezel 8 + titanium 4 on each side
    const frameW = _screenW + 2 * (8 + 4);
    const frameH = _screenH + 2 * (8 + 4);

    return SizedBox(
      width: frameW + 8,
      height: frameH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Hardware buttons
          const Positioned(left: 0, top: 150, child: _SideButton(height: 32)),
          const Positioned(left: 0, top: 205, child: _SideButton(height: 62)),
          const Positioned(left: 0, top: 280, child: _SideButton(height: 62)),
          const Positioned(right: 0, top: 235, child: _SideButton(height: 98)),

          // Titanium frame
          Positioned(
            left: 4,
            right: 4,
            top: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF5A606B),
                    Color(0xFF2B2F36),
                    Color(0xFF4A505A),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .45),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(60),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(52),
                  child: Container(
                    color: _igBlack,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            const SizedBox(height: 54), // status bar space
                            const _IgChatHeader(
                              username: username,
                              accountType: "Business Chat",
                            ),
                            Expanded(
                              child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context)
                                    .copyWith(scrollbars: false),
                                child: ListView(
                                  controller: _scroll,
                                  physics: const ClampingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    6,
                                    14,
                                    14,
                                  ),
                                  children: body,
                                ),
                              ),
                            ),
                            const _IgComposer(),
                            const _HomeIndicator(),
                          ],
                        ),

                        // Status bar
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 54,
                          child: _IosStatusBar(),
                        ),

                        // Dynamic Island
                        Positioned(
                          top: 11,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 124,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Align(
                                alignment: const Alignment(.62, 0),
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF0B0E16),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF4A505A),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

class _IosStatusBar extends StatelessWidget {
  const _IosStatusBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 8, 34, 0),
      child: Row(
        children: [
          Text(
            '9:41',
            style: AppTextStyles.t(17, w: FontWeight.w700, c: Colors.white),
          ),
          const Spacer(),
          const Icon(
            Icons.signal_cellular_alt_rounded,
            size: 18,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          const Icon(Icons.wifi_rounded, size: 18, color: Colors.white),
          const SizedBox(width: 5),
          const Icon(Icons.battery_full_rounded, size: 25, color: Colors.white),
        ],
      ),
    );
  }
}

class _HomeIndicator extends StatelessWidget {
  const _HomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      color: _igBlack,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(bottom: 4),
      child: Container(
        width: 136,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

// ── Instagram chat pieces ────────────────────────────────────────────────────

class _IgAvatar extends StatelessWidget {
  const _IgAvatar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F5B73), Color(0xFF2A3142)],
        ),
      ),
      child: Text(
        'a',
        style: AppTextStyles.t(size * .42, w: FontWeight.w700, c: Colors.white),
      ),
    );
  }
}

class _IgChatHeader extends StatelessWidget {
  const _IgChatHeader({required this.accountType, required this.username});

  final String accountType;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: _igBlack,
        border: Border(bottom: BorderSide(color: Color(0xFF1A1A1A))),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 12),
          const _IgAvatar(size: 38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.t(
                    15,
                    w: FontWeight.w700,
                    c: Colors.white,
                  ),
                ),
                Text(
                  accountType,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.t(12, c: _igSubtle),
                ),
              ],
            ),
          ),
          const Icon(Icons.call_outlined, size: 25, color: Colors.white),
          const SizedBox(width: 18),
          const Icon(Icons.videocam_outlined, size: 28, color: Colors.white),
        ],
      ),
    );
  }
}

class _IgProfileIntro extends StatelessWidget {
  const _IgProfileIntro({required this.name, required this.username});

  final String name;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Column(
        children: [
          const _IgAvatar(size: 84),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.t(18, w: FontWeight.w700, c: Colors.white),
          ),
          const SizedBox(height: 3),
          Text(
            '$username · Instagram',
            style: AppTextStyles.t(13, c: _igSubtle),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: _igBubbleGrey,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              'View profile',
              style: AppTextStyles.t(13.5, w: FontWeight.w600, c: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _IgTimeLabel extends StatelessWidget {
  const _IgTimeLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(text, style: AppTextStyles.t(11.5, c: _igSubtle)),
      ),
    );
  }
}

class _IgBubble extends StatelessWidget {
  const _IgBubble({
    required this.text,
    required this.mine,
    required this.joinTop,
    required this.joinBottom,
    this.showAvatar = false,
    this.reserveAvatar = true,
    this.outlined = false,
  });

  final String text;
  final bool mine;
  final bool joinTop;
  final bool joinBottom;
  final bool showAvatar;
  final bool reserveAvatar;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    const big = Radius.circular(22);
    const small = Radius.circular(6);

    final radius = mine
        ? BorderRadius.only(
            topLeft: big,
            bottomLeft: big,
            topRight: joinTop ? small : big,
            bottomRight: joinBottom ? small : big,
          )
        : BorderRadius.only(
            topRight: big,
            bottomRight: big,
            topLeft: joinTop ? small : big,
            bottomLeft: joinBottom ? small : big,
          );

    final bubble = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 252),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: mine && !outlined ? _igSentGradient : null,
          color: mine ? null : _igBubbleGrey,
          borderRadius: radius,
          border: outlined ? Border.all(color: _igBorder) : null,
        ),
        child: Text(
          text,
          style: AppTextStyles.t(
            15,
            w: FontWeight.w400,
            c: Colors.white,
            h: 1.3,
          ),
        ),
      ),
    );

    return Row(
      mainAxisAlignment: mine ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!mine && reserveAvatar) ...[
          showAvatar ? const _IgAvatar(size: 26) : const SizedBox(width: 26),
          const SizedBox(width: 8),
        ],
        Flexible(child: bubble),
      ],
    );
  }
}

class _IgStoryCard extends StatelessWidget {
  const _IgStoryCard({required this.caption, required this.mention});

  final String caption;
  final bool mention;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: AppTextStyles.t(11.5, c: _igSubtle)),
        const SizedBox(height: 8),
        Container(
          width: 128,
          height: 214,
          decoration: BoxDecoration(
            gradient: _igStoryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    mention ? _InstagramPhoneState.username : 'yourbrand',
                    style: AppTextStyles.t(
                      10.5,
                      w: FontWeight.w700,
                      c: Colors.white,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (mention)
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .45),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '@yourbrand',
                      style: AppTextStyles.t(
                        12,
                        w: FontWeight.w700,
                        c: Colors.white,
                      ),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

class _IgComposer extends StatelessWidget {
  const _IgComposer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _igBlack,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF7A4DFF)],
              ),
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              size: 21,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _igBubbleGrey,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Message...',
                      style: AppTextStyles.t(
                        15,
                        w: FontWeight.w400,
                        c: _igSubtle,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.mic_none_rounded,
                    size: 23,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.image_outlined,
                    size: 23,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 14),
                  const Icon(
                    Icons.emoji_emotions_outlined,
                    size: 23,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
//  SHARED BUILDER WIDGETS
// ════════════════════════════════════════════════════════════════════════════

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final int number;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      hoverable: false,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: AppColors.darkGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$number',
                  style: AppTextStyles.t(
                    13,
                    w: FontWeight.w700,
                    c: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.t(16, w: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.t(
          12,
          w: FontWeight.w600,
          c: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .14)
              : AppColors.surfaceVariant.withValues(alpha: .5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.t(
            12,
            w: FontWeight.w600,
            c: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  const _ChannelTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.comingSoon = false,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool selected;
  final bool comingSoon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: comingSoon ? .65 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: .10)
                : AppColors.surfaceVariant.withValues(alpha: .45),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? color : AppColors.border),
          ),
          child: Row(
            children: [
              StudioIconBox(icon, color, size: 38),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.t(13.5, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.t(11.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              if (comingSoon)
                const StudioPill('Soon', color: AppColors.waColor)
              else if (selected)
                Icon(RemixIcons.checkbox_circle_fill, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _TriggerTile extends StatelessWidget {
  const _TriggerTile({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final TriggerType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: .10)
              : AppColors.surfaceVariant.withValues(alpha: .45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StudioIconBox(
              type.icon,
              selected ? AppColors.primary : AppColors.igColor,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.title,
                    style: AppTextStyles.t(13.5, w: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    type.description,
                    style: AppTextStyles.t(12, c: AppColors.textMuted, h: 1.4),
                  ),
                ],
              ),
            ),
            if (selected)
              const Padding(
                padding: EdgeInsets.only(left: 6),
                child: Icon(
                  RemixIcons.checkbox_circle_fill,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: .4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            RemixIcons.information_line,
            size: 16,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.t(12, c: AppColors.textMuted, h: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
