import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get_storage/get_storage.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';
import '../../../../core/routes/app_routes.dart';
import '../models/pet_model.dart';
import '../services/pet_api_service.dart';

class PetProfileController extends GetxController with BaseController {
  final PetApiService _petApi = PetApiService();
  final ImagePicker _picker = ImagePicker();

  final RxList<PetModel> pets = <PetModel>[].obs;
  final Rxn<PetModel> selectedPet = Rxn<PetModel>();

  final profileFormKey = GlobalKey<FormState>();
  final addFormKey = GlobalKey<FormState>();

  // Form fields (Profile / Update)
  final profileNameController = TextEditingController();
  final profileAgeController = TextEditingController();
  final RxString profileSelectedType = 'DOG'.obs;
  final RxString profileSelectedBreed = 'Pitbull'.obs;

  // Form fields (Add New Pet)
  final addNameController = TextEditingController();
  final addAgeController = TextEditingController();
  final RxString addSelectedType = 'DOG'.obs;
  final RxString addSelectedBreed = 'Pitbull'.obs;

  final Rxn<XFile> imageFile = Rxn<XFile>();

  /// Blocks double-taps on Update / Create before `isLoading` rebuilds the UI.
  bool _saveInFlight = false;

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
    fetchPets();

    // Automatically prepare for edit when selectedPet changes
    ever(selectedPet, (pet) {
      if (pet != null) {
        prepareForEdit(pet);
      }
    });
  }

  @override
  void onClose() {
    profileNameController.dispose();
    profileAgeController.dispose();
    addNameController.dispose();
    addAgeController.dispose();
    super.onClose();
  }

  Future<void> fetchPets({bool force = false}) async {
    // Avoid double fetching if not forced
    if (pets.isNotEmpty && !force) return;

    try {
      setLoading(true);
      debugPrint("Fetching pets from API...");
      final list = await _petApi.getAllPets();
      debugPrint("Fetched ${list.length} pets.");
      pets.assignAll(list);

      // If there's an active pet ID in AuthController, find it in the list
      final activeId = AuthController.to.user.value?.activePetId;
      if (activeId != null) {
        selectedPet.value = pets.firstWhereOrNull((p) => p.id == activeId);
      } else if (pets.isNotEmpty) {
        selectedPet.value = pets.first;
      }
    } catch (e) {
      debugPrint("Error fetching pets: $e");
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void prepareForAdd() {
    addNameController.clear();
    addAgeController.clear();
    final savedPet = GetStorage().read<String>('onboarding_selected_pet');
    if (savedPet != null && savedPet.toLowerCase() == 'cat') {
      addSelectedType.value = 'CAT';
      addSelectedBreed.value = catBreeds.first;
    } else {
      addSelectedType.value = 'DOG';
      addSelectedBreed.value = dogBreeds.first;
    }
    imageFile.value = null;
  }

  void prepareForEdit(PetModel pet) {
    profileNameController.text = pet.name;
    profileAgeController.text = pet.age?.toString() ?? '';
    profileSelectedType.value = pet.type == PetType.DOG ? 'DOG' : 'CAT';
    profileSelectedBreed.value =
        pet.breed ??
        (profileSelectedType.value == 'DOG'
            ? dogBreeds.first
            : catBreeds.first);
    // imageFile is shared for simplicity as it's only used for local picking
    imageFile.value = null;
  }

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

  Future<void> savePet({bool isUpdating = false, String? id}) async {
    if (_saveInFlight || isLoading.value) return;

    final name = isUpdating
        ? profileNameController.text.trim()
        : addNameController.text.trim();
    if (name.isEmpty) {
      showError("Please enter pet name");
      return;
    }

    // Enforce 1-pet limit on creation for non-premium accounts
    if (!isUpdating) {
      final isPremium = AuthController.to.user.value?.isPremium ?? false;
      if (pets.length >= 1 && !isPremium) {
        Get.toNamed(AppRoutes.payment);
        return;
      }
    }

    _saveInFlight = true;
    try {
      setLoading(true);

      String? uploadedImageUrl;
      if (imageFile.value != null) {
        final File file = File(imageFile.value!.path);
        uploadedImageUrl = await _petApi.uploadPetImage(file);
      }

      final type = isUpdating
          ? profileSelectedType.value
          : addSelectedType.value;

      final data = <String, dynamic>{
        'name': name,
        'type': type,
        'breed': isUpdating
            ? profileSelectedBreed.value
            : addSelectedBreed.value,
        'age': int.tryParse(
          isUpdating ? profileAgeController.text : addAgeController.text,
        ),
      };

      if (uploadedImageUrl != null) {
        data['imageUrl'] = uploadedImageUrl;
      } else if (isUpdating) {
        // Retain existing image if we didn't pick a new one, but don't send local asset strings
        final currentUrl = selectedPet.value?.imageUrl;
        if (currentUrl != null && !currentUrl.startsWith('assets/')) {
          data['imageUrl'] = currentUrl;
        }
      }

      if (isUpdating && id != null) {
        await _petApi.updatePet(id, data);
        showSnack(
          content: "Pet updated successfully",
          status: SnackBarStatus.success,
        );
      } else {
        await _petApi.createPet(data);
        showSnack(
          content: "Pet created successfully",
          status: SnackBarStatus.success,
        );
      }

      await fetchPets(force: true);
      await AuthController.to.fetchUserProfile();
      Get.back();
    } catch (e) {
      showError(e.toString());
    } finally {
      _saveInFlight = false;
      setLoading(false);
    }
  }

  Future<void> deletePet(String id) async {
    try {
      setLoading(true);
      await _petApi.deletePet(id);
      showSnack(
        content: "Pet deleted successfully",
        status: SnackBarStatus.success,
      );
      await fetchPets(force: true);
      await AuthController.to.fetchUserProfile();
      Get.back(); // Go back from detail view
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  Future<void> switchActivePet(String id) async {
    try {
      setLoading(true);
      await _petApi.setActivePet(id);
      await AuthController.to.fetchUserProfile();
      selectedPet.value = pets.firstWhereOrNull((p) => p.id == id);
      showSnack(content: "Active pet switched", status: SnackBarStatus.success);
    } catch (e) {
      showError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
