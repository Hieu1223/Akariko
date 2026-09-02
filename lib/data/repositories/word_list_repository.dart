import 'package:hive/hive.dart';

import '../../data/local/hive_boxes.dart';
import '../../data/models/word_list_entry.dart';
import '../../data/models/word_entry.dart';

/// Repository for managing per-website word lists.
///
/// Each website (by host) has its own word list stored in Hive.
/// Words can be added from dictionary lookups and exported.
class WordListRepository {
  final Map<String, Box<WordListEntry>> _boxes = {};

  /// Gets or creates a Hive box for a specific website host.
  Future<Box<WordListEntry>> _getBoxForHost(String host) async {
    if (_boxes.containsKey(host)) {
      return _boxes[host]!;
    }
    
    // Sanitize host for use as box name
    final safeName = host.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final boxName = 'wordlist_$safeName';
    
    final box = await Hive.openBox<WordListEntry>(boxName);
    _boxes[host] = box;
    return box;
  }

  /// Adds a word to the word list for a specific website.
  Future<void> addWord({
    required String websiteHost,
    required String word,
    required String reading,
    required String meaning,
  }) async {
    final box = await _getBoxForHost(websiteHost);
    final id = '${DateTime.now().millisecondsSinceEpoch}_${word.hashCode}';
    final entry = WordListEntry(
      id: id,
      word: word,
      reading: reading,
      meaning: meaning,
      websiteHost: websiteHost,
      createdAt: DateTime.now(),
    );
    await box.put(id, entry);
  }

  /// Gets all words for a specific website.
  Future<List<WordListEntry>> getWordsForWebsite(String websiteHost) async {
    try {
      final box = await _getBoxForHost(websiteHost);
      return box.values.toList();
    } catch (_) {
      return [];
    }
  }

  /// Removes a word from a website's word list.
  Future<void> removeWord({
    required String websiteHost,
    required String wordId,
  }) async {
    final box = await _getBoxForHost(websiteHost);
    await box.delete(wordId);
  }

  /// Gets all website hosts that have word lists.
  Future<List<String>> getAllWebsiteHosts() async {
    final hosts = <String>{};
    for (final boxName in Hive.boxKeys()) {
      if (boxName.toString().startsWith('wordlist_')) {
        // Extract original host from box name (approximate)
        final host = boxName.toString().substring(9).replaceAll('_', '.');
        hosts.add(host);
      }
    }
    return hosts.toList();
  }

  /// Exports all words from a specific website's word list.
  Future<List<Map<String, String>>> exportWebsiteWordList(String websiteHost) async {
    final words = await getWordsForWebsite(websiteHost);
    return words.map((w) => {
      'word': w.word,
      'reading': w.reading,
      'meaning': w.meaning,
      'website': w.websiteHost,
      'createdAt': w.createdAt.toIso8601String(),
    }).toList();
  }

  /// Exports all word lists from all websites.
  Future<Map<String, List<Map<String, String>>>> exportAllWordLists() async {
    final hosts = await getAllWebsiteHosts();
    final result = <String, List<Map<String, String>>>{};
    
    for (final host in hosts) {
      result[host] = await exportWebsiteWordList(host);
    }
    
    return result;
  }

  /// Checks if a word already exists in a website's word list.
  Future<bool> wordExists({
    required String websiteHost,
    required String word,
  }) async {
    final words = await getWordsForWebsite(websiteHost);
    return words.any((w) => w.word == word);
  }

  void dispose() {
    for (final box in _boxes.values) {
      box.close();
    }
    _boxes.clear();
  }
}
