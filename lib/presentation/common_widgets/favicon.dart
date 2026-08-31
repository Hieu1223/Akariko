import 'package:flutter/material.dart';

/// Small favicon for a tab/bookmark: shows the remote icon when available,
/// otherwise a fallback glyph.
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
            errorBuilder: (_, _, _) => Icon(fallback, size: size),
          ),
        ),
      );
    }
    return Icon(fallback, size: size);
  }
}
