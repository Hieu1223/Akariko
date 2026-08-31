import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Google autocomplete ("suggest") endpoint.
///
/// `client=firefox` is the only public flavour that answers with plain JSON:
///
/// ```json
/// ["flut", ["flutter", "flutter web", …], [], {…}]
/// ```
///
/// Everything about this class is built for the typing hot path:
///
/// * one [http.Client] is reused for the whole app session, so the TLS
///   handshake to `suggestqueries.google.com` is paid once instead of on every
///   keystroke (keep-alive);
/// * an LRU cache answers repeats instantly — deleting a character, retyping it
///   or re-opening the bar costs no network at all;
/// * a short timeout keeps a stalled request from pinning the list in the
///   "loading" state, and any failure degrades to an empty list (local
///   history/bookmark suggestions still show).
class GoogleSuggestDataSource {
  GoogleSuggestDataSource({http.Client? client, this.maxCacheEntries = 64})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// How many query→completions pairs to keep. Entries are tiny (a handful of
  /// short strings), so this is a few KB at most.
  final int maxCacheEntries;

  static const Duration _timeout = Duration(milliseconds: 2500);

  /// Insertion-ordered so the oldest entry is the first key (LRU eviction).
  final LinkedHashMap<String, List<String>> _cache =
      LinkedHashMap<String, List<String>>();

  bool _closed = false;

  /// Completions for [query], or an empty list when offline / rate-limited.
  ///
  /// [hl] is the UI language hint (e.g. `ja`); it is part of the cache key so
  /// switching app language doesn't serve stale-language completions.
  Future<List<String>> fetch(String query, {String? hl}) async {
    final normalized = query.trim();
    if (normalized.isEmpty || _closed) return const [];

    final key = '${hl ?? ''}\u0000${normalized.toLowerCase()}';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached; // re-insert → most recently used
      return cached;
    }

    final uri = Uri.https('suggestqueries.google.com', '/complete/search', {
      'client': 'firefox',
      'q': normalized,
      if (hl != null && hl.isNotEmpty) 'hl': hl,
    });

    try {
      final response = await _client.get(uri).timeout(_timeout);
      if (response.statusCode != 200) return const [];
      final parsed = parseSuggestResponse(response.bodyBytes);
      if (parsed.isNotEmpty) _remember(key, parsed);
      return parsed;
    } on Object {
      // Offline, DNS failure, timeout, malformed payload — suggestions are a
      // convenience, never an error the user should see.
      return const [];
    }
  }

  void _remember(String key, List<String> value) {
    _cache[key] = value;
    while (_cache.length > maxCacheEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Drops every cached completion (used when suggestions get disabled, so no
  /// remote data lingers in memory).
  void clearCache() => _cache.clear();

  void close() {
    if (_closed) return;
    _closed = true;
    _cache.clear();
    _client.close();
  }
}

/// Parses the `client=firefox` suggest payload into its completion strings.
///
/// Exposed for tests; tolerates the trailing metadata arrays Google appends and
/// any non-string entries.
List<String> parseSuggestResponse(List<int> bodyBytes) {
  final decoded = jsonDecode(utf8.decode(bodyBytes, allowMalformed: true));
  if (decoded is! List || decoded.length < 2) return const [];
  final completions = decoded[1];
  if (completions is! List) return const [];
  final out = <String>[];
  for (final item in completions) {
    if (item is String && item.trim().isNotEmpty) out.add(item);
  }
  return out;
}
