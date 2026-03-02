import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../../../core/themes/app_colors.dart';
import '../spacer/app_spacer.dart';

class AppRichText extends StatelessWidget {
  final String leadingText;
  final String highlightedText;
  final String? trailingText;
  final VoidCallback? onTap;

  // Optional Global TextStyles
  final TextStyle? leadingTextStyle;
  final TextStyle? highlightTextStyle;
  final TextStyle? trailingTextStyle;

  // Leading individual overrides
  final double leadingFontSize;
  final FontWeight leadingFontWeight;
  final double leadingHeight;
  final double leadingLetterSpacing;

  // Highlighted individual overrides
  final Color? highlightColor;
  final TextDecoration highlightDecorationStyle;
  final double highlightFontSize;
  final FontWeight highlightFontWeight;
  final double highlightHeight;
  final double highlightLetterSpacing;

  // Trailing individual overrides
  final double trailingFontSize;
  final FontWeight trailingFontWeight;
  final double trailingHeight;
  final double trailingLetterSpacing;

  final double spacing;
  final bool isHighlightedTextFirst;
  final TextAlign textAlign;

  // Width of spacer between leading and highlighted text
  final double spacerWidth;

  const AppRichText({
    super.key,
    required this.leadingText,
    required this.highlightedText,
    this.trailingText,
    this.onTap,

    // Global Styles
    this.leadingTextStyle,
    this.highlightTextStyle,
    this.trailingTextStyle,

    // Leading defaults
    this.leadingFontSize = 14,
    this.leadingFontWeight = FontWeight.w600,
    this.leadingHeight = 1.14,
    this.leadingLetterSpacing = 0.40,

    // Highlight defaults
    this.highlightColor,
    this.highlightDecorationStyle = TextDecoration.none,
    this.highlightFontSize = 14,
    this.highlightFontWeight = FontWeight.w600,
    this.highlightHeight = 1.14,
    this.highlightLetterSpacing = 0.40,

    // Trailing defaults
    this.trailingFontSize = 14,
    this.trailingFontWeight = FontWeight.w600,
    this.trailingHeight = 1.14,
    this.trailingLetterSpacing = 0.40,

    this.spacing = 5.0,
    this.isHighlightedTextFirst = false,
    this.textAlign = TextAlign.center,

    this.spacerWidth = 0.0, // Default no spacer
  });

  @override
  Widget build(BuildContext context) {
    final List<InlineSpan> textSpans = [];

    final leadingStyle =
        leadingTextStyle ??
        TextStyle(
          fontSize: leadingFontSize,
          fontWeight: leadingFontWeight,
          height: leadingHeight,
          letterSpacing: leadingLetterSpacing,
          color: Colors.black,
        );

    final highlightStyle =
        highlightTextStyle ??
        TextStyle(
          fontSize: highlightFontSize,
          color: highlightColor ?? AppColors.primaryColor,
          fontWeight: highlightFontWeight,
          height: highlightHeight,
          letterSpacing: highlightLetterSpacing,
          decoration: highlightDecorationStyle,
        );

    final trailingStyle =
        trailingTextStyle ??
        TextStyle(
          fontSize: trailingFontSize,
          fontWeight: trailingFontWeight,
          height: trailingHeight,
          letterSpacing: trailingLetterSpacing,
          color: Colors.black,
        );

    InlineSpan spacerSpan = spacerWidth > 0
        ? WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: SizedBox(width: spacerWidth),
          )
        : const TextSpan(text: ' ');

    if (isHighlightedTextFirst) {
      textSpans.add(
        TextSpan(
          text: highlightedText,
          style: highlightStyle,
          recognizer: onTap != null
              ? (TapGestureRecognizer()..onTap = onTap)
              : null,
        ),
      );

      textSpans.add(spacerSpan);

      textSpans.add(TextSpan(text: leadingText, style: leadingStyle));
    } else {
      textSpans.add(TextSpan(text: leadingText, style: leadingStyle));

      textSpans.add(spacerSpan);

      textSpans.add(
        TextSpan(
          text: highlightedText,
          style: highlightStyle,
          recognizer: onTap != null
              ? (TapGestureRecognizer()..onTap = onTap)
              : null,
        ),
      );
    }

    if (trailingText != null) {
      textSpans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: addSpacer(spacing),
        ),
      );

      textSpans.add(spacerSpan);

      textSpans.add(TextSpan(text: trailingText, style: trailingStyle));
    }

    return Text.rich(
      TextSpan(children: textSpans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
