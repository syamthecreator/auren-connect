import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/utils/helper.dart';
import 'package:auren_connect/core/utils/shell_scope.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/responsive_grid.dart';
import 'package:auren_connect/core/widgets/section_title.dart';
import 'package:auren_connect/core/widgets/split_row.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';
import 'package:auren_connect/features/overview/presentation/widget/glow.dart';
import 'package:auren_connect/features/overview/presentation/widget/info_banner.dart';
import 'package:auren_connect/features/overview/presentation/widget/legend.dart';
import 'package:auren_connect/features/overview/presentation/widget/progress_bar.dart';
import 'package:auren_connect/features/overview/presentation/widget/spark.dart';
import 'package:auren_connect/features/overview/presentation/widget/stat.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

// ════════════════════════════════════════════════════════════════════════════
//  1. OVERVIEW
// ════════════════════════════════════════════════════════════════════════════

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  int _range = 0;
  int _chan = 0; // 0 both, 1 WhatsApp, 2 Instagram

  static final _stats = [
    Stat(
      'Messages sent',
      '128.4k',
      '12.5%',
      true,
      RemixIcons.send_plane_2_line,
      AppColors.primary,
      Helper.generateWave(count: 14, base: 40, amplitude: 8, phase: 0),
    ),
    Stat(
      'Handled by automation',
      '68%',
      '5.2%',
      true,
      RemixIcons.robot_2_line,
      AppColors.accent,
      Helper.generateWave(count: 14, base: 60, amplitude: 5, phase: 1),
    ),
    Stat(
      'Reply rate',
      '31.4%',
      '3.1%',
      true,
      RemixIcons.chat_3_line,
      AppColors.success,
      Helper.generateWave(count: 14, base: 30, amplitude: 9, phase: 2),
    ),
    Stat(
      'Avg. first response',
      '14 sec',
      '38%',
      true,
      RemixIcons.timer_flash_line,
      AppColors.warning,
      Helper.generateWave(count: 14, base: 50, amplitude: 6, phase: 3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final counts = [7, 15, 20];
    final labels = [
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      ['Oct 6', 'Oct 13', 'Oct 20', 'Oct 27', 'Nov 3'],
      ['Aug', 'Sep', 'Oct', 'Nov'],
    ];
    final n = counts[_range];
    final ph = _range * 1.3;

    final List<List<double>> series;
    final List<Color> colors;
    final List<(String, Color)> legend;

    if (_chan == 0) {
      series = [
        Helper.generateWave(count: n, base: 60, amplitude: 14, phase: ph),
        Helper.generateWave(count: n, base: 40, amplitude: 12, phase: ph + 1.5),
      ];

      colors = [AppColors.waColor, AppColors.igColor];

      legend = [
        ('WhatsApp', AppColors.waColor),
        ('Instagram', AppColors.igColor),
      ];
    } else {
      final c = _chan == 1 ? AppColors.waColor : AppColors.igColor;

      series = [
        Helper.generateWave(
          count: n,
          base: _chan == 1 ? 60 : 40,
          amplitude: 14,
          phase: ph,
        ),
        Helper.generateWave(
          count: n,
          base: _chan == 1 ? 24 : 18,
          amplitude: 7,
          phase: ph + 1,
        ),
      ];

      colors = [c, AppColors.accent];
      legend = [('Sent', c), ('Replied', AppColors.accent)];
    }

    return StudioPage(
      children: [
        const _Hero(),
        ResponsiveGrid(
          minItemWidth: 250,
          children: [for (final s in _stats) StatTile(s)],
        ),
        ResponsiveGrid(
          minItemWidth: 440,
          maxColumns: 2,
          spacing: 20,
          children: [
            _ChannelCard(
              name: 'WhatsApp',
              handle: 'Business · +91 98765 43210',
              metrics: const [
                ('84.2k', 'Sent'),
                ('34.8%', 'Reply rate'),
                ('9', 'Automations'),
              ],
              footer: 'Quality rating: High · Limit 10k conversations a day',
              spark: Helper.generateWave(
                count: 18,
                base: 40,
                amplitude: 9,
                phase: .3,
              ),
            ),
            _ChannelCard(
              name: 'Instagram',
              handle: 'Business · @auren.studio',
              metrics: const [
                ('44.2k', 'Sent'),
                ('26.1%', 'Reply rate'),
                ('6', 'Automations'),
              ],
              footer: '4 comment triggers live · Replies sent inside the 24h window',
              spark: Helper.generateWave(
                count: 18,
                base: 30,
                amplitude: 10,
                phase: 1.4,
              ),
            ),
          ],
        ),
        SplitRow(
          main: StudioCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LayoutBuilder(
                  builder: (context, c) {
                    final ranges = StudioChips(
                      options: const ['7D', '30D', '90D'],
                      selected: _range,
                      onChanged: (i) => setState(() => _range = i),
                    );
                    const title = SectionTitle(
                      'Message performance',
                      subtitle: 'Compare WhatsApp and Instagram',
                    );
                    return c.maxWidth > 620
                        ? Row(
                            children: [
                              const Expanded(child: title),
                              ranges,
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              title,
                              const SizedBox(height: 12),
                              ranges,
                            ],
                          );
                  },
                ),
                const SizedBox(height: 16),
                StudioChips(
                  options: const ['Both channels', 'WhatsApp', 'Instagram'],
                  selected: _chan,
                  onChanged: (i) => setState(() => _chan = i),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  children: [for (final l in legend) Legend(l.$1, l.$2)],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 240,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: LinePainter(series: series, colors: colors),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final l in labels[_range])
                      Text(
                        l,
                        style: AppTextStyles.t(12, c: AppColors.textMuted),
                      ),
                  ],
                ),
              ],
            ),
          ),
          side: const _ServiceWindows(),
          sideWidth: 380,
        ),
        const _Recipes(),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final go = ShellScope.of(context).goTo;
    return StudioCard(
      padding: EdgeInsets.zero,
      radius: 26,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0B2A52), Color(0xFF0E1726), Color(0xFF070C15)],
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -70,
            top: -90,
            child: Glow(300, AppColors.primary, .28),
          ),
          const Positioned(
            right: 160,
            bottom: -120,
            child: Glow(240, AppColors.igColor, .12),
          ),
          const Positioned(
            left: -80,
            bottom: -140,
            child: Glow(260, AppColors.waColor, .10),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth > 820;
                final left = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StudioPill(
                          'WhatsApp connected',
                          color: AppColors.waColor,
                          icon: RemixIcons.whatsapp_line,
                        ),
                        StudioPill(
                          'Instagram connected',
                          color: AppColors.igColor,
                          icon: RemixIcons.instagram_line,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Good evening, Aria',
                      style: AppTextStyles.t(32, w: FontWeight.w700, ls: -1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your automations answered 1,842 WhatsApp and Instagram conversations today. 12 need a human reply.',
                      style: AppTextStyles.t(
                        15,
                        c: AppColors.textSecondary,
                        h: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        GradientButton(
                          label: 'Create automation',
                          icon: RemixIcons.flow_chart,
                          onTap: () => go(NavDestination.automations),
                        ),
                        GhostButton(
                          label: 'Open inbox',
                          icon: RemixIcons.inbox_line,
                          onTap: () => go(NavDestination.inbox),
                        ),
                      ],
                    ),
                  ],
                );
                final live = Container(
                  width: 300,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(
                                    alpha: .7,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Automated replies',
                            style: AppTextStyles.t(
                              13,
                              c: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '342',
                            style: AppTextStyles.t(
                              34,
                              w: FontWeight.w700,
                              ls: -1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'per minute',
                              style: AppTextStyles.t(
                                12.5,
                                c: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Spark(
                        Helper.generateWave(
                          count: 24,
                          base: 40,
                          amplitude: 10,
                          phase: 4,
                        ),
                        AppColors.accent,
                        height: 56,
                      ),
                    ],
                  ),
                );
                return wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: left),
                          const SizedBox(width: 30),
                          live,
                        ],
                      )
                    : left;
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelCard extends StatelessWidget {
  const _ChannelCard({
    required this.name,
    required this.handle,
    required this.metrics,
    required this.footer,
    required this.spark,
  });

  final String name, handle, footer;
  final List<(String, String)> metrics;
  final List<double> spark;

  @override
  Widget build(BuildContext context) {
    final ch = Helper.getChannel(name);
    return StudioCard(
      hoverable: true,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          ch.color.withValues(alpha: .16),
          const Color(0xFF0E1726),
          const Color(0xFF070C15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudioIconBox(ch.icon, ch.color, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.t(17, w: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const StudioPill('Connected', color: AppColors.success),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              for (final m in metrics)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.$1,
                        style: AppTextStyles.t(22, w: FontWeight.w700, ls: -.4),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.$2,
                        style: AppTextStyles.t(12, c: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Spark(spark, ch.color, height: 54),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(RemixIcons.shield_check_line, size: 15, color: ch.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  footer,
                  style: AppTextStyles.t(12, c: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceWindows extends StatelessWidget {
  const _ServiceWindows();

  @override
  Widget build(BuildContext context) {
    Widget row(String channel, int open, int closing, double value) {
      final ch = Helper.getChannel(channel);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(ch.icon, size: 18, color: ch.color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    channel,
                    style: AppTextStyles.t(14, w: FontWeight.w600),
                  ),
                ),
                Text(
                  '$open open',
                  style: AppTextStyles.t(13, w: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ProgressBar(value, color: ch.color),
            const SizedBox(height: 8),
            Text(
              '$closing close within 2 hours',
              style: AppTextStyles.t(12, c: AppColors.warning),
            ),
          ],
        ),
      );
    }

    return StudioCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(
            'Reply windows',
            subtitle: 'Conversations you can still answer freely',
          ),
          const SizedBox(height: 10),
          row('WhatsApp', 214, 12, .72),
          row('Instagram', 98, 6, .55),
          const SizedBox(height: 8),
          const InfoBanner(
            'Both apps allow free-form replies for 24 hours after a customer writes. After that, WhatsApp needs an approved template.',
          ),
        ],
      ),
    );
  }
}

class _Recipe {
  const _Recipe(this.title, this.desc, this.channel);
  final String title, desc, channel;
}

class _Recipes extends StatelessWidget {
  const _Recipes();

  static const _items = [
    _Recipe(
      'Comment to DM',
      'Send a DM when someone comments a keyword on your Reel or post.',
      'Instagram',
    ),
    _Recipe(
      'Story reply responder',
      'Answer story replies and ask what the customer wants.',
      'Instagram',
    ),
    _Recipe(
      'Cart recovery',
      'Remind shoppers on WhatsApp and send a coupon if they stay quiet.',
      'WhatsApp',
    ),
    _Recipe(
      'Order updates',
      'Send receipts, shipping and delivery messages automatically.',
      'WhatsApp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final go = ShellScope.of(context).goTo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          'Start with a ready-made automation',
          subtitle: 'Pick a recipe, adjust the wording and switch it on',
        ),
        const SizedBox(height: 14),
        ResponsiveGrid(
          minItemWidth: 280,
          children: [
            for (final r in _items)
              StudioCard(
                hoverable: true,
                onTap: () => go(NavDestination.automations),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StudioIconBox(
                          Helper.getChannel(r.channel).icon,
                          Helper.getChannel(r.channel).color,
                          size: 38,
                        ),
                        const Spacer(),
                        const Icon(
                          RemixIcons.arrow_right_up_line,
                          size: 18,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      r.title,
                      style: AppTextStyles.t(15, w: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      r.desc,
                      style: AppTextStyles.t(
                        12.5,
                        c: AppColors.textSecondary,
                        h: 1.45,
                      ),
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
