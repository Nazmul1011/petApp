import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/emotions_controller.dart';

class EmotionsView extends GetView<EmotionsController> {
  const EmotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Emotions Module",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
