import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/theme/ui_prefs_notifier.dart';
import 'data/datasources/local/dictionary_binary.dart';
import 'data/local/app_database.dart';
import 'data/local/hive_boxes.dart';
import 'modules/browser_module.dart';
import 'modules/dictionary_module.dart';

/// Asset key of the prebuilt, compressed in-memory dictionary trie.
const String kDictionaryAssetKey = 'lib/asset/dictionary.dat';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive (KV: settings / UI prefs)
  await Hive.initFlutter();
  final prefsBox = await Hive.openBox(HiveBoxes.prefs);
  final settingsBox = await Hive.openBox(HiveBoxes.settings);

  // 2. Drift DB (runs onCreate migration + seed on first access)
  final db = AppDatabase();

  // 3. In-memory dictionary: decode the prebuilt trie asset once, up front, so
  //    every search is served from RAM (no SQLite table, no JSON parse).
  final dictBytes =
      (await rootBundle.load(kDictionaryAssetKey)).buffer.asUint8List();
  final dictionary = decodeDictionary(
    Uint8List.fromList(GZipCodec().decode(dictBytes)),
  );

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        uiPrefsBoxProvider.overrideWithValue(prefsBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
        inMemoryDictionaryProvider.overrideWithValue(dictionary),
      ],
      child: const YomuApp(),
    ),
  );
}
