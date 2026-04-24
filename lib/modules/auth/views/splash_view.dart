import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is already initialized via GlobalBindings (permanent: true)
    // and it handles routing automatically in onInit() -> _autoLogin() -> handleRouting()

    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6A4C93), // Using a brand-like purple
        ),
      ),
    );
  }
}
