import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/payment/models/subscription_plan.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionHeaderCard extends StatelessWidget {
  final SubscriptionPlan plan;

  const SubscriptionHeaderCard({super.key, required this.plan});

  String get _planTitle {
    switch (plan) {
      case SubscriptionPlan.yearlyRegular:
      case SubscriptionPlan.yearlyIntro:
        return 'PRO Yearly';
      case SubscriptionPlan.yearlyStandard:
        return 'PRO Standard';
    }
  }

  String get _planPrice {
    switch (plan) {
      case SubscriptionPlan.yearlyRegular:
        return '7 days free, then \$40/year';
      case SubscriptionPlan.yearlyIntro:
        return '\$1 first month, then \$40/year';
      case SubscriptionPlan.yearlyStandard:
        return '\$25/year';
    }
  }

  String get _planDescription {
    switch (plan) {
      case SubscriptionPlan.yearlyRegular:
        return 'Start with a 7-day free trial. Full access to all premium features.';
      case SubscriptionPlan.yearlyIntro:
        return 'Get your first month for \$1. Full access to all premium features.';
      case SubscriptionPlan.yearlyStandard:
        return 'One year of full access to all premium features and tools.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(R.width(12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                R.width(16),
                R.height(16),
                R.width(8),
                R.height(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PREMIUM STATUS',
                    style: AppTypography.overlineXs.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      letterSpacing: 0.8,
                    ),
                  ),
                  SizedBox(height: R.height(4)),
                  Text(
                    _planTitle,
                    style: AppTypography.h5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: R.height(2)),
                  Text(
                    _planPrice,
                    style: AppTypography.subtitleSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: R.height(8)),
                  Text(
                    _planDescription,
                    style: AppTypography.bodyXs.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: R.width(8)),
            child: Image.asset(
              'assets/images/payment_header1.png',
              height: R.height(132),
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }
}
