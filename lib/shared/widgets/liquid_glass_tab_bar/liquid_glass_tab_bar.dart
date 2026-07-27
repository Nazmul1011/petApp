import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';

/// Native iOS/macOS liquid-glass tab bar powered by [CNTabBar].
///
/// On non-Apple platforms, [CNTabBar] falls back to a Cupertino-style bar.
class LiquidGlassTabBar extends StatelessWidget {
  const LiquidGlassTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.tint = const Color(0xFF9F82CE),
    this.height = 85,
    this.shrinkCentered = false,
    this.backgroundColor,
    this.iconSize,
    this.split = false,
    this.rightCount = 1,
    this.splitSpacing = 8.0,
  });

  final List<CNTabBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color tint;
  final double height;
  final bool shrinkCentered;
  final Color? backgroundColor;
  final double? iconSize;
  final bool split;
  final int rightCount;
  final double splitSpacing;

  /// Default PawTranslator main-tab SF Symbols.
  static const List<CNTabBarItem> defaultMainItems = [
    CNTabBarItem(
      icon: CNSymbol('bubble.left.and.text.bubble.right.fill'),
    ),
    CNTabBarItem(
      icon: CNSymbol('pawprint.fill'),
    ),
    CNTabBarItem(
      icon: CNSymbol('waveform'),
    ),
    CNTabBarItem(
      icon: CNSymbol('volleyball.fill'),
    ),
    CNTabBarItem(
      icon: CNSymbol('bell.fill'),
    ),
    CNTabBarItem(
      icon: CNSymbol('ellipsis'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CNTabBar(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      tint: tint,
      height: height,
      shrinkCentered: shrinkCentered,
      backgroundColor: backgroundColor,
      iconSize: iconSize,
      split: split,
      rightCount: rightCount,
      splitSpacing: splitSpacing,
    );
  }
}
