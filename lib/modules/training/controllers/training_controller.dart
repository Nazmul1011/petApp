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
  final _allItems = <TrainingItem>[];

  @override
  void onInit() {
    super.onInit();
    fetchTraining();

    // Refresh UI when user state changes (e.g., premium upgrade or pet switch)
    ever(_authController.user, (_) {
      _applyFilters();
    });
  }

  Future<void> fetchTraining() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/training');
      if (response.statusCode == 200 && response.data != null) {
        final dynamic respData = response.data;

        dynamic rawData = (respData is Map && respData.containsKey('data'))
            ? respData['data']
            : respData;

        // The backend returns { items: [...], premiumAllowed: boolean }
        List<dynamic> dataList = [];
        if (rawData is Map && rawData.containsKey('items')) {
          dataList = rawData['items'];
        } else if (rawData is List) {
          dataList = rawData;
        }

        _allItems.clear();
        _allItems.addAll(dataList
            .map((json) => TrainingItem.fromJson(json))
            .toList());

        _applyFilters();
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
      Get.toNamed(AppRoutes.payment);
    } else {
      Get.toNamed(AppRoutes.trainingDetail, arguments: item);
    }
  }

  void goToViewAll(String category) {
    Get.toNamed(AppRoutes.trainingViewAll, arguments: category);
  }

  void _applyFilters() {
    final activePetType = _activePetType;
    if (activePetType == null) return;

    basicCommands.assignAll(
      _allItems
          .where((e) => e.category == 'BASIC' && e.petType == activePetType)
          .toList(),
    );
    tricks.assignAll(
      _allItems
          .where((e) => e.category == 'TRICK' && e.petType == activePetType)
          .toList(),
    );
  }

  String? get _activePetType {
    final user = _authController.user.value;
    if (user == null || user.activePetId == null) return null;

    final activePet = user.pets.firstWhereOrNull(
      (p) => p['id'] == user.activePetId,
    );
    return activePet?['type'];
  }
}
