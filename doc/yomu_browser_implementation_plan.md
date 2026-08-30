# Yomu Browser — Implementation Plan & UI Specification

> Working name: **Yomu** ("to read"). Rename freely — referenced as `Yomu` throughout.
> Platform: Android (Flutter). Everything runs **on-device**; sync is a stubbed interface for later.
> Architecture: **three layers, strictly one-directional** — `presentation` → `modules` → `data` (db/low-level). **Presentation** (View + ViewModel, MVVM; ViewModel = Riverpod `Notifier`/`AsyncNotifier`) is the only layer that imports Flutter widgets. **Modules** hold business logic (use-cases, the FSRS algorithm, the AI-launcher and sync abstractions) and are the only layer presentation is allowed to call into. **Data** is the low-level layer — Drift/Hive persistence, repositories, and thin native-platform bridges (tokenizer, OCR, screen capture, download engine) — with no business rules and no UI. Routing via **go_router**.

---

## 1. Tech stack decisions

| Concern | Choice | Why |
|---|---|---|
| WebView / browser engine | `flutter_inappwebview` | Only Flutter webview with JS injection, text-selection callbacks, screenshot capture, custom context menu — required for popup dictionary + OCR region capture |
| State mgmt / DI | Riverpod (`Notifier`, `AsyncNotifier`, providers as DI graph) | ViewModels map 1:1 to Notifiers; providers replace a service locator |
| Routing | `go_router` | Declarative, supports nested/shell routes (tabs + bottom sheets) |
| Relational storage | `drift` (SQLite) | Bookmarks, history, dictionary, flashcards, review logs, downloads, news, tabs |
| KV storage | `Hive` | Settings, feature toggles, last-open-tab id |
| Secrets | `flutter_secure_storage` + AES (via `cryptography` pkg) | Password vault entries, encrypted at rest |
| Tokenizer | Native Kotlin **Kuromoji** (ipadic) via `MethodChannel` | Pure-JVM, no network, no embedded interpreter — runs entirely offline on Android with a simple, well-understood dependency |
| FSRS | Hand-ported Dart implementation of the FSRS-4.5 algorithm | No good maintained Dart FSRS package; algorithm is ~150 LOC, easy to port and unit-test against the reference weights |
| OCR | `google_mlkit_text_recognition` (Japanese model) fed by a native screen-region capture (`MediaProjection`) | On-device, supports vertical/horizontal Japanese, no extra native bridge to maintain (official Flutter plugin) |
| Downloads | `flutter_downloader` | Native download manager w/ notifications, pause/resume |
| RSS/Atom parsing | `webfeed_revised` + `http` | Manual news source list, no aggregator backend |
| YouTube captions | `youtube_explode_dart` (metadata/timedtext) + custom parser | No API key needed, works offline of any backend server |
| AI "explain" launcher | `url_launcher` (external) with `flutter_inappwebview` fallback tab | Opens ChatGPT with the selected text prefilled |
| Localization | `flutter_localizations` + `intl`, ARB-based (`.arb` files → generated `AppLocalizations`) | Standard Flutter i18n toolchain; language list starts with whatever locales have an `.arb` file, easy to add more later without touching app logic |

---

## 2. Project structure

