import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:image_picker/image_picker.dart';

class CreatePetProfileController extends GetxController with BaseController {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  
  final selectedType = 'Dog'.obs;
  final selectedBreed = RxnString();
  final pickedImagePath = RxnString();
  
  final _picker = ImagePicker();

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        pickedImagePath.value = image.path;
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  final breeds = <String>[
    'Pitbull',
    'Labrador',
    'Golden Retriever',
    'Bulldog',
    'Beagle',
    'Poodle',
    'Rottweiler',
  ];

  @override
  void onClose() {
    nameController.dispose();
    ageController.dispose();
    super.onClose();
  }

  void onLetsBegin() {
    // Proceed to next step
  }
}
