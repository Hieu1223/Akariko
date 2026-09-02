import 'package:hive/hive.dart';

part 'video_transcript.g.dart';

@HiveType(typeId: 16)
class VideoTranscriptSegment {
  @HiveField(0)
  final double start;

  @HiveField(1)
  final double end;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final List<String> tokens;

  VideoTranscriptSegment({
    required this.start,
    required this.end,
    required this.text,
    required this.tokens,
  });
}

@HiveType(typeId: 17)
class CachedVideoTranscript {
  @HiveField(0)
  final String videoId;

  @HiveField(1)
  final String url;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final List<VideoTranscriptSegment> segments;

  @HiveField(4)
  final DateTime cachedAt;

  CachedVideoTranscript({
    required this.videoId,
    required this.url,
    required this.title,
    required this.segments,
    required this.cachedAt,
  });
}