```
lib/
  main.dart                          // init Hive/Drift/native channels, runs ProviderScope
  app/
    app.dart                         // MaterialApp.router, theming, locale (watches UiPrefsNotifier)
    router.dart                      // GoRouter route table (see §6)
    theme/app_theme.dart             // Safari-like light/dark theme, SF-style rounded toolbar,
                                      // builds a ThemeData from the current accent-color/font-size prefs
    theme/ui_prefs_notifier.dart     // Notifier<UiPrefs> — theme mode, accent color, font scale,
                                      // address-bar position, toolbar layout, home layout; Hive-backed
  l10n/
    app_en.arb, app_ja.arb, app_vi.arb   // source strings per locale; more locales = add another .arb
                                          // generated AppLocalizations class is what widgets read from

  core/                               // cross-cutting, no layer owns it exclusively
    constants/routes.dart            // route name/path constants
    constants/db_constants.dart      // table/column name constants
    errors/failures.dart             // sealed Failure classes
    utils/result.dart                // Result<T> = Ok(T) | Err(Failure)
    utils/debouncer.dart             // used by address bar search + dictionary lookup
    utils/extensions.dart

  // ══════════════════════════════════════════════════════════════════
  // LAYER 1 — data: DB / low-level layer. No business rules, no UI.
  // Persistence + thin platform bridges only.
  // ══════════════════════════════════════════════════════════════════
  data/
    local/
      app_database.dart              // Drift DB, all @DriftDatabase tables
      tables/*.dart                  // BookmarksTable, HistoryTable, TabsTable,
                                      // DictionaryEntriesTable, FlashcardsTable, DecksTable,
                                      // ReviewLogsTable, DownloadItemsTable, NewsSourcesTable,
                                      // NewsArticlesTable, PasswordEntriesTable
      daos/*.dart                    // one Dao per table group (BookmarkDao, FlashcardDao, ...)
      hive_boxes.dart                // Hive box names + typed accessors for settings

    models/                          // freezed immutable models (DB-row <-> domain mapping)
      word_entry.dart, sentence_entry.dart, flashcard.dart, review_log.dart,
      tab_model.dart, bookmark.dart, history_entry.dart, download_item.dart,
      news_source.dart, news_article.dart, password_entry.dart,
      caption_segment.dart, ocr_result.dart

    repositories/                    // interface + Drift-backed impl, one file each — pure CRUD, no rules
      dictionary_repository.dart
      flashcard_repository.dart
      browser_repository.dart        // tabs, bookmarks, history
      download_repository.dart
      news_repository.dart
      password_repository.dart
      caption_repository.dart

    datasources/
      remote/
        youtube_caption_datasource.dart
        news_rss_datasource.dart
      local/
        dictionary_import_datasource.dart   // custom-made dictionary dataset importer (see §4, DictionaryEntriesTable)
        flashcard_import_datasource.dart    // custom .yfsrs / CSV importer (see §7)

    native/                          // thin wrappers around platform channels/plugins — no business logic
      tokenizer_service.dart         // abstract TokenizerService + KuromojiTokenizerService impl
      ocr_service.dart               // abstract + MlkitOcrService impl
      screen_capture_service.dart    // native region capture (MethodChannel)
      webview_bridge_service.dart    // injects selection-listener JS, receives selection events
      download_engine_service.dart   // wraps flutter_downloader, exposes progress Stream
      password_vault_crypto.dart     // AES encrypt/decrypt primitives only, no vault business rules

  // ══════════════════════════════════════════════════════════════════
  // LAYER 2 — modules: business logic. The only layer presentation calls into.
  // Orchestrates one or more `data` repositories/native services per use-case.
  // ══════════════════════════════════════════════════════════════════
  modules/
    fsrs_engine.dart                     // pure FSRS algorithm, no I/O — unit-testable in isolation
    usecases/
      lookup_word_usecase.dart           // orchestrates tokenizer_service + dictionary_repository
      schedule_review_usecase.dart       // calls fsrs_engine, writes ReviewLog + updated Flashcard
      import_flashcards_usecase.dart     // parses file, maps to Flashcard+schedule, bulk insert
      capture_ocr_usecase.dart           // screen_capture_service -> ocr_service -> tokenizer_service
      manage_downloads_usecase.dart      // pairs download_engine_service with download_repository
      manage_passwords_usecase.dart      // pairs password_vault_crypto with password_repository
      manage_news_usecase.dart           // polling/refresh rules over news_rss_datasource + news_repository
    ai_launcher_module.dart              // decides how to build/launch the ChatGPT "explain" request
    sync_module.dart                     // abstract SyncModule + NoOpSyncModule (default, stubbed)

  // ══════════════════════════════════════════════════════════════════
  // LAYER 3 — presentation: MVVM. The only layer that imports Flutter widgets.
  // ══════════════════════════════════════════════════════════════════
  presentation/
    common_widgets/
      safari_address_bar.dart, bottom_toolbar.dart, tab_grid_card.dart,
      long_press_ask_ai_menu.dart, popup_dictionary_card.dart
    browser/
      browser_view.dart  browser_viewmodel.dart
      new_tab_view.dart  new_tab_viewmodel.dart      // home page: search + news feed
      tab_switcher_view.dart  tab_switcher_viewmodel.dart
      history_view.dart  history_viewmodel.dart
      bookmarks_view.dart  bookmarks_viewmodel.dart
    dictionary/
      dictionary_view.dart  dictionary_viewmodel.dart
      word_detail_view.dart  word_detail_viewmodel.dart
      popup_dictionary_viewmodel.dart                // drives the overlay widget above
    flashcards/
      deck_list_view.dart  deck_list_viewmodel.dart
      deck_detail_view.dart  deck_detail_viewmodel.dart
      study_session_view.dart  study_session_viewmodel.dart
      import_view.dart  import_viewmodel.dart
    youtube_caption/
      caption_view.dart  caption_viewmodel.dart
    ocr/
      ocr_capture_view.dart  ocr_capture_viewmodel.dart
      ocr_result_sheet.dart
    passwords/
      vault_list_view.dart  vault_list_viewmodel.dart
      entry_edit_view.dart  entry_edit_viewmodel.dart
    downloads/
      download_list_view.dart  download_list_viewmodel.dart
    news/
      news_source_manage_view.dart  news_source_manage_viewmodel.dart
    settings/
      settings_view.dart  settings_viewmodel.dart
```

