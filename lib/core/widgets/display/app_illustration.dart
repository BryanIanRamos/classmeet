import 'package:flutter/widgets.dart';

import '../../assets/app_images.dart';
import '../../theme/app_colors.dart';

/// Shows an [AppImage] (a 3x PNG) at its logical size, decoded at the
/// display's resolution (`cacheWidth`) so large art costs no more memory than
/// it shows. If the file can't be loaded, a tinted placeholder of the same
/// size takes its place, so a screen never waits on art.
class AppIllustration extends StatelessWidget {
  const AppIllustration(
    this.image, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.placeholderColor = AppColors.sage50,
  });

  final AppImage image;

  /// Defaults to the image's logical width, or follows [height] at the
  /// image's aspect ratio.
  final double? width;

  /// Defaults to the image's logical height, or follows [width] at the
  /// image's aspect ratio.
  final double? height;

  final BoxFit fit;
  final AlignmentGeometry alignment;

  /// Read by screen readers; decorative art leaves it null.
  final String? semanticLabel;

  /// Fill of the placeholder shown when the file is missing.
  final Color placeholderColor;

  /// Pixel width to decode for a box of [boxWidth] × [boxHeight]: the drawn
  /// width (wider than the box under [BoxFit.cover]) times [pixelRatio],
  /// capped at the file's own width.
  @visibleForTesting
  int decodeWidth(double boxWidth, double boxHeight, double pixelRatio) {
    final aspect = image.width / image.height;
    final drawn = fit == BoxFit.cover
        ? (boxWidth > boxHeight * aspect ? boxWidth : boxHeight * aspect)
        : boxWidth;
    final maxPixels = image.width * 3;
    final pixels = drawn * pixelRatio;
    return (pixels > maxPixels ? maxPixels : pixels).round();
  }

  @override
  Widget build(BuildContext context) {
    final aspect = image.width / image.height;
    final w = width ?? (height != null ? height! * aspect : image.width);
    final h = height ?? (width != null ? width! / aspect : image.height);
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    return Image.asset(
      image.path,
      width: w,
      height: h,
      fit: fit,
      alignment: alignment,
      cacheWidth: decodeWidth(w, h, dpr),
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      errorBuilder: (_, _, _) => SizedBox(
        width: w,
        height: h,
        child: ColoredBox(color: placeholderColor),
      ),
    );
  }
}
