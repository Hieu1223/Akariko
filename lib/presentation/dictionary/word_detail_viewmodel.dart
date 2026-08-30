import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/token.dart';
import '../../data/models/word_entry.dart';
import '../../modules/dictionary_module.dart';
import '../../modules/tokenizer_module.dart';

/// Loads one dictionary entry for the Word Detail screen (§7.7) and records it
/// in the recent-lookup list.
final wordDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<WordDetailViewModel, WordEntry?, String>(WordDetailViewModel.new);

class WordDetailViewModel
    extends AutoDisposeFamilyAsyncNotifier<WordEntry?, String> {
  @override
  Future<WordEntry?> build(String entryId) async {
    final lookup = ref.read(lookupWordUsecaseProvider);
    final entry = await lookup.byId(entryId);
    if (entry != null) {
      // Feeds the "Recent lookups" section on the Dictionary screen.
      await lookup.remember(entry.id);
    }
    return entry;
  }
}

/// Morpheme breakdown of a piece of text (phase 4: Kuromoji bridge).
///
/// Drives the "Word breakdown" panel on the Word Detail screen; debounced on
/// the UI side so it only re-tokenizes after the user pauses typing. Empty /
/// whitespace text yields an empty list without touching the native channel.
final tokenizedBreakdownProvider =
    FutureProvider.autoDispose.family<List<Token>, String>((ref, text) async {
  if (text.trim().isEmpty) return const [];
  final usecase = ref.watch(tokenizeTextUsecaseProvider);
  return usecase(text);
});