**Layer rule (strict, one direction):** `presentation` → `modules` → `data`. A View never touches a ViewModel's internals beyond `ref.watch`/`ref.read`; a ViewModel never imports anything from `data` directly — it only calls a `modules/usecases/*` class (or, for simple pass-through reads like "list all bookmarks," a `modules`-level thin wrapper around the repository — but the import always goes through `modules`, never straight from `presentation` to `data`). Within `modules`, a usecase is what's allowed to reach into `data/repositories` and `data/native` and combine them (e.g. `capture_ocr_usecase.dart` chains `screen_capture_service` → `ocr_service` → `tokenizer_service` → `dictionary_repository`). Nothing in `data` ever imports from `modules` or `presentation` — dependencies point one way only. ViewModels hold **no Flutter widgets**, only Riverpod `Notifier` state + calls into `modules`.

---

## 3. Key interfaces (the contracts between files)

```dart
// data/native/tokenizer_service.dart
abstract class TokenizerService {
  /// Returns tokens with surface form, reading, base form, POS tag.
  Future<List<Token>> tokenize(String text);
}
class KuromojiTokenizerService implements TokenizerService {
  static const _channel = MethodChannel('yomu/tokenizer');
  @override
  Future<List<Token>> tokenize(String text) async {
    final raw = await _channel.invokeMethod<List>('tokenize', {'text': text});
    return raw!.map((e) => Token.fromMap(Map<String, dynamic>.from(e))).toList();
  }
}
```

```dart
// data/native/ocr_service.dart
abstract class OcrService {
  /// Runs on-device text recognition on a cropped region bitmap.
  Future<OcrResult> recognize(Uint8List croppedPngBytes);
}
class MlkitOcrService implements OcrService {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.japanese);
  @override
  Future<OcrResult> recognize(Uint8List croppedPngBytes) async {
    final input = InputImage.fromBytes(bytes: croppedPngBytes, metadata: /* ... */);
    final recognized = await _recognizer.processImage(input);
    return OcrResult.fromMlkit(recognized);
  }
}
```

```dart
// modules/fsrs_engine.dart  (pure function, unit-testable, no I/O)
class FsrsEngine {
  final FsrsWeights weights;
  const FsrsEngine(this.weights);

  /// Given the current card state and a rating (Again/Hard/Good/Easy),
  /// returns the new stability/difficulty/due-date — no side effects.
  ScheduleResult schedule(CardScheduleState current, Rating rating, DateTime now);
}
```

```dart
// modules/usecases/schedule_review_usecase.dart
class ScheduleReviewUsecase {
  final FsrsEngine _engine;
  final FlashcardRepository _flashcards;
  ScheduleReviewUsecase(this._engine, this._flashcards);

  Future<void> call(String cardId, Rating rating) async {
    final card = await _flashcards.getById(cardId);
    final result = _engine.schedule(card.scheduleState, rating, DateTime.now());
    await _flashcards.updateSchedule(cardId, result);
    await _flashcards.appendReviewLog(cardId, rating, result);
  }
}
```

```dart
// data/repositories/flashcard_repository.dart
abstract class FlashcardRepository {
  Stream<List<Flashcard>> watchDueCards(String deckId);
  Future<Flashcard> getById(String id);
  Future<void> updateSchedule(String id, ScheduleResult result);
  Future<void> appendReviewLog(String id, Rating rating, ScheduleResult result);
  Future<void> bulkInsert(List<Flashcard> cards);       // used by import
}
```

