import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class DashboardPageTitle extends StatelessWidget {
  final String title;

  const DashboardPageTitle({super.key, required this.title});

  static TextStyle get style => AppTypography.h5.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.headingText,
      );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(24),
          vertical: R.height(8),
        ),
        child: Text(title, style: style),
      ),
    );
  }
}
