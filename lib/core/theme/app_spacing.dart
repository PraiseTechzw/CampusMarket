/// @Branch: Spacing System Implementation
///
/// Centralized spacing and sizing utilities
/// Provides consistent spacing values across the application
library;

class AppSpacing {
  // Base spacing units (4px grid system)
  static const double xs = 4; // 0.25rem
  static const double sm = 8; // 0.5rem
  static const double md = 16; // 1rem
  static const double lg = 24; // 1.5rem
  static const double xl = 32; // 2rem
  static const double xxl = 48; // 3rem
  static const double xxxl = 64; // 4rem

  // Component specific spacing
  static const double cardPadding = md;
  static const double screenPadding = md;
  static const double sectionSpacing = xl;
  static const double itemSpacing = sm;

  // Border radius
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusFull = 999;

  // Icon sizes
  static const double iconXs = 16;
  static const double iconSm = 20;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 40;

  // Button heights
  static const double buttonHeightSm = 32;
  static const double buttonHeightMd = 40;
  static const double buttonHeightLg = 48;
  static const double buttonHeightXl = 56;

  // Input heights
  static const double inputHeightSm = 36;
  static const double inputHeightMd = 44;
  static const double inputHeightLg = 52;

  // Card dimensions
  static const double cardMinHeight = 120;
  static const double cardMaxHeight = 300;

  // Avatar sizes
  static const double avatarXs = 24;
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 48;
  static const double avatarXl = 64;

  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Helper methods
  static double responsive(
    double mobile,
    double tablet,
    double desktop,
    double screenWidth,
  ) {
    if (screenWidth >= desktopBreakpoint) {
      return desktop;
    } else if (screenWidth >= tabletBreakpoint) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static double getScreenPadding(double screenWidth) => responsive(screenPadding, lg, xl, screenWidth);

  static double getCardPadding(double screenWidth) => responsive(cardPadding, md, lg, screenWidth);
}

