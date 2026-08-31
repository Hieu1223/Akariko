import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_suggestion.dart';
import 'address_suggestions_viewmodel.dart';
import 'browser_viewmodel.dart';

/// Address-bar suggestion list, rendered *inside* the browser shell.
///
/// It is a layer of `BrowserView`'s content [Stack] rather than a pushed route:
///
/// * the OS back button is handled by the shell, so back closes the overlay and
///   returns to the page instead of walking the WebView's history;
/// * no route transition means the retained WebView is never detached or
///   re-attached (a platform-view re-attach is the single most expensive thing
///   that can happen on this screen);
/// * only this subtree rebuilds while typing.
class AddressSuggestionsOverlay extends ConsumerWidget {
  const AddressSuggestionsOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch a single bool: while the overlay is closed nothing else here builds.
    final visible =
        ref.watch(addressSuggestionsProvider.select((s) => s.visible));
    if (!visible) return const SizedBox.shrink();
    return const RepaintBoundary(child: _SuggestionsPanel());
  }
}

class _SuggestionsPanel extends ConsumerWidget {
  const _SuggestionsPanel();

  static const double _rowHeight = 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only the *list contents* drive this structure. `query` and `loading`
    // changes are fenced into the list / loading-line subtrees below, so a
    // keystroke (incl. a burst of deletes) rebuilds at most the visible rows.
    final suggestions =
        ref.watch(addressSuggestionsProvider.select((s) => s.suggestions));
    final browser = ref.read(browserViewModelProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    // The shell keeps `resizeToAvoidBottomInset: false`, so the keyboard
    // overlaps the content area instead of shrinking it. Pad the list so its
    // last row stays above the IME.
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    // Full-screen, opaque panel: it completely covers the retained WebView, so
    // the page never re-composites while the overlay is up — that transparent
    // layer over the platform view was the source of the scroll / delete jank.
    // Tapping anywhere that isn't a row cancels editing and returns to the page
    // (a row's own tap wins the gesture arena, so it still opens / fills).
    return GestureDetector(
      key: const Key('suggestionScrim'),
      behavior: HitTestBehavior.opaque,
      onTap: browser.cancelAddressEditing,
      child: Material(
        key: const Key('suggestionPanel'),
        color: scheme.surface,
        elevation: 0,
        child: Column(
          children: [
            const _LoadingLine(),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboard),
                child: suggestions.isEmpty
                    ? const _EmptyHint()
                    : _SuggestionListView(
                        suggestions: suggestions,
                        onOpen: browser.openSuggestion,
                        onFill: browser.fillAddress,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The scrollable suggestion list. It is its own [Consumer] so a `query`
/// change (every keystroke) rebuilds only this viewport and its visible rows,
/// not the surrounding [Material]/[Column] chrome of [_SuggestionsPanel].
class _SuggestionListView extends ConsumerWidget {
  const _SuggestionListView({
    required this.suggestions,
    required this.onOpen,
    required this.onFill,
  });

  final List<SearchSuggestion> suggestions;
  final void Function(SearchSuggestion) onOpen;
  final void Function(String) onFill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(addressSuggestionsProvider.select((s) => s.query));
    return ListView.builder(
      // Fixed-height rows + a bounded height (from the `Expanded` parent) make
      // this a proper viewport: only visible rows are built / painted and it
      // scrolls on the compositor, which is what keeps deletion and scrolling
      // smooth.
      itemExtent: _SuggestionsPanel._rowHeight,
      padding: EdgeInsets.zero,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: suggestions.length,
      itemBuilder: (ctx, i) {
        final suggestion = suggestions[i];
        return _SuggestionRow(
          key: ValueKey(suggestion.dedupeKey),
          suggestion: suggestion,
          query: query,
          height: _SuggestionsPanel._rowHeight,
          onOpen: () => onOpen(suggestion),
          onFill: () => onFill(suggestion.text),
        );
      },
    );
  }
}

/// 2px progress line shown while a lookup is in flight (the rows themselves
/// stay put, so the list never flashes empty between keystrokes). It watches
/// only `loading`, so flipping it doesn't rebuild the panel around it.
class _LoadingLine extends ConsumerWidget {
  const _LoadingLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active =
        ref.watch(addressSuggestionsProvider.select((s) => s.loading));
    return SizedBox(
      height: 2,
      child: active
          ? LinearProgressIndicator(
              minHeight: 2,
              backgroundColor: Colors.transparent,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

/// Shown when there are no suggestions. Watches only `query`, so an empty-list
/// keystroke updates just this text instead of the whole panel.
class _EmptyHint extends ConsumerWidget {
  const _EmptyHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query =
        ref.watch(addressSuggestionsProvider.select((s) => s.query));
    final text = query.trim().isEmpty
        ? 'Search or enter a website address'
        : 'No suggestions';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Theme.of(context).hintColor),
      ),
    );
  }
}

/// One suggestion row: tap to open, tap the arrow to put it in the bar.
class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    super.key,
    required this.suggestion,
    required this.query,
    required this.height,
    required this.onOpen,
    required this.onFill,
  });

  final SearchSuggestion suggestion;
  final String query;
  final double height;
  final VoidCallback onOpen;
  final VoidCallback onFill;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitle = _subtitle;

    return InkWell(
      onTap: onOpen,
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(_icon, size: 20, color: scheme.outline),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Title(
                    text: suggestion.text,
                    query: query,
                    style: textTheme.bodyMedium,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.outline,
                      ),
                    ),
                ],
              ),
            ),
            // `ExcludeFocus`: tapping this must not blur the address field,
            // which would close the overlay we are editing in.
            ExcludeFocus(
              child: IconButton(
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: 'Edit this suggestion',
                icon: Icon(Icons.north_west, color: scheme.outline),
                onPressed: onFill,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (suggestion.kind) {
        SuggestionKind.query => Icons.search,
        SuggestionKind.search => Icons.search,
        SuggestionKind.url => Icons.public,
        SuggestionKind.history => Icons.history,
        SuggestionKind.bookmark => Icons.bookmark_border,
      };

  String get _subtitle => switch (suggestion.kind) {
        SuggestionKind.query => 'Google Search',
        SuggestionKind.search => 'Google Search',
        SuggestionKind.url => 'Open website',
        SuggestionKind.history =>
          suggestion.subtitle.isEmpty ? 'History' : suggestion.subtitle,
        SuggestionKind.bookmark =>
          suggestion.subtitle.isEmpty ? 'Bookmark' : suggestion.subtitle,
      };
}

/// Renders the part of the suggestion the user has not typed yet in bold, the
/// way Google's own autocomplete does.
class _Title extends StatelessWidget {
  const _Title({required this.text, required this.query, this.style});

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final typed = query.trim();
    final matches = typed.isNotEmpty &&
        typed.length < text.length &&
        text.toLowerCase().startsWith(typed.toLowerCase());

    if (!matches) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, typed.length)),
          TextSpan(
            text: text.substring(typed.length),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
