/// Raster image assets with their logical (dp) size.
///
/// Every PNG is exported at 3x, so its pixel size is exactly 3 × the logical
/// size (checked by `dart run tool/check_assets.dart`). Show images with
/// `AppIllustration` at [AppImage.width] × [AppImage.height].
///
/// This file is plain Dart (no Flutter imports) so `tool/check_assets.dart`
/// can read it.
library;

final class AppImage {
  const AppImage(
    this.path, {
    required this.width,
    required this.height,
    this.provisional = false,
  });

  /// Asset path, relative to the project root.
  final String path;

  /// Logical width in dp.
  final double width;

  /// Logical height in dp.
  final double height;

  /// A placeholder taken from an early 2x Figma export. It gets re-exported
  /// at 3x with confirmed logical sizes in task 1.7. Until then the size
  /// check only warns.
  final bool provisional;
}

abstract final class AppImages {
  // common
  static const avatar = AppImage(
    'assets/images/common/avatar.png',
    width: 32,
    height: 32,
    provisional: true,
  );
  static const bgPattern = AppImage(
    'assets/images/common/bg_pattern.png',
    width: 268,
    height: 512,
    provisional: true,
  );
  static const coin = AppImage(
    'assets/images/common/coin.png',
    width: 217,
    height: 217,
    provisional: true,
  );

  // home
  static const owl = AppImage(
    'assets/images/home/owl.png',
    width: 446.5,
    height: 471,
    provisional: true,
  );
  static const owlBooks = AppImage(
    'assets/images/home/owl_books.png',
    width: 443.5,
    height: 139,
    provisional: true,
  );

  /// Every image, for checks and pre-caching.
  static const all = [avatar, bgPattern, coin, owl, owlBooks];
}
