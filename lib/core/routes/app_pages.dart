import 'package:get/get.dart';
import 'package:petapp/modules/home/views/home_view.dart';
import 'package:petapp/modules/onboarding/views/onboarding_view.dart';
import 'package:petapp/modules/onboarding/views/onboarding_two_view.dart';
import 'package:petapp/modules/onboarding/views/onboarding_three_view.dart';
import 'package:petapp/modules/dashboard/views/dashboard_view.dart';
import 'package:petapp/modules/payment/views/payment_view.dart';

import '../../shared/widgets/scaffold/app_scaffold.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingView()),
    GetPage(
      name: AppRoutes.onboardingTwo,
      page: () => const OnboardingTwoView(),
    ),
    GetPage(name: AppRoutes.appScaffold, page: () => const AppScaffold()),
    GetPage(name: AppRoutes.homeView, page: () => const HomeViewScreen()),
    GetPage(name: AppRoutes.dashboard, page: () => const DashboardView()),
    GetPage(
      name: AppRoutes.onboardingThree,
      page: () => const OnboardingThreeView(),
    ),
    GetPage(name: AppRoutes.payment, page: () => const PaymentView()),
    // Add your pages here
  ];
}
