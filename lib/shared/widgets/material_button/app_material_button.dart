import 'package:flutter/material.dart';

import '../progress_loader/progress_loader.dart';
import '../../helpers/responsive.dart';

enum IconPosition { left, right }

enum LoadingStyle { simple, morphing }

class AppMaterialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final double height;
  final double width;
  final double elevation;
  final double borderRadius;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color? textColor;
  final TextStyle? textStyle;
  final Widget? child;

  final Widget? icon;
  final IconPosition iconPosition;
  final double? spacerWidth;
  final LoadingStyle loadingStyle;

  const AppMaterialButton({
    super.key,
    this.label = 'Material Button',
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.height = 56,
    this.width = double.infinity,
    this.elevation = 0,
    this.borderRadius = 50,
    this.shape,
    this.backgroundColor,
    this.disabledColor,
    this.textColor = Colors.white,
    this.textStyle,
    this.child,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.spacerWidth,
    this.loadingStyle = LoadingStyle.morphing,
  });

  factory AppMaterialButton.icon({
    Key? key,
    required String label,
    required Widget icon,
    double spacerWidth = 8,
    VoidCallback? onPressed,
    IconPosition iconPosition = IconPosition.left,
    bool isLoading = false,
    bool isDisabled = false,
    double height = 48,
    double width = double.infinity,
    double elevation = 0,
    double borderRadius = 8,
    ShapeBorder? shape,
    Color? backgroundColor,
    Color? disabledColor,
    Color? textColor = Colors.white,
    TextStyle? textStyle,
    LoadingStyle loadingStyle = LoadingStyle.morphing,
  }) {
    return AppMaterialButton(
      key: key,
      label: label,
      icon: icon,
      spacerWidth: spacerWidth,
      iconPosition: iconPosition,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      height: height,
      width: width,
      elevation: elevation,
      borderRadius: borderRadius,
      shape: shape,
      backgroundColor: backgroundColor,
      disabledColor: disabledColor,
      textColor: textColor,
      textStyle: textStyle,
      loadingStyle: loadingStyle,
    );
  }

  // Computed property: button is disabled if either isDisabled or isLoading is true
  bool get _isEffectivelyDisabled => isDisabled || isLoading;

  @override
  Widget build(BuildContext context) {
    if (loadingStyle == LoadingStyle.morphing) {
      return _buildMorphingButton(context);
    }
    return _buildSimpleButton(context);
  }

  Widget _buildSimpleButton(BuildContext context) {
    final effectiveOnPressed = _isEffectivelyDisabled ? null : (onPressed ?? () {});

    final labelWidget = Text(
      label,
      style: textStyle ??
          const TextStyle(
            fontFamily: 'NationalPark',
            color: Colors.white,
            fontSize: 16,
            height: 20 / 16, // Label/md line height
            fontWeight: FontWeight.w600,
            letterSpacing: -0.34,
          ),
    );

    final content = isLoading
        ? SizedBox(
            width: R.width(24),
            height: R.width(24),
            child: showLoader(progressColor: textColor ?? Colors.white),
          )
        : _buildAlignedContent(labelWidget);

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFF6C3BAA),
        borderRadius: BorderRadius.circular(borderRadius > 50 ? 999 : borderRadius),
        border: Border.all(
          color: const Color(0xFFB398D9),
          width: 0.5,
        ),
        boxShadow: [
          // Subtle outer shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: effectiveOnPressed,
          borderRadius: BorderRadius.circular(borderRadius > 50 ? 999 : borderRadius),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: R.width(16)),
              child: child ?? content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMorphingButton(BuildContext context) {
    final effectiveOnPressed = _isEffectivelyDisabled ? null : (onPressed ?? () {});
    final loaderColor = textColor ?? Colors.white;

    final labelWidget = Text(
      label,
      style: textStyle ??
          TextStyle(
            fontFamily: 'NationalPark',
            color: textColor,
            fontSize: 16,
            height: 20 / 16,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.34,
          ),
    );

    final content = _buildAlignedContent(labelWidget);

    return LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth =
            width == double.infinity ? constraints.maxWidth : width;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: isLoading ? height : actualWidth,
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor ?? const Color(0xFF6C3BAA),
            borderRadius: BorderRadius.circular(
              isLoading ? height / 2 : (borderRadius > 50 ? 999 : borderRadius),
            ),
            border: Border.all(
              color: const Color(0xFFB398D9),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: effectiveOnPressed,
              borderRadius: BorderRadius.circular(
                isLoading ? height / 2 : (borderRadius > 50 ? 999 : borderRadius),
              ),
              // While loading: circle + spinner only. Label never shows in
              // the loading state (avoids "Continue" flashing in the circle).
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isLoading
                      ? SizedBox(
                          key: const ValueKey('loader'),
                          width: R.width(24),
                          height: R.width(24),
                          child: showLoader(progressColor: loaderColor),
                        )
                      : KeyedSubtree(
                          key: const ValueKey('label'),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.width(16),
                            ),
                            child: child ?? content,
                          ),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlignedContent(Widget labelWidget) {
    if (icon == null) return labelWidget;

    final spacing = spacerWidth ?? 4; // Design spec gap is 4

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: iconPosition == IconPosition.left
          ? [icon!, SizedBox(width: spacing), labelWidget]
          : [labelWidget, SizedBox(width: spacing), icon!],
    );
  }
}
