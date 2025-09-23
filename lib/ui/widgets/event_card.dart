/// @Branch: Event Card Widget Implementation
///
/// Reusable card component for displaying events
/// Includes image, title, date, location, and RSVP functionality
library;

import 'package:flutter/material.dart';

import '../../core/models/event.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/widgets/glow_card.dart';

class EventCard extends StatelessWidget {

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onRSVP,
    this.onShare,
    this.showOrganizerInfo = true,
  });
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onRSVP;
  final VoidCallback? onShare;
  final bool showOrganizerInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlowCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          _buildImageSection(context, theme),

          const SizedBox(height: AppSpacing.sm),

          // Content section
          _buildContentSection(context, theme),

          if (showOrganizerInfo) ...[
            const SizedBox(height: AppSpacing.sm),
            _buildOrganizerSection(context, theme),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Action buttons
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildImageSection(BuildContext context, ThemeData theme) => Stack(
      children: [
        // Main image with enhanced styling
        Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                ? Image.network(
                    event.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(theme);
                    },
                  )
                : _buildPlaceholderImage(theme),
          ),
        ),

        // Gradient overlay for better text readability
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
        ),

        // Live badge with enhanced styling
        if (event.isLive)
          Positioned(
            top: AppSpacing.sm,
            left: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'LIVE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Featured badge with enhanced styling
        if (event.isFeatured)
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'FEATURED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        // Free badge
        if (event.isFree)
          Positioned(
            bottom: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'FREE',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        // Action buttons
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Share button
              GestureDetector(
                onTap: onShare,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.share, color: Colors.white, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              // RSVP button
              GestureDetector(
                onTap: onRSVP,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

  Widget _buildPlaceholderImage(ThemeData theme) => Container(
      color: theme.colorScheme.surface,
      child: Icon(
        Icons.event,
        color: theme.colorScheme.onSurface.withOpacity(0.3),
        size: 40,
      ),
    );

  Widget _buildContentSection(BuildContext context, ThemeData theme) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          event.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: AppSpacing.xs),

        // Date and time
        Row(
          children: [
            Icon(Icons.schedule, size: 14, color: theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              _formatDateTime(event.startDate),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // Location
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 14,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                event.location,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.xs),

        // Price and attendees
        Row(
          children: [
            Text(
              event.formattedPrice,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            if (event.maxAttendees > 0) ...[
              Icon(
                Icons.people,
                size: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${event.currentAttendees}/${event.maxAttendees}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ],
    );

  Widget _buildOrganizerSection(BuildContext context, ThemeData theme) => Row(
      children: [
        // Organizer avatar
        CircleAvatar(
          radius: 12,
          backgroundImage: event.organizerProfileImage != null
              ? NetworkImage(event.organizerProfileImage!)
              : null,
          child: event.organizerProfileImage == null
              ? Text(
                  event.organizerName.isNotEmpty
                      ? event.organizerName[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),

        const SizedBox(width: AppSpacing.sm),

        // Organizer name
        Expanded(
          child: Text(
            event.organizerName,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // View count
        if (event.viewCount > 0)
          Row(
            children: [
              Icon(
                Icons.visibility,
                size: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                event.viewCount.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
      ],
    );

  Widget _buildActionButtons(BuildContext context, ThemeData theme) => Row(
      children: [
        // RSVP/Buy Tickets button
        Expanded(
          child: ElevatedButton(
            onPressed: event.hasSpotsAvailable ? onRSVP : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: event.isFree
                  ? theme.colorScheme.primary
                  : theme.colorScheme.secondary,
              foregroundColor: event.isFree
                  ? Colors.white
                  : theme.colorScheme.onSecondary,
            ),
            child: Text(
              event.isFree ? 'RSVP' : 'Buy Tickets',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Favorite button
        IconButton(
          onPressed: () {
            // TODO: Implement favorite functionality
          },
          icon: const Icon(Icons.favorite_border),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final eventDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (eventDate == today) {
      return 'Today, ${_formatTime(dateTime)}';
    } else if (eventDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)}, ${_formatTime(dateTime)}';
    }
  }

  String _formatDate(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$displayHour:$minute $period';
  }
}
