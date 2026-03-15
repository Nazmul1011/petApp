import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/spacer/app_spacer.dart';
import 'package:petapp/shared/widgets/text_form_field/app_text_form_field.dart';
import 'dart:math' as math;
import 'dart:io';

import '../controllers/create_pet_profile_controller.dart';

class CreatePetProfileView extends GetView<CreatePetProfileController> {
  const CreatePetProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreatePetProfileController>()) {
      Get.put(CreatePetProfileController());
    }

    return AppScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(24.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Content Group
                    Column(
                      children: [
                        addSpacer(R.height(24)),
                        
                        // Top Text
                        Text(
                          "Create a pet profile",
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF525252),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        addSpacer(R.height(4)),
                        
                        // Header Text
                        Text(
                          "Lets get to know your pet",
                          style: AppTypography.h5.copyWith(
                            color: const Color(0xFF0A0A0A),
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        addSpacer(R.height(40)),
                        
                        // Image Upload Container
                        Obx(() => GestureDetector(
                          onTap: controller.pickImage,
                          child: CustomPaint(
                            painter: DashedCirclePainter(
                              color: const Color(0xFFA1A1A1),
                              strokeWidth: 0.578,
                              dashSpace: 5,
                              dashWidth: 5,
                            ),
                            child: Container(
                              width: R.width(100),
                              height: R.width(100),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: controller.pickedImagePath.value != null
                                  ? Image.file(
                                      File(controller.pickedImagePath.value!),
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: SvgPicture.string(
                                        '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none">
                                          <path d="M11.001 19.002V13.002H5C4.44772 13.002 4 12.5543 4 12.002C4 11.4498 4.44772 11.002 5 11.002H11.001V5.00009C11.001 4.44781 11.4487 4.00009 12.001 4.00009C12.5533 4.0001 13.001 4.44781 13.001 5.00009V11.002H19.002L19.1045 11.0069C19.6086 11.0583 20.002 11.4844 20.002 12.002C20.002 12.5197 19.6086 12.9458 19.1045 12.9972L19.002 13.002H13.001V19.002C13.001 19.5543 12.5533 20.002 12.001 20.002C11.4487 20.002 11.001 19.5543 11.001 19.002Z" fill="#525252"/>
                                        </svg>''',
                                        width: R.width(24),
                                        height: R.width(24),
                                      ),
                                    ),
                            ),
                          ),
                        )),
                        
                        addSpacer(R.height(8)),
                        
                        // Upload Text
                        Text(
                          "Upload a picture",
                          style: AppTypography.bodySm.copyWith(
                            color: const Color(0xFF525252),
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        addSpacer(R.height(40)),
                        
                        // Form Fields
                        AppTextFormField(
                          label: "Type",
                          hintText: "Dog",
                          showPrefixIcon: false,
                          type: FormFieldType.name,
                          enabled: false,
                        ),
                        
                        addSpacer(R.height(20)),
                        
                        AppTextFormField(
                          label: "Name",
                          hintText: "Example: Tommy",
                          controller: controller.nameController,
                          showPrefixIcon: false,
                          type: FormFieldType.name,
                        ),
                        
                        addSpacer(R.height(20)),
                        
                        AppTextFormField(
                          label: "Age in human year",
                          hintText: "Example: 3",
                          controller: controller.ageController,
                          showPrefixIcon: false,
                          type: FormFieldType.number,
                        ),
                        
                        addSpacer(R.height(20)),
                        
                        // Breed Dropdown (Custom implementation matching AppTextFormField style)
                        _buildDropdownField(),
                      ],
                    ),
                    
                    // Bottom Button Group
                    Column(
                      children: [
                        addSpacer(R.height(20)),
                        AppMaterialButton(
                          label: "Lets begin",
                          onPressed: controller.onLetsBegin,
                          borderRadius: 999,
                          height: R.height(56),
                          backgroundColor: const Color(0xFF7F67CB),
                          textColor: Colors.white,
                        ),
                        addSpacer(R.height(40)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownField() {
    return Obx(() {
      final border = Border.all(
        color: const Color(0xFFD8D9DD),
        width: 1,
      );

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: border,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Breed",
              style: AppTypography.bodyXs.copyWith(color: const Color(0xFF0A0A0A)),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: controller.selectedBreed.value,
                hint: Text(
                  "Select breed",
                  style: AppTypography.bodySm.copyWith(color: const Color(0xFFA1A1A1)),
                ),
                isExpanded: true,
                isDense: true,
                icon: SvgPicture.string(
                  '''<svg xmlns="http://www.w3.org/2000/svg" width="14" height="8" viewBox="0 0 14 8" fill="none">
                    <path d="M13.5932 0.194861C14.0378 0.522371 14.1328 1.14837 13.8053 1.59306C13.5509 1.93847 13.2965 2.2668 13.0733 2.5528C12.6278 3.1236 12.0145 3.8882 11.3481 4.6556C10.6861 5.4181 9.95204 6.2064 9.26684 6.8119C8.92534 7.1136 8.57234 7.3911 8.22814 7.5986C7.91144 7.7895 7.47624 8 7.00014 8C6.52404 8 6.08874 7.7895 5.77204 7.5986C5.42784 7.3911 5.07494 7.1136 4.73344 6.8119C4.04815 6.2064 3.31411 5.4181 2.65207 4.6556C1.98572 3.8882 1.3724 3.1236 0.926884 2.5528C0.703714 2.2668 0.449264 1.93847 0.194874 1.59307C-0.132636 1.14837 -0.0376465 0.522371 0.407044 0.194861C0.585804 0.0632008 0.793864 -0.000169659 1.00006 3.4111e-07H7.00014H13.0001C13.2063 -0.000169659 13.4144 0.0632008 13.5932 0.194861Z" fill="#0A0A0A"/>
                  </svg>'''
                ),
                style: AppTypography.bodySm.copyWith(
                  color: Theme.of(Get.context!).colorScheme.onSurface,
                ),
                items: controller.breeds.map((String breed) {
                  return DropdownMenuItem<String>(
                    value: breed,
                    child: Text(breed),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  controller.selectedBreed.value = newValue;
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final perimeter = rect.width * math.pi;
    
    final dashCount = (perimeter / (dashWidth + dashSpace)).floor();
    final sweepAngle = (dashWidth / perimeter) * 2 * math.pi;
    final spaceAngle = (dashSpace / perimeter) * 2 * math.pi;

    double startAngle = 0;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
