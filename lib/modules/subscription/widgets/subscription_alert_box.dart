import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionAlertBox extends StatelessWidget {
  const SubscriptionAlertBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.width(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E5), // Light orange background
        borderRadius: BorderRadius.circular(R.width(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Trial ends in 2 days",
            style: AppTypography.subtitleSm.copyWith(
              color: const Color(0xFFFF7A00),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: R.height(4)),
          Text(
            "You will be automatically charged \$12.99 on March 12, 2027 unless canceled at least 24 hours before the period ends.",
            style: AppTypography.bodyXs.copyWith(
              color: const Color(0xFFFF7A00),
            ),
          ),
        ],
      ),
    );
  }
}
