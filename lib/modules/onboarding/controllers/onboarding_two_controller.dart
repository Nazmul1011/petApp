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
  final RxBool isPlaying = false.obs;

  // Waveform data
  final RxList<double> waveformValues = RxList<double>.filled(75, 0.1);
  Timer? _waveformTimer;
  Timer? _listeningTimer;

  // Sound wave animation
  final Rx<double> soundWaveAnimation = 0.0.obs;
  Timer? _soundWaveTimer;

  // Track repeat/replay button presses
  final RxInt replayCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get pet from previous screen or default to dog
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
    
    // Listen for player completion to stop animation
    _player.onPlayerComplete.listen((event) {
      isPlaying.value = false;
      _waveformTimer?.cancel();
      _soundWaveTimer?.cancel();
    });
  }

  @override
  void onClose() {
    _waveformTimer?.cancel();
    _soundWaveTimer?.cancel();
    _listeningTimer?.cancel();
    _player.dispose();
    super.onClose();
  }

  void startListening() {
    if (voiceState.value != VoiceState.idle) return;

    voiceState.value = VoiceState.listening;
    HapticFeedback.mediumImpact();

    // Start waveform animation (Live Mic look)
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final random = Random();
      waveformValues.value = List.generate(
        75,
        (index) => 0.2 + random.nextDouble() * 0.8,
      );
    });

    // Auto-stop after 3 seconds
    _listeningTimer?.cancel();
    _listeningTimer = Timer(const Duration(seconds: 3), () {
      stopListening();
    });
  }

  void stopListening() {
    if (voiceState.value != VoiceState.listening) return;

    _listeningTimer?.cancel();
    _waveformTimer?.cancel();
    voiceState.value = VoiceState.processing;
    HapticFeedback.lightImpact();

    // After a short "processing" delay, show result and play sound
    Future.delayed(const Duration(milliseconds: 800), () {
      voiceState.value = VoiceState.result;
      _playPetResult();
    });
  }

  void replayVoice() {
    if (isPlaying.value) return;
    _playPetResult();

    replayCount.value++;
    if (replayCount.value >= 3) {
      completeOnboarding();
    }
  }

  void _playPetResult() async {
    isPlaying.value = true;
    HapticFeedback.heavyImpact();

    // Play real pet sound
    final sound = selectedPet.value == PetType.cat
        ? 'audio/meow_1.wav'
        : 'audio/bark_1.wav';
    try {
      await _player.stop();
      await _player.play(AssetSource(sound));
    } catch (e) {
      // Log error silently
    }

    // Initialize waveform values with active random values immediately
    final random = Random();
    waveformValues.value = List.generate(
      75,
      (index) => 0.2 + random.nextDouble() * 0.8,
    );

    // Start yellow sound wave animation (Top pet head)
    _soundWaveTimer?.cancel();
    _soundWaveTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      soundWaveAnimation.value += 0.05;
      if (soundWaveAnimation.value >= 1.0) {
        soundWaveAnimation.value = 0.0;
      }
    });

    // Start "Flowing" waveform animation (Bottom bar)
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final random = Random();
      // Shift values to the left to create 'flow'
      final newList = List<double>.from(waveformValues);
      newList.removeAt(0);
      newList.add(0.3 + random.nextDouble() * 0.6);
      waveformValues.value = newList;
    });
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
