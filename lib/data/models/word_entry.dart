/// A single dictionary entry (maps from the in-memory dictionary store).
///
/// Entries live in memory only — paged in via [InMemoryDictionary.search], never
/// held as a full list. The id is the entry's stable index in the dictionary
/// asset, encoded as a string so it can travel through route parameters.
class WordEntry {
  const WordEntry({
    required this.id,
    required this.headword,
    this.reading = '',
    this.meanings = const [],
  });

  final String id;
  final String headword;
  final String reading;
  final List<String> meanings;

  bool get hasReading => reading.isNotEmpty && reading != headword;

  /// Short gloss for list rows (§7.6): the first few senses, joined.
  String get shortGloss => meanings.take(3).join('; ');

  @override
  String toString() => 'WordEntry($id, $headword, $reading)';
}
