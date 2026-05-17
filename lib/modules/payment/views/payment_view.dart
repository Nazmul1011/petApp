import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

import '../controllers/payment_controller.dart';
import '../widgets/feature_list.dart';
import '../widgets/subscription_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

class PaymentView extends GetView<PaymentController> {
  const PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final subController = Get.find<SubscriptionModuleController>();
    return AppScaffold(
      horizontalPadding: 0,
      useSafeArea: false,
      systemNavigationBarIconBrightness: Brightness.light,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0xFFE9E4F8),
                    Color(0xFF9E8EDD),
                  ],
                  stops: [0.0, 0.4, 0.7, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false, // Allow content to reach the extreme bottom
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                      child: Column(
                        children: [
                          SizedBox(height: R.height(8)),
                          // Hero Image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(R.width(20)),
                            child: Image.asset(
                              'assets/images/payment.png',
                              width: double.infinity,
                              height: R.height(160),
                              fit: BoxFit.cover,
                            ),
                          ),

                          SizedBox(height: R.height(12)),

                          // Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTypography.h5.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                              children: [
                                const TextSpan(text: "Get "),
                                const TextSpan(
                                  text: "PRO ",
                                  style: TextStyle(
                                    color: Color(0xFF7F67CB),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const TextSpan(text: "access"),
                              ],
                            ),
                          ),

                          SizedBox(height: R.height(6)),

                          // Feature List
                          const FeatureList(),

                          SizedBox(height: R.height(12)),

                          const DottedLine(
                            dashColor: Color(0xFF7F67CB),
                            dashLength: 4,
                            dashGapLength: 4,
                            lineThickness: 1,
                          ),

                          SizedBox(height: R.height(24)),

                          // Subscriptions
                          Obx(
                            () {
                              final isLimitReached = (AuthController.to.user.value?.pets.length ?? 0) >= 1;
                              return Column(
                                children: [
                                  if (!isLimitReached)
                                    SubscriptionCard(
                                      title: "3 days free trial",
                                      subtitle: "\$00.00",
                                      rightText: "Access to limited features",
                                      isSelected:
                                          controller.selectedPlan.value ==
                                          SubscriptionPlan.trial,
                                      onTap: () => controller.selectPlan(
                                        SubscriptionPlan.trial,
                                      ),
                                    ),
                                  SubscriptionCard(
                                    title: "Weekly",
                                    subtitle: "\$1.99 per week",
                                    rightText:
                                        "Short-term access to all Pro features",
                                    isSelected:
                                        controller.selectedPlan.value ==
                                        SubscriptionPlan.weekly,
                                    onTap: () => controller.selectPlan(
                                      SubscriptionPlan.weekly,
                                    ),
                                  ),
                                  SubscriptionCard(
                                    title: "Monthly",
                                    subtitle: "\$2.99 per month",
                                    rightText:
                                        "Full Pro access with better value",
                                    badgeText: "Best value",
                                    isSelected:
                                        controller.selectedPlan.value ==
                                        SubscriptionPlan.monthly,
                                    onTap: () => controller.selectPlan(
                                      SubscriptionPlan.monthly,
                                    ),
                                  ),
                                  SubscriptionCard(
                                    title: "Yearly",
                                    subtitle: "\$12.99 per year",
                                    rightText: "Full Pro access",
                                    isSelected:
                                        controller.selectedPlan.value ==
                                        SubscriptionPlan.yearly,
                                    onTap: () => controller.selectPlan(
                                      SubscriptionPlan.yearly,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Actions
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: R.height(8)),
                      Obx(
                        () {
                          final isLimitReached = (AuthController.to.user.value?.pets.length ?? 0) >= 1;
                          final isLoading = controller.isLoading.value || subController.isLoading.value;
                          final label = isLimitReached ? "Subscribe Now" : "Continue with free trial";
                          return AppMaterialButton(
                            label: label,
                            onPressed: isLoading
                                ? null
                                : () => controller.handleButtonTap(),
                            height: R.height(58),
                            borderRadius: R.width(40),
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            textStyle: AppTypography.labelMd.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            isLoading: isLoading,
                          );
                        },
                      ),
                      SizedBox(height: R.height(14)),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.security,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: R.width(8)),
                            Text(
                              "Cancel anytime",
                              style: AppTypography.labelXs.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: R.height(24)),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _buildFooterLink("PRIVACY POLICY", onTap: controller.openPrivacyPolicy),
                          _buildDot(),
                          _buildFooterLink("TERMS AND CONDITIONS", onTap: controller.openTermsConditions),
                          _buildDot(),
                          _buildFooterLink("RESTORE", onTap: controller.restorePurchase),
                        ],
                      ),
                      SizedBox(height: R.height(34)),
                      // Home Indicator Handle
                      // Center(
                      //   child: Container(
                      //     width: R.width(134),
                      //     height: R.height(5),
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(10),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(height: R.height(8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.width(20),
                  vertical: R.height(10),
                ),
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.8),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.height(4)),
        child: Text(
          text,
          style: AppTypography.overlineXxs.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.width(15.6)),
      child: Container(
        width: 4.5,
        height: 4.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
