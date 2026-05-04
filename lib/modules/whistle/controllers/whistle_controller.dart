import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:petapp/core/controllers/base_controller.dart';

class WhistleController extends GetxController
    with GetSingleTickerProviderStateMixin, BaseController {
  final RxBool isPlaying = false.obs;
  final RxDouble frequency = 8740.0.obs;

  AudioSource? _waveformSource;
  SoundHandle? _currentHandle;

  late AnimationController pulseController;

  @override
  void onInit() {
    super.onInit();
    pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _initAudioEngine();
  }

  Future<void> _initAudioEngine() async {
    try {
      if (!SoLoud.instance.isInitialized) {
        await SoLoud.instance.init();
      }
    } catch (e) {
      Get.log("Failed to initialize SoLoud: $e");
    }
  }

  Future<void> toggleWhistle() async {
    if (!SoLoud.instance.isInitialized) return;

    if (isPlaying.value) {
      if (_currentHandle != null) {
        SoLoud.instance.stop(_currentHandle!);
        _currentHandle = null;
      }
      pulseController.stop();
      pulseController.value = 0.0;
      isPlaying.value = false;
    } else {
      _waveformSource ??= await SoLoud.instance.loadWaveform(
        WaveForm.sin,
        true,
        0.25,
        1.0,
      );

      if (_waveformSource != null) {
        SoLoud.instance.setWaveformFreq(_waveformSource!, frequency.value);
        _currentHandle = await SoLoud.instance.play(_waveformSource!);
        pulseController.repeat(reverse: true);
        isPlaying.value = true;
      }
    }
  }

  void updateFrequency(double value) {
    frequency.value = value;
    if (isPlaying.value && _waveformSource != null) {
      SoLoud.instance.setWaveformFreq(_waveformSource!, frequency.value);
    }
  }

  @override
  void onClose() {
    if (_currentHandle != null) {
      SoLoud.instance.stop(_currentHandle!);
    }
    pulseController.dispose();
    super.onClose();
  }
}
