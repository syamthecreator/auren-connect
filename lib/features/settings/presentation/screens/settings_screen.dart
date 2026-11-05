// ════════════════════════════════════════════════════════════════════════════
//  7. SETTINGS
// ════════════════════════════════════════════════════════════════════════════

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:auren_connect/app/theme/app_input_decorations.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/utils/helper.dart';
import 'package:auren_connect/core/widgets/ghost_button.dart';
import 'package:auren_connect/core/widgets/gradient_button.dart';
import 'package:auren_connect/core/widgets/section_title.dart';
import 'package:auren_connect/core/widgets/split_row.dart';
import 'package:auren_connect/core/widgets/studio_avatar.dart';
import 'package:auren_connect/core/widgets/studio_card.dart';
import 'package:auren_connect/core/widgets/studio_icon_box.dart';
import 'package:auren_connect/core/widgets/studio_page.dart';
import 'package:auren_connect/core/widgets/studio_pill.dart';
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _prefs = [true, true, false, true];
  bool _showKey = false;

  Widget _field(String label, String value, {IconData? icon}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.t(12.5, c: AppColors.textSecondary)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          style: AppTextStyles.t(14),
          cursorColor: AppColors.primary,
          decoration: AppInputDecorations.dec('', icon: icon),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    const live = [
      (
        'WhatsApp',
        'Business API · +91 98765 43210',
        'Quality rating High · 10k conversations a day',
      ),
      (
        'Instagram',
        'Business account · @auren.studio',
        'Messaging and comment access granted',
      ),
    ];
    const soon = [
      ('SMS', 'Text messages'),
      ('Email', 'Newsletters and receipts'),
      ('Telegram', 'Bot messaging'),
    ];
    const prefLabels = [
      ('Campaign finished', 'Get notified when a send completes'),
      ('New reply', 'Alert me when a customer answers'),
      ('Window closing', 'Warn me before a 24h reply window ends'),
      ('Template status', 'Approvals and rejections from Meta'),
    ];

    return StudioPage(
      children: [
        SplitRow(
          sideWidth: 400,
          main: Column(
            children: [
              StudioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'Connected channels',
                      subtitle: 'Where your messages are sent from',
                      trailing: StudioPill(
                        'Meta business verified',
                        color: AppColors.success,
                        icon: RemixIcons.verified_badge_line,
                      ),
                    ),
                    const SizedBox(height: 14),
                    for (final c in live)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            StudioIconBox(
                              Helper.getChannel(c.$1).icon,
                              Helper.getChannel(c.$1).color,
                              size: 46,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.$1,
                                    style: AppTextStyles.t(
                                      14.5,
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.$2,
                                    style: AppTextStyles.t(
                                      12.5,
                                      c: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    c.$3,
                                    style: AppTextStyles.t(
                                      12,
                                      c: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const StudioPill(
                              'Connected',
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 6),
                    Container(height: 1, color: AppColors.border),
                    const SizedBox(height: 10),
                    Text(
                      'Coming soon',
                      style: AppTextStyles.t(12.5, c: AppColors.textMuted),
                    ),
                    for (final c in soon)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            StudioIconBox(
                              Helper.getChannel(c.$1).icon,
                              AppColors.textMuted,
                              size: 38,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.$1,
                                    style: AppTextStyles.t(
                                      14,
                                      w: FontWeight.w600,
                                      c: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    c.$2,
                                    style: AppTextStyles.t(
                                      12,
                                      c: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const StudioPill(
                              'Soon',
                              color: AppColors.textMuted,
                              dot: false,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StudioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'Workspace',
                      subtitle: 'How your studio appears to your team',
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        StudioAvatar('Auren Studio', size: 64),
                        SizedBox(width: 16),
                        GhostButton(
                          label: 'Change logo',
                          icon: RemixIcons.image_line,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _field(
                      'Workspace name',
                      'Auren Studio',
                      icon: RemixIcons.building_line,
                    ),
                    _field(
                      'Support email',
                      'support@auren.studio',
                      icon: RemixIcons.mail_line,
                    ),
                    _field(
                      'Time zone',
                      'Asia/Kolkata (UTC+05:30)',
                      icon: RemixIcons.time_line,
                    ),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: GradientButton(label: 'Save changes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          side: Column(
            children: [
              StudioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'API access',
                      subtitle: 'Send messages from your own systems',
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: .6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _showKey
                                  ? 'ak_live_9f3c71d2b8e04a65'
                                  : 'ak_live_••••••••••••••••',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => setState(() => _showKey = !_showKey),
                            child: Icon(
                              _showKey
                                  ? RemixIcons.eye_off_line
                                  : RemixIcons.eye_line,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            RemixIcons.file_copy_line,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep this key private. Rotate it if you think it was shared.',
                      style: AppTextStyles.t(
                        12.5,
                        c: AppColors.textMuted,
                        h: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              StudioCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle(
                      'Notifications',
                      subtitle: 'Choose what reaches you',
                    ),
                    const SizedBox(height: 10),
                    for (var i = 0; i < prefLabels.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    prefLabels[i].$1,
                                    style: AppTextStyles.t(
                                      14,
                                      w: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    prefLabels[i].$2,
                                    style: AppTextStyles.t(
                                      12.5,
                                      c: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _prefs[i],
                              activeThumbColor: AppColors.primary,
                              activeTrackColor: AppColors.primary.withValues(
                                alpha: .3,
                              ),
                              inactiveThumbColor: AppColors.textMuted,
                              inactiveTrackColor: AppColors.border,
                              onChanged: (v) => setState(() => _prefs[i] = v),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
