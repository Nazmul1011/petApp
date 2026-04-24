import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/text_form_field/app_text_form_field.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/app_drop_down_search/app_drop_down_search.dart';
import '../controllers/pet_profile_controller.dart';
import '../models/pet_model.dart';
import '../widgets/dashed_circle_painter.dart';
import '../../../../core/routes/app_routes.dart';

class PetProfileView extends GetView<PetProfileController> {
  const PetProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: false,
      statusBarIconBrightness: Brightness.dark,
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: Colors.white)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.pets.isEmpty) {
                      return _buildEmptyState();
                    }
                    final pet =
                        controller.selectedPet.value ?? controller.pets.first;
                    return _buildPetDetails(pet);
                  }),
                ),
                _buildHomeIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(20),
        vertical: R.height(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
          SizedBox(height: R.height(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pet profile",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {
                  controller.prepareForAdd();
                  Get.toNamed(AppRoutes.addPet);
                },
                child: Row(
                  children: [
                    const Icon(Icons.add, size: 18, color: Colors.black),
                    SizedBox(width: R.width(4)),
                    const Text(
                      "ADD NEW",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("No pet profiles found.", style: AppTypography.bodySm),
          SizedBox(height: R.height(20)),
          AppMaterialButton(
            label: "Create Profile",
            onPressed: () {
              controller.prepareForAdd();
              Get.toNamed(AppRoutes.addPet);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetails(PetModel pet) {
    return Form(
      key: controller.profileFormKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: R.width(24)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: R.height(20)),
            Center(child: _buildImagePicker(pet)),
            SizedBox(height: R.height(30)),
            _buildLabel("Name"),
            SizedBox(height: R.height(8)),
            AppTextFormField(
              controller: controller.profileNameController,
              hintText: "Tommy",
              showPrefixIcon: false,
              borderRadius: 30, // Pill shaped as per screenshot
              type: FormFieldType.name,
            ),
            SizedBox(height: R.height(20)),
            _buildLabel("Age in human year"),
            SizedBox(height: R.height(8)),
            AppTextFormField(
              controller: controller.profileAgeController,
              hintText: "3",
              showPrefixIcon: false,
              borderRadius: 30,
              type: FormFieldType.number,
            ),
            SizedBox(height: R.height(20)),
            _buildLabel("Breed"),
            SizedBox(height: R.height(8)),
            Obx(
              () => AppDropdownSearch(
                key: ValueKey(
                  controller.profileSelectedType.value +
                      (controller.selectedPet.value?.id ?? ''),
                ),
                labelText: "", // We use external label
                showLabelText: false,
                initialItems: controller.profileSelectedType.value == 'DOG'
                    ? controller.dogBreeds
                    : controller.catBreeds,
                showLeadingIcon: false,
                onChanged: (val) {
                  if (val != null) controller.profileSelectedBreed.value = val;
                },
                controller: TextEditingController(
                  text: controller.profileSelectedBreed.value,
                ),
              ),
            ),
            SizedBox(height: R.height(60)),
            Row(
              children: [
                Expanded(
                  child: AppMaterialButton(
                    label: "Delete profile",
                    backgroundColor: const Color(
                      0xFFF05151,
                    ), // Red from screenshot
                    textColor: Colors.white,
                    onPressed: () => _showDeleteConfirmation(pet),
                    borderRadius: 30,
                    height: R.height(56),
                  ),
                ),
                SizedBox(width: R.width(16)),
                Expanded(
                  child: AppMaterialButton(
                    label: "Update",
                    backgroundColor: const Color(0xFF8B78E6),
                    textColor: Colors.white,
                    onPressed: () =>
                        controller.savePet(isUpdating: true, id: pet.id),
                    borderRadius: 30,
                    height: R.height(56),
                  ),
                ),
              ],
            ),
            SizedBox(height: R.height(40)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: R.width(12)),
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF737373),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildImagePicker(PetModel pet) {
    return Column(
      children: [
        GestureDetector(
          onTap: controller.pickImage,
          child: Obx(() {
            final localImage = controller.imageFile.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(R.width(110), R.width(110)),
                  painter: DashedCirclePainter(
                    color: const Color(0xFFD8D9DD),
                    strokeWidth: 1.5,
                    dashLength: 6,
                    gapLength: 4,
                  ),
                ),
                Container(
                  width: R.width(90),
                  height: R.width(90),
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: localImage != null
                        ? Image.file(File(localImage.path), fit: BoxFit.cover)
                        : pet.imageUrl != null
                        ? Image.network(pet.imageUrl!, fit: BoxFit.cover)
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              pet.type == PetType.DOG
                                  ? "assets/images/dog image.png"
                                  : "assets/images/cat image.png",
                              fit: BoxFit.contain,
                            ),
                          ),
                  ),
                ),
              ],
            );
          }),
        ),
        SizedBox(height: R.height(12)),
        const Text(
          "Upload a picture",
          style: TextStyle(
            color: Color(0xFF737373),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(PetModel pet) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Delete Profile", style: AppTypography.h6),
        content: Text(
          "Are you sure you want to delete ${pet.name}'s profile? This action cannot be undone.",
          style: AppTypography.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: AppTypography.bodySm.copyWith(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => controller.deletePet(pet.id),
            child: Text(
              "Delete",
              style: AppTypography.bodySm.copyWith(
                color: const Color(0xFFF05151),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Column(
      children: [
        Center(
          child: Container(
            width: R.width(134),
            height: R.height(5),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(height: R.height(8)),
      ],
    );
  }
}
