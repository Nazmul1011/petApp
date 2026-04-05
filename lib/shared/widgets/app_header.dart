import 'package:flutter/material.dart';
import 'package:petapp/shared/helpers/responsive.dart';

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
            Image.asset(
              'assets/images/Logo_image.png',
              height: R.height(40),
            ),
            Row(
              children: [
                Container(
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
                SizedBox(width: R.width(12)),
                Container(
                  width: R.width(36),
                  height: R.width(36),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/dog image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
