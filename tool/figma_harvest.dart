// Figma harvest for "ClassMeet – Official" (REST API, token in env FIGMA_TOKEN).
//
//   dart run tool/figma_harvest.dart <command> [options] [--dry-run]
//
// Commands
//   plan                     Print every request of the standard harvest
//                            (tasks 1.2 and 1.3) and whether it is cached.
//   nodes <preset|label>     Fetch node JSON. Presets: sections (one request
//                            per section), design-system, drafts (depth 2).
//                            Custom: nodes <label> --ids 1:2,3:4 [--depth N]
//   frames                   Write design/frames.csv (offline; uses cached
//                            section nodes, else the screen inventory).
//   images <section|all>     Render frames to PNG, one request per section,
//                            and copy them to design/ref/<section>/<no>_<slug>.png.
//                            Options: --scale 2 (default) --format png
//                            Custom: images <label> --ids 1:2,3:4 --scale 3
//   spec <frame id|all>      Write design/specs/<no>_<slug>.md (offline).
//
// Options
//   --dry-run   List requests without sending anything (no token needed).
//
// Cached responses are never re-fetched; delete the cache file to refetch.
// Every API request is logged in DEV_TRACKER.md before it is sent. HTTP 429
// stops the run (exit code 3).
import 'dart:convert';
import 'dart:io';

import 'figma/client.dart';
import 'figma/config.dart';
import 'figma/frames.dart';
import 'figma/spec.dart';

Future<void> main(List<String> argv) async {
  final args = _Args.parse(argv);
  if (args.positional.isEmpty || args.flags.contains('help')) {
    stdout.writeln(_usage);
    return;
  }

  final client = FigmaClient(dryRun: args.flags.contains('dry-run'));
  try {
    final command = args.positional.first;
    final target = args.positional.length > 1 ? args.positional[1] : null;
    switch (command) {
      case 'plan':
        await _plan(client);
      case 'nodes':
        await _nodes(client, target, args);
      case 'frames':
        _frames();
      case 'images':
        await _images(client, target, args);
      case 'spec':
        _spec(target);
      default:
        stderr.writeln('Unknown command "$command".\n\n$_usage');
        exitCode = 64;
    }
  } on RateLimited catch (e) {
    stderr.writeln('STOPPED: $e Nothing further was sent.');
    exitCode = 3;
  } on FigmaError catch (e) {
    stderr.writeln('ERROR: $e');
    exitCode = 1;
  } finally {
    client.close();
  }
}

const _usage = '''
Usage: dart run tool/figma_harvest.dart <command> [options] [--dry-run]
  plan | nodes <sections|design-system|drafts|label --ids ..> | frames
  images <section|all|label --ids ..> [--scale 2] [--format png] | spec <id|all>''';

// ---------------------------------------------------------------- requests

List<FigmaRequest> _nodePreset(String name) => switch (name) {
  'sections' => [
    for (final MapEntry(:key, :value) in sections.entries)
      nodesRequest(key, [value]),
  ],
  'design-system' => [
    nodesRequest('design-system', [designSystemPage]),
  ],
  'drafts' => [
    nodesRequest('drafts', [draftsPage], depth: 2),
  ],
  _ => const [],
};

List<FigmaRequest> _imageRequests(String target, num scale, String format) {
  final frames = loadFrames();
  final labels = target == 'all' ? sections.keys : [target];
  return [
    for (final label in labels)
      if (frames.where((f) => f.section == label).toList() case final fs
          when fs.isNotEmpty)
        imagesRequest(
          label,
          [for (final f in fs) f.id],
          scale: scale,
          format: format,
        ),
  ];
}

// ---------------------------------------------------------------- commands

Future<void> _plan(FigmaClient client) async {
  final requests = [
    ..._nodePreset('sections'),
    ..._nodePreset('design-system'),
    ..._nodePreset('drafts'),
    ..._imageRequests('all', 2, 'png'),
  ];
  final pending = requests.where((r) => !r.isCached).length;
  stdout.writeln(
    'Standard harvest: ${requests.length} API requests, $pending not cached.\n'
    'Design System sheet images are planned after design-system nodes '
    '(their ids come from that response).\n',
  );
  for (final (i, r) in requests.indexed) {
    stdout.writeln(
      '${'${i + 1}'.padLeft(2)}. ${r.isCached ? 'cached' : 'send  '}  '
      '${r.summary}',
    );
    stdout.writeln('    GET ${r.uri}');
  }
  stdout.writeln('\nFrames known: ${loadFrames().length} (see `frames`).');
}

Future<void> _nodes(FigmaClient client, String? target, _Args args) async {
  if (target == null) {
    throw const FigmaError(64, 'nodes needs a preset or label');
  }
  final ids = args.list('ids');
  final requests = ids.isEmpty
      ? _nodePreset(target)
      : [nodesRequest(target, ids, depth: args.integer('depth'))];
  if (requests.isEmpty) {
    throw FigmaError(64, 'unknown preset "$target" (or pass --ids)');
  }
  for (final r in requests) {
    await client.fetch(r);
  }
}

