import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/routes.dart';
import '../../data/models/word_entry.dart';
import '../browser/browser_viewmodel.dart';
import '../dictionary/popup_dictionary_viewmodel.dart';

/// Overlay anchored to the current text selection (§7.5).
///
/// On a selection it shows a context menu (Copy / Paste / Select All / Web
/// Search / Lookup / Ask AI). Choosing "Lookup" swaps the menu for a popup
/// listing dictionary entries whose headword/reading starts with the selection,
/// shortest first. Tapping outside dismisses whatever is showing.
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
                    child: state.showMenu ? const _ContextMenu() : const _LookupList(),
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

/// The context menu shown on a text selection.
class _ContextMenu extends ConsumerWidget {
  const _ContextMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popupDictionaryViewModelProvider);
    final text = state.selection?.text ?? '';
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuItem(
            icon: Icons.copy_outlined,
            label: 'Copy',
            enabled: text.isNotEmpty,
            onTap: () {
              ref.read(browserViewModelProvider.notifier).copySelection(text);
              ref.read(popupDictionaryViewModelProvider.notifier).hide();
            },
          ),
          _MenuItem(
            icon: Icons.content_paste_outlined,
            label: 'Paste',
            onTap: () {
              ref.read(browserViewModelProvider.notifier).pasteSelection();
              ref.read(popupDictionaryViewModelProvider.notifier).hide();
            },
          ),
          _MenuItem(
            icon: Icons.select_all_outlined,
            label: 'Select All',
            onTap: () {
              ref.read(browserViewModelProvider.notifier).selectAll();
            },
          ),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.search_outlined,
            label: 'Web Search',
            enabled: text.isNotEmpty,
            onTap: () {
              ref.read(browserViewModelProvider.notifier).webSearch(text);
              ref.read(popupDictionaryViewModelProvider.notifier).hide();
            },
          ),
          _MenuItem(
            icon: Icons.translate_outlined,
            label: 'Lookup',
            enabled: text.isNotEmpty,
            onTap: () {
              ref.read(popupDictionaryViewModelProvider.notifier).lookup();
            },
          ),
          _MenuItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Ask AI',
            enabled: text.isNotEmpty,
            onTap: () {
              ref.read(browserViewModelProvider.notifier).askAi(text);
              ref.read(popupDictionaryViewModelProvider.notifier).hide();
            },
          ),
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.outline.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 18, color: enabled ? scheme.onSurface : scheme.outline),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: enabled ? null : scheme.outline,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The dictionary list popup opened by "Lookup".
class _LookupList extends ConsumerWidget {
  const _LookupList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(popupDictionaryViewModelProvider);
    final textTheme = Theme.of(context).textTheme;
    final query = state.selection?.text.trim() ?? '';

    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '“$query”',
              style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            if (state.loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.lookupResults.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No dictionary entries found.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: state.lookupResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (ctx, i) => _EntryRow(entry: state.lookupResults[i]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry});

  final WordEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        context.pushNamed(Routes.wordDetail, pathParameters: {'id': entry.id});
        ref.read(popupDictionaryViewModelProvider.notifier).hide();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.headword,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (entry.hasReading) ...[
              const SizedBox(height: 2),
              Text(
                entry.reading,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.outline),
              ),
            ],
            if (entry.shortGloss.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.shortGloss,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
