import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get_storage/get_storage.dart';

import 'bottom_navigation_bar.dart';
import 'app_drawer.dart';
import '../controllers/main_navigation_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainView extends StatelessWidget {
  MainView({super.key});

  final nav = Get.find<MainNavigationController>();
  final box = GetStorage();
  ProfileController get profileController => Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    final userName = box.read("profile_name") ?? "Guest User";
    final userPic = box.read("profile_picture") ?? "";
    final userPhone = box.read("profile_phone") ?? "";

    return Obx(() {
      final index = nav.bottomNavIndex.value;

      return AdvancedDrawer(
        controller: nav.drawerController,
        animationDuration: const Duration(milliseconds: 110),
        backdropColor: const Color.fromRGBO(68, 68, 68, 1),
        childDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
        ),
        drawer: AppDrawer(
          name: userName,
          phone: userPhone,
          pic: userPic,
          localPic: profileController.localImagePath.value,
        ),
        child: Scaffold(
          body: IndexedStack(
            index: index,
            children: nav.pages,
          ),
          bottomNavigationBar: const BottomNavBar(),
        ),
      );
    });
  }
}
