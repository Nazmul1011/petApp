import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class WelcomeSplashView extends StatefulWidget {
  const WelcomeSplashView({super.key});

  @override
  State<WelcomeSplashView> createState() => _WelcomeSplashViewState();
}

class _WelcomeSplashViewState extends State<WelcomeSplashView> {
  @override
  void initState() {
    super.initState();
    // Delay for 2-3 seconds, then navigate to Pet Profile Setup
    Future.delayed(const Duration(seconds: 3), () {
      Get.offNamed(AppRoutes.petProfileSetup);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.primaryColor, // Purple background
      horizontalPadding: 0,
      body: Center(
        child: Image.asset(
          'assets/images/Logo Container.png',
          height: R.height(260),
          color: Colors.white,
        ),
      ),
    );
  }
}
