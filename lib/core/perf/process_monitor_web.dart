import 'system_stats.dart';

/// Web has no `dart:io`, so stats are reported as unavailable.
Future<SystemStats> sampleSystemStats() async => SystemStats.unavailable();
