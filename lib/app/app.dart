import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme/app_theme.dart';
import 'theme/ui_prefs_notifier.dart';
import 'router.dart';

/// Root widget: MaterialApp.router driven by [uiPrefsProvider] for live
/// theme / locale updates.
class YomuApp extends ConsumerWidget {
  const YomuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(uiPrefsProvider);
    final router = ref.watch(routerProvider);

    final Locale? locale = prefs.locale == null
        ? null
        : Locale.fromSubtags(languageCode: prefs.locale!);

    return MaterialApp.router(
      title: 'Yomu',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(prefs),
      darkTheme: buildDarkTheme(prefs),
      themeMode: prefs.themeMode,
      locale: locale,
      routerConfig: router,
    );
  }
}
