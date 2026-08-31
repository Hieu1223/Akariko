import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/remote/news_rss_datasource.dart';
import '../data/repositories/news_repository.dart';

// appDatabaseProvider is defined in browser_module (the project's DI root for
// the DB), so it's imported from there rather than duplicated.
import '../modules/browser_module.dart';
import 'usecases/manage_news_usecase.dart';

/// Binding for the news feed phase (§7.3 / §7.17): repository → RSS datasource
/// → use-case. ViewModels depend only on [manageNewsUsecaseProvider].
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftNewsRepository(db);
});

final newsRssDataSourceProvider =
    Provider<NewsRssDataSource>((ref) => NewsRssDataSource());

final manageNewsUsecaseProvider = Provider<ManageNewsUsecase>((ref) {
  return ManageNewsUsecase(
    ref.watch(newsRepositoryProvider),
    ref.watch(newsRssDataSourceProvider),
  );
});
