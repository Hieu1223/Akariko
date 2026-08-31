/// Build-time generator for the compressed, in-memory dictionary asset.
///
/// Reads the bundled 50 MB `lib/asset/dictionary.json`, trims each entry to
/// (word, kana, meaning), builds a prefix trie for headwords and readings, and
/// writes a gzipped binary blob to `lib/asset/dictionary.dat`. The runtime then
/// loads that blob directly — no on-device JSON parse, no SQLite table.
///
/// Run with: `dart run tool/build_dictionary.dart`
library;

import 'dart:io';

import 'package:arisu_browser/data/datasources/local/dictionary_binary.dart';
import 'package:arisu_browser/data/datasources/local/dictionary_source_parse.dart';

const String _sourcePath = 'lib/asset/dictionary.json';
const String _outputPath = 'lib/asset/dictionary.dat';

Future<void> main() async {
  stdout.writeln('Reading source dictionary ...');
  final bytes = await File(_sourcePath).readAsBytes();

  stdout.writeln('Parsing entries ...');
  final entries = parseDictionaryEntries(bytes).toList();

  stdout.writeln('Building entry arrays (${entries.length} entries) ...');
  final words = <String>[];
  final kanas = <String>[];
  final meanings = <List<String>>[];
  final readingKeys = <String>[];
  final readingVals = <int>[];

  for (var i = 0; i < entries.length; i++) {
    final e = entries[i];
    words.add(e.word);
    kanas.add(e.kana);
    meanings.add(e.meanings);
    if (e.kana.isNotEmpty) {
      readingKeys.add(e.kana);
      readingVals.add(i);
    }
  }

  stdout.writeln('Building headword trie ...');
  final head = buildTrie(words, [for (var i = 0; i < words.length; i++) i]);

  stdout.writeln('Building reading trie ...');
  final reading = buildTrie(readingKeys, readingVals);

  final dict = InMemoryDictionary(
    words: words,
    kanas: kanas,
    meanings: meanings,
    head: head,
    reading: reading,
  );

  stdout.writeln('Encoding + compressing ...');
  final encoded = encodeDictionary(dict);
  final compressed = GZipCodec().encode(encoded);

  await File(_outputPath).writeAsBytes(compressed);

  final rawKb = encoded.length ~/ 1024;
  final outKb = compressed.length ~/ 1024;
  stdout.writeln(
    'Wrote $_outputPath: ${entries.length} entries, '
    '$rawKb KB raw -> $outKb KB gzipped.',
  );
}
