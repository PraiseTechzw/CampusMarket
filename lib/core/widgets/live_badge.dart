/// @Branch: Live Badge Widget Implementation
///
/// Custom badge widget with pulsing animation for live/active states
/// Provides the signature live badge behavior with green dot pulsing
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class LiveBadge extends StatefulWidget {

  const LiveBadge(
    this.text, {
    super.key,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
    this.enablePulse = true,
    this.pulseDuration = const Duration(seconds: 1),
    this.pulseCurve = Curves.easeInOut,
    this.pulseScale = 1.2,
  });
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enablePulse;
  final Duration pulseDuration;
  final Curve pulseCurve;
  final double pulseScale;

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1, end: widget.pulseScale).animate(
      CurvedAnimation(parent: _animationController, curve: widget.pulseCurve),
    );

    if (widget.enablePulse) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.backgroundColor ?? AppColors.live;
    final textColor = widget.textColor ?? Colors.white;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            padding:
                widget.padding ??
                const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  widget.borderRadius ??
                  BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: textColor,
                fontSize: widget.fontSize ?? 10,
                fontWeight: widget.fontWeight ?? FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
    );
  }
}

class LiveDot extends StatefulWidget {

  const LiveDot({
    super.key,
    this.size = 8.0,
    this.color,
    this.enablePulse = true,
    this.pulseDuration = const Duration(seconds: 1),
    this.pulseCurve = Curves.easeInOut,
    this.pulseScale = 1.5,
  });
  final double size;
  final Color? color;
  final bool enablePulse;
  final Duration pulseDuration;
  final Curve pulseCurve;
  final double pulseScale;

  @override
  State<LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.pulseDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1, end: widget.pulseScale).animate(
      CurvedAnimation(parent: _animationController, curve: widget.pulseCurve),
    );

    if (widget.enablePulse) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.live;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) => Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5 * _pulseAnimation.value),
                blurRadius: widget.size * _pulseAnimation.value,
                spreadRadius: 2 * _pulseAnimation.value,
              ),
            ],
          ),
        ),
    );
  }
}

class StatusBadge extends StatelessWidget {

  const StatusBadge(
    this.text, {
    super.key,
    this.type = BadgeType.primary,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.borderRadius,
  });
  final String text;
  final BadgeType type;
  final double? fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(type, theme);

    return Container(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius:
            borderRadius ?? BorderRadius.circular(AppSpacing.radiusFull),
        border: colors.borderColor != null
            ? Border.all(color: colors.borderColor!)
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textColor,
          fontSize: fontSize ?? 10,
          fontWeight: fontWeight ?? FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  _BadgeColors _getColors(BadgeType type, ThemeData theme) {
    switch (type) {
      case BadgeType.primary:
        return _BadgeColors(
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
        );
      case BadgeType.secondary:
        return _BadgeColors(
          backgroundColor: AppColors.secondary,
          textColor: AppColors.foreground,
        );
      case BadgeType.success:
        return _BadgeColors(
          backgroundColor: AppColors.success,
          textColor: Colors.white,
        );
      case BadgeType.warning:
        return _BadgeColors(
          backgroundColor: AppColors.warning,
          textColor: Colors.white,
        );
      case BadgeType.error:
        return _BadgeColors(
          backgroundColor: AppColors.error,
          textColor: Colors.white,
        );
      case BadgeType.info:
        return _BadgeColors(
          backgroundColor: AppColors.info,
          textColor: Colors.white,
        );
      case BadgeType.outline:
        return _BadgeColors(
          backgroundColor: Colors.transparent,
          textColor: theme.colorScheme.primary,
          borderColor: theme.colorScheme.primary,
        );
    }
  }
}

enum BadgeType { primary, secondary, success, warning, error, info, outline }

class _BadgeColors {

  _BadgeColors({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
}