ViewModels depend only on the **abstract** repository/service types (bound to concrete impls in `core/di/providers.dart`), so any layer can be swapped (e.g. `NoOpSyncModule` → a real server sync later) without touching presentation code.

---

## 4. Local database schema (Drift)

- `TabsTable(id, url, title, favicon_url, screenshot_path, created_at, last_active_at, is_pinned)`
- `HistoryTable(id, url, title, visited_at)`
- `BookmarksTable(id, url, title, folder, created_at)`
- `DictionaryEntriesTable(id, headword, reading, pos, meanings_json, source_pack)` — imported once from Hieu's own custom-built dictionary dataset (not a third-party pack), indexed (FTS5) on `headword`/`reading`; `source_pack` still kept as a column in case a second dataset is layered in later
- `DecksTable(id, name, created_at, card_count)`
- `FlashcardsTable(id, deck_id, type[word|sentence], content, reading, meaning, extra_json, due, stability, difficulty, elapsed_days, scheduled_days, reps, lapses, state, last_review)`
- `ReviewLogsTable(id, card_id, rating, reviewed_at, prev_state_json, new_state_json)`
- `DownloadItemsTable(id, url, file_path, status, progress, total_bytes, created_at)`
- `NewsSourcesTable(id, name, feed_url, added_at)` — seeded with a starter list on first launch (see §7.17), user-editable/removable thereafter
- `NewsArticlesTable(id, source_id, title, link, published_at, summary, is_read)`
- `PasswordEntriesTable(id, site_url, username, encrypted_password, notes, updated_at)` — `encrypted_password` is AES-GCM ciphertext; key lives in `flutter_secure_storage`, never in Drift

---

## 5. Custom flashcard/schedule import format (`.yfsrs`)

A zip containing `manifest.json` + `cards.jsonl`, so schedule data is optional and portable:

```json
// manifest.json
{ "format_version": 1, "app": "yomu", "exported_at": "2026-08-30T00:00:00Z" }
```

```json
// cards.jsonl — one JSON object per line
{
  "type": "word",
  "content": "読む",
  "reading": "よむ",
  "meaning": "to read",
  "tags": ["N4"],
  "schedule": {
    "due": "2026-09-02T00:00:00Z",
    "stability": 4.2, "difficulty": 6.1,
    "elapsed_days": 3, "scheduled_days": 4,
    "reps": 5, "lapses": 1, "state": "Review",
    "last_review": "2026-08-29T00:00:00Z"
  }
}
```

`schedule` is optional — omitting it imports the card as brand-new (`state: New`). The **Import screen** (§6, Flashcards) also accepts a plain CSV with a column-mapping step (front/back/reading/tags) for pulling from Anki-style exports, but CSV import never carries schedule data.

---

## 6. Navigation map

```
Splash ──(init done)──▶ Browser (NewTab shown as tab 0)

Browser (shell route, holds AddressBar + WebView + BottomToolbar)
 ├─ tap address bar ─────────▶ Address/Search suggestions (inline, not a route)
 ├─ tap "+" ──────────────────▶ New Tab (pushed into shell)
 ├─ tap tabs icon ────────────▶ Tab Switcher (modal route)
 │    ├─ tap a tab card ──────▶ back to Browser (that tab active)
 │    └─ tap "+" ─────────────▶ New Tab
 ├─ select text in page ──────▶ Popup Dictionary (overlay, no route push)
 │    ├─ tap "Add to deck" ───▶ Deck picker sheet ─▶ (stay on page)
 │    └─ tap "Full entry" ────▶ Word Detail (pushed)
 ├─ long-press selection ─────▶ "Ask AI" quick action ▶ external/tab ChatGPT
 ├─ tap bookmark icon ────────▶ toggles bookmark (no nav)
 ├─ swipe-down menu ▶ Bookmarks / History / Downloads / Passwords / Settings / Flashcards
 └─ region-select toolbar icon▶ OCR Capture (fullscreen overlay)

New Tab (home)
 ├─ search bar ───────────────▶ navigates active tab to search/URL, back to Browser
 └─ news article tap ─────────▶ opens article URL in current tab

Dictionary (from menu)
 ├─ search result tap ────────▶ Word Detail
 └─ Word Detail "add to deck" ▶ Deck picker sheet

Flashcards
 Deck List ─ tap deck ────────▶ Deck Detail
 Deck Detail ─ "Study" ───────▶ Study Session
             ─ "Import" ──────▶ Import screen
 Study Session ─ session end ─▶ back to Deck Detail (summary shown inline)
 Import ─ pick file ──────────▶ preview/mapping ─▶ confirm ─▶ back to Deck List

YouTube Caption View (opened when active tab URL is a youtube.com/watch URL,
 via toolbar toggle "Caption mode")
 ├─ toggle switch ─────────────▶ shows/hides caption panel below video
 └─ tap a caption token ───────▶ Popup Dictionary overlay

OCR Capture (fullscreen overlay over current screen)
 ├─ drag-select region ───────▶ Ocr Result Sheet (bottom sheet)
 │    └─ tap a recognized token ▶ Popup Dictionary overlay
 └─ cancel ────────────────────▶ dismiss, back to previous screen

Passwords / Downloads / News Sources / Settings — each a standalone pushed route
 from the browser menu; Entry Edit is pushed from Vault List "Add"/tap-entry.
```

