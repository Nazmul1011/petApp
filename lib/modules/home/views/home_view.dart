import 'package:flutter/material.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class HomeViewScreen extends StatelessWidget {
  const HomeViewScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
     body:Column(
      children: [
        Text("Hello There how are you "),
        AppMaterialButton()
      ],
     )
    );
  }
}
