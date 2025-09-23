/// @Branch: Main Navigation Wrapper
///
/// Central navigation component that handles responsive layout
/// Switches between sidebar (web/desktop) and bottom navigation (mobile)
/// Manages navigation state and provides consistent navigation experience
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'sidebar_navigation.dart';
import 'bottom_navigation.dart';

class MainNavigation extends StatelessWidget {

  const MainNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
  });
  final Widget child;
  final String currentRoute;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const isWeb = kIsWeb;
    final isMobile = screenWidth < mobileBreakpoint;
    final isTablet =
        screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
    final isDesktop = screenWidth >= desktopBreakpoint;

    return Scaffold(
      body: _buildBody(context, isWeb, isMobile, isTablet, isDesktop),
      bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    bool isWeb,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    // For web and desktop, use sidebar layout
    if (isWeb || isDesktop) {
      return Row(
        children: [
          // Sidebar with intelligent behavior
          SidebarNavigation(
            currentRoute: currentRoute,
            autoHide: false,
          ),

          // Main content
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: EdgeInsets.symmetric(horizontal: isDesktop ? 24.0 : 16.0),
              child: child,
            ),
          ),
        ],
      );
    }

    // For tablet, use sidebar if wide enough, otherwise bottom nav
    if (isTablet) {
      return Row(
        children: [
          // Sidebar for tablets with auto-hide
          SidebarNavigation(
            currentRoute: currentRoute,
            collapseBreakpoint: 600,
          ),

          // Main content
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: child,
            ),
          ),
        ],
      );
    }

    // For mobile, just return the child (bottom nav is handled separately)
    return child;
  }

  Widget _buildBottomNavigation() => BottomNavigation(currentRoute: currentRoute);
}

/// Navigation wrapper with custom configuration
class CustomMainNavigation extends StatelessWidget {

  const CustomMainNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    this.showSidebar = true,
    this.showBottomNavigation = true,
    this.customSidebar,
    this.customBottomNavigation,
  });
  final Widget child;
  final String currentRoute;
  final bool showSidebar;
  final bool showBottomNavigation;
  final Widget? customSidebar;
  final Widget? customBottomNavigation;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = kIsWeb;
    final isMobile = screenWidth < MainNavigation.mobileBreakpoint;

    return Scaffold(
      body: _buildBody(context, isWeb, isMobile),
      bottomNavigationBar: _buildBottomNavigation(isMobile),
    );
  }

  Widget _buildBody(BuildContext context, bool isWeb, bool isMobile) {
    if (isWeb && showSidebar) {
      return Row(
        children: [
          customSidebar ?? SidebarNavigation(currentRoute: currentRoute),
          Expanded(child: child),
        ],
      );
    }

    return child;
  }

  Widget? _buildBottomNavigation(bool isMobile) {
    if (!isMobile || !showBottomNavigation) return null;

    return customBottomNavigation ??
        BottomNavigation(currentRoute: currentRoute);
  }
}

/// Navigation wrapper for specific layouts
class LayoutNavigation extends StatelessWidget {

  const LayoutNavigation({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.layout,
  });
  final Widget child;
  final String currentRoute;
  final NavigationLayout layout;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case NavigationLayout.mobile:
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigation(currentRoute: currentRoute),
        );

      case NavigationLayout.tablet:
        return Scaffold(
          body: Row(
            children: [
              SidebarNavigation(currentRoute: currentRoute),
              Expanded(child: child),
            ],
          ),
        );

      case NavigationLayout.desktop:
        return Scaffold(
          body: Row(
            children: [
              SidebarNavigation(currentRoute: currentRoute),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: child,
                ),
              ),
            ],
          ),
        );

      case NavigationLayout.web:
        return Scaffold(
          body: Row(
            children: [
              SidebarNavigation(currentRoute: currentRoute),
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  child: child,
                ),
              ),
            ],
          ),
        );
    }
  }
}

enum NavigationLayout { mobile, tablet, desktop, web }

/// Navigation utilities
class NavigationUtils {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < MainNavigation.mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= MainNavigation.mobileBreakpoint &&
        width < MainNavigation.tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >=
        MainNavigation.desktopBreakpoint;

  static bool isWeb() => kIsWeb;

  static NavigationLayout getLayout(BuildContext context) {
    if (isWeb()) return NavigationLayout.web;
    if (isDesktop(context)) return NavigationLayout.desktop;
    if (isTablet(context)) return NavigationLayout.tablet;
    return NavigationLayout.mobile;
  }
}
