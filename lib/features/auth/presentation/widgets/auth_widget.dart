import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(color: AppColors.background),
        ),

        const CustomPaint(painter: _GridPainter()),
        child,
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.subtitleSpan,
    this.green = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final InlineSpan? subtitleSpan;
  final bool green;

  @override
  Widget build(BuildContext context) {
    const subStyle = TextStyle(
      fontSize: 14.5,
      color: AppColors.textMuted,
      height: 1.35,
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: green
                ? AppColors.iconGreenGradient
                : AppColors.iconDarkGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (green ? AppColors.success : AppColors.background)
                    .withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              if (subtitleSpan != null)
                Text.rich(subtitleSpan!, style: subStyle)
              else
                Text(subtitle ?? '', style: subStyle),
            ],
          ),
        ),
      ],
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
    ),
  );
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.prefixIcon,
    this.hint,
    this.obscureText = false,
    this.readOnly = false,
    this.suffix,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
    this.textInputAction,
    this.onSubmitted,
    this.letterSpacing,
    this.autofocus = false,
    this.iconColor,
    this.autofillHints,
  });

  final TextEditingController controller;
  final IconData prefixIcon;
  final String? hint;
  final bool obscureText;
  final bool readOnly;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final double? letterSpacing;
  final bool autofocus;
  final Color? iconColor;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode();
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _focus,
      builder: (context, child) {
        final focused = _focus.hasFocus && !widget.readOnly;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: focused ? AppColors.primary.withValues(alpha: 0.22) : null,
          ),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.readOnly
                  ? AppColors.surfaceVariant
                  : focused
                  ? AppColors.card
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: focused ? AppColors.borderGlow : AppColors.border,
                width: focused ? 1.4 : 1.2,
              ),
            ),
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              readOnly: widget.readOnly,
              obscureText: widget.obscureText,
              obscuringCharacter: '•',
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              maxLength: widget.maxLength,
              textInputAction: widget.textInputAction,
              onSubmitted: widget.onSubmitted,
              autofillHints: widget.autofillHints,
              cursorColor: AppColors.primary,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: widget.letterSpacing,
              ),
              decoration: InputDecoration(
                isDense: true,
                counterText: '',
                border: InputBorder.none,
                hintText: widget.hint,
                hintStyle: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textMuted,
                  letterSpacing: 0,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                prefixIcon: Icon(
                  widget.prefixIcon,
                  size: 20,
                  color:
                      widget.iconColor ??
                      (focused ? AppColors.primary : AppColors.textSecondary),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 46,
                  minHeight: 46,
                ),
                suffixIcon: widget.suffix,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.iconAfter = false,
    this.shadowColor = AppColors.background,
  });

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onPressed;
  final bool loading;
  final String? loadingLabel;
  final bool iconAfter;
  final Color shadowColor;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      loading ? (loadingLabel ?? label) : label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.onPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );

    final leading = loading
        ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: AppColors.onPrimary,
            ),
          )
        : Icon(icon, color: AppColors.onPrimary, size: 19);

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: loading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: iconAfter && !loading
                  ? [Flexible(child: text), const SizedBox(width: 8), leading]
                  : [leading, const SizedBox(width: 8), Flexible(child: text)],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthTextLink extends StatelessWidget {
  const AuthTextLink({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17, color: AppColors.textPrimary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
