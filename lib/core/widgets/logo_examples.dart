/// @Branch: Logo Widget Usage Examples
///
/// Examples of how to use the AppLogo widget in different scenarios
/// This file demonstrates various configurations and use cases
library;

import 'package:flutter/material.dart';
import 'app_logo.dart';

class LogoExamples extends StatelessWidget {
  const LogoExamples({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Logo Examples'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Basic Logo Sizes',
              [
                const AppLogo.small(),
                const SizedBox(height: 16),
                const AppLogo.medium(),
                const SizedBox(height: 16),
                const AppLogo.large(),
                const SizedBox(height: 16),
                const AppLogo.hero(),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              'Logo Variants',
              [
                AppLogoVariants.withGlow(context: context),
                const SizedBox(height: 16),
                AppLogoVariants.circular(context: context),
                const SizedBox(height: 16),
                AppLogoVariants.withBorder(context: context),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              'Custom Styling',
              [
                const AppLogo(
                  size: 100,
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.all(16),
                ),
                const SizedBox(height: 16),
                const AppLogo(
                  size: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.yellow, Colors.orange],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            _buildSection(
              'Interactive Logo',
              [
                const AppLogo(
                  size: 120,
                  onTap: null, // Add your onTap handler here
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the logo above to navigate',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildSection(String title, List<Widget> children) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
}

/// Usage examples for different screens
class LogoUsageExamples {
  /// Example: App Bar with logo
  static Widget appBarWithLogo(BuildContext context) => AppBar(
      title: Row(
        children: [
          const AppLogo.small(),
          const SizedBox(width: 12),
          const Text('Campus Market'),
        ],
      ),
      centerTitle: false,
    );

  /// Example: Splash screen with logo
  static Widget splashScreenWithLogo(BuildContext context) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogoVariants.withGlow(
              context: context,
              size: 200,
              glowRadius: 30,
            ),
            const SizedBox(height: 32),
            const Text(
              'Campus Market',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connecting Zimbabwe\'s Universities',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );

  /// Example: Card with logo
  static Widget cardWithLogo(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const AppLogo.small(),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to Campus Market',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Your one-stop marketplace for campus life',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

  /// Example: Footer with logo
  static Widget footerWithLogo(BuildContext context) => Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.grey[100],
      child: Row(
        children: [
          const AppLogo.medium(),
          const SizedBox(width: 24),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Campus Market',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Connecting students across Zimbabwe\'s universities',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
}
