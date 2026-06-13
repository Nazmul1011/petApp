import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/more_controller.dart';
import '../../mood_history/views/mood_history_view.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "More",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(20),
          vertical: R.height(16),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: R.width(16),
          crossAxisSpacing: R.width(16),
          childAspectRatio: 0.95,
          children: [
            _buildGridItem(
              imagePath: "assets/images/icon/pet_profile.png",
              label: "Pet profile",
              iconColor: const Color(0xFF8B78E6),
              bgColor: const Color(0xFF8B78E6).withValues(alpha: 0.12),
              onTap: () => Get.toNamed(AppRoutes.petProfile),
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/mood_history.png",
              label: "Mood History",
              iconColor: const Color(0xFFFF8A65),
              bgColor: const Color(0xFFFF8A65).withValues(alpha: 0.12),
              onTap: () => Get.to(() => const MoodHistoryView()),
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Saved_talk.png",
              label: "Saved Talks",
              iconColor: const Color(0xFFF06292),
              bgColor: const Color(0xFFF06292).withValues(alpha: 0.12),
              onTap: () => Get.toNamed(AppRoutes.savedTalks),
            ),
            // _buildGridItem(
            //   imagePath: "assets/images/icon/Language.png",
            //   label: "Language",
            //   iconColor: const Color(0xFF4DB6AC),
            //   bgColor: const Color(0xFF4DB6AC).withValues(alpha: 0.12),
            //   onTap: () => Get.toNamed(AppRoutes.language),
            // ),
            _buildGridItem(
              imagePath: "assets/images/icon/Subscription.png",
              label: "Subscription",
              iconColor: const Color(0xFF4DD0E1),
              bgColor: const Color(0xFF4DD0E1).withValues(alpha: 0.12),
              onTap: () => Get.toNamed(AppRoutes.subscription),
            ),
            // _buildGridItem(
            //   imagePath: "assets/images/icon/Others.png",
            //   label: "Others",
            //   iconColor: const Color(0xFFFFB300),
            //   bgColor: const Color(0xFFFFB300).withValues(alpha: 0.12),
            //   onTap: () {},
            // ),
            _buildGridItem(
              imagePath: "assets/images/icon/Support.png",
              label: "Support",
              iconColor: const Color(0xFFFF8A65),
              bgColor: const Color(0xFFFF8A65).withValues(alpha: 0.12),
              onTap: () => controller.launchEmailSupport(),
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Rate_Us.png",
              label: "Rate us",
              iconColor: const Color(0xFFFFB300),
              bgColor: const Color(0xFFFFB300).withValues(alpha: 0.12),
              onTap: () => _showRateUsSheet(context),
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Share_app.png",
              label: "Share app",
              iconColor: const Color(0xFF5C6BC0),
              bgColor: const Color(0xFF5C6BC0).withValues(alpha: 0.12),
              onTap: () {
                Share.share(
                  'Check out the PawLingo app! It helps you communicate with your pet.',
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRateUsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _RateUsBottomSheet(
          onSubmit: () {
            Get.back();
            controller.launchRateUs();
          },
        ),
      ),
    );
  }

  Widget _buildGridItem({
    IconData? icon,
    Widget? customIcon,
    String? imagePath,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.15),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.width(48),
              height: R.width(48),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      )
                    : (customIcon ?? Icon(icon, color: iconColor, size: 24)),
              ),
            ),
            SizedBox(height: R.height(12)),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _RateUsBottomSheet extends StatefulWidget {
  final VoidCallback onSubmit;
  const _RateUsBottomSheet({required this.onSubmit});

  @override
  State<_RateUsBottomSheet> createState() => _RateUsBottomSheetState();
}

class _RateUsBottomSheetState extends State<_RateUsBottomSheet> {
  int _rating = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: R.width(24),
        vertical: R.height(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: R.width(48),
              height: R.height(4),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: R.height(24)),
          const Text(
            "Rate us",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: R.height(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isFilled = starIndex <= _rating;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(right: R.width(12)),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFF7A00),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: R.height(24)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: R.width(16),
              vertical: R.height(12),
            ),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your thoughts",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: R.height(4)),
                TextField(
                  maxLines: 3,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: "Details",
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: R.height(24)),
          AppMaterialButton(
            label: "Submit",
            onPressed: widget.onSubmit,
            height: R.height(56),
            borderRadius: 28,
            backgroundColor: const Color(0xFF6C3BAA),
          ),
          SizedBox(height: R.height(20)),
        ],
      ),
    );
  }
}
