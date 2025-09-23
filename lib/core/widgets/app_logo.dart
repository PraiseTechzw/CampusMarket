/// @Branch: App Logo Widget
///
/// Reusable logo widget for Campus Market
/// Supports different sizes and styles for various use cases
/// Uses the brand logo with proper scaling and theming
library;

import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {

  const AppLogo({
    super.key,
    this.width,
    this.height,
    this.size = 120.0,
    this.backgroundColor,
    this.padding,
    this.decoration,
    this.onTap,
  });

  /// Small logo for headers and compact spaces
  const AppLogo.small({
    super.key,
    this.backgroundColor,
    this.padding,
    this.decoration,
    this.onTap,
  })  : width = null,
        height = null,
        size = 60.0;

  /// Medium logo for cards and standard use
  const AppLogo.medium({
    super.key,
    this.backgroundColor,
    this.padding,
    this.decoration,
    this.onTap,
  })  : width = null,
        height = null,
        size = 120.0;

  /// Large logo for splash screens and hero sections
  const AppLogo.large({
    super.key,
    this.backgroundColor,
    this.padding,
    this.decoration,
    this.onTap,
  })  : width = null,
        height = null,
        size = 200.0;

  /// Extra large logo for marketing and landing pages
  const AppLogo.hero({
    super.key,
    this.backgroundColor,
    this.padding,
    this.decoration,
    this.onTap,
  })  : width = null,
        height = null,
        size = 300.0;
  final double? width;
  final double? height;
  final double size;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    Widget logoWidget = Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: padding ?? const EdgeInsets.all(8),
      decoration: decoration ??
          BoxDecoration(
            color: backgroundColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
      child: Image.asset(
        'assets/images/logo.png',
        width: effectiveWidth - (padding?.horizontal ?? 16.0),
        height: effectiveHeight - (padding?.vertical ?? 16.0),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Fallback to text logo if image fails to load
          return _buildFallbackLogo(theme, effectiveWidth, effectiveHeight);
        },
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: logoWidget,
      );
    }

    return logoWidget;
  }

  Widget _buildFallbackLogo(ThemeData theme, double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school,
            size: width * 0.3,
            color: Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            'CAMPUS',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.08,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'MARKET',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.06,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
}

/// Logo variants for specific use cases
class AppLogoVariants {
  /// Logo with glow effect for special sections
  static Widget withGlow({
    required BuildContext context,
    double size = 120.0,
    Color? glowColor,
    double glowRadius = 20.0,
  }) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: (glowColor ?? theme.colorScheme.primary).withOpacity(0.3),
            blurRadius: glowRadius,
            spreadRadius: 2,
          ),
        ],
      ),
      child: AppLogo(
        size: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Logo with circular background
  static Widget circular({
    required BuildContext context,
    double size = 120.0,
    Color? backgroundColor,
  }) {
    final theme = Theme.of(context);
    return AppLogo(
      size: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Logo with border
  static Widget withBorder({
    required BuildContext context,
    double size = 120.0,
    Color? borderColor,
    double borderWidth = 2.0,
  }) {
    final theme = Theme.of(context);
    return AppLogo(
      size: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? theme.colorScheme.primary,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
