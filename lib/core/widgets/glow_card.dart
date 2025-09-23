/// @Branch: Glow Card Widget Implementation
///
/// Custom card widget with glow effects and animations
/// Provides the signature glow card behavior for the Campus Market design
library;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/app_spacing.dart';

class GlowCard extends StatefulWidget {

  const GlowCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.glowColor,
    this.enableGlow = true,
    this.enableFloat = true,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? glowColor;
  final bool enableGlow;
  final bool enableFloat;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<GlowCard> createState() => _GlowCardState();
}

class _GlowCardState extends State<GlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onTap != null) {
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.onTap != null) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.appColors;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: widget.margin ?? const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface.withOpacity(0.9),
                    theme.colorScheme.surface.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  // Base shadow
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                  // Glow effect
                  if (widget.enableGlow && _glowAnimation.value > 0)
                    BoxShadow(
                      color: (widget.glowColor ?? appColors.glow).withOpacity(
                        0.4 * _glowAnimation.value,
                      ),
                      blurRadius: 25 * _glowAnimation.value,
                      spreadRadius: 3 * _glowAnimation.value,
                    ),
                ],
              ),
              child: Material(
                elevation: 0,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                color: Colors.transparent,
                child: Container(
                  padding:
                      widget.padding ?? const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
      ),
    );
  }
}

class FloatCard extends StatefulWidget {

  const FloatCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.floatHeight = 4.0,
    this.animationDuration = const Duration(seconds: 2),
    this.animationCurve = Curves.easeInOut,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double floatHeight;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<FloatCard> createState() => _FloatCardState();
}

class _FloatCardState extends State<FloatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _floatAnimation = Tween<double>(begin: 0, end: widget.floatHeight)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: widget.animationCurve,
          ),
        );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: GlowCard(
            onTap: widget.onTap,
            padding: widget.padding,
            margin: widget.margin,
            child: widget.child,
          ),
        );
      },
    );
}

class ShimmerCard extends StatefulWidget {

  const ShimmerCard({super.key, this.width, this.height, this.borderRadius});
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  State<ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      height: widget.height ?? 120,
      decoration: BoxDecoration(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(AppSpacing.radiusMd),
        color: theme.colorScheme.surface,
      ),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
            decoration: BoxDecoration(
              borderRadius:
                  widget.borderRadius ??
                  BorderRadius.circular(AppSpacing.radiusMd),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  theme.colorScheme.surface,
                  theme.colorScheme.surface.withOpacity(0.5),
                  theme.colorScheme.surface,
                ],
                stops: [
                  _animation.value - 0.3,
                  _animation.value,
                  _animation.value + 0.3,
                ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              ),
            ),
          ),
      ),
    );
  }
}
