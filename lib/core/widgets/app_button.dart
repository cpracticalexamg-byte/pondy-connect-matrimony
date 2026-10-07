import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final AppButtonType type;
  final double height;
  final double? width;
  final IconData? icon;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.type = AppButtonType.primary,
    this.height = 54,
    this.width,
    this.icon,
    this.borderRadius = 28,
    this.backgroundColor,
    this.textColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.isEnabled && !widget.isLoading && widget.onPressed != null) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.isEnabled && !widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.isEnabled && !widget.isLoading && widget.onPressed != null) {
      _controller.reverse();
    }
  }

  void _handleTap() {
    if (widget.isEnabled && !widget.isLoading && widget.onPressed != null) {
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveEnabled = widget.isEnabled && !widget.isLoading && widget.onPressed != null;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (widget.type) {
      case AppButtonType.primary:
        bg = effectiveEnabled ? AppColors.primary : AppColors.primary.withOpacity(0.4);
        fg = Colors.white;
        break;
      case AppButtonType.secondary:
        bg = effectiveEnabled ? AppColors.primaryLight : Colors.grey.shade100;
        fg = effectiveEnabled ? AppColors.primary : Colors.grey.shade400;
        break;
      case AppButtonType.outline:
        bg = Colors.transparent;
        fg = effectiveEnabled ? AppColors.primary : Colors.grey.shade400;
        border = BorderSide(
          color: effectiveEnabled ? AppColors.primary : Colors.grey.shade300,
          width: 1.5,
        );
        break;
      case AppButtonType.text:
        bg = Colors.transparent;
        fg = effectiveEnabled ? AppColors.primary : Colors.grey.shade400;
        break;
    }

    if (widget.backgroundColor != null) {
      bg = effectiveEnabled ? widget.backgroundColor! : widget.backgroundColor!.withOpacity(0.4);
    }
    if (widget.textColor != null) {
      fg = effectiveEnabled ? widget.textColor! : widget.textColor!.withOpacity(0.5);
    }

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: _handleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
            boxShadow: (effectiveEnabled && widget.type == AppButtonType.primary)
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: widget.isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: fg, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: AppTypography.buttonText(color: fg),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
