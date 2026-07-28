import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/payment/models/subscription_plan.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionAlertBox extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool trialAvailable;

  const SubscriptionAlertBox({
    super.key,
    required this.plan,
    this.trialAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    if (plan == SubscriptionPlan.yearlyStandard) {
      return const SizedBox.shrink();
    }

    final isNoPaymentTrial =
        trialAvailable && plan == SubscriptionPlan.yearlyRegular;

    final title = plan == SubscriptionPlan.yearlyIntro
        ? 'Intro offer'
        : isNoPaymentTrial
            ? 'Free trial — no card needed'
            : 'Free trial included';

    final message = plan == SubscriptionPlan.yearlyIntro
        ? 'After your \$1 first month, you will be charged \$25/year unless canceled at least 24 hours before the period ends.'
        : isNoPaymentTrial
            ? 'Start a 7-day free trial with no payment. You get limited Pro samples (not full unlock). Subscribe anytime for unlimited access.'
            : 'After your 7-day free trial, you will be charged \$25/year unless canceled at least 24 hours before the period ends.';

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
            title,
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
