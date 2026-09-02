import 'package:hive/hive.dart';

part 'word_list_entry.g.dart';

@HiveType(typeId: 15)
class WordListEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String word;

  @HiveField(2)
  final String reading;

  @HiveField(3)
  final String meaning;

  @HiveField(4)
  final String websiteHost;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  final DateTime? lastReviewedAt;

  WordListEntry({
    required this.id,
    required this.word,
    required this.reading,
    required this.meaning,
    required this.websiteHost,
    required this.createdAt,
    this.lastReviewedAt,
  });

  WordListEntry copyWith({
    String? id,
    String? word,
    String? reading,
    String? meaning,
    String? websiteHost,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
  }) =>
      WordListEntry(
        id: id ?? this.id,
        word: word ?? this.word,
        reading: reading ?? this.reading,
        meaning: meaning ?? this.meaning,
        websiteHost: websiteHost ?? this.websiteHost,
        createdAt: createdAt ?? this.createdAt,
        lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      );
}
