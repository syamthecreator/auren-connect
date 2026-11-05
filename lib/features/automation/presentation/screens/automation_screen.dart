// ════════════════════════════════════════════════════════════════════════════
//  2. AUTOMATIONS
// ════════════════════════════════════════════════════════════════════════════

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/utils/helper.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/section_title.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_page_heading.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class _Flow {
  const _Flow(
    this.name,
    this.desc,
    this.channel,
    this.steps,
    this.runs,
    this.success,
    this.icon,
  );
  final String name, desc, channel, runs, success;
  final List<String> steps;
  final IconData icon;
}

class AutomationsScreen extends StatefulWidget {
  const AutomationsScreen({super.key});

  @override
  State<AutomationsScreen> createState() => _AutomationsScreenState();
}

class _AutomationsScreenState extends State<AutomationsScreen> {
  static const _flows = [
    _Flow(
      'Comment to DM',
      'Sends a DM with your link when someone comments a keyword on a Reel or post.',
      'Instagram',
      ['Comment has “PRICE”', 'Reply to comment', 'Send DM', 'Wait for reply'],
      '6,420',
      '96%',
      RemixIcons.chat_smile_2_line,
    ),
    _Flow(
      'Story reply responder',
      'Answers story replies and asks what the customer is looking for.',
      'Instagram',
      ['Story reply', 'Auto reply', 'Ask interest', 'Tag lead'],
      '3,188',
      '94%',
      RemixIcons.camera_lens_line,
    ),
    _Flow(
      'Welcome DM',
      'Greets first-time messengers and offers quick reply buttons.',
      'Instagram',
      ['First message', 'Greeting', 'Quick replies', 'Route by choice'],
      '2,905',
      '98%',
      RemixIcons.hand_heart_line,
    ),
    _Flow(
      'Ice breaker FAQs',
      'Answers the questions people tap on your profile Message screen.',
      'Instagram',
      ['Tap ice breaker', 'Answer FAQ', 'Offer human'],
      '1,240',
      '97%',
      RemixIcons.question_answer_line,
    ),
    _Flow(
      'Abandoned cart',
      'Reminds shoppers about items they left behind, then sends a coupon.',
      'WhatsApp',
      ['Cart idle 1 hr', 'Template reminder', 'If no purchase', 'Send coupon'],
      '1,982',
      '94%',
      RemixIcons.shopping_cart_2_line,
    ),
    _Flow(
      'Order updates',
      'Sends receipts, shipping and delivery status automatically.',
      'WhatsApp',
      ['Order placed', 'Receipt', 'Shipped', 'Tracking link'],
      '9,744',
      '99%',
      RemixIcons.truck_line,
    ),
    _Flow(
      'Welcome series',
      'Greets every new opt-in and shares your best offer over two days.',
      'WhatsApp',
      ['New opt-in', 'Wait 5 min', 'Welcome', 'Wait 2 days', 'Offer'],
      '4,210',
      '97%',
      RemixIcons.user_smile_line,
    ),
    _Flow(
      'Out-of-hours reply',
      'Answers instantly when your team is offline and assigns for morning.',
      'WhatsApp',
      ['Message received', 'Outside 9–6', 'Auto reply', 'Assign tomorrow'],
      '688',
      '100%',
      RemixIcons.moon_line,
    ),
  ];

  int _chan = 0;
  final Set<String> _off = {'Out-of-hours reply'};

