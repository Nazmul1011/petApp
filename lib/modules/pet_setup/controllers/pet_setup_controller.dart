import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/services/api_service.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/pet_profile/services/pet_api_service.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';

class PetSetupController extends GetxController with BaseController {
  final ApiService _api = ApiService();

  final ImagePicker _picker = ImagePicker();

  final petNameController = TextEditingController();
  final petAgeController = TextEditingController();

  final Rxn<XFile> imageFile = Rxn<XFile>();

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      imageFile.value = image;
    }
  }

  final RxString selectedType = 'DOG'.obs;
  final RxString selectedBreed = 'Pitbull'.obs; // Default based on UI

  final List<String> petTypes = ['DOG', 'CAT'];
  final List<String> dogBreeds = [
    'Pitbull',
    'Golden Retriever',
    'Bulldog',
    'Poodle',
    'Mixed',
    'Others',
  ];
  final List<String> catBreeds = ['Persian', 'Siamese', 'Maine Coon', 'Mixed', 'Others'];

  @override
  void onInit() {
    super.onInit();
    final savedPet = GetStorage().read<String>('onboarding_selected_pet');
    if (savedPet != null) {
      if (savedPet.toLowerCase() == 'dog') {
        selectedType.value = 'DOG';
        selectedBreed.value = dogBreeds.first;
      } else if (savedPet.toLowerCase() == 'cat') {
        selectedType.value = 'CAT';
        selectedBreed.value = catBreeds.first;
      }
    }
  }

  @override
  void onClose() {
    petNameController.dispose();
    petAgeController.dispose();
    super.onClose();
  }

  Future<void> createPetProfile() async {
    final name = petNameController.text.trim();
    final ageStr = petAgeController.text.trim();

    if (name.isEmpty) {
      showError("Please enter your pet's name.");
      return;
    }

    final age = int.tryParse(ageStr);

    try {
      setLoading(true);

      String? uploadedImageUrl;
      if (imageFile.value != null) {
        final File file = File(imageFile.value!.path);
        final PetApiService petApi = PetApiService();
        uploadedImageUrl = await petApi.uploadPetImage(file);
      }

      final Map<String, dynamic> payload = {
        "type": selectedType.value,
        "name": name,
        "breed": selectedBreed.value,
      };
      if (age != null) payload["age"] = age;
      if (uploadedImageUrl != null) {
        payload["imageUrl"] = uploadedImageUrl;
      }

      final response = await _api.post('/pets', data: payload);

      setLoading(false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh user profile so activePetId is updated globally
        await AuthController.to.fetchUserProfile();

        showSnack(
          content: 'Pet profile created successfully!',
          status: SnackBarStatus.success,
        );
        Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      setLoading(false);
      showError(e.toString());
    }
  }
}
