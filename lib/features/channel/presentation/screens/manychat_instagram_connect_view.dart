import 'dart:async';
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:auren_connect/app/theme/app_text_styles.dart';
import 'package:auren_connect/core/widgets/app_snackbar.dart';

import '../../controller/channel_controller.dart';

class ManyChatInstagramConnectView extends StatefulWidget {
  const ManyChatInstagramConnectView({
    super.key,
    required this.onBack,
    required this.onConnected,
  });

  final VoidCallback onBack;
  final VoidCallback onConnected;

  @override
  State<ManyChatInstagramConnectView> createState() =>
      _ManyChatInstagramConnectViewState();
}

class _ManyChatInstagramConnectViewState
    extends State<ManyChatInstagramConnectView> {
  bool _isLoading = false;
  bool _isAwaitingMeta = false;
  bool _showMoreOptions = false;
  Timer? _pollingTimer;
  StreamSubscription<html.MessageEvent>? _messageSub;
  dynamic _authPopup;

  @override
  void initState() {
    super.initState();
    _listenForMetaCallback();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _messageSub?.cancel();
    _authPopup?.close();
    super.dispose();
  }

  void _listenForMetaCallback() {
    try {
      _messageSub = html.window.onMessage.listen((event) {
        if (event.data is Map &&
            event.data['type'] == 'AUREN_INSTAGRAM_CONNECTED') {
          _handleConnectionSuccess();
        }
      });
    } catch (_) {}
  }

  Future<void> _handleConnectionSuccess() async {
    _pollingTimer?.cancel();
    _authPopup?.close();
    if (!mounted) return;

    final controller = context.read<ChannelController>();
    await controller.loadChannels();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isAwaitingMeta = false;
    });

    AppSnackBar.success(context, 'Instagram account connected successfully!');
    widget.onConnected();
  }

  Future<void> _connectViaMeta() async {
    // Open blank popup immediately on user gesture to avoid browser popup blockers
    try {
      _authPopup = html.window.open(
        'about:blank',
        'auren_meta_oauth',
        'width=650,height=820,left=250,top=80,resizable=yes,scrollbars=yes',
      );
    } catch (_) {}

    setState(() {
      _isLoading = true;
      _isAwaitingMeta = true;
    });

    final controller = context.read<ChannelController>();
    final url = await controller.getInstagramAuthorizationUrl();

    if (!mounted) {
      _authPopup?.close();
      return;
    }

    setState(() => _isLoading = false);

    if (url == null || url.isEmpty) {
      _authPopup?.close();
      setState(() => _isAwaitingMeta = false);
      AppSnackBar.error(
        context,
        controller.errorMessage ?? 'Failed to initialize Meta connection.',
      );
      return;
    }

    // Direct popup to Meta Unified Login
    try {
      _authPopup?.location.href = url;
    } catch (_) {
      html.window.open(url, '_blank');
    }

    // Start polling in background to detect when user clicks "Save" on Meta
    _startPolling();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    int count = 0;

    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      count++;
      if (!mounted) {
        timer.cancel();
        return;
      }

      final controller = context.read<ChannelController>();
      await controller.loadChannels();

      if (!mounted) return;

      if (controller.isInstagramConnected) {
        timer.cancel();
        _handleConnectionSuccess();
      } else if (count >= 80) {
        // Stop polling after 4 minutes
        timer.cancel();
        setState(() => _isAwaitingMeta = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      color: const Color(0xFF070C15),
      child: SafeArea(
        child: Column(
          children: [
            // Top Nav bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Row(children: [_buildBrandLogo()]),
            ),

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 20,
                  ),
                  child: isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: _buildLeftHero()),
                            const SizedBox(width: 60),
                            Expanded(child: _buildRightCard()),
                          ],
                        )
                      : Column(
                          children: [
                            _buildLeftHero(),
                            const SizedBox(height: 36),
                            _buildRightCard(),
                          ],
                        ),
                ),
              ),
            ),

            // Bottom Navigation Link
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: widget.onBack,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          RemixIcons.arrow_left_s_line,
                          size: 18,
                          color: Color(0xFF0866FF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Choose Another Channel',
                          style: AppTextStyles.t(
                            14,
                            c: const Color(0xFF0866FF),
                            w: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
            ),
          ),
          child: const Center(
            child: Icon(
              RemixIcons.instagram_line,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'auren',
                style: AppTextStyles.t(22, w: FontWeight.w800, c: Colors.white),
              ),
              TextSpan(
                text: 'Connect',
                style: AppTextStyles.t(
                  22,
                  w: FontWeight.w400,
                  c: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ManyChat-style Abstract Graphic
        _buildStarburstGraphic(),
        const SizedBox(height: 28),
        Text(
          'Connect Instagram',
          style: AppTextStyles.t(36, w: FontWeight.w800, h: 1.15),
        ),
        const SizedBox(height: 12),
        Text(
          'Use your Instagram account to connect to aurenConnect.',
          style: AppTextStyles.t(15.5, c: const Color(0xFF94A3B8), h: 1.4),
        ),
      ],
    );
  }

  Widget _buildStarburstGraphic() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00C6FF).withValues(alpha: .2),
            const Color(0xFF0072FF).withValues(alpha: .2),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft glow
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF38EF7D).withValues(alpha: .25),
            ),
          ),
          // Ring badge
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0866FF), width: 7),
              color: const Color(0xFF0E1726),
            ),
            child: const Center(
              child: Icon(
                RemixIcons.instagram_fill,
                size: 34,
                color: Color(0xFFE1306C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF0E1726),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E293B)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .35),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A few steps in',
            style: AppTextStyles.t(20, w: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            'We\'ll take you to Meta to connect. Just set your permissions, and your Instagram account will be linked to aurenConnect.',
            style: AppTextStyles.t(14, c: const Color(0xFF94A3B8), h: 1.5),
          ),
          const SizedBox(height: 24),

          // Primary Blue "Connect Via Meta" Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _connectViaMeta,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0866FF), // Meta Blue
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(RemixIcons.facebook_circle_fill, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _isAwaitingMeta
                              ? 'Connecting on Meta...'
                              : 'Connect Via Meta',
                          style: AppTextStyles.t(15, w: FontWeight.w700),
                        ),
                      ],
                    ),
            ),
          ),

          if (_isAwaitingMeta) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0866FF).withValues(alpha: .1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF0866FF).withValues(alpha: .3),
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Complete authorization in the Meta window...',
                      style: AppTextStyles.t(12.5, c: const Color(0xFF0866FF)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Trust Badge Box (Exact ManyChat Layout)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF151E2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF243044)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'aurenConnect is a trusted Meta Business Partner',
                    style: AppTextStyles.t(
                      12.5,
                      c: const Color(0xFFCBD5E1),
                      w: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      RemixIcons.meta_line,
                      size: 22,
                      color: Color(0xFF0866FF),
                    ),
                    const SizedBox(width: 6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta',
                          style: AppTextStyles.t(
                            11,
                            w: FontWeight.w800,
                            c: Colors.white,
                          ),
                        ),
                        Text(
                          'Business Partner',
                          style: AppTextStyles.t(9, c: const Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // See More Options Expandable
          InkWell(
            onTap: () => setState(() => _showMoreOptions = !_showMoreOptions),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See More Options',
                    style: AppTextStyles.t(
                      13,
                      c: const Color(0xFF64748B),
                      w: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showMoreOptions
                        ? RemixIcons.arrow_up_s_line
                        : RemixIcons.arrow_down_s_line,
                    size: 16,
                    color: const Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),

          if (_showMoreOptions) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF151E2E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Prerequisites checklist:',
                    style: AppTextStyles.t(
                      12,
                      w: FontWeight.w600,
                      c: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Must be an Instagram Professional (Creator or Business) account.\n'
                    '• Must have a linked Facebook Page in Meta Accounts Center.\n'
                    '• "Allow access to messages" enabled in Instagram mobile app settings.',
                    style: AppTextStyles.t(
                      11.5,
                      c: const Color(0xFF94A3B8),
                      h: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
