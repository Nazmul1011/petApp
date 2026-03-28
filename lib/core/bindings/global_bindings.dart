import 'package:get/get.dart';
import 'package:petapp/modules/payment/controllers/payment_controller.dart';
import 'package:petapp/modules/payment/services/payment_service.dart';
import 'package:petapp/modules/language/controllers/language_controller.dart';
import 'package:petapp/modules/language/services/language_service.dart';
import 'package:petapp/modules/legal/controllers/legal_controller.dart';
import 'package:petapp/modules/legal/services/legal_service.dart';
import 'package:petapp/modules/subscription/controllers/subscription_controller.dart';
import 'package:petapp/modules/subscription/services/subscription_service.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentService>(() => PaymentService(), fenix: true);
    Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
    
    Get.lazyPut<LanguageService>(() => LanguageService(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    
    Get.lazyPut<LegalService>(() => LegalService(), fenix: true);
    Get.lazyPut<LegalController>(() => LegalController(), fenix: true);
    
    Get.lazyPut<SubscriptionService>(() => SubscriptionService(), fenix: true);
    Get.lazyPut<SubscriptionModuleController>(() => SubscriptionModuleController(), fenix: true);
  }
}
