import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/helpers/responsive.dart';

import '../controllers/payment_controller.dart';
import '../widgets/feature_list.dart';
import '../widgets/subscription_card.dart';
import 'package:petapp/shared/widgets/spacer/app_spacer.dart';
import 'package:petapp/shared/widgets/richtext/app_rich_text.dart';

class DashedDivider extends StatelessWidget {
  final Color color;
  final double height;
  const DashedDivider({super.key, this.color = const Color(0xFF7F67CB), this.height = 0.5});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    return AppScaffold(
      horizontalPadding: 0,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white,
              const Color(0xCC7F67CB),
            ],
            stops: const [0.0, 0.45, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.width(16.0)),
          child: Column(
            children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    addSpacer(R.height(16)),
                    // Hero Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(R.width(20)),
                      child: Image.asset(
                        'assets/images/payment.png',
                        width: double.infinity,
                        height: R.height(185),
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    addSpacer(R.height(12)),
                    
                    // Title
                    AppRichText(
                      leadingText: "Get",
                      highlightedText: "PRO",
                      trailingText: "access",
                      leadingTextStyle: AppTypography.h5.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                      highlightTextStyle: AppTypography.h5.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                      trailingTextStyle: AppTypography.h5.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    
                    addSpacer(R.height(8)),
                    
                    // Feature List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.width(8)),
                      child: const FeatureList(),
                    ),
                    
                    addSpacer(R.height(12)),
                    const DashedDivider(),
                    addSpacer(R.height(12)),
                    
                    // Subscriptions
                    Obx(() => Column(
                      children: [
                        SubscriptionCard(
                          title: "3 days free trial",
                          subtitle: "\$00.00",
                          rightText: "Access to limited features",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.trial,
                          onTap: () => controller.selectPlan(SubscriptionPlan.trial),
                        ),
                        addSpacer(R.height(12)),
                        SubscriptionCard(
                          title: "Weekly",
                          subtitle: "\$1.99 per week",
                          rightText: "Short-term access to all Pro features",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.weekly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.weekly),
                        ),
                        addSpacer(R.height(12)),
                        SubscriptionCard(
                          title: "Monthly",
                          subtitle: "\$2.99 per month",
                          rightText: "Full Pro access with better value",
                          badgeText: "Best value",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.monthly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.monthly),
                        ),
                        addSpacer(R.height(12)),
                        SubscriptionCard(
                          title: "Yearly",
                          subtitle: "\$12.99 per year",
                          rightText: "Full Pro access",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.yearly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.yearly),
                        ),
                      ],
                    )),
                    
                    addSpacer(R.height(40)), // Space for sticky bottom bar
                  ],
                ),
              ),
            ),
            
            // Bottom Actions
            Container(
              padding: EdgeInsets.symmetric(vertical: R.height(16)),
              color: Colors.transparent, // Background context
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final isTrialSelected = controller.selectedPlan.value == SubscriptionPlan.trial;
                    return AppMaterialButton(
                      label: isTrialSelected ? "Continue with free trial" : "Buy subscription",
                      onPressed: controller.isLoading.value ? null : () => controller.continueWithTrial(),
                      height: R.height(56),
                      borderRadius: R.width(999),
                      backgroundColor: Colors.white,
                      textColor: AppColors.headingText,
                      textStyle: AppTypography.labelMd.copyWith(color: AppColors.headingText),
                      isLoading: controller.isLoading.value,
                    );
                  }),
                  addSpacer(R.height(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Shield icon.svg',
                        width: R.width(14.625),
                        height: R.height(16.125),
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      addSpacer(R.width(8), direction: SpacerDirection.horizontal),
                      Text(
                        "Cancel anytime",
                        style: AppTypography.labelXs.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: R.height(16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [                      Text("PRIVACY POLICY", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("•", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("TERMS AND CONDITIONS", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("•", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("RESTORE", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                    ],
                  ),
                  addSpacer(R.height(10)),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
