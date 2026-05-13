import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';

class MoreController extends GetxController with BaseController {
  final String supportEmail = "support@example.com";
  final String appleAppId = "YOUR_APP_ID_HERE"; // e.g. 6443831968

  Future<void> launchEmailSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      query: 'subject=Support Request - PetApp',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        showSnack(
          content: "Could not open email app. Please email us at $supportEmail",
          status: SnackBarStatus.error,
        );
      }
    } catch (e) {
      showSnack(
        content: "An unexpected error occurred while trying to open the email app.",
        status: SnackBarStatus.error,
      );
    }
  }

  Future<void> launchRateUs() async {
    final Uri url = Uri.parse(
      'https://apps.apple.com/app/id$appleAppId?action=write-review',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        showSnack(
          content: "Could not open App Store.",
          status: SnackBarStatus.error,
        );
      }
    } catch (e) {
      showSnack(
        content: "An unexpected error occurred while trying to open the App Store.",
        status: SnackBarStatus.error,
      );
    }
  }
}
