import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:petapp/modules/home/views/home_view.dart';

class MainNavigationController extends GetxController {
  final bottomNavIndex = 0.obs;
  final drawerController = AdvancedDrawerController();

  final List<Widget> pages = [
    const HomeView(), // Talk
    const PlaceholderView(title: "Emotions"),
    const PlaceholderView(title: "Whistle"),
    const PlaceholderView(title: "Training"),
    const PlaceholderView(title: "Notification"),
    const PlaceholderView(title: "More"),
  ];

  void switchTab(int index) {
    bottomNavIndex.value = index;
  }

  void openDrawer() {
    drawerController.showDrawer();
  }
}

class PlaceholderView extends StatelessWidget {
  final String title;
  const PlaceholderView({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("$title View"),
      ),
    );
  }
}
