/// The frame list: which Figma frames exist, their screen number and slug.
///
/// Sources, in order:
/// 1. cached section node JSON (`design/figma/nodes/<section>.json`): the
///    authoritative list of top-level frames in each section;
/// 2. `design/notes/screen_inventory.md`: screen number, slug and route per
///    frame id (lines like `- **5444:10019 | 94 | splash_welcome | /splash | S.**`).
library;

import 'dart:convert';
import 'dart:io';

import 'config.dart';

final class Frame {
  const Frame({
    required this.id,
    required this.section,
    required this.no,
    required this.slug,
    this.route = '',
    this.width,
    this.height,
  });

  final String id;
  final String section;

  /// Screen number as named in Figma, e.g. `94`, `3.1`, `13.2`.
  final String no;
  final String slug;
  final String route;
  final double? width;
  final double? height;

  /// `<no>_<slug>`, the base name for refs and specs.
  String get fileStem => '${no}_$slug';

  static const csvHeader = 'id,section,no,slug,route,width,height';

  String toCsvRow() => [
    id,
    section,
    no,
    slug,
    route,
    width?.toStringAsFixed(0) ?? '',
    height?.toStringAsFixed(0) ?? '',
  ].map(_csvField).join(',');
}

String _csvField(String v) =>
    v.contains(RegExp(r'[",\n]')) ? '"${v.replaceAll('"', '""')}"' : v;

/// Lowercase snake_case: `(state of 3.1)` → `state_of_3_1`.
String slugify(String text) => text
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

final _sectionHeader = RegExp(r'^##\s.*\(section (\d+:\d+)\)');
final _frameLine = RegExp(
  r'^- \*\*(\d+:\d+) \| ([^|*]+?)(?: \| ([^|*]+?))?(?: \| ([^|*]+?))?(?: \| ([^|*]+?))?\.?\*\*',
);

/// Parses the inventory markdown into frames keyed by id.
Map<String, Frame> parseInventory(String markdown) {
  final sectionById = {for (final e in sections.entries) e.value: e.key};
  final frames = <String, Frame>{};
  String? section;
  for (final line in const LineSplitter().convert(markdown)) {
    final header = _sectionHeader.firstMatch(line);
    if (header != null) {
      section = sectionById[header.group(1)];
      continue;
    }
    final m = _frameLine.firstMatch(line);
    if (m == null || section == null) continue;
    final id = m.group(1)!;
    final no = m.group(2)!.trim();
    final third = m.group(3)?.trim() ?? '';
    final route = m.group(4)?.trim() ?? '';
    frames[id] = Frame(
      id: id,
      section: section,
      no: no,
      slug: slugify(third.isEmpty ? 'frame' : third),
      route: route.startsWith('/') ? route : '',
    );
  }
  return frames;
}

/// Top-level FRAME children of a cached section, with their size.
List<({String id, String name, double width, double height})> sectionFrames(
  Map<String, dynamic> nodesResponse,
  String sectionId,
) {
  final nodes = nodesResponse['nodes'] as Map<String, dynamic>? ?? const {};
  final entry = nodes[sectionId] as Map<String, dynamic>?;
  final document = entry?['document'] as Map<String, dynamic>?;
  final children = (document?['children'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  return [
    for (final child in children)
      if (child['type'] == 'FRAME' && child['visible'] != false)
        (
          id: child['id'] as String,
          name: child['name'] as String,
          width: _box(child, 'width'),
          height: _box(child, 'height'),
        ),
  ];
}

double _box(Map<String, dynamic> node, String key) =>
    ((node['absoluteBoundingBox'] as Map<String, dynamic>?)?[key] as num?)
        ?.toDouble() ??
    0;

/// Builds the frame list from cached nodes where available, falling back to
/// the inventory. Returns frames in section order, then canvas order.
List<Frame> loadFrames() {
  final inventoryFile = File(inventoryPath);
  final inventory = inventoryFile.existsSync()
      ? parseInventory(inventoryFile.readAsStringSync())
      : <String, Frame>{};

  final result = <Frame>[];
  for (final MapEntry(key: label, value: sectionId) in sections.entries) {
    final cache = File(nodesCachePath(label));
    if (!cache.existsSync()) {
      result.addAll(inventory.values.where((f) => f.section == label));
      continue;
    }
    final json = jsonDecode(cache.readAsStringSync()) as Map<String, dynamic>;
    for (final f in sectionFrames(json, sectionId)) {
      final known = inventory[f.id];
      result.add(
        Frame(
          id: f.id,
          section: label,
          no: known?.no ?? f.name.trim(),
          slug: known?.slug ?? slugify(f.name),
          route: known?.route ?? '',
          width: f.width,
          height: f.height,
        ),
      );
    }
  }
  return result;
}
