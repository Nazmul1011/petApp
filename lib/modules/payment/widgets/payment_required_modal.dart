import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class PaymentRequiredModal extends StatelessWidget {
  const PaymentRequiredModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1C1C1E), // Dark gray background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(R.width(20)),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: R.width(20)),
      child: Padding(
        padding: EdgeInsets.all(R.width(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Payment information required",
              style: AppTypography.subtitleLg.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.height(8)),
            Text(
              "To subscribe, add a new payment method. You'll be charged when your trial ends.",
              style: AppTypography.bodySm.copyWith(
                color: Colors.grey[400],
                height: 1.4,
              ),
            ),
            SizedBox(height: R.height(24)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B68FF), // Blue Cancel
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.width(30)),
                      ),
                      padding: EdgeInsets.symmetric(vertical: R.height(14)),
                    ),
                    child: Text(
                      "Cancel",
                      style: AppTypography.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: R.width(12)),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E), // Dark Gray Continue
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(R.width(30)),
                      ),
                      padding: EdgeInsets.symmetric(vertical: R.height(14)),
                    ),
                    child: Text(
                      "Continue",
                      style: AppTypography.labelMd.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
