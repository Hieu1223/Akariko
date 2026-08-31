import 'package:arisu_browser/app/theme/ui_prefs_notifier.dart';
import 'package:arisu_browser/data/models/search_suggestion.dart';
import 'package:arisu_browser/data/repositories/browser_repository.dart';
import 'package:arisu_browser/data/repositories/search_suggestion_repository.dart';
import 'package:arisu_browser/modules/search_suggestions_module.dart';
import 'package:arisu_browser/presentation/browser/address_suggestions_viewmodel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records every lookup and lets the test control how long each one takes.
class ScriptedSuggestionsModule extends SearchSuggestionsModule {
  ScriptedSuggestionsModule()
      : super(browser: _UnusedBrowser(), remote: _UnusedRemote());

  final List<String> queries = [];

  /// When set, every lookup answers with an equal-but-new list, which is how a
  /// cache hit after a keystroke behaves.
  List<SearchSuggestion>? fixedResult;

  /// Query → artificial latency, so a slow early request can be raced against a
  /// fast later one.
  final Map<String, Duration> delays = {};

  @override
  Future<List<SearchSuggestion>> suggest(
    String rawQuery, {
    bool remoteEnabled = true,
    String? hl,
    int limit = 8,
  }) async {
    queries.add(rawQuery);
    final delay = delays[rawQuery];
    if (delay != null) await Future<void>.delayed(delay);
    final fixed = fixedResult;
    if (fixed != null) return List<SearchSuggestion>.of(fixed);
    return [
      SearchSuggestion(text: 'result:$rawQuery', kind: SuggestionKind.search),
    ];
  }
}

class _UnusedBrowser implements BrowserRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _UnusedRemote implements SearchSuggestionRepository {
  @override
  Future<List<String>> completions(String query, {String? hl}) async => const [];
  @override
  void clearCache() {}
  @override
  void dispose() {}
}

/// [UiPrefsNotifier] without Hive behind it.
class StubUiPrefs extends UiPrefsNotifier {
  @override
  UiPrefs build() => const UiPrefs();
}

void main() {
  late ScriptedSuggestionsModule module;
  late ProviderContainer container;

  setUp(() {
    module = ScriptedSuggestionsModule();
    container = ProviderContainer(
      overrides: [
        uiPrefsProvider.overrideWith(StubUiPrefs.new),
        searchSuggestionsModuleProvider.overrideWithValue(module),
      ],
    );
    addTearDown(container.dispose);
  });

  AddressSuggestionsViewModel vm() =>
      container.read(addressSuggestionsProvider.notifier);
  AddressSuggestionsState state() => container.read(addressSuggestionsProvider);

  test('starts closed with no rows', () {
    expect(state().visible, isFalse);
    expect(state().suggestions, isEmpty);
    expect(module.queries, isEmpty);
  });

  test('opening looks up immediately (no debounce on focus)', () async {
    vm().open('');
    expect(state().visible, isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(module.queries, ['']);
    expect(state().suggestions.single.text, 'result:');
    expect(state().loading, isFalse);
  });

  test('coalesces a burst of keystrokes into one lookup', () async {
    vm().open('');
    await Future<void>.delayed(Duration.zero);
    module.queries.clear();

    vm()
      ..onQueryChanged('f')
      ..onQueryChanged('fl')
      ..onQueryChanged('flu')
      ..onQueryChanged('flut');

    // Query text is applied at once (the field must feel instant) …
    expect(state().query, 'flut');
    // … but only the final value is looked up, once the typing settles.
    expect(module.queries, isEmpty);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(module.queries, ['flut']);
    expect(state().suggestions.single.text, 'result:flut');
  });

  test('a slow earlier response cannot overwrite a newer one', () async {
    module.delays['a'] = const Duration(milliseconds: 400);
    module.delays['ab'] = const Duration(milliseconds: 10);

    vm().open('a');
    vm().onQueryChanged('ab');

    await Future<void>.delayed(const Duration(milliseconds: 600));
    expect(module.queries, ['a', 'ab']);
    expect(state().suggestions.single.text, 'result:ab');
  });

  test('closing clears the rows and abandons an in-flight lookup', () async {
    module.delays['slow'] = const Duration(milliseconds: 200);
    vm().open('slow');
    expect(state().visible, isTrue);

    vm().close();
    expect(state().visible, isFalse);
    expect(state().suggestions, isEmpty);
    expect(state().query, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    // The late answer must not resurrect the overlay.
    expect(state().visible, isFalse);
    expect(state().suggestions, isEmpty);
  });

  test('closing cancels a pending debounced lookup', () async {
    vm().open('');
    await Future<void>.delayed(Duration.zero);
    module.queries.clear();

    vm().onQueryChanged('never');
    vm().close();

    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(module.queries, isEmpty);
  });

  test('re-opening with unchanged text does not re-query', () async {
    vm().open('same');
    await Future<void>.delayed(Duration.zero);
    vm().open('same');
    await Future<void>.delayed(Duration.zero);
    expect(module.queries, ['same']);
  });

  test('an equal result list is not swapped in (nothing to rebuild)', () async {
    module.fixedResult = const [
      SearchSuggestion(text: 'stable', kind: SuggestionKind.search),
    ];

    vm().open('a');
    await Future<void>.delayed(Duration.zero);
    final first = state().suggestions;

    vm().onQueryChanged('ab');
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(module.queries, ['a', 'ab']);
    expect(state().loading, isFalse);
    // Same contents → the very same list instance, so a `select` on
    // `suggestions` does not fire and the rows are not rebuilt.
    expect(state().suggestions, same(first));
  });
}
