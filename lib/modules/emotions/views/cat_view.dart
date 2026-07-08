import 'package:flutter/material.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class CatViewMain extends StatelessWidget {
  const CatViewMain({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      body: Text("Hello kitty"),
    );
  }
}