---

## 7. Screen-by-screen UI spec

### 7.1 Splash
| Elements | Events → Transition |
|---|---|
| App logo, progress spinner | DB/Hive/tokenizer-channel init complete → replace with **Browser** |

### 7.2 Browser (main shell)
**Layout (Safari-style):** rounded pill address bar at top (or bottom, toggle in Settings) showing domain + reader/lock icon; full-bleed WebView below; bottom toolbar with Back / Forward / Share / Tabs-count-bubble / Menu.

| Elements | Events → Transition |
|---|---|
| Address bar (pill) | tap → focus + show suggestions dropdown (history/bookmarks match, inline) |
| | submit URL/query → loads in current WebView tab |
| WebView | text selection → show **Popup Dictionary** card anchored above selection |
| | long-press on selection → show "Ask AI" chip in the native selection toolbar |
| | region-select icon (toolbar, only shown when Settings > OCR is enabled) → **OCR Capture** |
| Back / Forward buttons | tap → `webViewController.goBack/goForward`; disabled state reflects `canGoBack/Forward` |
| Tabs button (shows tab count) | tap → **Tab Switcher** |
| Share button | tap → native share sheet with current URL |
| Menu (overflow) | tap → sheet: Bookmarks / History / Downloads / Passwords / Flashcards / News Sources / Settings / "Caption Mode" (enabled only on youtube.com) |
| Bookmark toggle (in address bar) | tap → insert/delete `BookmarksTable` row, icon fills/unfills |

**ViewModel state:** `activeTabId`, `canGoBack`, `canGoForward`, `isLoading`, `pageTitle`, `selection: TextSelection?`.

### 7.3 New Tab (home page)
| Elements | Events → Transition |
|---|---|
| Centered search bar (same widget as address bar) | submit → navigate active tab, switch to Browser view |
| Quick-access row (top bookmarks, favicon grid) | tap tile → navigate |
| **News feed list** (title, source name, timestamp, optional thumbnail) | tap article → open URL in current tab |
| | pull-to-refresh → `modules/usecases/manage_news_usecase.dart` refresh, updates `NewTabViewModel` state |
| "Manage sources" link (feed section header) | tap → **News Source Management** |

### 7.4 Tab Switcher
| Elements | Events → Transition |
|---|---|
| Grid of tab cards (screenshot thumbnail, title, close "x") | tap card → set active tab, pop to Browser |
| | tap "x" on card → close tab (removes from `TabsTable`), grid animates removal |
| "+" FAB | tap → new tab created, pop to Browser showing New Tab |
| "Close All" (menu) | tap → confirm dialog → clears `TabsTable` except one blank tab |

### 7.5 Popup Dictionary (overlay widget, not a route)
Triggered by WebView text-selection callback (via `webview_bridge_service`).
| Elements | Events → Transition |
|---|---|
| Card: headword, reading (furigana), top 1-3 short meanings, tokenized breakdown if a sentence was selected | tap outside card → dismiss |
| "Add to deck" icon button | tap → deck-picker bottom sheet → confirm → inserts `FlashcardsTable` row (state=New) |
| "Full entry →" | tap → push **Word Detail** |
| "Ask AI" icon | tap → `ai_launcher_module.explain(selectedText)` |

