import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/shared/helpers/responsive.dart';

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
    return Scaffold(
      backgroundColor: AppColors.primaryColor, // Purple background
      body: Stack(
        children: [
          // Centered Content
          Center(
            child: Image.asset(
              'assets/images/Logo Container.png',
              height: R.height(
                150,
              ), // Made it a bit larger since it's the only content now
              color: Colors.white,
            ),
          ),

          // Bottom Content
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: R.height(60)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.width(4)),
                    child: Icon(
                      Icons.pets,
                      color: Colors.white.withValues(
                        alpha: index == 4 ? 0.3 : 1.0,
                      ),
                      size: R.width(18),
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
}
