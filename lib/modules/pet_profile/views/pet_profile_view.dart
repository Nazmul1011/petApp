import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/text_form_field/app_text_form_field.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/app_popup_menu_dropdown/app_popup_menu_dropdown.dart';
import 'package:petapp/shared/widgets/pet_avatar/pet_avatar.dart';
import '../controllers/pet_profile_controller.dart';
import '../models/pet_model.dart';
import '../widgets/dashed_circle_painter.dart';
import '../../../../core/routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.pets.isEmpty) {
                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(child: _buildEmptyState()),
                  ],
                );
              }
              final pet = controller.selectedPet.value ?? controller.pets.first;
              return Form(
                key: controller.profileFormKey,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context),
                            _buildPetDetails(pet),
                          ],
                        ),
                      ),
                    ),
                    _buildActionButtons(pet),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(20),
        vertical: R.height(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
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
          ],
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
                  final isPremium =
                      AuthController.to.user.value?.isPremium ?? false;
                  if (controller.pets.length >= 1 && !isPremium) {
                    Get.toNamed(AppRoutes.payment);
                  } else {
                    controller.prepareForAdd();
                    Get.toNamed(AppRoutes.addPet);
                  }
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
              final isPremium =
                  AuthController.to.user.value?.isPremium ?? false;
              if (controller.pets.length >= 1 && !isPremium) {
                Get.toNamed(AppRoutes.payment);
              } else {
                controller.prepareForAdd();
                Get.toNamed(AppRoutes.addPet);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetails(PetModel pet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.width(2.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: R.height(20)),
          Center(child: _buildImagePicker(pet)),
          SizedBox(height: R.height(30)),
          AppTextFormField(
            label: "Name",
            controller: controller.profileNameController,
            hintText: "Tommy",
            showPrefixIcon: false,
            type: FormFieldType.name,
          ),
          SizedBox(height: R.height(20)),
          AppTextFormField(
            label: "Age in human year",
            controller: controller.profileAgeController,
            hintText: "3",
            showPrefixIcon: false,
            type: FormFieldType.number,
          ),
          SizedBox(height: R.height(20)),
          Obx(
            () => AppPopupMenuDropdown(
              key: ValueKey(
                controller.profileSelectedType.value +
                    (controller.selectedPet.value?.id ?? ''),
              ),
              labelText: "Breed",
              items: controller.profileSelectedType.value == 'DOG'
                  ? controller.dogBreeds
                  : controller.catBreeds,
              selectedValue: controller.profileSelectedBreed.value,
              onChanged: (val) {
                if (val != null) {
                  controller.profileSelectedBreed.value = val;
                }
              },
            ),
          ),
          SizedBox(height: R.height(20)),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PetModel pet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.width(2)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Delete icon hidden for now, only keep the Update button.
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     GestureDetector(
          //       onTap: () => _showDeleteConfirmation(pet),
          //       child: Container(
          //         width: R.height(60),
          //         height: R.height(60),
          //         decoration: const BoxDecoration(
          //           shape: BoxShape.circle,
          //           color: Color(0xFFFFEBEB),
          //         ),
          //         child: const Icon(
          //           Icons.delete_outline,
          //           color: Color(0xFFF05151),
          //           size: 24,
          //         ),
          //       ),
          //     ),
          //     SizedBox(width: R.width(16)),
          //   ],
          // ),
          Obx(
            () => AppMaterialButton(
              label: "Update",
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.savePet(isUpdating: true, id: pet.id),
              isLoading: controller.isLoading.value,
              height: R.height(60),
              borderRadius: 30,
            ),
          ),
          SizedBox(height: R.height(40.0)),
        ],
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
                  child: localImage != null
                      ? ClipOval(
                          child: Image.file(
                            File(localImage.path),
                            fit: BoxFit.cover,
                          ),
                        )
                      : PetAvatar(
                          imageUrl: pet.imageUrl,
                          type: pet.type,
                          size: R.width(90),
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

  // ignore: unused_element
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
}
