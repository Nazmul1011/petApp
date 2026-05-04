import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/core/routes/app_routes.dart';
import '../../modules/auth/controllers/auth_controller.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(24),
          vertical: R.height(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/header_logo.png', height: R.height(40)),
            Obx(() {
              final user = AuthController.to.user.value;
              final isPremium = user?.isPremium ?? false;
              final pets = user?.pets ?? [];
              final activePetId = user?.activePetId;

              dynamic activePet;
              if (activePetId != null) {
                activePet = pets.firstWhereOrNull(
                  (p) => p['id'] == activePetId,
                );
              }

              String avatarAsset = 'assets/images/dog image.png';
              if (activePet != null && activePet['type'] == 'CAT') {
                avatarAsset = 'assets/images/cat image.png';
              }

              return Row(
                children: [
                  if (!isPremium) ...[
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.subscription),
                      child: Container(
                        padding: EdgeInsets.all(R.width(8)),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFFF7EA),
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          color: Color(0xFFFF9900),
                          size: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: R.width(12)),
                  ],
                  PopupMenuButton<String>(
                    offset: Offset(0, R.height(50)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    elevation: 4,
                    constraints: BoxConstraints(
                      minWidth: R.width(200),
                      maxWidth: R.width(240),
                    ),
                    onSelected: (petId) {
                      if (petId == 'add_new') {
                        Get.toNamed(AppRoutes.addPet);
                      } else {
                        AuthController.to.switchPet(petId);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      if (pets.isEmpty) {
                        return [
                          const PopupMenuItem<String>(
                            enabled: false,
                            value: '',
                            child: Text("No pets found"),
                          ),
                        ];
                      }

                      return [
                        ...pets.map((pet) {
                          final isSelected = pet['id'] == activePetId;
                          final assetPath = pet['type'] == 'CAT'
                              ? 'assets/images/cat image.png'
                              : 'assets/images/dog image.png';

                          return PopupMenuItem<String>(
                            value: pet['id'],
                            padding: EdgeInsets.zero,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: R.width(16),
                                vertical: R.height(8),
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFF4F0FB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: EdgeInsets.symmetric(
                                horizontal: R.width(8),
                                vertical: R.height(4),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: R.width(36),
                                    height: R.width(36),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF7F67CB)
                                            : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage(assetPath),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: R.width(12)),
                                  Expanded(
                                    child: Text(
                                      pet['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check,
                                      color: Color(0xFF7F67CB),
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ];
                    },
                    child: Row(
                      children: [
                        Container(
                          width: R.width(36),
                          height: R.width(36),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF7F67CB),
                              width: 1.5,
                            ),
                            image: DecorationImage(
                              image: AssetImage(avatarAsset),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
