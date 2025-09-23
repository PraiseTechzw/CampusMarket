/// @Branch: Gradient Text Widget
///
/// A custom text widget that displays text with a gradient effect
/// Used for titles and headings throughout the app
library;

import 'package:flutter/material.dart';

class GradientText extends StatelessWidget {

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.gradientColors,
  });
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors =
        gradientColors ??
        [
          theme.colorScheme.primary, // Green - Growth, trust, education
          theme.colorScheme.secondary, // Yellow - Energy, youth, opportunities
        ];

    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        text,
        style:
            style?.copyWith(color: Colors.white) ??
            TextStyle(color: Colors.white),
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
