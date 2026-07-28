import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/payment/models/subscription_plan.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionHeaderCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool trialAvailable;

  const SubscriptionHeaderCard({
    super.key,
    required this.plan,
    this.trialAvailable = false,
  });

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
        return trialAvailable
            ? '7 days free,\nno card needed'
            : '7 days free,\nthen \$25/year';
      case SubscriptionPlan.yearlyIntro:
        return '\$1 first month,\nthen \$25/year';
      case SubscriptionPlan.yearlyStandard:
        return '\$25/year';
    }
  }

  // String get _planDescription {
  //   switch (plan) {
  //     case SubscriptionPlan.yearlyRegular:
  //       return trialAvailable
  //           ? 'Limited Pro samples. No payment required.'
  //           : '7-day free trial. Full access';
  //     case SubscriptionPlan.yearlyIntro:
  //       return '\$1 first month. Full premium access.';
  //     case SubscriptionPlan.yearlyStandard:
  //       return 'Full access to all premium features.';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: R.height(148),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(R.width(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Sparkles (second-card style)
          Positioned(
            right: R.width(118),
            top: R.height(18),
            child: _Sparkle(size: R.width(10)),
          ),
          Positioned(
            right: R.width(28),
            top: R.height(28),
            child: _Sparkle(size: R.width(8)),
          ),
          Positioned(
            right: R.width(96),
            bottom: R.height(28),
            child: _Sparkle(size: R.width(7)),
          ),
          Positioned(
            right: R.width(16),
            bottom: R.height(52),
            child: _Sparkle(size: R.width(9)),
          ),

          // Pets image anchored bottom-right like the second card
          Positioned(
            right: -R.width(4),
            bottom: -R.height(6),
            child: Image.asset(
              'assets/images/payment_header1.png',
              height: R.height(138),
              fit: BoxFit.contain,
              alignment: Alignment.bottomRight,
            ),
          ),

          // Keep first-card text content unchanged
          Padding(
            padding: EdgeInsets.fromLTRB(
              R.width(18),
              R.height(16),
              R.width(168),
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
                SizedBox(height: R.height(6)),
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
                // const Spacer(),
                // Text(
                //   _planDescription,
                //   maxLines: 2,
                //   overflow: TextOverflow.ellipsis,
                //   style: AppTypography.bodyXs.copyWith(
                //     color: Colors.white.withValues(alpha: 0.9),
                //     height: 1.35,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatelessWidget {
  final double size;

  const _Sparkle({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SparklePainter(
        color: Colors.white.withValues(alpha: 0.95),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final Color color;

  _SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = size.width / 8;

    final path = Path()
      ..moveTo(cx, cy - outer)
      ..lineTo(cx + inner, cy - inner)
      ..lineTo(cx + outer, cy)
      ..lineTo(cx + inner, cy + inner)
      ..lineTo(cx, cy + outer)
      ..lineTo(cx - inner, cy + inner)
      ..lineTo(cx - outer, cy)
      ..lineTo(cx - inner, cy - inner)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
