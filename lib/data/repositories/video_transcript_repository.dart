import 'package:hive/hive.dart';

import '../data/local/hive_boxes.dart';
import '../data/models/video_transcript.dart';

/// Repository for managing video transcripts caching.
///
/// Transcripts are cached per video ID and include tokenization for dictionary lookup.
class VideoTranscriptRepository {
  late Box<CachedVideoTranscript> _box;

  /// Initializes the repository by opening the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<CachedVideoTranscript>(HiveBoxes.videoTranscripts);
  }

  /// Caches a video transcript.
  Future<void> cacheTranscript(CachedVideoTranscript transcript) async {
    await _box.put(transcript.videoId, transcript);
  }

  /// Gets a cached transcript for a video ID.
  Future<CachedVideoTranscript?> getTranscript(String videoId) async {
    try {
      return _box.get(videoId);
    } catch (_) {
      return null;
    }
  }

  /// Checks if a transcript is cached for a video ID.
  Future<bool> isCached(String videoId) async {
    return _box.containsKey(videoId);
  }

  /// Removes a cached transcript.
  Future<void> removeTranscript(String videoId) async {
    await _box.delete(videoId);
  }

  /// Clears all cached transcripts.
  Future<void> clearAll() async {
    await _box.clear();
  }

  void dispose() {
    _box.close();
  }
}
