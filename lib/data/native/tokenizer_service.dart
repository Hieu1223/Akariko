import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';

import '../models/token.dart';

/// Splits Japanese text into morphemes with surface form, kana reading,
/// dictionary (base) form and part-of-speech tag.
///
/// Abstract so a non-Android platform or a different engine can be dropped in
/// without touching the use-case or UI that depend on it.
abstract class TokenizerService {
  Future<List<Token>> tokenize(String text);
}

/// Kuromoji (ipadic) morphological analyzer, reached over a `MethodChannel`.
///
/// The heavy dictionary load happens once on the native side (in
/// `MainActivity.configureFlutterEngine`), so each `tokenize` call just runs a
/// lookup — cheap enough for a sentence. Calls run off the Dart UI thread only
/// insofar as the native handler posts its result back; for typical input the
/// cost is a few milliseconds.
class KuromojiTokenizerService implements TokenizerService {
  static const MethodChannel _channel = MethodChannel('yomu/tokenizer');

  @override
  Future<List<Token>> tokenize(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];

    try {
      final raw = await _channel.invokeMethod<List<dynamic>>(
        'tokenize',
        {'text': trimmed},
      );
      if (raw == null) return const [];
      return raw
          .map((e) => Token.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(growable: false);
    } on PlatformException catch (e) {
      // Tokenization is a best-effort enrichment; never block the dictionary
      // screen on a missing native bridge.
      log('Kuromoji tokenize failed: ${e.message}');
      return const [];
    }
  }
}
