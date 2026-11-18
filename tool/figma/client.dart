/// Figma REST client with a write-once cache, a request log and a hard stop on
/// rate limiting.
///
/// Rules (DEV_TRACKER.md → Figma budget):
/// - a cached response is never re-fetched (delete the file to refetch);
/// - every API request is logged in the tracker *before* it is sent;
/// - HTTP 429 stops the whole run;
/// - the token comes from env `FIGMA_TOKEN` and is never printed or logged.
library;

import 'dart:convert';
import 'dart:io';

import 'config.dart';

/// One planned API call.
final class FigmaRequest {
  const FigmaRequest({
    required this.label,
    required this.endpoint,
    required this.query,
    required this.cachePath,
    required this.summary,
  });

  /// Short name used for cache files, e.g. `onboarding`.
  final String label;

  /// Path below the API base, e.g. `/files/<key>/nodes`.
  final String endpoint;
  final Map<String, String> query;
  final String cachePath;

  /// Human-readable description for the log, e.g. `nodes onboarding 5444:10018`.
  final String summary;

  Uri get uri => Uri.parse('$apiBase$endpoint').replace(queryParameters: query);

  bool get isCached => File(cachePath).existsSync();
}

FigmaRequest nodesRequest(
  String label,
  List<String> ids, {
  int? depth,
}) => FigmaRequest(
  label: label,
  endpoint: '/files/$fileKey/nodes',
  query: {'ids': ids.join(','), 'depth': ?depth?.toString()},
  cachePath: nodesCachePath(label),
  summary:
      'nodes $label ${ids.join(',')}${depth == null ? '' : ' depth=$depth'}',
);

FigmaRequest imagesRequest(
  String label,
  List<String> ids, {
  required num scale,
  String format = 'png',
}) => FigmaRequest(
  label: label,
  endpoint: '/images/$fileKey',
  query: {'ids': ids.join(','), 'scale': '$scale', 'format': format},
  cachePath: imageUrlsCachePath(label, scale, format),
  summary: 'images $label ×${ids.length} @${scale}x $format',
);

final class RateLimited implements Exception {
  const RateLimited(this.retryAfter);
  final String? retryAfter;
  @override
  String toString() =>
      'Rate limited by Figma (429). Retry after: ${retryAfter ?? 'unknown'}.';
}

final class FigmaError implements Exception {
  const FigmaError(this.status, this.message);
  final int status;
  final String message;
  @override
  String toString() => 'Figma error $status: $message';
}

final class FigmaClient {
  FigmaClient({required this.dryRun, this.log = const RequestLog()});

  final bool dryRun;
  final RequestLog log;
  final _http = HttpClient();

  /// Fetches [request] into its cache file and returns the decoded JSON.
  /// Returns the cached JSON without any network call when present. In dry-run
  /// mode prints the request and returns null.
  Future<Map<String, dynamic>?> fetch(FigmaRequest request) async {
    final cache = File(request.cachePath);
    if (cache.existsSync()) {
      stdout.writeln('cached  ${request.summary}  → ${request.cachePath}');
      return jsonDecode(await cache.readAsString()) as Map<String, dynamic>;
    }
    if (dryRun) {
      stdout.writeln('WOULD   GET ${request.uri}');
      stdout.writeln('        → ${request.cachePath}');
      return null;
    }

    final token = Platform.environment['FIGMA_TOKEN'];
    if (token == null || token.isEmpty) {
      throw const FigmaError(0, 'FIGMA_TOKEN is not set (see task 0.12).');
    }

    final entry = log.begin(request.summary);
    stdout.writeln('GET     ${request.summary}');
    final HttpClientResponse response;
    final String body;
    try {
      final req = await _http.getUrl(request.uri);
      req.headers.set('X-Figma-Token', token);
      response = await req.close();
      body = await response.transform(utf8.decoder).join();
    } on Object catch (e) {
      log.finish(entry, 'network error: ${e.runtimeType}');
      rethrow;
    }

    if (response.statusCode == 429) {
      final retry = response.headers.value('retry-after');
      log.finish(
        entry,
        '429 rate limited (retry-after ${retry ?? '?'}); run stopped',
      );
      throw RateLimited(retry);
    }
    if (response.statusCode != 200) {
      log.finish(entry, 'HTTP ${response.statusCode}');
      throw FigmaError(response.statusCode, _errorMessage(body));
    }

    await cache.parent.create(recursive: true);
    await cache.writeAsString(body);
    log.finish(
      entry,
      'ok, ${(body.length / 1024).toStringAsFixed(0)} KB cached',
    );
    return jsonDecode(body) as Map<String, dynamic>;
  }

