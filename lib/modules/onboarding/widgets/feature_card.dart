import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class OnboardingFeatureCard extends StatelessWidget {
  final Widget icon;
  final Color iconBgColor;
  final String title;
  final String subtitle;

  const OnboardingFeatureCard({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: R.width(173),
      height: R.height(180),
      padding: EdgeInsets.only(
        top: R.height(12),
        left: R.width(12),
        right: R.width(12),
        bottom: R.height(24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.width(24)),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: R.width(60),
            height: R.width(60),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(child: icon),
          ),
          const Spacer(),
          Text(
            title,
            style: AppTypography.subtitleMd.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: R.height(4)),
          Text(
            subtitle,
            style: AppTypography.bodyXs.copyWith(
              color: Colors.black54,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
