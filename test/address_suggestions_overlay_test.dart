import 'package:arisu_browser/app/theme/ui_prefs_notifier.dart';
import 'package:arisu_browser/data/models/search_suggestion.dart';
import 'package:arisu_browser/presentation/browser/address_suggestions_overlay.dart';
import 'package:arisu_browser/presentation/browser/address_suggestions_viewmodel.dart';
import 'package:arisu_browser/presentation/browser/browser_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records the shell actions the overlay triggers, without a database, a
/// WebView or the tab machinery behind them.
class RecordingBrowserViewModel extends BrowserViewModel {
  final List<SearchSuggestion> opened = [];
  final List<String> filled = [];
  int cancels = 0;

  @override
  BrowserState build() => const BrowserState(tabs: [], activeTabId: '');

  @override
  void openSuggestion(SearchSuggestion suggestion) => opened.add(suggestion);

  @override
  void fillAddress(String text) => filled.add(text);

  @override
  void cancelAddressEditing() => cancels++;
}

/// Serves a fixed overlay state.
class StubSuggestions extends AddressSuggestionsViewModel {
  StubSuggestions(this.initial);
  final AddressSuggestionsState initial;

  @override
  AddressSuggestionsState build() => initial;
}

class StubUiPrefs extends UiPrefsNotifier {
  StubUiPrefs(this.prefs);
  final UiPrefs prefs;

  @override
  UiPrefs build() => prefs;
}

const _rows = [
  SearchSuggestion(text: 'flut', kind: SuggestionKind.query),
  SearchSuggestion(
    text: 'https://flutter.dev',
    kind: SuggestionKind.history,
    subtitle: 'Flutter',
    url: 'https://flutter.dev',
  ),
  SearchSuggestion(text: 'flutter web', kind: SuggestionKind.search),
];

Future<void> _pump(
  WidgetTester tester, {
  required AddressSuggestionsState state,
  required RecordingBrowserViewModel browser,
  UiPrefs prefs = const UiPrefs(),
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        uiPrefsProvider.overrideWith(() => StubUiPrefs(prefs)),
        addressSuggestionsProvider.overrideWith(() => StubSuggestions(state)),
        browserViewModelProvider.overrideWith(() => browser),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [Positioned.fill(child: AddressSuggestionsOverlay())],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  late RecordingBrowserViewModel browser;

  setUp(() => browser = RecordingBrowserViewModel());

  testWidgets('renders nothing while closed', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(),
      browser: browser,
    );

    expect(find.byType(InkWell), findsNothing);
    expect(find.text('flut'), findsNothing);
  });

  testWidgets('lists every suggestion with its source label', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(
        visible: true,
        query: 'flut',
        suggestions: _rows,
      ),
      browser: browser,
    );

    expect(find.text('flut'), findsOneWidget);
    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.text('flutter web'), findsOneWidget);
    expect(find.text('Flutter'), findsOneWidget); // history subtitle
    expect(find.text('Google Search'), findsNWidgets(2));
    expect(find.byIcon(Icons.history), findsOneWidget);
    expect(find.byIcon(Icons.north_west), findsNWidgets(3));
  });

  testWidgets('tapping a row opens it; tapping the arrow only fills the bar',
      (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(
        visible: true,
        query: 'flut',
        suggestions: _rows,
      ),
      browser: browser,
    );

    await tester.tap(find.text('flutter web'));
    await tester.pump();
    expect(browser.opened.single.text, 'flutter web');
    expect(browser.filled, isEmpty);

    await tester.tap(find.byIcon(Icons.north_west).first);
    await tester.pump();
    expect(browser.filled, ['flut']);
    expect(browser.opened, hasLength(1));
  });

  testWidgets('tapping the dimmed page area cancels editing', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(
        visible: true,
        query: 'flut',
        suggestions: _rows,
      ),
      browser: browser,
    );

    await tester.tap(find.byKey(const Key('suggestionScrim')));
    await tester.pump();

    expect(browser.cancels, 1);
    expect(browser.opened, isEmpty);
  });

  testWidgets('shows a hint instead of an empty list', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(visible: true),
      browser: browser,
    );

    expect(find.text('Search or enter a website address'), findsOneWidget);
  });

  testWidgets('shows a hint when a query has no matches', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(visible: true, query: 'zzz'),
      browser: browser,
    );

    expect(find.text('No suggestions'), findsOneWidget);
  });

  testWidgets('renders as a full-screen panel covering the page', (tester) async {
    await _pump(
      tester,
      state: const AddressSuggestionsState(
        visible: true,
        query: 'flut',
        suggestions: _rows,
      ),
      browser: browser,
    );

    final screen = tester.getSize(find.byType(MaterialApp));
    final panel = tester.getRect(find.byKey(const Key('suggestionPanel')));
    expect(panel.left, 0);
    expect(panel.top, 0);
    expect(panel.right, screen.width);
    expect(panel.bottom, screen.height);
  });

  testWidgets('a long list stays scrollable without overflowing',
      (tester) async {
    final many = [
      for (var i = 0; i < 8; i++)
        SearchSuggestion(text: 'suggestion $i', kind: SuggestionKind.search),
    ];
    tester.view.physicalSize = const Size(400, 500);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await _pump(
      tester,
      state: AddressSuggestionsState(
        visible: true,
        query: 'sug',
        suggestions: many,
      ),
      browser: browser,
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(Scrollable), findsOneWidget);
  });
}
