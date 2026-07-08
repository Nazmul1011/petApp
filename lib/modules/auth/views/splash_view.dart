import 'package:flutter/material.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthController is already initialized via GlobalBindings (permanent: true)
    // and it handles routing automatically in onInit() -> _autoLogin() -> handleRouting()

    return AppScaffold(
      backgroundColor: Color(0xFF6C3BAA),
      horizontalPadding: 0,
      body: Center(
        child: Image.asset(
          'assets/images/logo 1.png',
          width: 200,
        ),
      ),
    );
  }
}
