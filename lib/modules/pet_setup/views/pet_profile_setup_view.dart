import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/pet_setup/controllers/pet_setup_controller.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/text_form_field/app_text_form_field.dart';
import 'package:petapp/shared/widgets/app_drop_down_search/app_drop_down_search.dart';

class PetProfileSetupView extends GetView<PetSetupController> {
  const PetProfileSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PetSetupController>()) {
      Get.put(PetSetupController());
    }

    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.width(24.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.height(40)),
              Center(
                child: Column(
                  children: [
                    Text(
                      "Create a pet profile",
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: R.height(8)),
                    Text(
                      "Lets get to know your pet",
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: R.height(40)),

                    GestureDetector(
                      onTap: () => controller.pickImage(),
                      child: Column(
                        children: [
                          Obx(
                            () => Container(
                              width: R.width(100),
                              height: R.width(100),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: AppColors.primaryColor.withValues(
                                    alpha: 0.3,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: ClipOval(
                                child: controller.imageFile.value != null
                                    ? Image.file(
                                        File(controller.imageFile.value!.path),
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        imageUrl:
                                            "https://ui-avatars.com/api/?name=${controller.petNameController.text.isEmpty ? 'Pet' : controller.petNameController.text}&background=E9E4F8&color=7F67CB",
                                        placeholder: (context, url) =>
                                            const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Center(
                                              child: Image.asset(
                                                'assets/images/dog_happy_face.png',
                                                width: R.width(60),
                                              ),
                                            ),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: R.height(12)),
                          Text(
                            "Upload a picture",
                            style: AppTypography.bodyXs.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: R.height(30)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AppDropdownSearch(
                        labelText: "Pet type",
                        initialItems: controller.petTypes,
                        showLeadingIcon: false,
                        onChanged: (val) {
                          if (val != null) {
                            controller.selectedType.value = val;
                          }
                        },
                      ),
                      // SizedBox(height: R.height(20)),

                      // Using your custom text field
                      AppTextFormField(
                        label: "Name",
                        hintText: "yo",
                        controller: controller.petNameController,
                        type: FormFieldType.name,
                        showPrefixIcon: false,
                      ),
                      SizedBox(height: R.height(20)),

                      AppTextFormField(
                        label: "Age in human year",
                        hintText: "3",
                        controller: controller.petAgeController,
                        type: FormFieldType.number,
                        showPrefixIcon: false,
                      ),
                      SizedBox(height: R.height(20)),

                      Obx(
                        () => AppDropdownSearch(
                          key: ValueKey(controller.selectedType.value),
                          labelText: "Breed",
                          initialItems: controller.selectedType.value == 'DOG'
                              ? controller.dogBreeds
                              : controller.catBreeds,
                          showLeadingIcon: false,
                          onChanged: (val) {
                            if (val != null)
                              controller.selectedBreed.value = val;
                          },
                        ),
                      ),
                      SizedBox(height: R.height(20)),
                    ],
                  ),
                ),
              ),
              Obx(
                () => AppMaterialButton(
                  label: "Lets begin",
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.createPetProfile(),
                  height: R.height(56),
                  backgroundColor: AppColors.primaryColor,
                  textColor: Colors.white,
                  borderRadius: 28,
                ),
              ),
              SizedBox(height: R.height(24)),
            ],
          ),
        ),
      ),
    );
  }
}