### 7.6 Dictionary (manual browse/search)
| Elements | Events → Transition |
|---|---|
| Search field (debounced) | typing → live-filters `DictionaryEntriesTable` FTS query, results list updates |
| Result list rows (headword, reading, short gloss) | tap → **Word Detail** |
| Recent-lookups section (above results, empty query state) | tap entry → **Word Detail** |

### 7.7 Word Detail
| Elements | Events → Transition |
|---|---|
| Headword + reading (large), POS tag chips | — |
| Meanings list (numbered senses) | — |
| Example sentences (if present in dict pack), each tappable to tokenize | tap sentence token → mini popup (same widget as §7.5) |
| "Add to deck" button | tap → deck-picker sheet |
| "Already in deck: <name>" badge (if applicable) | tap badge → **Deck Detail** |

### 7.8 Flashcards — Deck List
| Elements | Events → Transition |
|---|---|
| Deck cards (name, due-today count, total count) | tap → **Deck Detail** |
| "+ New Deck" | tap → inline text-field dialog → creates `DecksTable` row |
| "Import" (top bar icon) | tap → **Import** |

### 7.9 Flashcards — Deck Detail
| Elements | Events → Transition |
|---|---|
| Stats header: due today / learning / new / total | — |
| "Study Now" button (disabled if 0 due) | tap → **Study Session** |
| Card list (content, state chip, due date) | tap row → inline expand (edit content) |
| Row swipe-actions: Edit / Delete | Delete → confirm dialog → removes card + its review logs |
| "Import into this deck" | tap → **Import** (pre-selects this deck) |

### 7.10 Study Session
| Elements | Events → Transition |
|---|---|
| Card front (word or sentence, audio icon if TTS available) | tap card → flips to reveal reading/meaning (front→back animation) |
| Rating bar (Again / Hard / Good / Easy), shown only after flip | tap rating → `ScheduleReviewUsecase.call()`, advances to next due card |
| Progress bar (reviewed / total-due-this-session) | — |
| "End session" (top-left) | tap → confirm if mid-session → pop to **Deck Detail**, summary snackbar |
| Session exhausted (no cards left) | auto → summary screen state (reviewed count, accuracy) → "Done" button → pop to Deck Detail |

### 7.11 Import
| Elements | Events → Transition |
|---|---|
| File picker button (accepts `.yfsrs`, `.csv`) | pick file → parses header, shows preview table |
| Preview table (first 10 rows) + column-mapping dropdowns (CSV only) | change mapping → live-updates preview |
| Target deck picker (existing or "new deck: <name>") | — |
| "Import N cards" button | tap → `ImportFlashcardsUsecase.call()` → progress indicator → success toast → pop to Deck List/Detail |

### 7.12 YouTube Caption View
Rendered as a mode of the Browser screen when the current tab is a `youtube.com/watch` URL and the user taps "Caption mode".
| Elements | Events → Transition |
|---|---|
| Video player (top half, native YouTube iframe/webview) | plays normally; playback time drives caption sync |
| Toggle switch "Captions" (top-right of caption panel) | off → collapses caption panel, video expands full height |
| Caption panel (bottom half): current + upcoming lines, each line's tokens individually tappable | tap a token → **Popup Dictionary** overlay anchored to that token |
| | tap a caption line (not a token) → seeks video to that line's timestamp |
| Auto-scroll toggle (small icon) | off → panel stays put even as video plays; on → follows current line |

