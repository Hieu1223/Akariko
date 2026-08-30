import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/native/tokenizer_service.dart';
import 'usecases/tokenize_text_usecase.dart';

/// Binding for the Japanese tokenizer bridge (phase 4).
///
/// `KuromojiTokenizerService` is the only concrete impl; it talks to the native
/// Kuromoji `MethodChannel` registered in `MainActivity`. Swapping engines
/// later means replacing the bound implementation here — no UI change needed.
final tokenizerServiceProvider = Provider<TokenizerService>((ref) {
  return KuromojiTokenizerService();
});

final tokenizeTextUsecaseProvider = Provider<TokenizeTextUsecase>((ref) {
  return TokenizeTextUsecase(ref.watch(tokenizerServiceProvider));
});
