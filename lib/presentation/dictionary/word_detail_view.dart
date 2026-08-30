import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/debouncer.dart';
import '../../data/models/token.dart';
import '../../data/models/word_entry.dart';
import 'word_detail_viewmodel.dart';

/// Full entry screen (§7.7): headword, reading, POS chips, numbered senses.
///
/// Example-sentence tokenisation and the deck picker arrive with the tokenizer
/// (phase 4) and flashcards (phase 6); the "Add to deck" action is present but
/// inert until then.
class WordDetailView extends ConsumerWidget {
  const WordDetailView({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryAsync = ref.watch(wordDetailViewModelProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(entryAsync.valueOrNull?.headword ?? 'Entry'),
        actions: [
          if (entryAsync.valueOrNull case final entry?)
            IconButton(
              icon: const Icon(Icons.copy_outlined),
              tooltip: 'Copy word',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: entry.headword));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Copied “${entry.headword}”')),
                );
              },
            ),
        ],
      ),
      body: switch (entryAsync) {
        AsyncValue(hasError: true, :final error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Could not load this entry.\n$error',
                  textAlign: TextAlign.center),
            ),
          ),
        AsyncValue(value: final entry?) => _EntryBody(entry: entry),
        AsyncValue(isLoading: true) =>
          const Center(child: CircularProgressIndicator()),
        _ => const Center(child: Text('Entry not found')),
      },
    );
  }
}

class _EntryBody extends StatelessWidget {
  const _EntryBody({required this.entry});

  final WordEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          entry.headword,
          style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (entry.hasReading) ...[
          const SizedBox(height: 6),
          Text(
            entry.reading,
            style: textTheme.titleMedium?.copyWith(color: Colors.grey),
          ),
        ],
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in entry.posTags) _Chip(label: tag),
            _Chip(label: sourcePackLabel(entry.sourcePack)),
          ],
        ),
        const SizedBox(height: 24),
        Text('Meanings', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        if (entry.meanings.isEmpty)
          Text(
            'No meanings recorded for this entry.',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
          )
        else
          for (var i = 0; i < entry.meanings.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 26,
                    child: Text(
                      '${i + 1}.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      entry.meanings[i],
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
        const SizedBox(height: 28),
        _TokenizePanel(initialText: entry.headword),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add to deck'),
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Decks arrive with the flashcards phase.'),
            ),
          ),
        ),
      ],
    );
  }
}

/// Word-breakdown panel (phase 4): live Kuromoji tokenization of any text.
///
/// Pre-filled with the entry's headword so a single-word entry still shows its
/// reading / base form / POS; the user can paste a whole sentence to see it
/// split into morphemes. Tokenization is debounced so we don't hit the native
/// channel on every keystroke.
class _TokenizePanel extends ConsumerStatefulWidget {
  const _TokenizePanel({required this.initialText});

  final String initialText;

  @override
  ConsumerState<_TokenizePanel> createState() => _TokenizePanelState();
}

class _TokenizePanelState extends ConsumerState<_TokenizePanel> {
  late final TextEditingController _controller;
  final Debouncer _debouncer = Debouncer();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _query = widget.initialText.trim();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debouncer(() {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final tokensAsync = ref.watch(tokenizedBreakdownProvider(_query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Word breakdown', style: textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          onChanged: _onChanged,
          maxLines: null,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Type or paste Japanese text…',
            prefixIcon: const Icon(Icons.translate_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 12),
        switch (tokensAsync) {
          AsyncValue(isLoading: true) =>
            const Center(child: CircularProgressIndicator()),
          AsyncValue(hasError: true, :final error?) => Text(
              'Tokenizer unavailable.\n$error',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
          AsyncValue(:final value?) when value.isNotEmpty => Column(
              children: [
                for (final token in value) _TokenRow(token: token),
              ],
            ),
          _ => Text('No morphemes to show.',
              style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
        },
      ],
    );
  }
}

/// One morpheme row: surface form, optional reading, base form and POS label.
class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.token});

  final Token token;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  token.surface,
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (token.posShort.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    token.posShort,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          if (token.hasReading) ...[
            const SizedBox(height: 2),
            Text('読み: ${token.reading}',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
          if (token.hasBaseForm) ...[
            const SizedBox(height: 2),
            Text('原形: ${token.baseForm}',
                style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}

/// Human-readable name for a dataset's `source_pack` tag.
String sourcePackLabel(String sourcePack) => switch (sourcePack) {
      'jp_vn' => 'Nhật Việt (JP → VI/EN)',
      'default' => 'Dictionary',
      _ => sourcePack,
    };

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
