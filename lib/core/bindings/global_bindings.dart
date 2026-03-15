import 'package:get/get.dart';
import 'package:petapp/modules/payment/controllers/payment_controller.dart';
import 'package:petapp/modules/payment/services/payment_service.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentService>(() => PaymentService(), fenix: true);
    Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
  }
}
