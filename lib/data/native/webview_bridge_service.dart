import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/webview_bridge.dart';

/// `flutter_inappwebview` implementation of [WebviewBridgeService].
///
/// Injects a small selection listener that posts `{text, rect}` to a JS handler
/// registered on the controller. The handler is controller-scoped (so a fresh
/// controller — e.g. when switching tabs — re-registers cleanly), while the
/// selection stream is shared process-wide so any part of the UI can react.
class InAppWebviewBridgeService implements WebviewBridgeService {
  static const String _handlerName = 'yomuSelection';

  final StreamController<WebSelection> _stream =
      StreamController<WebSelection>.broadcast();

  @override
  Stream<WebSelection> get selectionStream => _stream.stream;

  @override
  void registerHandler(InAppWebViewController controller) {
    // `addJavaScriptHandler` is keyed per controller and asserts a unique name
    // on that controller; a new tab gets a new controller, so registering on
    // every `onWebViewCreated` is correct and never double-binds the same one.
    controller.addJavaScriptHandler(
      handlerName: _handlerName,
      callback: (args) {
        final raw = args.isNotEmpty ? args[0] : null;
        _emit(raw);
      },
    );
  }

  void _emit(dynamic raw) {
    if (raw is! String) {
      _stream.add(const WebSelection(text: '', rect: Rect.zero));
      return;
    }
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final text = (map['text'] as String?)?.trim() ?? '';
      final r = map['rect'] as Map<String, dynamic>?;
      if (text.isEmpty || r == null) {
        _stream.add(const WebSelection(text: '', rect: Rect.zero));
        return;
      }
      final rect = Rect.fromLTRB(
        (r['left'] as num).toDouble(),
        (r['top'] as num).toDouble(),
        (r['right'] as num).toDouble(),
        (r['bottom'] as num).toDouble(),
      );
      _stream.add(WebSelection(text: text, rect: rect));
    } on FormatException {
      _stream.add(const WebSelection(text: '', rect: Rect.zero));
    }
  }

  @override
  Future<void> injectListener(InAppWebViewController controller) async {
    await controller.evaluateJavascript(source: _script);
  }

  @override
  void dispose() => _stream.close();

  /// Installs a `selectionchange` listener that debounces and reports the
  /// current selection's text + bounding rect to the Dart side. Guards against
  /// re-installing after a script re-injection on the same page.
  static const String _script = '''
(function() {
  if (window.__yomuSelInstalled) return;
  window.__yomuSelInstalled = true;

  function report() {
    try {
      var sel = window.getSelection();
      if (!sel || sel.rangeCount === 0 || sel.isCollapsed) {
        window.flutter_inappwebview.callHandler('$_handlerName',
          JSON.stringify({ text: '', rect: null }));
        return;
      }
      var text = (sel.toString() || '').trim();
      if (text.length === 0) {
        window.flutter_inappwebview.callHandler('$_handlerName',
          JSON.stringify({ text: '', rect: null }));
        return;
      }
      var r = sel.getRangeAt(0).getBoundingClientRect();
      window.flutter_inappwebview.callHandler('$_handlerName', JSON.stringify({
        text: text,
        rect: { left: r.left, top: r.top, right: r.right, bottom: r.bottom,
                width: r.width, height: r.height }
      }));
    } catch (e) {
      window.flutter_inappwebview.callHandler('$_handlerName',
        JSON.stringify({ text: '', rect: null }));
    }
  }

  document.addEventListener('selectionchange', function() {
    if (window.__yomuSelTimer) clearTimeout(window.__yomuSelTimer);
    window.__yomuSelTimer = setTimeout(report, 250);
  });
})();
''';
}