void _frames() {
  final frames = loadFrames();
  final file = File(framesCsv)..parent.createSync(recursive: true);
  file.writeAsStringSync(
    '${Frame.csvHeader}\n${frames.map((f) => f.toCsvRow()).join('\n')}\n',
  );
  final bySection = <String, int>{};
  for (final f in frames) {
    bySection.update(f.section, (n) => n + 1, ifAbsent: () => 1);
  }
  stdout.writeln('Wrote $framesCsv: ${frames.length} frames $bySection');
}

Future<void> _images(FigmaClient client, String? target, _Args args) async {
  if (target == null) {
    throw const FigmaError(64, 'images needs a section or all');
  }
  final scale = num.parse(args.value('scale') ?? '2');
  final format = args.value('format') ?? 'png';
  final ids = args.list('ids');
  final requests = ids.isEmpty
      ? _imageRequests(target, scale, format)
      : [imagesRequest(target, ids, scale: scale, format: format)];
  if (requests.isEmpty) throw FigmaError(64, 'no frames for "$target"');

  final frames = {for (final f in loadFrames()) f.id: f};
  for (final request in requests) {
    final json = await client.fetch(request);
    if (json == null) continue; // dry run
    final urls = (json['images'] as Map<String, dynamic>? ?? const {})
        .cast<String, String?>();
    for (final MapEntry(key: id, value: url) in urls.entries) {
      if (url == null) {
        stderr.writeln('WARN    Figma could not render $id');
        continue;
      }
      final path = imageFilePath(request.label, id, scale, format);
      await client.download(url, path);
      final frame = frames[id];
      if (frame != null && File(path).existsSync()) {
        final ref = File('$refDir/${frame.section}/${frame.fileStem}.$format');
        if (!ref.existsSync()) {
          ref.parent.createSync(recursive: true);
          File(path).copySync(ref.path);
          stdout.writeln('ref     ${ref.path}');
        }
      }
    }
  }
}

void _spec(String? target) {
  if (target == null) {
    throw const FigmaError(64, 'spec needs a frame id or all');
  }
  final frames = loadFrames();
  final selected = target == 'all'
      ? frames
      : frames.where((f) => f.id == target).toList();
  if (selected.isEmpty) throw FigmaError(64, 'unknown frame "$target"');

  final tokens = TokenNames.parse(
    colorsSource: File('lib/core/theme/app_colors.dart').readAsStringSync(),
    typographySource: File(
      'lib/core/theme/app_typography.dart',
    ).readAsStringSync(),
  );
  var written = 0;
  for (final frame in selected) {
    final cache = File(nodesCachePath(frame.section));
    if (!cache.existsSync()) {
      stderr.writeln('skip    ${frame.id}: run `nodes sections` first');
      continue;
    }
    final json = jsonDecode(cache.readAsStringSync()) as Map<String, dynamic>;
    final node = findInNodesResponse(json, frame.id);
    if (node == null) {
      stderr.writeln('skip    ${frame.id}: not in ${cache.path}');
      continue;
    }
    final md = condenseFrame(
      node,
      title: '${frame.no} ${frame.slug}',
      tokens: tokens,
    );
    final out = File('$specsDir/${frame.fileStem}.md')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(md);
    // Budget: about 4 characters per token, at most ~6k tokens per spec.
    final estimate = md.length ~/ 4;
    stdout.writeln(
      'spec    ${out.path}  ~${estimate}t'
      '${estimate > 6000 ? '  WARN over the 6k budget' : ''}',
    );
    written++;
  }
  stdout.writeln('$written spec(s) written.');
}

// ---------------------------------------------------------------- args

final class _Args {
  _Args(this.positional, this.options, this.flags);

  factory _Args.parse(List<String> argv) {
    final positional = <String>[];
    final options = <String, String>{};
    final flags = <String>{};
    for (var i = 0; i < argv.length; i++) {
      final a = argv[i];
      if (!a.startsWith('--')) {
        positional.add(a);
        continue;
      }
      final name = a.substring(2);
      final eq = name.indexOf('=');
      if (eq > 0) {
        options[name.substring(0, eq)] = name.substring(eq + 1);
      } else if (const {'dry-run', 'help'}.contains(name)) {
        flags.add(name);
      } else if (i + 1 < argv.length) {
        options[name] = argv[++i];
      }
    }
    return _Args(positional, options, flags);
  }

  final List<String> positional;
  final Map<String, String> options;
  final Set<String> flags;

  String? value(String name) => options[name];
  int? integer(String name) =>
      options[name] == null ? null : int.parse(options[name]!);
  List<String> list(String name) => [
    for (final s in (options[name] ?? '').split(','))
      if (s.trim().isNotEmpty) s.trim(),
  ];
}
