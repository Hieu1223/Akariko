import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';

/// Top-level settings screen. Hosts appearance prefs, the customizable
/// ChatGPT prompt, and quick links to the secondary pages.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(uiPrefsProvider);
    final prefsNotifier = ref.read(uiPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionTitle('ChatGPT'),
          ListTile(
            title: const Text('Prompt sent to ChatGPT'),
            subtitle: const Text(
              'Use {text} where the selected text should go. '
              'Saved automatically.',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              maxLines: 4,
              controller: TextEditingController(text: prefs.chatGptPrompt)
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: prefs.chatGptPrompt.length),
                ),
              onChanged: prefsNotifier.setChatGptPrompt,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Explain the following text:\n\n{text}',
              ),
            ),
          ),
          const _SectionTitle('Browser'),
          SwitchListTile(
            title: const Text('Auto-hide address bar on scroll'),
            subtitle: const Text('Collapses the bar when scrolling the page.'),
            value: prefs.autoHideChrome,
            onChanged: prefsNotifier.setAutoHideChrome,
          ),
          ListTile(
            title: const Text('Address bar position'),
            trailing: SegmentedButton<AddressBarPosition>(
              selected: {prefs.addressBarPosition},
              onSelectionChanged: (s) =>
                  prefsNotifier.setAddressBarPosition(s.first),
              segments: const [
                ButtonSegment(
                  value: AddressBarPosition.top,
                  label: Text('Top'),
                  icon: Icon(Icons.vertical_align_top),
                ),
                ButtonSegment(
                  value: AddressBarPosition.bottom,
                  label: Text('Bottom'),
                  icon: Icon(Icons.vertical_align_bottom),
                ),
              ],
            ),
          ),
          const _SectionTitle('Tabs'),
          _NumberField(
            label: 'Max history per tab',
            value: prefs.maxTabHistory,
            onChanged: prefsNotifier.setMaxTabHistory,
          ),
          _NumberField(
            label: 'Tabs keeping page state',
            hint: 'Top-N tabs keep their live page; the rest keep URL only.',
            value: prefs.cachedTabCount,
            onChanged: prefsNotifier.setCachedTabCount,
          ),
          _NumberField(
            label: 'Release page data after (seconds)',
            hint: '0 keeps the page state until the tab is pushed out.',
            value: prefs.tabPageTimeoutSec,
            onChanged: prefsNotifier.setTabPageTimeoutSec,
          ),
          SwitchListTile(
            title: const Text('Swipe to close tabs'),
            subtitle: const Text('Swipe a tab card left/right to delete it.'),
            value: prefs.tabSwipeToClose,
            onChanged: prefsNotifier.setTabSwipeToClose,
          ),
          const _SectionTitle('Pages'),
          _PageTile(
            icon: Icons.bookmark,
            title: 'Bookmarks',
            onTap: () => context.pushNamed(Routes.bookmarks),
          ),
          _PageTile(
            icon: Icons.history,
            title: 'History',
            onTap: () => context.pushNamed(Routes.history),
          ),
          _PageTile(
            icon: Icons.menu_book,
            title: 'Dictionary',
            onTap: () => context.pushNamed(Routes.dictionary),
          ),
          _PageTile(
            icon: Icons.download,
            title: 'Downloads',
            onTap: () => context.pushNamed(Routes.downloads),
          ),
          _PageTile(
            icon: Icons.shield_outlined,
            title: 'Permissions',
            subtitle: 'Manage internet and storage access.',
            onTap: () => context.pushNamed(Routes.permissions),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      );
}

class _PageTile extends StatelessWidget {
  const _PageTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: subtitle == null ? null : Text(subtitle!),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      );
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
  });
  final String label;
  final int value;
  final String? hint;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    return ListTile(
      title: Text(label),
      subtitle: hint == null ? null : Text(hint!),
      trailing: SizedBox(
        width: 72,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: const InputDecoration(isDense: true),
          onSubmitted: (t) {
            final parsed = int.tryParse(t);
            if (parsed != null) onChanged(parsed);
          },
        ),
      ),
    );
  }
}
