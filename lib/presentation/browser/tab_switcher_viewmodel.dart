import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/tab_model.dart';
import '../../modules/browser_module.dart';

/// Tab Switcher state (grid of open tabs).
class TabSwitcherState {
  const TabSwitcherState({this.tabs = const []});
  final List<TabModel> tabs;

  TabSwitcherState copyWith({List<TabModel>? tabs}) =>
      TabSwitcherState(tabs: tabs ?? this.tabs);
}

final tabSwitcherViewModelProvider =
    NotifierProvider<TabSwitcherViewModel, TabSwitcherState>(
        TabSwitcherViewModel.new);

class TabSwitcherViewModel extends Notifier<TabSwitcherState> {
  late final BrowserModule _module;
  StreamSubscription<List<TabModel>>? _sub;

  @override
  TabSwitcherState build() {
    _module = ref.read(browserModuleProvider);
    _sub = _module.watchTabs().listen((tabs) {
      state = state.copyWith(tabs: tabs);
    });
    ref.onDispose(() => _sub?.cancel());
    return const TabSwitcherState();
  }

  Future<void> closeTab(String id) => _module.closeTab(id);
  Future<void> openNewTab() => _module.createTab(url: 'about:home', title: 'New Tab');

  /// Clears every tab. The browser view-model's tab watcher re-creates a single
  /// fresh blank tab so the browser is never left empty.
  Future<void> closeAll() async {
    await _module.closeAll();
  }
}
