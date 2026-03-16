import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class AppDrawer extends StatelessWidget {
  final String name;
  final String phone;
  final String pic;
  final String localPic;

  const AppDrawer({
    super.key,
    required this.name,
    required this.phone,
    required this.pic,
    required this.localPic,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListTileTheme(
        textColor: Colors.white,
        iconColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: R.width(128.0),
              height: R.width(128.0),
              margin: EdgeInsets.only(
                top: R.height(24.0),
                bottom: R.height(48.0),
              ),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: localPic.isNotEmpty
                  ? Image.file(File(localPic), fit: BoxFit.cover)
                  : pic.isNotEmpty
                      ? Image.network(pic, fit: BoxFit.cover)
                      : const Icon(Icons.person, color: Colors.white, size: 60),
            ),
            Text(
              name,
              style: AppTypography.h5.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            Text(
              phone,
              style: AppTypography.bodySm.copyWith(color: Colors.white70),
            ),
            SizedBox(height: R.height(40)),
            _buildDrawerItem(Icons.home, 'Home', () {}),
            _buildDrawerItem(Icons.person, 'Profile', () {}),
            _buildDrawerItem(Icons.settings, 'Settings', () {}),
            _buildDrawerItem(Icons.help_outline, 'Help & Feedback', () {}),
            const Spacer(),
            _buildDrawerItem(Icons.logout, 'Logout', () {}),
            SizedBox(height: R.height(16)),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, size: R.width(24)),
      title: Text(
        label,
        style: AppTypography.bodyMd.copyWith(color: Colors.white),
      ),
    );
  }
}
