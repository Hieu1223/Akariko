import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Decides how to build/launch the ChatGPT "explain" request (§3, §7.5).
///
/// Kept as a pure module (no `url_launcher`/platform dependency) so it is
/// trivially unit-testable and swappable. The browser opens the returned URL
/// in a new in-app tab — the `flutter_inappwebview` fallback path from the
/// plan; an external open via `url_launcher` can wrap [explainUrl] later.
abstract class AiLauncherModule {
  /// Builds the URL that opens ChatGPT with [text] prefilled.
  String explainUrl(String text);
}

/// Opens ChatGPT's compose view with the selected text as the prompt.
class ChatGptAiLauncherModule implements AiLauncherModule {
  @override
  String explainUrl(String text) {
    final q = Uri.encodeQueryComponent(text);
    return 'https://chatgpt.com/?q=$q';
  }
}

final aiLauncherModuleProvider = Provider<AiLauncherModule>((ref) {
  return ChatGptAiLauncherModule();
});
