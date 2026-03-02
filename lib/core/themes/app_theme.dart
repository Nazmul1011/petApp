import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';

import 'app_colors.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'NationalPark',
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.primaryColor,
    ),
    appBarTheme: const AppBarTheme(
      surfaceTintColor: AppColors.primaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFD8D9DD)),
        borderRadius: BorderRadius.circular(6),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFD8D9DD)),
      ),
      floatingLabelStyle: const TextStyle(color: AppColors.primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    ),


    
    textTheme: const TextTheme().apply(
      fontFamily: 'NationalPark',
      displayColor: AppColors.headingText,
      bodyColor: AppColors.bodyText,
    ).copyWith(
      titleLarge: AppTypography.h4.copyWith(color: AppColors.headingText),
      titleMedium: AppTypography.subtitleLg.copyWith(
        color: AppColors.headingText,
      ),
      bodyMedium: AppTypography.bodyMd.copyWith(color: AppColors.bodyText),
      bodySmall: AppTypography.bodySm.copyWith(color: AppColors.lightText),
      labelLarge: AppTypography.labelMd.copyWith(
        color: AppColors.headingText,
      ),
    ),
  );
}
