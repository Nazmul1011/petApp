import 'package:get/get.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/main/controllers/main_controller.dart';
import 'package:petapp/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:petapp/modules/emotions/controllers/emotions_controller.dart';
import 'package:petapp/modules/whistle/controllers/whistle_controller.dart';
import 'package:petapp/modules/training/controllers/training_controller.dart';
import 'package:petapp/modules/notification/controllers/notification_controller.dart';
import 'package:petapp/modules/more/controllers/more_controller.dart';
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
    // Auth & Identity
    Get.put<AuthController>(AuthController(), permanent: true);

    // Core Navigation & Main Shell
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
    Get.lazyPut<DashboardController>(() => DashboardController(), fenix: true);

    // Feature Modules
    Get.lazyPut<EmotionsController>(() => EmotionsController(), fenix: true);
    Get.lazyPut<WhistleController>(() => WhistleController(), fenix: true);
    Get.lazyPut<TrainingController>(() => TrainingController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<MoreController>(() => MoreController(), fenix: true);

    // Payments
    Get.lazyPut<PaymentService>(() => PaymentService(), fenix: true);
    Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
    
    // Language
    Get.lazyPut<LanguageService>(() => LanguageService(), fenix: true);
    Get.lazyPut<LanguageController>(() => LanguageController(), fenix: true);
    
    // Legal
    Get.lazyPut<LegalService>(() => LegalService(), fenix: true);
    Get.lazyPut<LegalController>(() => LegalController(), fenix: true);
    
    // Subscriptions
    Get.lazyPut<SubscriptionService>(() => SubscriptionService(), fenix: true);
    Get.lazyPut<SubscriptionModuleController>(() => SubscriptionModuleController(), fenix: true);
  }
}
