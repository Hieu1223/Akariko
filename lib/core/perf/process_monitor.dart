import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import 'process_monitor_platform.dart';
import 'system_stats.dart';

/// Periodically samples [SystemStats] for the performance overlay.
///
/// Emits an initial sample immediately, then refreshes on the interval stored
/// in [UiPrefs.perfRefreshMs] (so changing it in settings re-arms the stream).
final processMonitorProvider =
    StreamProvider.autoDispose<SystemStats>((ref) {
  final intervalMs = ref.watch(
    uiPrefsProvider.select((s) => s.perfRefreshMs),
  );
  final interval = Duration(milliseconds: intervalMs.clamp(250, 5000));

  final controller = StreamController<SystemStats>();
  var stopped = false;

  Future<void> tick() async {
    if (stopped) return;
    final sample = await sampleSystemStats();
    if (stopped) return;
    controller.add(sample);
  }

  tick();
  final timer = Timer.periodic(interval, (_) => tick());
  ref.onDispose(() {
    stopped = true;
    timer.cancel();
    controller.close();
  });

  return controller.stream;
});
