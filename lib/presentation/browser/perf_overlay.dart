import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/ui_prefs_notifier.dart';
import '../../core/perf/process_monitor.dart';
import '../../core/perf/system_stats.dart';

/// A minimal, draggable performance HUD.
///
/// Collapses to a small bubble (just an icon) and expands into a compact card
/// showing CPU + RAM usage. Toggle visibility from Settings
/// ([UiPrefs.perfOverlayEnabled]); this widget is only mounted when enabled.
class PerfOverlay extends ConsumerStatefulWidget {
  const PerfOverlay({super.key});

  @override
  ConsumerState<PerfOverlay> createState() => _PerfOverlayState();
}

class _PerfOverlayState extends ConsumerState<PerfOverlay> {
  Offset _pos = Offset.zero;
  bool _posInit = false;
  bool _expanded = false;

  static const double _bubble = 52.0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final accent = ref.watch(uiPrefsProvider).accentColor;
    final statsAsync = ref.watch(processMonitorProvider);

    if (!_posInit) {
      _pos = Offset(size.width - _bubble - 12, size.height - 160);
      _posInit = true;
    }
    _pos = _clamp(size);

    final stats = statsAsync.valueOrNull;

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() {
          _pos += Offset(d.delta.dx, d.delta.dy);
        }),
        onTap: () => setState(() => _expanded = !_expanded),
        child: _expanded
            ? _ExpandedCard(
                accent: accent,
                stats: stats,
                onClose: () => ref
                    .read(uiPrefsProvider.notifier)
                    .setPerfOverlayEnabled(false),
                onCollapse: () => setState(() => _expanded = false),
              )
            : _Bubble(accent: accent, stats: stats),
      ),
    );
  }

  Offset _clamp(Size size) {
    final dx = _pos.dx.clamp(4.0, size.width - _bubble - 4.0);
    final dy = _pos.dy.clamp(4.0, size.height - _bubble - 4.0);
    return Offset(dx, dy);
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.accent, this.stats});
  final Color accent;
  final SystemStats? stats;

  @override
  Widget build(BuildContext context) {
    final loading = stats == null;
    return Container(
      width: _PerfOverlayState._bubble,
      height: _PerfOverlayState._bubble,
      decoration: BoxDecoration(
        color: accent,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Icon(
                stats!.available ? Icons.monitor_heart : Icons.monitor_heart_outlined,
                color: Colors.white,
                size: 24,
              ),
      ),
    );
  }
}

class _ExpandedCard extends StatelessWidget {
  const _ExpandedCard({
    required this.accent,
    this.stats,
    required this.onClose,
    required this.onCollapse,
  });
  final Color accent;
  final SystemStats? stats;
  final VoidCallback onClose;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    final loading = stats == null;
    final unavailable = stats != null && !stats!.available;
    final cpu = stats?.cpuPct ?? 0;
    final ram = stats?.ramUsedPct ?? 0;

    return Container(
      width: 168,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.5), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monitor_heart, size: 16, color: accent),
              const SizedBox(width: 6),
              const Text('Performance',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const Spacer(),
              GestureDetector(
                onTap: onCollapse,
                child: const Icon(Icons.remove, size: 16),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: const Icon(Icons.close, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (unavailable)
            const Text('Not available on this platform.',
                style: TextStyle(fontSize: 11))
          else if (loading)
            const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            _Metric(
              label: 'CPU',
              value: cpu,
              text: '${cpu.toStringAsFixed(0)}%',
              accent: accent,
            ),
            const SizedBox(height: 8),
            _Metric(
              label: 'RAM',
              value: ram,
              text:
                  '${stats!.ramUsedMb}/${stats!.ramTotalMb} MB',
              accent: accent,
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    required this.text,
    required this.accent,
  });
  final String label;
  final double value;
  final String text;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11)),
            Text(text,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value / 100,
            minHeight: 5,
            valueColor: AlwaysStoppedAnimation(accent),
            backgroundColor:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
