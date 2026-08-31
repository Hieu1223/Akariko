import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/constants/routes.dart';

/// Top-level settings screen. Preferences are grouped into cards (Appearance,
/// Browser, Tabs, Performance, ChatGPT, Pages).
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(uiPrefsProvider);
    final prefsNotifier = ref.read(uiPrefsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Group(
            title: 'Appearance',
            children: [
              ListTile(
                title: const Text('Theme'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<ThemeMode>(
                    selected: {prefs.themeMode},
                    onSelectionChanged: (s) =>
                        prefsNotifier.setThemeMode(s.first),
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Auto'),
                        icon: Icon(Icons.auto_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                title: const Text('Accent color'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    const Text('Used across the app for highlights.'),
                    const SizedBox(height: 8),
                    _AccentColorPicker(
                      selected: prefs.accentColor,
                      onSelected: prefsNotifier.setAccentColor,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('Font scale'),
                subtitle: Text('${(prefs.fontScale * 100).round()}%'),
                trailing: SizedBox(
                  width: 160,
                  child: Slider(
                    value: prefs.fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 12,
                    label: '${(prefs.fontScale * 100).round()}%',
                    onChanged: prefsNotifier.setFontScale,
                  ),
                ),
              ),
            ],
          ),
          _Group(
            title: 'Browser',
            children: [
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
              _NumberField(
                label: 'Top bar height',
                hint: 'Height of the address bar (28–120).',
                value: prefs.topBarHeight.round(),
                onChanged: (v) => prefsNotifier.setTopBarHeight(v.toDouble()),
              ),
              _NumberField(
                label: 'Bottom bar height',
                hint: 'Height of the bottom toolbar (36–120).',
                value: prefs.bottomBarHeight.round(),
                onChanged: (v) => prefsNotifier.setBottomBarHeight(v.toDouble()),
              ),
            ],
          ),
          _Group(
            title: 'Performance',
            children: [
              SwitchListTile(
                title: const Text('Show performance overlay'),
                subtitle: const Text(
                  'Floating bubble with live CPU and RAM usage.',
                ),
                value: prefs.perfOverlayEnabled,
                onChanged: prefsNotifier.setPerfOverlayEnabled,
              ),
              ListTile(
                title: const Text('Refresh interval'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SegmentedButton<int>(
                    selected: {prefs.perfRefreshMs},
                    onSelectionChanged: (s) =>
                        prefsNotifier.setPerfRefreshMs(s.first),
                    segments: const [
                      ButtonSegment(value: 500, label: Text('0.5s')),
                      ButtonSegment(value: 1000, label: Text('1s')),
                      ButtonSegment(value: 2000, label: Text('2s')),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _Group(
            title: 'Tabs',
            children: [
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
            ],
          ),
          _Group(
            title: 'ChatGPT',
            children: [
              ListTile(
                title: const Text('Prompt sent to ChatGPT'),
                subtitle: const Text(
                  'Use {text} where the selected text should go. '
                  'Saved automatically.',
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            ],
          ),
          _Group(
            title: 'Pages',
            children: [
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
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                title.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...children,
          ],
        ),
      );
}

class _AccentColorPicker extends StatelessWidget {
  const _AccentColorPicker({
    required this.selected,
    required this.onSelected,
  });
  final Color selected;
  final void Function(Color) onSelected;

  static const _presets = [
    Color(0xFF1A73E8), // Blue
    Color(0xFF6750A4), // Violet
    Color(0xFFE53935), // Red
    Color(0xFF2E7D32), // Green
    Color(0xFFF9A825), // Amber
    Color(0xFF00897B), // Teal
    Color(0xFFD81B60), // Pink
    Color(0xFF5D4037), // Brown
  ];

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in _presets)
            _Swatch(
              color: c,
              selected: c.toARGB32() == selected.toARGB32(),
              onTap: () => onSelected(c),
            ),
        ],
      );
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: selected
                ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 2)
                : null,
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : null,
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
