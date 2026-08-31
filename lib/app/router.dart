import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../presentation/browser/browser_view.dart';
import '../presentation/browser/tab_switcher_view.dart';
import '../presentation/browser/bookmarks_view.dart';
import '../presentation/browser/history_view.dart';
import '../presentation/dictionary/dictionary_view.dart';
import '../presentation/dictionary/word_detail_view.dart';
import '../presentation/downloads/download_list_view.dart';
import '../presentation/settings/permissions_view.dart';
import '../presentation/settings/settings_view.dart';

/// Application route table (§6 navigation map).
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: Routes.browser,
        builder: (context, state) => const BrowserView(),
        routes: [
          GoRoute(
            path: Routes.tabSwitcher,
            name: Routes.tabSwitcher,
            pageBuilder: (context, state) => MaterialPage(
              fullscreenDialog: true,
              child: const TabSwitcherView(),
            ),
          ),
          GoRoute(
            path: Routes.bookmarks,
            name: Routes.bookmarks,
            builder: (context, state) => const BookmarksView(),
          ),
          GoRoute(
            path: Routes.history,
            name: Routes.history,
            builder: (context, state) => const HistoryView(),
          ),
          GoRoute(
            path: Routes.downloads,
            name: Routes.downloads,
            builder: (context, state) => const DownloadListView(),
          ),
          GoRoute(
            path: Routes.dictionary,
            name: Routes.dictionary,
            builder: (context, state) => const DictionaryView(),
            routes: [
              GoRoute(
                path: Routes.wordDetailPath,
                name: Routes.wordDetail,
                builder: (context, state) => WordDetailView(
                  entryId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: Routes.permissions,
            name: Routes.permissions,
            builder: (context, state) => const PermissionsView(),
          ),
          GoRoute(
            path: Routes.settings,
            name: Routes.settings,
            builder: (context, state) => const SettingsView(),
          ),
        ],
      ),
    ],
  );
});

/// Brief splash; hands off to the Browser once the DB/Hive init in [main]
/// has completed (init is synchronous here, so this is a short visual beat).
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(Routes.browser);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
