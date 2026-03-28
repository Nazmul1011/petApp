import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';

class LegalSection {
  final String heading;
  final String body;

  LegalSection({required this.heading, required this.body});
}

class LegalController extends GetxController with BaseController {
  // 0 -> Privacy Policy, 1 -> Terms and conditions
  final RxInt selectedTabIndex = 0.obs;

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  // Texts for Privacy Policy
  final List<LegalSection> privacyContent = [
    LegalSection(
      heading: 'Data Controllers and Contracting Parties',
      body: 'If you are in the “Designated Countries”, LinkedIn Ireland Unlimited Company will be the controller of your personal data provided to, or collected by or for, or processed in connection with our Services.\nIf you are outside of the Designated Countries, LinkedIn Corporation will be the controller of (or business responsible for) your personal data provided to, or collected by or for, or processed in connection with our Services.\nAs a Visitor or Member of our Services, the collection, use and sharing of your personal data is subject to this Privacy Policy and other documents referenced in this Privacy Policy, as well as updates.',
    ),
    LegalSection(
      heading: 'Registration',
      body: 'You acknowledge that your continued use of our Services after we publish or send a notice about our changes to this Privacy Policy means that the collection, use and sharing of your personal data is subject to the updated Privacy Policy, as of its effective date.',
    ),
    LegalSection(
      heading: 'Posting and Uploading',
      body: 'We collect personal data from you when you provide, post or upload it to our Services, such as when you fill out a form, (e.g., with demographic data or salary), respond to a survey...',
    ),
  ];

  // Texts for Terms and Conditions
  final List<LegalSection> termsContent = [
    LegalSection(
      heading: 'Data Controllers and Contracting Parties',
      body: 'If you are in the “Designated Countries”, LinkedIn Ireland Unlimited Company will be the controller of your personal data provided to, or collected by or for, or processed in connection with our Services.\nIf you are outside of the Designated Countries, LinkedIn Corporation will be the controller of (or business responsible for) your personal data provided to, or collected by or for, or processed in connection with our Services.\nAs a Visitor or Member of our Services, the collection, use and sharing of your personal data is subject to this Privacy Policy and other documents referenced in this Privacy Policy, as well as updates.',
    ),
    LegalSection(
      heading: 'Registration',
      body: 'You acknowledge that your continued use of our Services after we publish or send a notice about our changes to this Privacy Policy means that the collection, use and sharing of your personal data is subject to the updated Privacy Policy, as of its effective date.',
    ),
    LegalSection(
      heading: 'Posting and Uploading',
      body: 'We collect personal data from you when you provide, post or upload it to our Services, such as when you fill out a form, (e.g., with demographic data or salary), respond to a survey...',
    ),
  ];
}
