import 'dart:ui';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// A text selection made inside a WebView, reported by [WebviewBridgeService].
///
/// [text] is the selected string; [rect] is its bounding box in CSS pixels
/// relative to the WebView viewport (which is the coordinate space the popup
/// overlay is rendered in, since the WebView fills that area 1:1).
class WebSelection {
  const WebSelection({required this.text, required this.rect});

  final String text;
  final Rect rect;

  /// True when the selection is empty (the user collapsed/cleared it).
  bool get isEmpty => text.isEmpty;
}

/// Platform bridge that turns in-page text selections into [WebSelection]
/// events the browser can react to (popup dictionary, "Ask AI").
///
/// Lives in `core` (cross-cutting) so both `data/native` (the concrete
/// `flutter_inappwebview` impl) and `presentation` (which drives the overlay)
/// can depend on it without either layer importing the other.
abstract class WebviewBridgeService {
  /// Registers the JS handler on a controller. Call once per controller, in
  /// `onWebViewCreated`.
  void registerHandler(InAppWebViewController controller);

  /// Re-injects the selection listener script. Call on every page load
  /// (`onLoadStart`/`onLoadStop`) — scripts do not survive navigation.
  Future<void> injectListener(InAppWebViewController controller);

  /// Stream of selection events. An event with empty [WebSelection.text]
  /// means the selection was cleared and any popup should dismiss.
  Stream<WebSelection> get selectionStream;

  /// Stream of URL-open requests originating from in-app HTML pages (e.g. the
  /// home page's quick-access tiles and news articles). The payload is the URL
  /// to navigate to.
  Stream<String> get urlOpenStream;

  /// Tears down the streams. Call when the browser session ends.
  void dispose();
}
