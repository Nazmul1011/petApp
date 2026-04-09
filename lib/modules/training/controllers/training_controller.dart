import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';
import '../models/training_item.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../../core/services/api_service.dart';

class TrainingController extends GetxController with BaseController {
  final ApiService _apiService = ApiService();
  final AuthController _authController = Get.find<AuthController>();

  final basicCommands = <TrainingItem>[].obs;
  final tricks = <TrainingItem>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTraining();
  }

  Future<void> fetchTraining() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/training');
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data;
        final items = data.map((json) => TrainingItem.fromJson(json)).toList();
        
        // Filter by category
        basicCommands.assignAll(items.where((e) => e.category == 'BASIC').toList());
        tricks.assignAll(items.where((e) => e.category == 'TRICK').toList());
      }
    } catch (e) {
      showSnack(
        content: "Failed to load training content",
        status: SnackBarStatus.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool isItemLocked(TrainingItem item) {
    if (!item.isPremium) return false;
    return !_authController.user.value!.isPremium;
  }

  void goToDetail(TrainingItem item) {
    if (isItemLocked(item)) {
      showSnack(
        content: "This training is locked. Please upgrade to premium.",
        status: SnackBarStatus.warning,
      );
    } else {
      Get.toNamed(AppRoutes.trainingDetail, arguments: item);
    }
  }

  void goToViewAll(String category) {
    Get.toNamed(AppRoutes.trainingViewAll, arguments: category);
  }
}
