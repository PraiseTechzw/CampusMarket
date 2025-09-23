/// @Branch: Component Library Screen Implementation
///
/// Storybook-like component showcase page
/// Demonstrates all UI components with interactive controls
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/glow_card.dart';
import '../../../core/widgets/live_badge.dart';

class ComponentLibraryScreen extends StatefulWidget {
  const ComponentLibraryScreen({super.key});

  @override
  State<ComponentLibraryScreen> createState() => _ComponentLibraryScreenState();
}

class _ComponentLibraryScreenState extends State<ComponentLibraryScreen> {
  bool _showGlow = true;
  bool _enableFloat = true;
  bool _enableShimmer = true;
  bool _enablePulse = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Component Library'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(theme),

            const SizedBox(height: AppSpacing.xl),

            // Controls
            _buildControls(theme),

            const SizedBox(height: AppSpacing.xl),

            // Typography
            _buildTypographySection(theme),

            const SizedBox(height: AppSpacing.xl),

            // Buttons
            _buildButtonsSection(theme),

            const SizedBox(height: AppSpacing.xl),

            // Cards
            _buildCardsSection(theme),

            const SizedBox(height: AppSpacing.xl),

            // Badges
            _buildBadgesSection(theme),

            const SizedBox(height: AppSpacing.xl),

            // Sample Components
            _buildSampleComponents(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientText(
          'Component Library',
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        Text(
          'Interactive showcase of all Campus Market UI components',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );

  Widget _buildControls(ThemeData theme) => GlowCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animation Controls',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Glow toggle
          SwitchListTile(
            title: const Text('Enable Glow Effect'),
            subtitle: const Text('Adds glow effect to cards'),
            value: _showGlow,
            onChanged: (value) {
              setState(() {
                _showGlow = value;
              });
            },
          ),

          // Float toggle
          SwitchListTile(
            title: const Text('Enable Float Animation'),
            subtitle: const Text('Adds floating animation to cards'),
            value: _enableFloat,
            onChanged: (value) {
              setState(() {
                _enableFloat = value;
              });
            },
          ),

          // Shimmer toggle
          SwitchListTile(
            title: const Text('Enable Text Shimmer'),
            subtitle: const Text('Adds shimmer effect to gradient text'),
            value: _enableShimmer,
            onChanged: (value) {
              setState(() {
                _enableShimmer = value;
              });
            },
          ),

          // Pulse toggle
          SwitchListTile(
            title: const Text('Enable Pulse Animation'),
            subtitle: const Text('Adds pulsing effect to live badges'),
            value: _enablePulse,
            onChanged: (value) {
              setState(() {
                _enablePulse = value;
              });
            },
          ),
        ],
      ),
    );

  Widget _buildTypographySection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Typography',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Display Large', style: theme.textTheme.displayLarge),

              const SizedBox(height: AppSpacing.sm),

              Text('Display Medium', style: theme.textTheme.displayMedium),

              const SizedBox(height: AppSpacing.sm),

              Text('Headline Large', style: theme.textTheme.headlineLarge),

              const SizedBox(height: AppSpacing.sm),

              Text('Title Large', style: theme.textTheme.titleLarge),

              const SizedBox(height: AppSpacing.sm),

              Text('Body Large', style: theme.textTheme.bodyLarge),

              const SizedBox(height: AppSpacing.sm),

              Text('Body Small', style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );

  Widget _buildButtonsSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buttons',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        GlowCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Primary Button'),
              ),

              const SizedBox(height: AppSpacing.md),

              OutlinedButton(
                onPressed: () {},
                child: const Text('Secondary Button'),
              ),

              const SizedBox(height: AppSpacing.md),

              TextButton(onPressed: () {}, child: const Text('Text Button')),

              const SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('With Icon'),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text('Download'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildCardsSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cards',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Basic card
        GlowCard(
          enableGlow: _showGlow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Basic Card',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'This is a basic card with some content. It can contain any widgets and supports tap interactions.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Float card
        if (_enableFloat)
          FloatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Float Card',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'This card has a floating animation that moves up and down continuously.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );

  Widget _buildBadgesSection(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Badges',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        const GlowCard(
          child: Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              LiveBadge('LIVE'),
              LiveBadge('FEATURED'),
              LiveBadge('NEW'),
              StatusBadge('Success', type: BadgeType.success),
              StatusBadge('Warning', type: BadgeType.warning),
              StatusBadge('Error', type: BadgeType.error),
              StatusBadge('Info', type: BadgeType.info),
              StatusBadge('Outline', type: BadgeType.outline),
            ],
          ),
        ),
      ],
    );

  Widget _buildSampleComponents(ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sample Components',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Marketplace item card
        Text(
          'Marketplace Item Card',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // TODO: Replace with actual data
        // MarketplaceItemCard(
        //   item: sampleItem,
        //   onTap: () {},
        // ),
        const SizedBox(height: AppSpacing.lg),

        // Event card
        Text(
          'Event Card',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // TODO: Replace with actual data
        // EventCard(event: sampleEvent, onTap: () {}),
        const SizedBox(height: AppSpacing.lg),

        // Accommodation card
        Text(
          'Accommodation Card',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // TODO: Replace with actual data
        // AccommodationCard(
        //   accommodation: sampleAccommodation,
        //   onTap: () {},
        // ),
      ],
    );
}
