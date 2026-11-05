// ════════════════════════════════════════════════════════════════════════════
//  3. INBOX
// ════════════════════════════════════════════════════════════════════════════

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/utils/helper.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/studio_avatar.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class _Msg {
  const _Msg(this.text, this.from, this.time);
  final String text;
  final int from; // 0 customer, 1 automation, 2 agent
  final String time;
}

class _Convo {
  _Convo(
    this.name,
    this.handle,
    this.channel,
    this.preview,
    this.time,
    this.unread,
    this.window,
    this.urgent,
    this.msgs,
  );
  final String name, handle, channel, preview, time, window;
  final int unread;
  final bool urgent;
  final List<_Msg> msgs;
}

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  int _sel = 0;
  int _tab = 0;
  final _ctrl = TextEditingController();

  final _all = [
    _Convo(
      'Rohan Mehta',
      '+91 98765 43210',
      'WhatsApp',
      'Can I change the delivery address?',
      '2m',
      2,
      '21h left',
      false,
      [
        const _Msg(
          'Hi Rohan, your order #4821 has shipped and will arrive on Friday.',
          1,
          '10:02',
        ),
        const _Msg(
          'Great, thanks. Can I change the delivery address?',
          0,
          '10:05',
        ),
        const _Msg(
          'Of course. Which address should we use instead?',
          2,
          '10:06',
        ),
        const _Msg('Can I change the delivery address?', 0, '10:07'),
      ],
    ),
    _Convo(
      'Priya Nair',
      '@priya.styles',
      'Instagram',
      'Do you have this in size M?',
      '14m',
      1,
      '23h left',
      false,
      [
        const _Msg(
          'Replied to your story: Do you have the linen shirt in size M?',
          0,
          '09:41',
        ),
        const _Msg(
          'Thanks for your message! Let me check stock for you.',
          1,
          '09:41',
        ),
      ],
    ),
    _Convo(
      'Daniel Okafor',
      '+234 803 555 0142',
      'WhatsApp',
      'Thanks, coupon worked!',
      '1h',
      0,
      '1h 20m left',
      true,
      [
        const _Msg(
          'Your cart is waiting. Use CART10 for 10% off today.',
          1,
          '08:15',
        ),
        const _Msg('Thanks, coupon worked!', 0, '08:52'),
      ],
    ),
    _Convo(
      'Sofia Alvarez',
      '@sofia.alvarez',
      'Instagram',
      'PRICE',
      '3h',
      1,
      '4h left',
      false,
      [
        const _Msg('PRICE', 0, '07:20'),
        const _Msg(
          'Hi Sofia! Here is our price list. Tap below to see the full catalog.',
          1,
          '07:20',
        ),
        const _Msg('Can I get the wholesale rate?', 0, '07:34'),
      ],
    ),
    _Convo(
      'Kenji Watanabe',
      '@kenji.w',
      'Instagram',
      'Is the webinar recorded?',
      '5h',
      0,
      '1h left',
      true,
      [
        const _Msg('Reminder: your webinar starts in 30 minutes.', 1, '05:30'),
        const _Msg('Is the webinar recorded?', 0, '05:44'),
      ],
    ),
  ];

  List<_Convo> get _visible => _tab == 0
      ? _all
      : _all
            .where((c) => c.channel == (_tab == 1 ? 'WhatsApp' : 'Instagram'))
            .toList();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send(_Convo convo) {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return;
    setState(() {
      convo.msgs.add(_Msg(t, 2, 'now'));
      _ctrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;
    final convo = visible[_sel.clamp(0, visible.length - 1)];
    final ch = Helper.getChannel(convo.channel);
    return StudioPage(
      children: [
        SizedBox(
          height: 700,
          child: StudioCard(
            padding: EdgeInsets.zero,
            child: LayoutBuilder(
              builder: (context, c) {
                final listW = c.maxWidth < 900 ? 250.0 : 330.0;
                final showInfo = c.maxWidth > 1150;
                return Row(
                  children: [
                    SizedBox(
                      width: listW,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextField(
                                  style: AppTextStyles.t(14),
                                  cursorColor: AppColors.primary,
                                  decoration: AppInputDecorations.dec(
                                    'Search conversations',
                                    icon: RemixIcons.search_line,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: StudioChips(
                                    options: const [
                                      'All',
                                      'WhatsApp',
                                      'Instagram',
                                    ],
                                    selected: _tab,
                                    onChanged: (i) => setState(() {
                                      _tab = i;
                                      _sel = 0;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: AppColors.border),
                          Expanded(
                            child: ListView.builder(
                              itemCount: visible.length,
                              itemBuilder: (context, i) {
                                final cv = visible[i];
                                final active = identical(cv, convo);
                                final cc = Helper.getChannel(cv.channel);
                                return InkWell(
                                  onTap: () => setState(() => _sel = i),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: active
                                          ? AppColors.primary.withValues(
                                              alpha: .08,
                                            )
                                          : null,
                                      border: Border(
                                        left: BorderSide(
                                          color: active
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          width: 3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            StudioAvatar(cv.name, size: 42),
                                            Positioned(
                                              right: -3,
                                              bottom: -3,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.surface,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.border,
                                                  ),
                                                ),
                                                child: Icon(
                                                  cc.icon,
                                                  size: 11,
                                                  color: cc.color,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      cv.name,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: AppTextStyles.t(
                                                        14,
                                                        w: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    cv.time,
                                                    style: AppTextStyles.t(
                                                      11.5,
                                                      c: AppColors.textMuted,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      cv.preview,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: AppTextStyles.t(
                                                        12.5,
                                                        c: cv.unread > 0
                                                            ? AppColors
                                                                  .textPrimary
                                                            : AppColors
                                                                  .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                  if (cv.unread > 0)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                            left: 6,
                                                          ),
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 7,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.primary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        '${cv.unread}',
                                                        style: AppTextStyles.t(
                                                          10.5,
                                                          w: FontWeight.w800,
                                                          c: AppColors
                                                              .onPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, color: AppColors.border),
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                StudioAvatar(convo.name, size: 40),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        convo.name,
                                        style: AppTextStyles.t(
                                          15,
                                          w: FontWeight.w700,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            ch.icon,
                                            size: 13,
                                            color: ch.color,
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              '${convo.channel} · ${convo.handle}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTextStyles.t(
                                                12,
                                                c: AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                StudioPill(
                                  '24h window · ${convo.window}',
                                  color: convo.urgent
                                      ? AppColors.warning
                                      : AppColors.success,
                                  icon: RemixIcons.time_line,
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  RemixIcons.more_2_fill,
                                  size: 20,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                          ),
                          Container(height: 1, color: AppColors.border),
                          Expanded(
                            child: ListView(
                              reverse: true,
                              padding: const EdgeInsets.all(20),
                              children: [
                                for (final m in convo.msgs.reversed) _Bubble(m),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  for (final q in [
                                    'Send price list',
                                    'Share catalog link',
                                    'Confirm order status',
                                  ])
                                    ActionChip(
                                      label: Text(
                                        q,
                                        style: AppTextStyles.t(
                                          12,
                                          c: AppColors.textSecondary,
                                        ),
                                      ),
                                      backgroundColor: AppColors.surfaceVariant
                                          .withValues(alpha: .6),
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      onPressed: () =>
                                          setState(() => _ctrl.text = q),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _ctrl,
                                    onSubmitted: (_) => _send(convo),
                                    style: AppTextStyles.t(14),
                                    cursorColor: AppColors.primary,
                                    decoration: AppInputDecorations.dec(
                                      'Write a reply on ${convo.channel}',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                GradientButton(
                                  label: 'Send',
                                  icon: RemixIcons.send_plane_2_line,
                                  onTap: () => _send(convo),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (showInfo) ...[
                      Container(width: 1, color: AppColors.border),
                      SizedBox(width: 280, child: _ContactInfo(convo)),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.m);
  final _Msg m;

  @override
  Widget build(BuildContext context) {
    final mine = m.from != 0;
    final bot = m.from == 1;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 440),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          gradient: mine && !bot ? AppColors.darkGradient : null,
          color: bot
              ? AppColors.paletteCyberNavy
              : (mine ? null : AppColors.surfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (bot)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      RemixIcons.robot_2_line,
                      size: 12,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Automation',
                      style: AppTextStyles.t(
                        11,
                        w: FontWeight.w600,
                        c: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              m.text,
              style: AppTextStyles.t(
                14,
                c: mine && !bot ? Colors.white : AppColors.textPrimary,
                h: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              m.time,
              style: AppTextStyles.t(
                10.5,
                c: mine && !bot ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo(this.c);
  final _Convo c;

  Widget _row(String k, String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        Expanded(
          child: Text(k, style: AppTextStyles.t(12.5, c: AppColors.textMuted)),
        ),
        Text(v, style: AppTextStyles.t(12.5, w: FontWeight.w600)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: StudioAvatar(c.name, size: 72)),
          const SizedBox(height: 12),
          Center(
            child: Text(c.name, style: AppTextStyles.t(16, w: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              c.handle,
              style: AppTextStyles.t(12, c: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          _row('Channel', c.channel),
          _row('Orders', '7'),
          _row('Lifetime value', '₹48,200'),
          _row(
            'Last automation',
            c.channel == 'Instagram' ? 'Comment to DM' : 'Order updates',
          ),
          const SizedBox(height: 12),
          Text('Tags', style: AppTextStyles.t(12.5, c: AppColors.textMuted)),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StudioPill('Hot lead', color: AppColors.accent, dot: false),
              StudioPill(
                'Repeat buyer',
                color: AppColors.secondary,
                dot: false,
              ),
              StudioPill('Mumbai', color: AppColors.textSecondary, dot: false),
            ],
          ),
        ],
      ),
    );
  }
}
