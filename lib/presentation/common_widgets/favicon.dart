import 'package:flutter/material.dart';

/// Small favicon for a tab/bookmark: shows the remote icon when available,
/// otherwise a fallback glyph.
///
/// `Image.network` already caches decoded images in Flutter's in-memory
/// [ImageCache], so repeats across list rebuilds are cheap; a [loadingBuilder]
/// keeps a neutral placeholder on screen instead of a layout pop.
class Favicon extends StatelessWidget {
  const Favicon({super.key, this.url, this.fallback = Icons.language, this.size = 20});

  final String? url;
  final IconData fallback;
  final double size;

  @override
  Widget build(BuildContext context) {
    final favicon = url;
    if (favicon != null && favicon.isNotEmpty) {
      return SizedBox(
        width: size,
        height: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            favicon,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: size.toInt() * 2,
            cacheHeight: size.toInt() * 2,
            // Bounded decode keeps memory low for large icons.
            isAntiAlias: true,
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return Center(
                child: SizedBox(
                  width: size * 0.6,
                  height: size * 0.6,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              );
            },
            errorBuilder: (_, _, _) => Icon(fallback, size: size),
          ),
        ),
      );
    }
    return Icon(fallback, size: size);
  }
}
