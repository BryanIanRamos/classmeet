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

  // onboarding
  /// chalkboard layer of the splash scene (Figma 5444:10022, frames 94).
  static const splashBoard = AppImage(
    'assets/images/onboarding/splash_board.png',
    width: 1023 / 3,
    height: 597 / 3,
  );

  /// Ollie teaching; stacked over the board (Figma 5444:10023, frames 94).
  static const splashOwlTeacher = AppImage(
    'assets/images/onboarding/splash_owl_teacher.png',
    width: 873 / 3,
    height: 837 / 3,
  );

  /// classroom circle behind both (Figma 5444:10024, frames 94).
  static const splashClassroom = AppImage(
    'assets/images/onboarding/splash_classroom.png',
    width: 1278 / 3,
    height: 1278 / 3,
  );

  /// sunny sky and clouds (vector, wider than the frame: clip) (Figma 5444:10035, frames 95).
  static const welcomeSky = AppImage(
    'assets/images/onboarding/welcome_sky.png',
    width: 2299 / 3,
    height: 2759 / 3,
  );

  /// winking Ollie with sparkles (Figma 5444:10061, frames 95).
  static const welcomeOwl = AppImage(
    'assets/images/onboarding/welcome_owl.png',
    width: 1101 / 3,
    height: 951 / 3,
  );

  /// Ollie peeking over the form (Figma 5444:10102, frames 3.1).
  static const signupOwl = AppImage(
    'assets/images/onboarding/signup_owl.png',
    width: 615 / 3,
    height: 471 / 3,
  );

  // create
  /// cloud group (same in 132/133) (Figma 5444:12111, frames 118, 132, 133).
  static const createCelebrateCloudLeft = AppImage(
    'assets/images/create/create_celebrate_cloud_left.png',
    width: 714 / 3,
    height: 870 / 3,
  );

  /// cloud group (same in 132/133) (Figma 5444:12119, frames 118, 132, 133).
  static const createCelebrateCloudRight = AppImage(
    'assets/images/create/create_celebrate_cloud_right.png',
    width: 651 / 3,
    height: 919 / 3,
  );

  /// happy Ollie, 199.5×165 (Figma 5444:12128, frames 118).
  static const createReadyOwl = AppImage(
    'assets/images/create/create_ready_owl.png',
    width: 597 / 3,
    height: 492 / 3,
  );

  // play
  /// confetti burst, 768×402 (wider than the frame: clip) (Figma 5453:17150, frames 132, 133).
  static const playConfetti = AppImage(
    'assets/images/play/play_confetti.png',
    width: 2304 / 3,
    height: 1207 / 3,
  );

  /// cheering Ollie, 197×149 (Figma 5453:17502, frames 132, 133).
  static const playResultsOwl = AppImage(
    'assets/images/play/play_results_owl.png',
    width: 591 / 3,
    height: 447 / 3,
  );

  /// Every image, for checks and pre-caching.
  static const all = [
    avatar,
    bgPattern,
    coin,
    owl,
    owlBooks,
    splashBoard,
    splashOwlTeacher,
    splashClassroom,
    welcomeSky,
    welcomeOwl,
    signupOwl,
    createCelebrateCloudLeft,
    createCelebrateCloudRight,
    createReadyOwl,
    playConfetti,
    playResultsOwl,
  ];
}
