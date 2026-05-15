import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is already initialized via GlobalBindings (permanent: true)
    // and it handles routing automatically in onInit() -> _autoLogin() -> handleRouting()

    return Scaffold(
      backgroundColor: const Color(0xFF8C52FF),
      body: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/less then android 12.png',
              width: 200,
            ),
          ),
          const Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
