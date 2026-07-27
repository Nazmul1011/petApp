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

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final tab = Get.arguments['tab'];
      if (tab != null && tab is int) {
        selectedTabIndex.value = tab;
      }
    }
  }

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  // Texts for Privacy Policy
  final List<LegalSection> privacyContent = [
    LegalSection(
      heading: '1. Introduction',
      body:
          'This Privacy Policy explains how PawTranslator (“we”, “us”, or “our”) collects, uses, stores, and shares information when you use the PawTranslator mobile application and related services (the “Service”).\n\nBy using PawTranslator, you agree to this Privacy Policy. If you do not agree, please do not use the Service.\n\nLast updated: July 26, 2026.',
    ),
    LegalSection(
      heading: '2. Who we are',
      body:
          'PawTranslator is a pet communication app that helps you translate pet sounds, talk with your pet, explore emotions, use training tools, whistle features, and manage pet profiles.\n\nFor privacy questions, contact us through the Support option in the app or email Tanjim@gr8rstudio.com.',
    ),
    LegalSection(
      heading: '3. Information we collect',
      body:
          'We may collect the following categories of information:\n\n• Account and device identifiers: a device-based account ID (game ID), authentication tokens, app version, platform (iOS/Android), and device push token.\n• Pet profile data: pet name, type, breed, age/birthday, gender, notes, and profile photos you upload.\n• Content you create: voice recordings, speech-to-text results, talk/translations, saved talks, mood/emotion selections, training progress, and related usage history.\n• Subscription and trial data: free-trial status, subscription plan status, purchase/validation references from our payment providers, and feature usage limits.\n• Notifications data: push notification tokens and notification delivery/read status for in-app alerts.\n• Technical and diagnostics data: app logs, crash/error information, network status, and basic analytics needed to operate and improve the Service.\n• Support communications: messages you send us for help or feedback.',
    ),
    LegalSection(
      heading: '4. Permissions we request',
      body:
          'Depending on how you use PawTranslator, the app may request:\n\n• Microphone — to record pet sounds and your voice for translation and speech features.\n• Speech recognition — to convert your speech into text.\n• Camera / Photo library — to take or select pet profile photos.\n• Notifications — to send reminders, product updates, and service messages.\n• Network access — to sync your data with our servers.\n\nYou can change most permissions in your device settings. Some features will not work without the related permission.',
    ),
    LegalSection(
      heading: '5. How we use your information',
      body:
          'We use your information to:\n\n• Create and manage your account and pet profiles.\n• Provide translation, talk, emotion, whistle, training, and history features.\n• Enforce free-tier, free-trial, and subscription limits.\n• Send push notifications you allow.\n• Improve accuracy, reliability, and user experience.\n• Detect abuse, troubleshoot issues, and keep the Service secure.\n• Comply with legal obligations and respond to support requests.',
    ),
    LegalSection(
      heading: '6. AI and processing of voice/content',
      body:
          'Some features may process audio, text, or related content using our backend systems and third-party AI/cloud services to generate translations, classifications, or responses.\n\nWe process this content only to provide the feature you requested and to improve the Service. Do not upload content you are not allowed to share.',
    ),
    LegalSection(
      heading: '7. How we share information',
      body:
          'We do not sell your personal information. We may share information with:\n\n• Service providers that help us run the app (hosting, databases, analytics, crash reporting, push delivery such as Firebase Cloud Messaging, and payment/subscription providers).\n• Professional advisors or authorities when required by law or to protect rights, safety, and security.\n• A successor entity if we are involved in a merger, acquisition, or asset transfer, subject to this Policy or equivalent protections.\n\nThese providers are allowed to process data only for services they perform for us.',
    ),
    LegalSection(
      heading: '8. Payments and subscriptions',
      body:
          'If you start a free trial or purchase a subscription, payment processing may be handled by Apple, Google, and/or our payment partners. We receive subscription status and related validation data needed to unlock features. We do not store your full payment card details on our servers.',
    ),
    LegalSection(
      heading: '9. Data retention',
      body:
          'We keep your information for as long as needed to provide the Service, maintain your account, meet legal/accounting requirements, resolve disputes, and enforce our agreements.\n\nYou may request deletion of your account or certain data by contacting support. Some records may be retained where we are legally required to keep them.',
    ),
    LegalSection(
      heading: '10. Security',
      body:
          'We use reasonable technical and organizational measures to protect your information, including encrypted transport (HTTPS) and access controls. No method of transmission or storage is 100% secure, so we cannot guarantee absolute security.',
    ),
    LegalSection(
      heading: '11. Children’s privacy',
      body:
          'PawTranslator is not directed to children under 13 (or the minimum age required in your country). We do not knowingly collect personal information from children. If you believe a child has provided us personal data, contact us and we will take appropriate steps to delete it.',
    ),
    LegalSection(
      heading: '12. International transfers',
      body:
          'Your information may be processed on servers located in countries other than your own. Where required, we take steps to ensure appropriate safeguards for such transfers.',
    ),
    LegalSection(
      heading: '13. Your rights',
      body:
          'Depending on your location, you may have rights to access, correct, delete, or export your personal data, object to or restrict certain processing, and withdraw consent where processing is based on consent.\n\nTo exercise these rights, contact us through in-app Support or Tanjim@gr8rstudio.com. You may also have the right to lodge a complaint with your local data protection authority.',
    ),
    LegalSection(
      heading: '14. Changes to this Privacy Policy',
      body:
          'We may update this Privacy Policy from time to time. We will post the updated version in the app and update the “Last updated” date. Continued use of the Service after changes means you accept the updated Policy.',
    ),
    LegalSection(
      heading: '15. Contact',
      body:
          'PawTranslator / Gr8r Design\nEmail: Tanjim@gr8rstudio.com\nIn-app: More → Support',
    ),
  ];

  // Texts for Terms and Conditions
  final List<LegalSection> termsContent = [
    LegalSection(
      heading: '1. Agreement to these Terms',
      body:
          'These Terms and Conditions (“Terms”) govern your use of the PawTranslator mobile application and related services (the “Service”). By downloading, accessing, or using PawTranslator, you agree to these Terms and our Privacy Policy.\n\nIf you do not agree, do not use the Service.\n\nLast updated: July 26, 2026.',
    ),
    LegalSection(
      heading: '2. The Service',
      body:
          'PawTranslator provides pet-related communication and engagement tools, including (depending on your plan and availability):\n\n• Pet sound / voice translation and talk features\n• Emotion and mood tools\n• Whistle and training features\n• Pet profiles, saved talks, and history\n• Notifications and related content\n\nFeatures may change, improve, or be limited over time. Some outputs are AI-assisted and may be inaccurate or incomplete.',
    ),
    LegalSection(
      heading: '3. Eligibility and accounts',
      body:
          'You must be legally able to enter into these Terms in your country. If you use the Service on behalf of someone else, you confirm you have authority to accept these Terms for them.\n\nPawTranslator may create or restore an account using a device-based identifier. You are responsible for activity on your account and for keeping your device secure.',
    ),
    LegalSection(
      heading: '4. Free tier, free trial, and subscriptions',
      body:
          'The Service may include:\n\n• A free tier with limited daily/feature usage\n• A one-time free trial with limited sample access (not a full Pro unlock)\n• Paid subscription plans for broader/unlimited access\n\nTrial availability, duration, and limits are shown in the app and enforced by our servers. Starting a free trial or subscription may be required to access certain features.\n\nPaid subscriptions renew according to the terms shown at purchase (for example, yearly plans). Prices and offers may vary by region and storefront. Unless cancelled according to the platform rules (Apple App Store / Google Play) or our checkout flow, renewals may continue automatically where applicable.\n\nRefunds are handled under Apple, Google, and/or our payment partner policies, as applicable.',
    ),
    LegalSection(
      heading: '5. Acceptable use',
      body:
          'You agree not to:\n\n• Misuse the Service, attempt to bypass usage limits, or interfere with servers/security\n• Upload unlawful, harmful, infringing, or abusive content\n• Reverse engineer, scrape, or copy the Service except as allowed by law\n• Use the Service for medical, veterinary, emergency, or safety-critical decisions\n• Impersonate others or misuse another person’s content or pets\n\nWe may suspend or terminate access if you violate these Terms.',
    ),
    LegalSection(
      heading: '6. Your content',
      body:
          'You keep ownership of content you submit (such as recordings, photos, and text). You grant us a worldwide, non-exclusive license to host, process, and use that content as needed to operate, secure, and improve the Service.\n\nYou represent that you have the rights needed to submit the content and that it does not violate any law or third-party rights.',
    ),
    LegalSection(
      heading: '7. AI-generated and informational nature',
      body:
          'Translations, emotion insights, training suggestions, and similar outputs are for entertainment and general informational purposes only. They are not veterinary advice, behavioral certification, or a guarantee of accuracy.\n\nAlways use your own judgment and consult a qualified professional for health or serious behavior concerns.',
    ),
    LegalSection(
      heading: '8. Intellectual property',
      body:
          'PawTranslator, including its software, design, branding, audio assets, and content we provide, is owned by us or our licensors and protected by intellectual property laws. Except for the limited right to use the Service, no rights are granted to you.',
    ),
    LegalSection(
      heading: '9. Third-party services',
      body:
          'The Service may rely on third parties such as cloud hosting, Firebase/push providers, AI providers, and payment platforms. Their terms and privacy practices may also apply when you use those services through PawTranslator.',
    ),
    LegalSection(
      heading: '10. Disclaimers',
      body:
          'THE SERVICE IS PROVIDED “AS IS” AND “AS AVAILABLE.” TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.\n\nWe do not warrant that the Service will be uninterrupted, error-free, or that results will meet your expectations.',
    ),
    LegalSection(
      heading: '11. Limitation of liability',
      body:
          'TO THE MAXIMUM EXTENT PERMITTED BY LAW, WE AND OUR AFFILIATES, OFFICERS, EMPLOYEES, AND PARTNERS WILL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF DATA, PROFITS, OR GOODWILL.\n\nOUR TOTAL LIABILITY FOR ANY CLAIM RELATING TO THE SERVICE WILL NOT EXCEED THE AMOUNT YOU PAID US FOR THE SERVICE IN THE 12 MONTHS BEFORE THE CLAIM (OR, IF YOU PAID NOTHING, USD \$50).',
    ),
    LegalSection(
      heading: '12. Termination',
      body:
          'You may stop using the Service at any time. We may suspend or end access if you breach these Terms, if required by law, or if we discontinue the Service.\n\nSections that by nature should survive (including intellectual property, disclaimers, liability limits, and governing law) will survive termination.',
    ),
    LegalSection(
      heading: '13. Changes to the Service or Terms',
      body:
          'We may update the Service and these Terms from time to time. Updated Terms will be shown in the app with a revised date. Continued use after changes means you accept the updated Terms. If you do not agree, stop using the Service.',
    ),
    LegalSection(
      heading: '14. Governing law',
      body:
          'These Terms are governed by the laws applicable to our business operations, without regard to conflict-of-law rules, unless mandatory consumer laws in your country provide otherwise. Courts in that jurisdiction will have exclusive venue, subject to any non-waivable consumer rights.',
    ),
    LegalSection(
      heading: '15. Contact',
      body:
          'Questions about these Terms:\nPawTranslator / Gr8r Design\nEmail: Tanjim@gr8rstudio.com\nIn-app: More → Support',
    ),
  ];
}
