/// Snapshot of system resource usage sampled by [sampleSystemStats].
class SystemStats {
  const SystemStats({
    required this.ramUsedPct,
    required this.ramUsedMb,
    required this.ramTotalMb,
    required this.cpuPct,
    this.available = true,
  });

  /// Percent of physical RAM in use (0–100).
  final double ramUsedPct;

  /// Physical RAM currently used, in megabytes.
  final int ramUsedMb;

  /// Total physical RAM, in megabytes.
  final int ramTotalMb;

  /// Overall CPU utilization (0–100).
  final double cpuPct;

  /// Whether the host platform can report stats. When false the values are
  /// placeholders and the overlay should show a "not available" hint.
  final bool available;

  factory SystemStats.unavailable() => const SystemStats(
        ramUsedPct: 0,
        ramUsedMb: 0,
        ramTotalMb: 0,
        cpuPct: 0,
        available: false,
      );

  SystemStats copyWith({
    double? ramUsedPct,
    int? ramUsedMb,
    int? ramTotalMb,
    double? cpuPct,
    bool? available,
  }) =>
      SystemStats(
        ramUsedPct: ramUsedPct ?? this.ramUsedPct,
        ramUsedMb: ramUsedMb ?? this.ramUsedMb,
        ramTotalMb: ramTotalMb ?? this.ramTotalMb,
        cpuPct: cpuPct ?? this.cpuPct,
        available: available ?? this.available,
      );
}
