// Asset check: `dart run tool/check_assets.dart` (exit code 1 on errors).
//
// - every AppImages entry exists, is a PNG, and is exactly 3x its logical
//   size (provisional entries only warn)
// - every image and icon file is registered in pubspec.yaml `flutter: assets:`
// - no PNG under assets/images is missing from AppImages.all
import 'dart:io';
import 'dart:typed_data';

import 'package:classmeet/core/assets/app_images.dart';

final errors = <String>[];
final warnings = <String>[];

void main() {
  final registered = _registeredAssets();

  for (final image in AppImages.all) {
    final file = File(image.path);
    if (!file.existsSync()) {
      errors.add('${image.path}: file missing');
      continue;
    }
    final size = _pngSize(file.readAsBytesSync());
    if (size == null) {
      errors.add('${image.path}: not a PNG');
      continue;
    }
    final (w, h) = size;
    final (ew, eh) = ((image.width * 3).round(), (image.height * 3).round());
    if (w != ew || h != eh) {
      final msg =
          '${image.path}: ${w}x$h px, expected ${ew}x$eh '
          '(3x ${image.width}x${image.height})';
      (image.provisional ? warnings : errors).add(msg);
    }
    if (!_isRegistered(image.path, registered)) {
      errors.add('${image.path}: not registered in pubspec.yaml');
    }
  }

  final known = {for (final i in AppImages.all) i.path};
  for (final path in _filesUnder('assets/images')) {
    if (path.endsWith('.png') && !known.contains(path)) {
      errors.add('$path: not listed in AppImages.all');
    }
  }
  for (final path in _filesUnder('assets/icons')) {
    if (!_isRegistered(path, registered)) {
      errors.add('$path: not registered in pubspec.yaml');
    }
  }

  for (final w in warnings) {
    stdout.writeln('WARN  $w');
  }
  for (final e in errors) {
    stdout.writeln('ERROR $e');
  }
  stdout.writeln(
    '${AppImages.all.length} images checked: '
    '${errors.length} errors, ${warnings.length} warnings',
  );
  exitCode = errors.isEmpty ? 0 : 1;
}

/// Entries of the `flutter: assets:` list in pubspec.yaml.
Set<String> _registeredAssets() {
  final result = <String>{};
  var inFlutter = false;
  var inAssets = false;
  for (final line in File('pubspec.yaml').readAsLinesSync()) {
    if (line.trim().isEmpty || line.trimLeft().startsWith('#')) continue;
    if (!line.startsWith(' ')) {
      inFlutter = line.startsWith('flutter:');
      inAssets = false;
    } else if (inFlutter && RegExp(r'^  \S').hasMatch(line)) {
      inAssets = line.trim() == 'assets:';
    } else if (inAssets) {
      final m = RegExp(r'^\s+-\s+(\S+)').firstMatch(line);
      if (m != null) result.add(m.group(1)!);
    }
  }
  return result;
}

/// A file is registered by its exact path or by its directory (`dir/`).
bool _isRegistered(String path, Set<String> registered) =>
    registered.contains(path) ||
    registered.contains('${path.substring(0, path.lastIndexOf('/'))}/');

List<String> _filesUnder(String dir) {
  final d = Directory(dir);
  if (!d.existsSync()) return const [];
  return [
    for (final f in d.listSync(recursive: true).whereType<File>())
      f.path.replaceAll(r'\', '/'),
  ]..sort();
}

/// Width and height from a PNG IHDR chunk, or null if not a PNG.
(int, int)? _pngSize(Uint8List bytes) {
  const signature = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];
  if (bytes.length < 24) return null;
  for (var i = 0; i < signature.length; i++) {
    if (bytes[i] != signature[i]) return null;
  }
  final data = ByteData.sublistView(bytes);
  return (data.getUint32(16), data.getUint32(20));
}
