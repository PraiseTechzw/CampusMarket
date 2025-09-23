/// @Branch: Platform-Aware Image Widget
///
/// Cross-platform image widget that handles both web and mobile
/// Automatically chooses the correct image widget based on platform
/// Provides consistent error handling and loading states
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class PlatformImage extends StatelessWidget {

  const PlatformImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.loadingWidget,
    this.errorWidget,
    this.width,
    this.height,
  });
  final String imageUrl;
  final BoxFit fit;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    // If it's a network URL, always use Image.network
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ??
              Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
        },
        errorBuilder: (context, error, stackTrace) => errorWidget ??
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.outline,
                  size: 48,
                ),
              ),
      );
    }

    // For local file paths, use platform-specific widgets
    if (kIsWeb) {
      // On web, treat file paths as network URLs
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => errorWidget ??
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.outline,
                  size: 48,
                ),
              ),
      );
    } else {
      // On mobile, use Image.file
      return Image.file(
        File(imageUrl),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => errorWidget ??
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.outline,
                  size: 48,
                ),
              ),
      );
    }
  }
}

/// Convenience widget for image grids with consistent styling
class PlatformImageGridItem extends StatelessWidget {

  const PlatformImageGridItem({
    super.key,
    required this.imageUrl,
    this.onRemove,
    this.size,
  });
  final String imageUrl;
  final VoidCallback? onRemove;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemSize = size ?? 100.0;

    return Container(
      width: itemSize,
      height: itemSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: PlatformImage(
                imageUrl: imageUrl,
              ),
            ),
            if (onRemove != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
