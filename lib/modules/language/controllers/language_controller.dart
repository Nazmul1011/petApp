import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';

class LanguageModel {
  final String id;
  final String name;
  final String nativeName;
  final String flagAsset;

  LanguageModel({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.flagAsset,
  });
}

class LanguageController extends GetxController with BaseController {
  // Predefined list from the provided image
  final List<LanguageModel> languages = [
    LanguageModel(id: 'en_uk', name: 'English', nativeName: 'English(UK)', flagAsset: 'assets/images/country_icon/UK.svg'),
    LanguageModel(id: 'en_us', name: 'English', nativeName: 'English(US)', flagAsset: 'assets/images/country_icon/US.svg'),
    LanguageModel(id: 'bn', name: 'Bangla', nativeName: 'Bangla', flagAsset: 'assets/images/country_icon/bangla.svg'),
    LanguageModel(id: 'de', name: 'Deutsch', nativeName: 'German', flagAsset: 'assets/images/country_icon/german.svg'),
    LanguageModel(id: 'fr', name: 'Français', nativeName: 'French', flagAsset: 'assets/images/country_icon/francois.svg'),
    LanguageModel(id: 'es', name: 'Espanol', nativeName: 'Spanish', flagAsset: 'assets/images/country_icon/espanol.svg'),
    LanguageModel(id: 'it', name: 'Italiano', nativeName: 'Italian', flagAsset: 'assets/images/country_icon/italiano.svg'),
  ];

  // Store the selected language ID (default to en_uk as per image)
  final RxString selectedLanguageId = 'en_uk'.obs;

  void selectLanguage(String id) {
    selectedLanguageId.value = id;
  }

  void continueWithSelection() {
    final selected = languages.firstWhere((element) => element.id == selectedLanguageId.value);
    Get.log('User selected primary language: ${selected.name} (${selected.nativeName})');
    // Implement navigation or next steps here
    // Get.offAllNamed(AppRoutes.onboarding); // example
  }
}
