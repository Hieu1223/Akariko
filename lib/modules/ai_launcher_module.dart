import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/ui_prefs_notifier.dart';

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
  const ChatGptAiLauncherModule({this.promptTemplate});

  /// Template sent to ChatGPT. The literal `{text}` (if present) is replaced
  /// with the user's selection; otherwise the selection is appended.
  final String? promptTemplate;

  @override
  String explainUrl(String text) {
    final template = promptTemplate?.trim();
    final prompt = (template == null || template.isEmpty)
        ? text
        : template.replaceAll('{text}', text);
    final q = Uri.encodeQueryComponent(prompt);
    return 'https://chatgpt.com/?q=$q';
  }
}

final aiLauncherModuleProvider = Provider<AiLauncherModule>((ref) {
  final prompt = ref.watch(uiPrefsProvider).chatGptPrompt;
  return ChatGptAiLauncherModule(promptTemplate: prompt);
});
