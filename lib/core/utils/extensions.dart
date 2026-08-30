import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colors => Theme.of(this).colorScheme;

  void showSnack(String message) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}

extension StringExtensions on String {
  bool get isBlank => trim().isEmpty;

  /// Returns true for what looks like a URL rather than a search query.
  bool get looksLikeUrl {
    final trimmed = trim();
    if (trimmed.isEmpty) return false;
    if (trimmed.contains(' ') && !trimmed.contains('.')) return false;
    return trimmed.contains('.') ||
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('about:');
  }

  /// Normalises user input into something a WebView can load.
  String toLoadableUrl() {
    final trimmed = trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('about:') || trimmed.startsWith('data:')) {
      return trimmed;
    }
    if (looksLikeUrl) return 'https://$trimmed';
    return 'https://www.google.com/search?q=${Uri.encodeComponent(trimmed)}';
  }
}
