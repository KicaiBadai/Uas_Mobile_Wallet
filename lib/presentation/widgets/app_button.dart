import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum AppButtonVariant { primary, dark, soft, ghost, outline, outlineWhite, white, danger, success }
enum AppButtonSize { lg, md, sm }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool fullWidth;
  final Widget? icon;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.lg,
    this.fullWidth = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 0.96);
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _scale = 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (height, fontSize, radius, px) = switch (widget.size) {
      AppButtonSize.lg => (54.0, 16.0, 16.0, 20.0),
      AppButtonSize.md => (46.0, 15.0, 14.0, 16.0),
      AppButtonSize.sm => (38.0, 13.0, 12.0, 14.0),
    };

    final (bg, fg, shadow, border) = _resolveStyle();
    final disabled = widget.onPressed == null;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: disabled || widget.isLoading ? null : widget.onPressed,
          child: Container(
            height: height,
            width: widget.fullWidth ? double.infinity : null,
            padding: EdgeInsets.symmetric(horizontal: px),
            decoration: BoxDecoration(
              gradient: widget.variant == AppButtonVariant.primary ? AppColors.primaryGradient : null,
              color: widget.variant != AppButtonVariant.primary ? bg : null,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow,
              border: border,
            ),
            child: Row(
              mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(fg),
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    color: fg,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color, List<BoxShadow>, Border?) _resolveStyle() {
    return switch (widget.variant) {
      AppButtonVariant.primary => (
          AppColors.primary,
          Colors.white,
          AppColors.shadowPrimary,
          null,
        ),
      AppButtonVariant.dark => (AppColors.ink, Colors.white, [], null),
      AppButtonVariant.soft => (AppColors.primarySurface, AppColors.primary, [], null),
      AppButtonVariant.ghost => (Colors.transparent, AppColors.slate600, [], null),
      AppButtonVariant.outline => (
          Colors.white,
          AppColors.ink,
          [],
          Border.all(color: AppColors.line, width: 1.5),
        ),
      AppButtonVariant.outlineWhite => (
          Colors.transparent,
          Colors.white,
          [],
          Border.all(color: Colors.white.withOpacity(0.7), width: 1.5),
        ),
      AppButtonVariant.white => (
          Colors.white,
          AppColors.primary,
          [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8))],
          null,
        ),
      AppButtonVariant.danger => (AppColors.red, Colors.white, [], null),
      AppButtonVariant.success => (AppColors.green, Colors.white, [], null),
    };
  }
}