### 7.13 OCR Capture
Fullscreen translucent overlay over whatever the user was looking at (in-webview or elsewhere on-device, via `screen_capture_service`'s `MediaProjection` region grab).
| Elements | Events → Transition |
|---|---|
| Dimmed background + drag-to-select rectangle | drag → live-updates selection rect |
| "Capture" button (appears once a rect is drawn) | tap → `CaptureOcrUsecase.call(rect)` → loading spinner → **OCR Result Sheet** |
| "Cancel" (top-left X) | tap → dismiss overlay, return to previous screen |

**OCR Result Sheet** (bottom sheet pushed on top of the capture overlay)
| Elements | Events → Transition |
|---|---|
| Recognized text, rendered as tappable tokens (tokenizer runs on OCR output) | tap token → **Popup Dictionary** overlay |
| "Copy all" | tap → clipboard |
| "Add sentence to deck" | tap → deck-picker sheet, inserts as `type: sentence` card |
| "Retry" | tap → back to capture overlay |

### 7.14 Passwords — Vault List
| Elements | Events → Transition |
|---|---|
| Biometric/PIN prompt (on screen entry) | success → shows list; fail/cancel → pop back |
| Entry rows (site favicon, site, username, masked password) | tap → **Entry Edit** |
| "+ Add" | tap → **Entry Edit** (blank) |
| Autofill suggestion banner (shown inside WebView login forms via `webview_bridge_service` detecting password fields) | tap "Fill" → injects credentials into the form |

### 7.15 Passwords — Entry Edit
| Elements | Events → Transition |
|---|---|
| Site URL, username, password (with reveal toggle + generator button), notes fields | Save → encrypts + upserts `PasswordEntriesTable`, pop to Vault List |
| Delete (edit mode only) | confirm dialog → delete, pop to Vault List |

### 7.16 Downloads
| Elements | Events → Transition |
|---|---|
| List rows: filename, progress bar/percentage, status (downloading/paused/done/failed) | tap row (done) → opens file via native viewer intent |
| Row actions: pause/resume, cancel, retry | tap → `DownloadListViewModel` calls `modules/usecases/manage_downloads_usecase.dart` |
| "Clear completed" | tap → removes finished rows from `DownloadItemsTable` |

### 7.17 News Source Management
| Elements | Events → Transition |
|---|---|
| List of sources (name, feed URL, last-fetched time) | swipe → delete source (cascades delete its `NewsArticlesTable` rows) |
| "+ Add source" (name + feed URL fields) | tap Save → validates feed parses → inserts `NewsSourcesTable` row |

**Default seed sources:** on first launch, a Drift migration seeds `NewsSourcesTable` with this starter list (all manually removable/editable afterward like any other source — this is just the out-of-the-box set, not a hardcoded/locked list):

| Source | Feed URL |
|---|---|
| Japan Times — latest articles | `https://www.japantimes.co.jp/feed/topstories/` |
| Japan Today | `https://japantoday.com/feed` |
| News On Japan | `http://www.newsonjapan.com/rss/top.xml` |
| Kyodo News+ (All) | `https://english.kyodonews.net/rss/all.xml` |
| BRIDGE（ブリッジ）テクノロジー＆スタートアップ情報 | `http://feeds.feedburner.com/SdJapan` |
| NYT > Japan | `https://www.nytimes.com/svc/collections/v1/publish/http://www.nytimes.com/topic/destination/japan/rss.xml` |
| ライブドアニュース - 主要トピックス | `https://news.livedoor.com/topics/rss/top.xml` |
| 朝日新聞デジタル | `http://rss.asahi.com/rss/asahi/newsheadlines.rdf` |

Some of these (BRIDGE, livedoor, Asahi) only expose an "All Feeds" landing page rather than a single category feed in the source list as given — `news_rss_datasource.dart` treats the URL above as each source's one `feed_url` (matching `NewsSourcesTable`'s single-feed-per-source schema); if a source later needs multiple category feeds, that's a schema change (`NewsSourcesTable` → one row per feed, grouped by a `source_group` column) rather than something the current single-feed-per-row design supports.

### 7.18 Settings
| Elements | Events → Transition |
|---|---|
| **Language** (app UI language picker: system default / specific locale) | change → persisted to Hive (`settings.locale`), app rebuilds under the new `Locale` immediately (no restart) |
| **Appearance** — theme (light/dark/system), accent color swatch picker, address-bar position (top/bottom), font size (body text scale, affects dictionary/flashcard/caption text), toolbar layout (which of Back/Forward/Share/Tabs/Menu show vs collapse into overflow), home page layout (news-feed-first vs quick-access-first) | change → persisted to Hive, applied live via a `ThemeNotifier`/`UiPrefsNotifier` the whole widget tree watches |
| Data & Storage (clear cache, dictionary pack management, export flashcards to `.yfsrs`) | export → file picker save location |
| OCR toggle (show/hide the region-select toolbar icon) | change → Hive setting, Browser toolbar updates |
| Sync (disabled/greyed, "Coming soon") | — (stub only, calls `NoOpSyncModule`) |
| About | — |

### 7.19 Bookmarks / History (standard browser screens)
| Elements | Events → Transition |
|---|---|
| List rows (title, URL, favicon; History grouped by day) | tap → opens URL in current tab, pop to Browser |
| Swipe to delete | tap → removes row |
| Search field (History only) | filters list |

---

## 8. Lifecycle notes

