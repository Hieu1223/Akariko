# Code Review — Yomu Browser (whole codebase)

- **Date:** 2026-08-30
- **Scope:** Full codebase (`lib/**`, `test/**`, `pubspec.yaml`, `analysis_options.yaml`)
- **Stack:** Flutter · Riverpod · Drift · go_router · flutter_inappwebview · Hive
- **Static check:** `flutter analyze` → **No issues found**

## Verdict

**Request changes.** One class of bug (stream leaks) should be fixed before merge.
The remainder are improvements. The dictionary import/search path is the most mature;
browser navigation and downloads are functional phase-1 work.

---

## Context

A Flutter (Riverpod + Drift + go_router) on-device Japanese-reading browser. Layering is
clean and consistent:

```
data  →  modules (repositories + use-cases)  →  presentation (ViewModels + Views)
```

The review was performed across the five axes: correctness, readability/architecture,
security, performance, and tests.

---

## Correctness

### Important — Stream subscriptions leak (missing `ref.onDispose`)

Five view models call `_module.watchX().listen(...)` inside `build()` and never cancel the
subscription:

- `lib/presentation/browser/new_tab_viewmodel.dart:29`
- `lib/presentation/browser/tab_switcher_viewmodel.dart:25`
- `lib/presentation/browser/bookmarks_viewmodel.dart:29`
- `lib/presentation/browser/history_viewmodel.dart:40`
- `lib/presentation/downloads/download_list_viewmodel.dart:26`

By contrast `browser_viewmodel.dart:71`, `dictionary_viewmodel.dart:82`, and
`dictionary_import_viewmodel.dart:24` do this correctly. The leaking cases keep the Drift
watch stream alive after the screen is popped and call `state = …` on a detached notifier
(a memory leak and stale-state writes).

**Fix:** capture the subscription and add `ref.onDispose(() => sub.cancel());` in each.

### Important (security / path) — Download filename taken from URL unsanitized

- `lib/modules/usecases/manage_downloads_usecase.dart:108` (`_safeName`)
- `:22` (`savePath = '${dir.path}/$id-${_safeName(url)}'`)

The last URL path segment is used verbatim. A segment such as `..` or containing illegal
filename characters (`/`, `:`, `*`) can write to an unexpected location or fail to open.
Always sanitize/strip path separators and illegal characters (or hash the URL) before
writing to disk.

### Consider — Duplicate history rows

- `browser_viewmodel.dart:138` (`navigateTo` records a visit) and
  `:167` (`onLoadStop` records again).

Same-URL navigations also produce distinct rows (no dedupe on `history_table`). History
will show repeats. Either record only on load-stop, or add a dedupe policy.

### Consider — FTS index not rebuilt on v1 → v2 upgrade

- `lib/data/local/app_database.dart:56-61` (`onUpgrade`) creates the FTS5 table but never
  calls `rebuildFtsIndex()`.

A user who imported under v1 has `entryCount() > 0`, so `isImported()` short-circuits
(`import_dictionary_usecase.dart:71`) and the index stays empty — latin/meaning search
silently falls back to `searchByContains`. Add `await _dao.rebuildFtsIndex()` in the
`from < 2` branch.

### Consider — Tab WebView state lost on switch

`BrowserView._WebViewArea` is keyed by `active.id` (`browser_view.dart:49`), so switching
tabs disposes and recreates the WebView; `switchTo` then calls `loadUrl` on the still-old
controller (`:114`). Each tab keeps no session (back/forward/scroll reset). Known phase-1
limitation, but worth a roadmap note (give each tab its own controller).

### Minor — Stale bookmark icon

`isActiveBookmarked` (`browser_viewmodel.dart:185`) starts `false` and is only refreshed
after a toggle, so the address-bar bookmark icon won't reflect an already-bookmarked page
when navigating/switching tabs.

---

## Architecture / Readability

### Consider — `BrowserModule` throws away type safety

- `lib/modules/browser_module.dart:14-36` returns `Stream<List<dynamic>>`, `Future<dynamic>`,
  `Future<List<dynamic>>`, forcing every consumer to `.cast<T>()` (e.g.
  `browser_viewmodel.dart:83`, `tab_switcher_viewmodel.dart:25`).

This is inconsistent with `DictionaryModule`/`DownloadModule`, which expose typed APIs, and
weakens compile-time guarantees. Return concrete `TabModel`/`Bookmark`/`HistoryEntry` types.

### FYI / dead code — Unimplemented routes & features

- `Routes.newTab`, `passwords`, `flashcards`, `newsSources`, `settings`
  (`lib/core/constants/routes.dart`) are declared but never registered as routes; the
  Settings menu item is a no-op (`browser_view.dart:157-161`) — a dead end for users.
- `NewsSourcesTable`/`NewsArticlesTable` are seeded (`app_database.dart:84`) but have no
  module/usecase/view (later phase). `PasswordEntriesTable` references
  `flutter_secure_storage`, which isn't even a dependency and has no code.

These are roadmap placeholders; flag before deleting. Recommend at least hiding the
Settings/no-op entries until wired.

---

## Security

- `javaScriptEnabled: true` on the WebView is expected for a browser; no injection into our
  own widgets (URL search uses `Uri.encodeComponent`, `extensions.dart:38`). No secrets in
  code. The only concrete issue is the download filename handling above.

---

## Performance

- Search uses `limit`/`offset` paging and the FTS5 `bm25` index — good. The streaming JSON
  parser (`dictionary_import_datasource.dart`) avoids loading 50 MB at once — well done.
- **Nit:** History filtering is done in memory on every build
  (`history_viewmodel.dart:14`); fine for now, move to a DB `LIKE` query when history grows.

---

## Tests

- Good, meaningful unit tests for query builders (`dictionary_search_query_test`), the
  streaming parser, and the asset shape (`dictionary_asset_test`, `dictionary_parsing_test`).
  Analyzer is clean.
- **Consider — coverage gaps on the riskiest logic:** no tests for
  `ImportDictionaryUsecase.run` (import orchestration/back-pressure),
  `ManageDownloadsUsecase` (pause/resume/cancel edge cases),
  `DictionaryRepository.search` mode selection, or any ViewModel. `widget_test.dart` is a
  placeholder. Recommend adding tests for the import use-case and download orchestration
  since those are the most failure-prone.

---

## Strengths

- Clean layer boundaries and dependency direction.
- `sealed` `Result`/`Failure` hierarchy; no raw exceptions leaking to the UI.
- Careful parameterized SQL with `LIKE` escaping and an FTS5 external-content index
  (`dictionary_dao.dart`).
- Backpressure-aware isolate import with current-isolate fallback
  (`dictionary_import_datasource.dart`).
- Disciplined `ref.keepAlive`/`onDispose` in the core view models, tinted/accessible theming.

---

## Required fixes (before merge)

1. Add `ref.onDispose` cancellation to the five leaking view models
   (new_tab, tab_switcher, bookmarks, history, download_list).
2. Sanitize the download file name derived from the URL.

## Then address

3. De-duplicate history records.
4. Rebuild FTS index in the v1→v2 `onUpgrade`.
5. Give `BrowserModule` typed return types.
6. Add tests for import/download orchestration and `DictionaryRepository.search`.
