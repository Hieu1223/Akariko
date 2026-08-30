import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/theme/ui_prefs_notifier.dart';
import 'data/local/app_database.dart';
import 'data/local/hive_boxes.dart';
import 'modules/browser_module.dart';
import 'modules/dictionary_module.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Hive (KV: settings / UI prefs)
  await Hive.initFlutter();
  final prefsBox = await Hive.openBox(HiveBoxes.prefs);
  final settingsBox = await Hive.openBox(HiveBoxes.settings);

  // 2. Drift DB (runs onCreate migration + seed on first access)
  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        uiPrefsBoxProvider.overrideWithValue(prefsBox),
        settingsBoxProvider.overrideWithValue(settingsBox),
      ],
      child: const YomuApp(),
    ),
  );
}
