import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

import '../../payment/models/subscription_plan.dart';
import '../../payment/widgets/subscription_card.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_alert_box.dart';
import '../widgets/subscription_header_card.dart';

class SubscriptionView extends GetView<SubscriptionModuleController> {
  SubscriptionView({super.key}) {
    // Refresh eligibility when the paywall route is opened.
    Future.microtask(() => controller.loadTrialAvailability());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      useSafeArea: false,
      systemNavigationBarIconBrightness: Brightness.light,
      backgroundColor: const Color(0xFF9E8EDD),
      extendBody: true,
      body: Stack(
        children: [
          // Background Gradient (Same as Payment)
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
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                    child: Column(
                      children: [
                        SizedBox(height: R.height(10)),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Get.back(),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade200),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: R.height(12)),
                        Obx(
                          () => SubscriptionHeaderCard(
                            plan: controller.selectedPlan.value,
                            trialAvailable: controller.trialAvailable.value,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rest of the screen (with padding)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                    child: Column(
                      children: [
                        SizedBox(height: R.height(16)),

                        Obx(
                          () => SubscriptionAlertBox(
                            plan: controller.selectedPlan.value,
                            trialAvailable: controller.trialAvailable.value,
                          ),
                        ),

                        SizedBox(height: R.height(24)),

                        const DottedLine(
                          dashColor: Color(0xFF6C3BAA),
                          dashLength: 4,
                          dashGapLength: 4,
                          lineThickness: 1,
                        ),

                        SizedBox(height: R.height(24)),

                        // Subscription Cards
                        Obx(
                          () {
                            final trialAvailable =
                                controller.trialAvailable.value;
                            return Column(
                              children: [
                                SubscriptionCard(
                                  title: "7 days free trial",
                                  subtitle: trialAvailable
                                      ? "No payment required"
                                      : "then \$40/year",
                                  rightText: trialAvailable
                                      ? "Limited Pro samples"
                                      : "Full Pro access",
                                  badgeText: "Popular",
                                  isSelected:
                                      controller.selectedPlan.value ==
                                      SubscriptionPlan.yearlyRegular,
                                  onTap: () => controller.selectPlan(
                                    SubscriptionPlan.yearlyRegular,
                                  ),
                                ),
                                SubscriptionCard(
                                  title: "Standard",
                                  subtitle: "\$25/year",
                                  rightText: "Full Pro access for 1 year",
                                  rightTextColor: AppColors.textGreen,
                                  isSelected:
                                      controller.selectedPlan.value ==
                                      SubscriptionPlan.yearlyStandard,
                                  onTap: () => controller.selectPlan(
                                    SubscriptionPlan.yearlyStandard,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),

                        // Bottom Actions
                        SizedBox(height: R.height(30)),
                        Obx(
                          () => AppMaterialButton(
                            label: controller.continueButtonLabel,
                            onPressed: controller.isLoading.value
                                ? null
                                : () => controller.continueSubscription(),
                            height: R.height(58),
                            borderRadius: R.width(40),
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            textStyle: AppTypography.labelMd.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            isLoading: controller.isLoading.value,
                          ),
                        ),
                        SizedBox(height: R.height(24)),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/Vector.png',
                                width: R.width(20),
                                height: R.width(20),
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: R.width(8)),
                              Text(
                                "Cancel anytime",
                                style: AppTypography.labelSm.copyWith(
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: R.height(28)),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildFooterLink("PRIVACY POLICY", () {
                                  Get.toNamed('/legal', arguments: {'tab': 0});
                                }),
                                _buildDot(),
                                _buildFooterLink("TERMS AND CONDITIONS", () {
                                  Get.toNamed('/legal', arguments: {'tab': 1});
                                }),
                                _buildDot(),
                                _buildFooterLink("RESTORE", () {
                                  controller.restorePurchase();
                                }),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: R.height(20)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: R.height(4)),
        child: Text(
          text,
          maxLines: 1,
          softWrap: false,
          style: AppTypography.overlineSm.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(4),
      ), // Reduced padding to prevent overflow
      child: Container(
        width: 3.5, // slightly smaller dot
        height: 3.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
