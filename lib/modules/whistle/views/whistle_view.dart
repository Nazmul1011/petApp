import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/whistle_controller.dart';

class WhistleView extends GetView<WhistleController> {
  const WhistleView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Whistle Module",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
