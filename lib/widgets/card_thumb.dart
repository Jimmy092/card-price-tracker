import 'package:flutter/material.dart';

/// Shared card art thumbnail used on search, watchlist, and detail.
class CardThumb extends StatelessWidget {
  const CardThumb({
    super.key,
    required this.url,
    this.width = 56,
    this.height = 78,
    this.heroTag,
    this.elevated = true,
  });

  final String? url;
  final double width;
  final double height;
  final Object? heroTag;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(width > 80 ? 14 : 10);
    Widget image = ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null || url!.isEmpty
            ? ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Icon(
                  Icons.style_outlined,
                  size: width * 0.32,
                  color: scheme.onSurfaceVariant,
                ),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: width * 0.32,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: scheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
      ),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    if (!elevated) return image;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.12),
            blurRadius: 16,
            spreadRadius: -2,
          ),
        ],
      ),
      child: image,
    );
  }
}
