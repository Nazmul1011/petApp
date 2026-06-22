import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionHeaderCard extends StatelessWidget {
  const SubscriptionHeaderCard({super.key});

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
                    'PRO Yearly',
                    style: AppTypography.h5.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: R.height(2)),
                  Text(
                    '\$12.99/year',
                    style: AppTypography.subtitleSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: R.height(8)),
                  Text(
                    'Full access to all premium features and tools.',
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
