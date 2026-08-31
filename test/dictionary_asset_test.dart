import 'dart:io';

import 'package:arisu_browser/data/datasources/local/dictionary_binary.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the prebuilt trie asset: it must stay declared in `pubspec.yaml`
/// (under `lib/asset/dictionary.dat`), decode, and actually answer searches.
/// A mis-declared or stale asset would only surface as an empty dictionary at
/// runtime, so we verify it here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled trie asset decodes and searches', () async {
    final data = await rootBundle.load('lib/asset/dictionary.dat');
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    final decoded = decodeDictionary(
      Uint8List.fromList(GZipCodec().decode(bytes)),
    );

    expect(decoded.entryCount, greaterThan(100000),
        reason: 'the shipped dataset holds ~190k entries');

    // A Japanese prefix should return headword hits.
    final jp = decoded.search('日本');
    expect(jp.entries, isNotEmpty);
    expect(jp.entries.first.headword, isNotEmpty);

    // A latin/meaning query should also return hits.
    final en = decoded.search('water');
    expect(en.entries, isNotEmpty);
  });
}