  @override
  Widget build(BuildContext context) {
    final list = _chan == 0
        ? _flows
        : _flows
              .where(
                (f) => f.channel == (_chan == 1 ? 'Instagram' : 'WhatsApp'),
              )
              .toList();
    return StudioPage(
      children: [
        const StudioPageHeading(
          actions: [
            GhostButton(label: 'Browse recipes', icon: RemixIcons.magic_line),
            GradientButton(label: 'New automation', icon: RemixIcons.add_line),
          ],
        ),
        const _FlowBuilderPreview(),
        StudioChips(
          options: const ['All automations', 'Instagram', 'WhatsApp'],
          selected: _chan,
          onChanged: (i) => setState(() => _chan = i),
        ),
        ResponsiveGrid(
          minItemWidth: 360,
          maxColumns: 3,
          children: [
            for (final f in list)
              StudioCard(
                hoverable: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StudioIconBox(
                          f.icon,
                          Helper.getChannel(f.channel).color,
                          size: 42,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: AppTextStyles.t(
                                  15.5,
                                  w: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Helper.getChannel(f.channel).icon,
                                    size: 13,
                                    color: Helper.getChannel(f.channel).color,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    f.channel,
                                    style: AppTextStyles.t(
                                      12,
                                      c: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: !_off.contains(f.name),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(
                            alpha: .3,
                          ),
                          inactiveThumbColor: AppColors.textMuted,
                          inactiveTrackColor: AppColors.border,
                          onChanged: (v) => setState(
                            () => v ? _off.remove(f.name) : _off.add(f.name),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      f.desc,
                      style: AppTextStyles.t(
                        13,
                        c: AppColors.textSecondary,
                        h: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (var s = 0; s < f.steps.length; s++) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withValues(
                                alpha: .7,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              f.steps[s],
                              style: AppTextStyles.t(
                                11.5,
                                c: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (s != f.steps.length - 1)
                            const Icon(
                              RemixIcons.arrow_right_s_line,
                              size: 14,
                              color: AppColors.textMuted,
                            ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${f.runs} runs',
                            style: AppTextStyles.t(
                              12.5,
                              c: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Text(
                          '${f.success} success',
                          style: AppTextStyles.t(
                            12.5,
                            w: FontWeight.w700,
                            c: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 12),
                        StudioPill(
                          _off.contains(f.name) ? 'Paused' : 'Active',
                          color: _off.contains(f.name)
                              ? AppColors.textMuted
                              : AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _FlowBuilderPreview extends StatefulWidget {
  const _FlowBuilderPreview();

  @override
  State<_FlowBuilderPreview> createState() => _FlowBuilderPreviewState();
}

class _FlowBuilderPreviewState extends State<_FlowBuilderPreview> {
  int _tab = 0;

  static const _ig = [
    (
      RemixIcons.chat_smile_2_line,
      AppColors.igColor,
      'Trigger',
      'Comment contains “PRICE”',
    ),
    (
      RemixIcons.reply_line,
      AppColors.secondary,
      'Public reply',
      'Check your DMs',
    ),
    (
      RemixIcons.send_plane_2_line,
      AppColors.igColor,
      'Send DM',
      'Price list with button',
    ),
    (
      RemixIcons.git_branch_line,
      AppColors.warning,
      'Condition',
      'Replied within 24h?',
    ),
    (
      RemixIcons.customer_service_2_line,
      AppColors.accent,
      'Hand over',
      'Assign to sales team',
    ),
  ];
  static const _wa = [
    (
      RemixIcons.shopping_cart_2_line,
      AppColors.waColor,
      'Trigger',
      'Cart idle for 1 hour',
    ),
    (
      RemixIcons.file_list_3_line,
      AppColors.waColor,
      'Template',
      'cart_reminder',
    ),
    (
      RemixIcons.git_branch_line,
      AppColors.warning,
      'Condition',
      'Purchased in 24h?',
    ),
    (
      RemixIcons.coupon_3_line,
      AppColors.accent,
      'Send coupon',
      'CART10 · 10% off',
    ),
    (
      RemixIcons.customer_service_2_line,
      AppColors.secondary,
      'Hand over',
      'Assign if they reply',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final nodes = _tab == 0 ? _ig : _wa;
    return StudioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            'Flow builder',
            subtitle: _tab == 0
                ? 'Comment to DM · drag steps to reorder'
                : 'Abandoned cart · drag steps to reorder',
            trailing: const StudioPill('Saved', color: AppColors.success),
          ),
          const SizedBox(height: 14),
          StudioChips(
            options: const ['Instagram flow', 'WhatsApp flow'],
            selected: _tab,
            onChanged: (i) => setState(() => _tab = i),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < nodes.length; i++) ...[
                  Container(
                    width: 210,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withValues(alpha: .55),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: nodes[i].$2.withValues(alpha: .4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: nodes[i].$2.withValues(alpha: .10),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        StudioIconBox(nodes[i].$1, nodes[i].$2, size: 38),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nodes[i].$3,
                                style: AppTextStyles.t(
                                  12,
                                  c: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                nodes[i].$4,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.t(
                                  13,
                                  w: FontWeight.w600,
                                  h: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 46,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 2,
                            color: AppColors.primary.withValues(alpha: .45),
                          ),
                        ),
                        const Icon(
                          RemixIcons.arrow_right_s_line,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
                Container(
                  width: 130,
                  height: 70,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1.4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        RemixIcons.add_line,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add step',
                        style: AppTextStyles.t(13, c: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
