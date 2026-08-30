import '../../data/models/token.dart';
import '../../data/native/tokenizer_service.dart';

/// Tokenizes arbitrary Japanese text into morphemes (§7.7 word breakdown).
///
/// Thin pass-through over [TokenizerService] so presentation depends on the
/// `modules` layer, never on `data/native` directly.
class TokenizeTextUsecase {
  TokenizeTextUsecase(this._tokenizer);

  final TokenizerService _tokenizer;

  Future<List<Token>> call(String text) => _tokenizer.tokenize(text);
}