**App lifecycle** (`main.dart`): initialize in strict order — Hive.initFlutter → open Drift DB (runs migrations) → register `MethodChannel` handlers (tokenizer, screen capture, OCR) → warm up `NoOpSyncModule`/real sync stub → `runApp(ProviderScope(child: YomuApp()))`. `WidgetsBindingObserver` on the root widget flushes any in-flight tab screenshot capture and pauses `modules/usecases/manage_news_usecase.dart`'s polling on `AppLifecycleState.paused`, resumes on `resumed`. `UiPrefsNotifier` (locale + theme/layout prefs) is read from Hive synchronously before `runApp` so the very first frame already renders in the right language/theme — no flash of default English/light theme on cold start.

**ViewModel (Notifier) lifecycle:** each screen's Notifier is created lazily by its provider on first `ref.watch`, and auto-disposed (`autoDispose`) when no widget watches it — except `BrowserViewModel`, `DownloadListViewModel`, and `TabSwitcherViewModel`, which are kept alive for the app session (tabs/downloads must survive navigation away). `StudySessionViewModel` disposes on session end/exit and flushes any queued review logs synchronously before disposal so a rating is never lost if the user backs out mid-session.

**WebView lifecycle:** one `InAppWebViewController` per open tab, kept in `BrowserViewModel`'s tab map; only the active tab's controller is attached to the visible widget tree (others are kept in a headless pool so background tabs don't re-render, capped at N=6 live controllers — least-recently-used tabs beyond that are frozen to a screenshot + reloaded on reactivation).

**Native services:** `tokenizer_service` (Kuromoji) is initialized once at app start — dictionary load is the expensive part, done once, well before it's likely to be needed. `ocr_service` (ML Kit) needs no warm-up — the recognizer initializes lazily on first use. `screen_capture_service`'s `MediaProjection` permission is requested lazily on first OCR use, and the projection session is torn down immediately after each capture (not held open) for battery/privacy.

**Download manager:** `flutter_downloader`'s background isolate posts progress via a port; `data/native/download_engine_service.dart` exposes it as a `Stream<DownloadItem>` that `modules/usecases/manage_downloads_usecase.dart` merges into Drift-backed state, which `DownloadListViewModel` watches — so progress survives app restarts (source of truth is always `DownloadItemsTable`, the stream just drives live UI updates).

---

## 9. Phased implementation roadmap

1. **Skeleton:** project structure, Drift schema + migrations, go_router shell, theme, empty Browser/NewTab screens with a working WebView and address bar (no extras yet).
2. **Core browser parity:** tabs, tab switcher, bookmarks, history, downloads — i.e. "a working Safari clone."
3. **Dictionary:** build/import Hieu's custom-made dictionary dataset into `DictionaryEntriesTable` (FTS5 index), Dictionary + Word Detail screens, manual search only (no popup yet).
4. **Tokenizer bridge:** Kotlin Kuromoji `MethodChannel`, `TokenizerService`, wire into Word Detail's example-sentence tokenization.
5. **Popup dictionary:** `webview_bridge_service` JS injection for selection events, overlay widget, "Ask AI" long-press action.
6. **Flashcards + FSRS:** schema already in place from step 1; `FsrsEngine` (unit-test against reference FSRS test vectors first), Deck List/Detail, Study Session.
7. **Import/export:** `.yfsrs` format, CSV mapping wizard, Import screen.
8. **YouTube captions:** caption fetch/parse, Caption View screen, token tap → popup dictionary reuse.
9. **OCR:** native screen-region capture + ML Kit bridge, Capture screen, Result sheet, reuse tokenizer + popup dictionary.
10. **Passwords:** vault CRUD + encryption first, then WebView autofill detection/injection last (riskiest native integration).
11. **News feed:** source management, RSS fetch service, New Tab feed section, seed `NewsSourcesTable` with the default source list (§7.17) via a Drift migration.
12. **Polish:** settings screen, language switching (`.arb` files + `UiPrefsNotifier` wiring), UI customization options (theme/accent/font-size/layout), theming pass to match Safari more closely, sync interface left as `NoOpSyncModule` for a future phase.

Steps 3–11 are largely independent after step 1–2 land, so they can be reordered or parallelized — the only hard dependency is **tokenizer (4) before popup dictionary (5), captions (8), and OCR (9)**, and **FSRS engine (6) before import (7)**.
