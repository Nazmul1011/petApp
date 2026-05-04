import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';

class MainController extends GetxController with BaseController {
  final RxInt currentIndex = 0.obs;

  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}
