import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/video_transcript_repository.dart';
import '../data/repositories/word_list_repository.dart';

/// Provider for the word list repository.
final wordListRepositoryProvider = Provider<WordListRepository>((ref) {
  return WordListRepository();
});

/// Provider for the video transcript repository.
final videoTranscriptRepositoryProvider = Provider<VideoTranscriptRepository>((ref) {
  final repo = VideoTranscriptRepository();
  // Initialize the repository
  repo.init();
  return repo;
});
