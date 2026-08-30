import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/webview_bridge.dart';
import '../data/native/webview_bridge_service.dart';

/// Binds the WebView selection bridge (§7.5) to its `flutter_inappwebview`
/// implementation. Presentation imports this provider, never `data/native`.
final webviewBridgeServiceProvider = Provider<WebviewBridgeService>((ref) {
  return InAppWebviewBridgeService();
});
