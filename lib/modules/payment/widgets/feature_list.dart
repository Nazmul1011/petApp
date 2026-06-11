import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: R.height(4)),
        
        // Line 1
        _buildLine([
          _bullet(),
          _text(" No ads, no data sold "),
          _bullet(),
          _text(" Unlock all training and sounds "),
          _bullet(),
        ]),
        
        SizedBox(height: R.height(4)),
        
        // Line 2
        _buildLine([
          _text("All tricks & commands guide "),
          _bullet(),
          _text(" Lifetime features & future AI upgrades"),
        ]),
        
        SizedBox(height: R.height(4)),
        
        // Line 3
        _buildLine([
          _bullet(),
          _text(" Unlimited Human to Dog/Cat translation"),
        ]),
        
        SizedBox(height: R.height(4)),
      ],
    );
  }

  Widget _buildLine(List<InlineSpan> children) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: children,
      ),
    );
  }

  InlineSpan _bullet() {
    return const TextSpan(
      text: " • ",
      style: TextStyle(
        color: Color(0xFF6C3BAA),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  InlineSpan _text(String text) {
    return TextSpan(
      text: text,
      style: AppTypography.bodyXs.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
