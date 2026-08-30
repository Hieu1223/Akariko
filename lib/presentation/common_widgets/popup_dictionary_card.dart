import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../../data/models/token.dart';
import '../../data/models/word_entry.dart';
import '../browser/browser_viewmodel.dart';
import '../dictionary/popup_dictionary_viewmodel.dart';

/// Overlay that shows the popup dictionary card anchored to the current text
/// selection (§7.5). Rendered on top of the WebView area; tapping outside the
/// card dismisses it. Returns nothing when there is no active selection.
class PopupDictionaryOverlay extends ConsumerStatefulWidget {
  const PopupDictionaryOverlay({super.key});

  @override
  ConsumerState<PopupDictionaryOverlay> createState() =>
      _PopupDictionaryOverlayState();
}

class _PopupDictionaryOverlayState extends ConsumerState<PopupDictionaryOverlay> {
  final GlobalKey _cardKey = GlobalKey();
  double _top = 0;
  double _left = 0;
  Size? _area;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(popupDictionaryViewModelProvider);
    if (!state.visible) return const SizedBox.shrink();

    final rect = state.selection!.rect;
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _area = Size(constraints.maxWidth, constraints.maxHeight);
        // Measure the card after layout, then clamp it on-screen.
        WidgetsBinding.instance.addPostFrameCallback((_) => _reposition(rect));
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () =>
                    ref.read(popupDictionaryViewModelProvider.notifier).hide(),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: _top,
              left: _left,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (constraints.maxWidth - 24).clamp(240, 340),
                  maxHeight: constraints.maxHeight * 0.72,
                ),
                child: GestureDetector(
                  // Consume taps on the card body so only outside taps dismiss.
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Material(
                    key: _cardKey,
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    color: Theme.of(context).colorScheme.surface,
                    child: const _PopupCard(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _reposition(Rect rect) {
    final area = _area;
    final ctx = _cardKey.currentContext;
    if (area == null || ctx == null) return;
    final size = ctx.size;
    if (size == null) return;

    final cardH = size.height;
    final cardW = size.width;
    var top = rect.top - cardH - 12;
    if (top < 8) top = rect.bottom + 12; // not enough room above → below
    top = top.clamp(8.0, area.height - cardH - 8);
    var left = rect.left + rect.width / 2 - cardW / 2;
    left = left.clamp(8.0, area.width - cardW - 8);

    if ((_top - top).abs() > 0.5 || (_left - left).abs() > 0.5) {
      setState(() {
        _top = top;
        _left = left;
      });
    }
  }
}

/// The card body: entry, morpheme breakdown, and actions.
class _PopupCard extends ConsumerWidget {
  const _PopupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popupDictionaryViewModelProvider);
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            if (state.word != null) _WordHeader(entry: state.word!)
            else if (!state.hasEntry)
              Text(
                'No dictionary entry found.',
                style: textTheme.bodyMedium
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            if (state.tokens.isNotEmpty) ...[
              const SizedBox(height: 10),
              _TokenChips(tokens: state.tokens),
            ],
            const SizedBox(height: 12),
            _Actions(),
          ],
        ],
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  const _WordHeader({required this.entry});

  final WordEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          entry.headword,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (entry.hasReading) ...[
          const SizedBox(height: 2),
          Text(
            entry.reading,
            style: textTheme.titleSmall?.copyWith(color: scheme.outline),
          ),
        ],
        if (entry.posTags.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in entry.posTags)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: textTheme.labelSmall
                        ?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          entry.shortGloss.isEmpty ? '—' : entry.shortGloss,
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _TokenChips extends ConsumerWidget {
  const _TokenChips({required this.tokens});

  final List<Token> tokens;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final token in tokens)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => ref
                .read(popupDictionaryViewModelProvider.notifier)
                .focusToken(token.surface),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                token.surface,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popupDictionaryViewModelProvider);
    final scheme = Theme.of(context).colorScheme;
    final selectedText = state.selection?.text ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.auto_awesome_outlined),
          tooltip: 'Ask AI',
          onPressed: selectedText.isNotEmpty
              ? () {
                  ref
                      .read(browserViewModelProvider.notifier)
                      .askAi(selectedText);
                  ref.read(popupDictionaryViewModelProvider.notifier).hide();
                }
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add to deck',
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Decks arrive with the flashcards phase.'),
            ),
          ),
        ),
        if (state.word != null)
          TextButton(
            onPressed: () {
              context.pushNamed(
                Routes.wordDetail,
                pathParameters: {'id': state.word!.id},
              );
              ref.read(popupDictionaryViewModelProvider.notifier).hide();
            },
            child: Text(
              'Full entry',
              style: TextStyle(color: scheme.primary),
            ),
          ),
      ],
    );
  }
}
