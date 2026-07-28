import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/app_asset_image.dart';

import '../controllers/payment_controller.dart';
import '../models/subscription_plan.dart';
import '../widgets/feature_list.dart';
import '../widgets/subscription_card.dart';
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
      backgroundColor: AppColors.primaryColor,
      extendBody: true,
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
                    AppColors.primaryColor,
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
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                child: Column(
                  children: [
                    SizedBox(height: R.height(4)),
                    // Hero Image
                    AppAssetImage(
                      'assets/images/payment.webp',
                      width: R.width(390),
                      height: R.height(220),
                      fit: BoxFit.contain,
                    ),

                    SizedBox(height: R.height(50)),

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
                              color: Color(0xFF6C3BAA),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: "access"),
                        ],
                      ),
                    ),

                    SizedBox(height: R.height(4)),

                    // Feature List
                    const FeatureList(),

                    SizedBox(height: R.height(6)),

                    const DottedLine(
                      dashColor: Color(0xFF6C3BAA),
                      dashLength: 4,
                      dashGapLength: 4,
                      lineThickness: 1,
                    ),

                    SizedBox(height: R.height(12)),

                    // Subscriptions
                    Obx(() {
                      final trialAvailable = subController.trialAvailable.value;
                      return Column(
                        children: [
                          SubscriptionCard(
                            title: "7 days free trial",
                            subtitle: trialAvailable
                                ? "No payment required"
                                : "then \$25/year",
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
                            title: "1 month for \$1",
                            subtitle: "then \$25/year",
                            rightText: "Full Pro access",
                            isSelected:
                                controller.selectedPlan.value ==
                                SubscriptionPlan.yearlyIntro,
                            onTap: () => controller.selectPlan(
                              SubscriptionPlan.yearlyIntro,
                            ),
                          ),
                        ],
                      );
                    }),

                    // Bottom Actions
                    SizedBox(height: R.height(30)),
                    Obx(() {
                      final isLoading =
                          controller.isLoading.value ||
                          subController.isLoading.value;
                      return AppMaterialButton(
                        label: subController.continueButtonLabel,
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
                    }),
                    SizedBox(height: R.height(16)),
                    Obx(() {
                      final trialAvailable = subController.trialAvailable.value;
                      final alreadyOnTrial =
                          subController.isTrialActive.value ||
                          (Get.isRegistered<AuthController>() &&
                              (AuthController.to.user.value?.hasTrialOrPremium ??
                                  false));
                      final label = alreadyOnTrial
                          ? 'Close'
                          : trialAvailable
                              ? 'Start free trial & continue'
                              : 'Continue with free plan';
                      return GestureDetector(
                        onTap: subController.isLoading.value ||
                                controller.isLoading.value
                            ? null
                            : () => controller.dismissPaywall(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppAssetImage(
                              'assets/images/Vector.png',
                              width: R.width(20),
                              height: R.width(20),
                              fit: BoxFit.contain,
                            ),
                            SizedBox(width: R.width(8)),
                            Text(
                              label,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.textWhite,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    SizedBox(height: R.height(28)),
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildFooterLink(
                              "PRIVACY POLICY",
                              onTap: controller.openPrivacyPolicy,
                            ),
                            _buildDot(),
                            _buildFooterLink(
                              "TERMS AND CONDITIONS",
                              onTap: controller.openTermsConditions,
                            ),
                            _buildDot(),
                            _buildFooterLink(
                              "RESTORE",
                              onTap: controller.restorePurchase,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: R.height(20)),
                  ],
                ),
              ),
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
                child: Obx(() {
                  final busy = controller.isLoading.value ||
                      subController.isLoading.value;
                  return GestureDetector(
                    onTap: busy ? null : () => controller.dismissPaywall(),
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
                  );
                }),
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
          maxLines: 1,
          softWrap: false,
          style: AppTypography.overlineSm.copyWith(
            color: Colors.white,
          ),
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
