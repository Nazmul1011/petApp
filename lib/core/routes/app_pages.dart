import 'package:get/get.dart';
import 'package:petapp/modules/home/views/home_view.dart';

import '../../shared/widgets/scaffold/app_scaffold.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.appScaffold, page: () => const AppScaffold()),
    GetPage(name: AppRoutes.homeView, page: () => const HomeViewScreen())
    // Add your pages here
  ];
}