  /// Downloads a rendered image (an S3 URL from the images endpoint; not an
  /// API call, so it is not logged). Skips files that already exist.
  Future<void> download(String url, String path) async {
    final file = File(path);
    if (file.existsSync()) {
      stdout.writeln('cached  $path');
      return;
    }
    if (dryRun) {
      stdout.writeln('WOULD   download → $path');
      return;
    }
    final response = await (await _http.getUrl(Uri.parse(url))).close();
    if (response.statusCode != 200) {
      throw FigmaError(response.statusCode, 'image download failed: $path');
    }
    await file.parent.create(recursive: true);
    await response.pipe(file.openWrite());
    stdout.writeln('saved   $path');
  }

  void close() => _http.close(force: true);
}

String _errorMessage(String body) {
  try {
    final json = jsonDecode(body) as Map<String, dynamic>;
    return '${json['err'] ?? json['message'] ?? body}';
  } on FormatException {
    return body.length > 200 ? '${body.substring(0, 200)}…' : body;
  }
}

/// Writes each API request to the tracker's "Figma budget & harvest log" table
/// (and to `design/figma/requests.log`) before it is sent, then fills in the
/// result.
final class RequestLog {
  const RequestLog({this.tracker = trackerPath, this.file = requestLog});

  final String tracker;
  final String file;

  static const _tableHeader =
      '| Date | Channel | Endpoint and nodes | Requests | Result |';
  static const _pending = 'sending…';

  /// Logs a pending request. Returns a handle for [finish].
  String begin(String summary) {
    final stamp = DateTime.now().toIso8601String().substring(0, 19);
    final row = '| $stamp | REST | $summary | 1 | $_pending |';
    _appendLine(file, row);
    final trackerFile = File(tracker);
    if (trackerFile.existsSync()) {
      trackerFile.writeAsStringSync(
        insertTrackerRow(trackerFile.readAsStringSync(), row),
      );
    }
    return row;
  }

  void finish(String row, String result) {
    final done = row.replaceFirst(_pending, result);
    _appendLine(file, done);
    final trackerFile = File(tracker);
    if (trackerFile.existsSync()) {
      trackerFile.writeAsStringSync(
        trackerFile.readAsStringSync().replaceFirst(row, done),
      );
    }
  }

  static void _appendLine(String path, String line) {
    final f = File(path)..parent.createSync(recursive: true);
    f.writeAsStringSync('$line\n', mode: FileMode.append);
  }

  /// Appends [row] to the harvest-log table and bumps the REST counter.
  static String insertTrackerRow(String tracker, String row) {
    final lines = tracker.split('\n');
    final header = lines.indexWhere((l) => l.trimRight() == _tableHeader);
    if (header < 0) return tracker;
    var end = header + 2; // skip the |---| separator
    while (end < lines.length && lines[end].startsWith('|')) {
      end++;
    }
    lines.insert(end, row);
    return lines
        .join('\n')
        .replaceFirstMapped(
          RegExp(r'(- \*\*REST:\*\* )(\d+)( requests?)'),
          (m) => '${m[1]}${int.parse(m[2]!) + 1} requests',
        );
  }
}
