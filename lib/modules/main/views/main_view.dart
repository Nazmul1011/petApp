import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import '../controllers/main_controller.dart';
import '../widgets/app_bottom_navigation_bar.dart';
import '../../dashboard/views/dashboard_view.dart';
import '../../emotions/views/emotions_view.dart';
import '../../whistle/views/whistle_view.dart';
import '../../training/views/training_view.dart';
import '../../notification/views/notification_view.dart';
import '../../more/views/more_view.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      useSafeArea: false,
      bottomNavigationBar: const AppBottomNavigationBar(),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            DashboardView(),
            EmotionsView(),
            WhistleView(),
            TrainingView(),
            NotificationView(),
            MoreView(),
          ],
        ),
      ),
    );
  }
}
