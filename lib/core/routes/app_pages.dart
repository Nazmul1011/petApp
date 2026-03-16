import 'package:get/get.dart';
import 'package:petapp/modules/onboarding/views/onboarding_view.dart';
import 'package:petapp/modules/onboarding/views/onboarding_two_view.dart';
import 'package:petapp/modules/onboarding/views/onboarding_three_view.dart';
import 'package:petapp/modules/main/views/main_view.dart';
import 'package:petapp/modules/payment/views/payment_view.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.onboardingTwo,
      page: () => const OnboardingTwoView(),
    ),
    GetPage(
      name: AppRoutes.onboardingThree,
      page: () => const OnboardingThreeView(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => MainView(),
    ),
    GetPage(
      name: AppRoutes.payment,
      page: () => const PaymentView(),
    ),
  ];
}
