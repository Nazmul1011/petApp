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

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }

    return AppScaffold(
      horizontalPadding: R.width(16.0), // Request from prompt
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFF7F67CB).withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: R.height(20)),
                    // Hero Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(R.width(20)),
                      child: Image.asset(
                        'assets/images/payment.png',
                        width: double.infinity,
                        height: R.height(220),
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    SizedBox(height: R.height(24)),
                    
                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTypography.h5.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                        children: [
                          const TextSpan(text: "Get "),
                          TextSpan(
                            text: "PRO ",
                            style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: "access"),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: R.height(16)),
                    
                    // Feature List
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.width(8)),
                      child: const FeatureList(),
                    ),
                    
                    SizedBox(height: R.height(30)),
                    
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
                        SubscriptionCard(
                          title: "Weekly",
                          subtitle: "\$1.99 per week",
                          rightText: "Short-term access to all Pro features",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.weekly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.weekly),
                        ),
                        SubscriptionCard(
                          title: "Monthly",
                          subtitle: "\$2.99 per month",
                          rightText: "Full Pro access with better value",
                          badgeText: "Best value",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.monthly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.monthly),
                        ),
                        SubscriptionCard(
                          title: "Yearly",
                          subtitle: "\$12.99 per year",
                          rightText: "Full Pro access",
                          isSelected: controller.selectedPlan.value == SubscriptionPlan.yearly,
                          onTap: () => controller.selectPlan(SubscriptionPlan.yearly),
                        ),
                      ],
                    )),
                    
                    SizedBox(height: R.height(100)), // Space for sticky bottom bar
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
                  Obx(() => AppMaterialButton(
                    label: "Continue with free trial",
                    onPressed: controller.isLoading.value ? null : () => controller.continueWithTrial(),
                    height: R.height(56),
                    borderRadius: R.width(999),
                    backgroundColor: Colors.white,
                    textColor: AppColors.headingText,
                    textStyle: AppTypography.labelMd.copyWith(color: AppColors.headingText),
                    isLoading: controller.isLoading.value,
                  )),
                  SizedBox(height: R.height(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/Shield icon.svg',
                        width: R.width(14.625),
                        height: R.height(16.125),
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                      SizedBox(width: R.width(6)),
                      Text(
                        "Cancel anytime",
                        style: AppTypography.labelXs.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: R.height(20)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("PRIVACY POLICY", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("•", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("TERMS AND CONDITIONS", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("•", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                      Text("RESTORE", style: AppTypography.overlineXs.copyWith(color: Colors.white)),
                    ],
                  ),
                  SizedBox(height: R.height(10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
