import 'package:arisu_browser/data/datasources/local/dictionary_import_datasource.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the bundled dataset itself: the asset must stay declared in
/// `pubspec.yaml` under [kDictionaryAssetKey] and keep the shape the importer
/// expects. Without this, a mis-declared asset would only surface as an empty
/// dictionary at runtime.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled dictionary asset is declared and parses', () async {
    final data = await rootBundle.load(kDictionaryAssetKey);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    final total = countDatasetEntries(bytes);
    expect(total, greaterThan(100000),
        reason: 'the shipped dataset holds ~190k entries');

    // Parsing is lazy, so only the first slice is materialised here.
    final sample = parseDictionaryEntries(bytes).take(500).toList();
    expect(sample, hasLength(500));
    expect(sample.every((e) => e.id.isNotEmpty), isTrue);
    expect(sample.every((e) => e.headword.isNotEmpty), isTrue);
    expect(sample.where((e) => e.meanings.isNotEmpty).length, greaterThan(400));
    // Ids are the dataset's primary key — duplicates would drop rows on import.
    expect(sample.map((e) => e.id).toSet(), hasLength(500));
  });
}
