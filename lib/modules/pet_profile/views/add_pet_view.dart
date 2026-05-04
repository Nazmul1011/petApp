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
import '../widgets/dashed_circle_painter.dart';

class AddPetView extends GetView<PetProfileController> {
  const AddPetView({super.key});

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
                  child: Form(
                    key: controller.addFormKey,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: R.height(10)),
                          Center(child: _buildImagePicker()),
                          SizedBox(height: R.height(16)),
                          _buildLabel("Type"),
                          SizedBox(height: R.height(6)),
                          AppDropdownSearch(
                            labelText: "",
                            showLabelText: false,
                            initialItems: controller.petTypes,
                            showLeadingIcon: false,
                            onChanged: (val) {
                              if (val != null) {
                                controller.addSelectedType.value = val;
                                // Reset breed to first of new type
                                controller.addSelectedBreed.value = val == 'DOG'
                                    ? controller.dogBreeds.first
                                    : controller.catBreeds.first;
                              }
                            },
                          ),
                          SizedBox(height: R.height(16)),
                          _buildLabel("Name"),
                          SizedBox(height: R.height(6)),
                          AppTextFormField(
                            controller: controller.addNameController,
                            hintText: "Tommy",
                            showPrefixIcon: false,
                            borderRadius: 30, // Pill shaped
                            type: FormFieldType.name,
                          ),
                          SizedBox(height: R.height(16)),
                          _buildLabel("Age in human year"),
                          SizedBox(height: R.height(6)),
                          AppTextFormField(
                            controller: controller.addAgeController,
                            hintText: "3",
                            showPrefixIcon: false,
                            borderRadius: 30,
                            type: FormFieldType.number,
                          ),
                          SizedBox(height: R.height(16)),
                          _buildLabel("Breed"),
                          SizedBox(height: R.height(6)),
                          Obx(
                            () => AppDropdownSearch(
                              key: ValueKey(controller.addSelectedType.value),
                              labelText: "",
                              showLabelText: false,
                              initialItems:
                                  controller.addSelectedType.value == 'DOG'
                                  ? controller.dogBreeds
                                  : controller.catBreeds,
                              showLeadingIcon: false,
                              onChanged: (val) {
                                if (val != null)
                                  controller.addSelectedBreed.value = val;
                              },
                              controller: TextEditingController(
                                text: controller.addSelectedBreed.value,
                              ),
                            ),
                          ),
                          SizedBox(height: R.height(30)),
                          AppMaterialButton(
                            label: "Create",
                            backgroundColor: const Color(0xFF8B78E6),
                            textColor: Colors.white,
                            onPressed: () =>
                                controller.savePet(isUpdating: false),
                            borderRadius: 30,
                            height: R.height(56),
                          ),
                          SizedBox(height: R.height(16)),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildHomeIndicator(),
              ],
            ),
          ),
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(20),
        vertical: R.height(10),
      ),
      child: Stack(
        alignment: Alignment.center,
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
                child: const Icon(Icons.close, color: Colors.black, size: 24),
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Create a pet profile",
                style: TextStyle(
                  color: const Color(0xFF737373),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "Lets get to know your pet",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
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
                        : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              controller.addSelectedType.value == 'DOG'
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
        SizedBox(height: R.height(8)),
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
