import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

import '../../payment/controllers/payment_controller.dart';
import '../../payment/widgets/subscription_card.dart';
import '../controllers/subscription_controller.dart';
import '../widgets/subscription_alert_box.dart';

class SubscriptionView extends GetView<SubscriptionModuleController> {
  const SubscriptionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      useSafeArea: false,
      systemNavigationBarIconBrightness: Brightness.light,
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
            child: Column(
              children: [
                // Top Custom App Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.width(20),
                    vertical: R.height(10),
                  ),
                  child: Align(
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
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                      child: Column(
                        children: [
                          SizedBox(height: R.height(12)),

                          // Big Purple PRO Card
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(R.width(20)),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7F67CB),
                              borderRadius: BorderRadius.circular(R.width(20)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "PREMIUM STATUS",
                                        style: AppTypography.overlineXs
                                            .copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                            ),
                                      ),
                                      SizedBox(height: R.height(8)),
                                      Text(
                                        "PRO Yearly",
                                        style: AppTypography.h6.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: R.height(4)),
                                      Text(
                                        "\$12.99/year",
                                        style: AppTypography.subtitleLg
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      SizedBox(height: R.height(12)),
                                      Text(
                                        "Full access to all premium features and tools.",
                                        style: AppTypography.bodyXs.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Image.asset(
                                    // Use best match from assets found
                                    'assets/images/dog image.png',
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.pets,
                                              size: 80,
                                              color: Colors.white54,
                                            ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: R.height(16)),

                          // Orange Alert Box
                          const SubscriptionAlertBox(),

                          SizedBox(height: R.height(24)),

                          const DottedLine(
                            dashColor: Color(0xFF7F67CB),
                            dashLength: 4,
                            dashGapLength: 4,
                            lineThickness: 1,
                          ),

                          SizedBox(height: R.height(24)),

                          // Subscription Cards
                          Obx(
                            () => Column(
                              children: [
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
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Actions (Same structure as payment)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: R.height(8)),
                      Obx(
                        () => AppMaterialButton(
                          label: "Continue",
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
                      SizedBox(height: R.height(14)),
                      Row(
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
                      SizedBox(height: R.height(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildFooterLink("PRIVACY POLICY"),
                          _buildDot(),
                          _buildFooterLink("TERMS AND CONDITIONS"),
                          _buildDot(),
                          _buildFooterLink("RESTORE"),
                        ],
                      ),
                      SizedBox(height: R.height(34)),
                      // Home Indicator Handle
                      Center(
                        child: Container(
                          width: R.width(134),
                          height: R.height(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: R.height(8)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: AppTypography.overlineXxs.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
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
