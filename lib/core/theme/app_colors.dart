/// @Branch: Color System Implementation
///
/// Centralized color definitions and utilities
/// Provides semantic color tokens and helper methods
library;

import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Campus Market Brand Colors
  static const Color green = Color(0xFF2E7D32); // Growth, trust, education
  static const Color yellow = Color(0xFFFBC02D); // Energy, youth, opportunities
  static const Color orange = Color(0xFFFF7043); // Hustle, entrepreneurship
  static const Color grey = Color(0xFF757575); // Neutral balance
  static const Color white = Color(0xFFFFFFFF); // Clean background

  // Semantic Color Mappings
  static const Color primary = green; // Main brand color
  static const Color primaryLight = Color(0xFF4CAF50); // Lighter green
  static const Color primaryDark = Color(0xFF1B5E20); // Darker green

  // Secondary Colors
  static const Color secondary = yellow; // Energy and opportunities
  static const Color accent = orange; // Entrepreneurship and hustle

  // Neutral Colors
  static const Color background = white; // Clean background
  static const Color surface = white; // Clean surface
  static const Color foreground = Color(0xFF0F172A); // Dark text
  static const Color muted = grey; // Neutral balance
  static const Color mutedForeground = Color(0xFF94A3B8);

  // Status Colors
  static const Color success = green; // Growth and trust
  static const Color warning = yellow; // Energy and attention
  static const Color error = Color(0xFFDC2626); // Error red
  static const Color info = Color(0xFF3B82F6); // Information blue

  // Border & Outline
  static const Color border = Color(0xFFE2E8F0);
  static const Color ring = green; // Primary brand color

  // Glass Effect
  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);

  // Gradient Colors
  static const List<Color> primaryGradient = [green, primaryLight];

  static const List<Color> energyGradient = [yellow, orange];

  static const List<Color> campusGradient = [green, yellow, orange];

  static const List<Color> shimmerGradient = [
    Color(0xFFE2E8F0),
    Color(0xFFF1F5F9),
    Color(0xFFE2E8F0),
  ];

  // Live/Active States
  static const Color live = green; // Growth and activity
  static const Color liveGlow = Color(0x332E7D32); // Green glow

  // Helper methods
  static Color withOpacity(Color color, double opacity) => color.withOpacity(opacity);

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
}
