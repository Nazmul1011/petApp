import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';

enum VoiceState { idle, listening, processing, result }

class OnboardingTwoController extends GetxController with BaseController {
  final Rx<VoiceState> voiceState = VoiceState.idle.obs;
  final Rx<PetType> selectedPet = PetType.none.obs;
  final AudioPlayer _player = AudioPlayer();

  // Waveform data
  final RxList<double> waveformValues = RxList<double>.filled(75, 0.1);
  Timer? _waveformTimer;

  // Sound wave animation
  final Rx<double> soundWaveAnimation = 0.0.obs;
  Timer? _soundWaveTimer;

  @override
  void onInit() {
    super.onInit();
    // Get pet from previous screen or default to dog
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
  }

  @override
  void onClose() {
    _waveformTimer?.cancel();
    _soundWaveTimer?.cancel();
    _player.dispose();
    super.onClose();
  }

  void startListening() {
    if (voiceState.value != VoiceState.idle) return;

    voiceState.value = VoiceState.listening;
    HapticFeedback.mediumImpact();

    // Start waveform animation
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final random = Random();
      waveformValues.value = List.generate(
        75,
        (index) => 0.2 + random.nextDouble() * 0.8,
      );
    });
  }

  void stopListening() {
    if (voiceState.value != VoiceState.listening) return;

    _waveformTimer?.cancel();
    voiceState.value = VoiceState.processing;
    HapticFeedback.lightImpact();

    // After a short "processing" delay, show result and play sound
    Future.delayed(const Duration(milliseconds: 800), () {
      voiceState.value = VoiceState.result;
      _playPetResult();
    });
  }

  void _playPetResult() async {
    HapticFeedback.heavyImpact();

    // Play real pet sound
    final sound = selectedPet.value == PetType.cat ? 'audio/meow_1.wav' : 'audio/bark_1.wav';
    try {
      await _player.stop();
      await _player.play(AssetSource(sound));
    } catch (e) {
      print("[Onboarding Step 2] Error playing sound: $e");
    }

    // Start yellow sound wave animation
    _soundWaveTimer?.cancel();
    _soundWaveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      soundWaveAnimation.value += 0.05;
      if (soundWaveAnimation.value >= 1.0) {
        soundWaveAnimation.value = 0.0;
      }
    });

    // Reset waveform to fixed bars for the result container
    // About 15 groups of 5
    waveformValues.value = List.generate(
      75,
      (i) => 0.4 + Random().nextDouble() * 0.5,
    );
  }

  String get titleText {
    final petName = selectedPet.value == PetType.dog ? 'dog' : 'cat';
    return "Let's talk to your $petName";
  }

  String get petImagePath {
    return selectedPet.value == PetType.dog
        ? 'assets/images/dog image.png'
        : 'assets/images/cat image.png';
  }

  void completeOnboarding() {
    Get.toNamed(AppRoutes.onboardingThree, arguments: selectedPet.value);
  }

  void skipDemo() {
    // Instead of bypassing everything, we complete onboarding formally 
    // so the AuthController can send the user to the Payment/Pet setup flow.
    AuthController.to.completeOnboarding();
  }
}
