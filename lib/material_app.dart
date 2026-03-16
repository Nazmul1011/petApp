import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/bindings/global_bindings.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'shared/helpers/responsive.dart';

class Petapp extends StatelessWidget {
  const Petapp({super.key});

  @override
  Widget build(BuildContext context) {
    R.init(context);
    return GetMaterialApp(
      title: 'petapp',
      theme: appTheme(context),
      initialBinding: GlobalBindings(),
      initialRoute: AppRoutes.dashboard,
      getPages: AppPages.pages,
    );
  }
}
