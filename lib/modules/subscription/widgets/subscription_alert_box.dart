import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/payment/models/subscription_plan.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionAlertBox extends StatelessWidget {
  final SubscriptionPlan plan;

  const SubscriptionAlertBox({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    if (plan == SubscriptionPlan.yearlyStandard) {
      return const SizedBox.shrink();
    }

    final message = plan == SubscriptionPlan.yearlyIntro
        ? 'After your \$1 first month, you will be charged \$40/year unless canceled at least 24 hours before the period ends.'
        : 'After your 7-day free trial, you will be charged \$40/year unless canceled at least 24 hours before the period ends.';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(R.width(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E5),
        borderRadius: BorderRadius.circular(R.width(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            plan == SubscriptionPlan.yearlyIntro
                ? 'Intro offer'
                : 'Free trial included',
            style: AppTypography.subtitleSm.copyWith(
              color: const Color(0xFFFF7A00),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: R.height(4)),
          Text(
            message,
            style: AppTypography.bodyXs.copyWith(
              color: const Color(0xFFFF7A00),
            ),
          ),
        ],
      ),
    );
  }
}
