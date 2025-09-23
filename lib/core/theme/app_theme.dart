/// @Branch: Design System Implementation
///
/// Campus Market Design System
/// Implements the semantic color tokens and design system as specified
/// Supports both light and dark themes with proper contrast ratios
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Design Tokens - Campus Market Brand Colors
  static const Color _primaryLight = Color(
    0xFF2E7D32,
  ); // Green - Growth, trust, education
  static const Color _primaryForegroundLight = Color(
    0xFFFFFFFF,
  ); // White text on green
  static const Color _secondaryLight = Color(
    0xFFFBC02D,
  ); // Yellow - Energy, youth, opportunities
  static const Color _accentLight = Color(
    0xFFFF7043,
  ); // Orange - Hustle, entrepreneurship
  static const Color _mutedLight = Color(
    0xFFFFFFFF,
  ); // White - Clean background
  static const Color _foregroundLight = Color(0xFF0F172A); // Dark text

  // Dark theme colors
  static const Color _backgroundDark = Color(0xFF0F172A); // Dark background
  static const Color _foregroundDark = Color(0xFFF8FAFC); // Light text
  static const Color _primaryDark = Color(
    0xFF4CAF50,
  ); // Lighter green for dark theme
  static const Color _ringDark = Color(0xFF2E7D32); // Primary green

  // Border radius
  static const double radius = 12; // 0.75rem

  // Spacing system
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacing2xl = 48;

  // Typography
  static const String fontFamily = 'Inter';

  static ThemeData get lightTheme => ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryLight,
        onPrimary: _primaryForegroundLight,
        secondary: _secondaryLight,
        onSecondary: _foregroundLight,
        surface: _mutedLight,
        onSurface: _foregroundLight,
        error: Color(0xFFDC2626),
        onError: Colors.white,
        outline: Color(0xFFE2E8F0),
        shadow: Color(0x1A000000),
      ),
      textTheme: _buildTextTheme(_foregroundLight),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      cardTheme: _buildCardTheme(),
      appBarTheme: _buildAppBarTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
      extensions: [
        AppColorScheme(
          accent: _accentLight,
          muted: _mutedLight,
          ring: _primaryLight,
          glow: _primaryLight.withOpacity(0.3),
        ),
      ],
    );

  static ThemeData get darkTheme => ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        onPrimary: _backgroundDark,
        secondary: _secondaryLight,
        onSecondary: _foregroundDark,
        surface: Color(0xFF1E293B),
        onSurface: _foregroundDark,
        error: Color(0xFFEF4444),
        onError: _backgroundDark,
        outline: Color(0xFF334155),
        shadow: Color(0x1A000000),
      ),
      textTheme: _buildTextTheme(_foregroundDark),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      cardTheme: _buildCardTheme(),
      appBarTheme: _buildAppBarTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      bottomNavigationBarTheme: _buildBottomNavigationBarTheme(),
      extensions: [
        AppColorScheme(
          accent: _accentLight.withOpacity(0.1),
          muted: const Color(0xFF1E293B),
          ring: _ringDark,
          glow: _primaryDark.withOpacity(0.4),
        ),
      ],
    );

  static TextTheme _buildTextTheme(Color foreground) => TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: foreground,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: foreground,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
      ),
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: foreground,
        height: 1.5,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.5,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: foreground,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: foreground,
        height: 1.6,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: foreground,
        height: 1.6,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: foreground,
        height: 1.4,
      ),
    );

  static ElevatedButtonThemeData _buildElevatedButtonTheme() => ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() => OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingLg,
          vertical: spacingMd,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

  static TextButtonThemeData _buildTextButtonTheme() => TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );

  static CardThemeData _buildCardTheme() => CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      margin: const EdgeInsets.all(spacingSm),
    );

  static AppBarTheme _buildAppBarTheme() => const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

  static InputDecorationTheme _buildInputDecorationTheme() => InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: _primaryLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingMd,
        vertical: spacingMd,
      ),
    );

  static BottomNavigationBarThemeData _buildBottomNavigationBarTheme() => const BottomNavigationBarThemeData(
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    );
}

/// Custom color scheme extension for additional colors
@immutable
class AppColorScheme extends ThemeExtension<AppColorScheme> {
  const AppColorScheme({
    required this.accent,
    required this.muted,
    required this.ring,
    required this.glow,
  });

  final Color accent;
  final Color muted;
  final Color ring;
  final Color glow;

  @override
  AppColorScheme copyWith({
    Color? accent,
    Color? muted,
    Color? ring,
    Color? glow,
  }) => AppColorScheme(
      accent: accent ?? this.accent,
      muted: muted ?? this.muted,
      ring: ring ?? this.ring,
      glow: glow ?? this.glow,
    );

  @override
  AppColorScheme lerp(ThemeExtension<AppColorScheme>? other, double t) {
    if (other is! AppColorScheme) {
      return this;
    }
    return AppColorScheme(
      accent: Color.lerp(accent, other.accent, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      ring: Color.lerp(ring, other.ring, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

/// Extension to easily access custom colors
extension AppColorSchemeExtension on ThemeData {
  AppColorScheme get appColors => extension<AppColorScheme>()!;
}
