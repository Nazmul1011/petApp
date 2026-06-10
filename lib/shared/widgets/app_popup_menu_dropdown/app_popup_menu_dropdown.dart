import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class AppPopupMenuDropdown extends StatelessWidget {
  final String labelText;
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String?> onChanged;
  final double? dropdownWidth;

  const AppPopupMenuDropdown({
    super.key,
    required this.labelText,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.dropdownWidth,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = const TextStyle(
      color: Color(0xFF737373),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    final valueStyle = const TextStyle(
      color: Colors.black,
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = dropdownWidth ?? constraints.maxWidth;

        return PopupMenuButton<String>(
          offset: Offset(0, R.height(58)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          elevation: 4,
          constraints: BoxConstraints(
            minWidth: width,
            maxWidth: width,
          ),
          onSelected: (String val) {
            onChanged(val);
          },
          itemBuilder: (BuildContext context) {
            return items.map((String item) {
              final isSelected = item == selectedValue;
              return PopupMenuItem<String>(
                value: item,
                padding: EdgeInsets.zero,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: R.width(16),
                    vertical: R.height(12),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF4F0FB) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: R.width(8),
                    vertical: R.height(4),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryColor : Colors.black87,
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 58.0),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: AppColors.inputBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        labelText,
                        style: labelStyle,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        selectedValue,
                        style: valueStyle,
                      ),
                    ],
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
        );
      },
    );
  }
}
