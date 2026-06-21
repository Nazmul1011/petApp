import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is already initialized via GlobalBindings (permanent: true)
    // and it handles routing automatically in onInit() -> _autoLogin() -> handleRouting()

    return Scaffold(
      backgroundColor: const Color(0xFF6C3BAA),
      body: Center(
        child: Image.asset(
          'assets/images/logo 1.png',
          width: 200,
        ),
      ),
    );
  }
}
