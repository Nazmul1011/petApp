import 'package:flutter/material.dart';

/// Asset image that decodes at *display* resolution (× device pixel ratio),
/// not full source resolution. Same on-screen sharpness, far less memory/CPU.
class AppAssetImage extends StatelessWidget {
  const AppAssetImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.high,
    this.gaplessPlayback = false,
    this.semanticLabel,
    this.excludeFromSemantics = false,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;
  final bool gaplessPlayback;
  final String? semanticLabel;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);

    // Explicit size → decode exactly for this screen density.
    if (width != null || height != null) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment,
        color: color,
        colorBlendMode: colorBlendMode,
        filterQuality: filterQuality,
        gaplessPlayback: gaplessPlayback,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        cacheWidth: width != null ? (width! * dpr).round() : null,
        cacheHeight: height != null ? (height! * dpr).round() : null,
      );
    }

    // Sized by parent → decode for the laid-out box.
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        // Cap extreme unbounded constraints so we never decode monster bitmaps.
        const maxDecodePx = 1600;
        int? cacheWidth;
        int? cacheHeight;

        if (maxW.isFinite && maxW > 0) {
          cacheWidth = (maxW * dpr).round().clamp(1, maxDecodePx);
        }
        if (maxH.isFinite && maxH > 0) {
          cacheHeight = (maxH * dpr).round().clamp(1, maxDecodePx);
        }

        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: filterQuality,
          gaplessPlayback: gaplessPlayback,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          cacheWidth: cacheWidth,
          cacheHeight: cacheHeight,
        );
      },
    );
  }
}
