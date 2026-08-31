import 'dart:async';
import 'dart:io';

import 'system_stats.dart';

/// Samples RAM + CPU on desktop / mobile (non-web) hosts.
///
/// - Windows: `wmic` for physical memory and per-core load.
/// - Linux / Android: `/proc/meminfo` + delta of `/proc/stat` for CPU.
/// Unsupported hosts fall back to [SystemStats.unavailable].
Future<SystemStats> sampleSystemStats() async {
  try {
    if (Platform.isWindows) return await _sampleWindows();
    if (Platform.isLinux || Platform.isAndroid) return await _sampleLinux();
  } catch (_) {
    return SystemStats.unavailable();
  }
  return SystemStats.unavailable();
}

Future<SystemStats> _sampleWindows() async {
  final mem = await Process.run(
    'wmic',
    const ['OS', 'get', 'FreePhysicalMemory,TotalVisibleMemorySize', '/Value'],
  );
  final memLines = _kvLines(mem.stdout.toString());
  final freeKb = _toInt(memLines['FreePhysicalMemory']);
  final totalKb = _toInt(memLines['TotalVisibleMemorySize']);
  if (totalKb == null || freeKb == null || totalKb <= 0) {
    return SystemStats.unavailable();
  }
  final usedKb = totalKb - freeKb;
  final ramPct = (usedKb / totalKb) * 100;

  final cpu = await Process.run(
    'wmic',
    const ['CPU', 'get', 'LoadPercentage', '/Value'],
  );
  final cpuLines = _kvLines(cpu.stdout.toString());
  final loads = cpuLines.values
      .map(_toInt)
      .where((v) => v != null)
      .map((v) => v!.toDouble())
      .toList();
  final cpuPct = loads.isEmpty
      ? 0.0
      : loads.reduce((a, b) => a + b) / loads.length;

  return SystemStats(
    ramUsedPct: ramPct,
    ramUsedMb: (usedKb / 1024).round(),
    ramTotalMb: (totalKb / 1024).round(),
    cpuPct: cpuPct.clamp(0, 100),
  );
}

Future<SystemStats> _sampleLinux() async {
  final memInfo = await File('/proc/meminfo').readAsString();
  final mem = _kvLines(memInfo);
  final totalKb = _toInt(mem['MemTotal']);
  final availableKb = _toInt(mem['MemAvailable']) ??
      ((_toInt(mem['MemFree']) ?? 0) +
          (_toInt(mem['Buffers']) ?? 0) +
          (_toInt(mem['Cached']) ?? 0));
  if (totalKb == null || totalKb <= 0) {
    return SystemStats.unavailable();
  }
  final usedKb = totalKb - availableKb;
  final ramPct = (usedKb / totalKb) * 100;

  final first = _procStatCpu(await File('/proc/stat').readAsString());
  await Future.delayed(const Duration(milliseconds: 250));
  final second = _procStatCpu(await File('/proc/stat').readAsString());
  final totalDelta = second.total - first.total;
  final idleDelta = second.idle - first.idle;
  final cpuPct = totalDelta <= 0
      ? 0.0
      : (1 - idleDelta / totalDelta) * 100;

  return SystemStats(
    ramUsedPct: ramPct,
    ramUsedMb: (usedKb / 1024).round(),
    ramTotalMb: (totalKb / 1024).round(),
    cpuPct: cpuPct.clamp(0, 100),
  );
}

({int total, int idle}) _procStatCpu(String content) {
  final line = content.split('\n').firstWhere(
        (l) => l.startsWith('cpu ') || l.startsWith('cpu\t'),
        orElse: () => 'cpu 0 0 0 0 0 0 0 0 0 0',
      );
  final cols = line
      .split(RegExp(r'\s+'))
      .skip(1)
      .map((c) => int.tryParse(c) ?? 0)
      .toList();
  while (cols.length < 8) {
    cols.add(0);
  }
  final user = cols[0];
  final nice = cols[1];
  final system = cols[2];
  final idle = cols[3];
  final iowait = cols[4];
  final irq = cols[5];
  final softirq = cols[6];
  final steal = cols[7];
  final total =
      user + nice + system + idle + iowait + irq + softirq + steal;
  return (total: total, idle: idle + iowait);
}

Map<String, String> _kvLines(String text) {
  final map = <String, String>{};
  for (final raw in text.split('\n')) {
    final line = raw.trim();
    if (line.isEmpty) continue;
    final eq = line.indexOf('=');
    if (eq < 0) continue;
    final key = line.substring(0, eq).trim();
    final value = line.substring(eq + 1).trim();
    if (key.isNotEmpty) map[key] = value;
  }
  return map;
}

int? _toInt(String? v) {
  if (v == null) return null;
  return int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
}
