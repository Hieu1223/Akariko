/// A single morpheme produced by the Japanese tokenizer (Kuromoji, see
/// `data/native/tokenizer_service.dart`).
///
/// Surface form, kana reading, dictionary (base) form and part-of-speech come
/// straight from the native tokenizer; the UI derives a short English POS label
/// so the breakdown reads sensibly regardless of the app's display language.
class Token {
  const Token({
    required this.surface,
    this.reading = '',
    this.baseForm = '',
    this.partOfSpeech = '',
  });

  final String surface;
  final String reading;
  final String baseForm;
  final String partOfSpeech;

  factory Token.fromMap(Map<String, dynamic> map) => Token(
        surface: (map['surface'] as String?) ?? '',
        reading: (map['reading'] as String?) ?? '',
        baseForm: (map['baseForm'] as String?) ?? '',
        partOfSpeech: (map['partOfSpeech'] as String?) ?? '',
      );

  /// Kuromoji marks unknown base forms with `"*"`.
  bool get hasBaseForm => baseForm.isNotEmpty && baseForm != '*';

  /// True when the kana reading differs from the surface (i.e. there is a
  /// reading worth showing as furigana).
  bool get hasReading => reading.isNotEmpty && reading != surface;

  /// Short English label for the part of speech, or `''` when unknown.
  String get posShort => _posShort(partOfSpeech);

  /// Maps the Kuromoji ipadic POS heading (e.g. `名詞`) to a compact English
  /// label. Falls back to the raw heading if it is not in the table.
  static String _posShort(String pos) {
    if (pos.isEmpty || pos == '*') return '';
    final head = pos.split(RegExp(r'[,\s]')).first;
    return _posLabels[head] ?? head;
  }

  static const Map<String, String> _posLabels = {
    '名詞': 'noun',
    '動詞': 'verb',
    '形容詞': 'adj',
    '副詞': 'adv',
    '助詞': 'particle',
    '助動詞': 'aux verb',
    '連体詞': 'pre-noun adj',
    '接続詞': 'conj',
    '感動詞': 'interj',
    '接頭詞': 'prefix',
    '接尾詞': 'suffix',
    '記号': 'symbol',
    'フィラー': 'filler',
    'その他': 'other',
    'サ変接続': 'verbal noun',
  };
}
