import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/model_pharse/mood_phrases.dart' as phrases;
import 'package:petapp/core/routes/app_routes.dart';
import '../services/classifier_service.dart';
import '../../talk/services/talk_api_service.dart';
import '../../auth/controllers/auth_controller.dart';

enum TranslationUIState { idle, recording, result }

/// Which mode the user is in (Human speaks → pet sound, or Pet sound → human phrase)
enum PetType { dog, cat }

class DashboardController extends GetxController with BaseController {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ClassifierService classifierService = ClassifierService();
  final TalkApiService _talkApi = TalkApiService();

  // ----- Observable states -----
  final Rx<TranslationUIState> uiState = TranslationUIState.idle.obs;
  final RxBool isHumanToDog = true.obs;
  final RxDouble amplitude = (-160.0).obs;
  final RxString resultText = ''.obs;
  final RxString resultMood = 'happy'.obs;
  final RxString currentRecordingPath = ''.obs;
  final RxString responseAssetPath = ''.obs;
  final Rx<PetType> selectedPet = PetType.dog.obs;
  final RxString voiceLabel = ''.obs;
  final RxBool isSaving = false.obs;
  final RxBool isPlaying = false.obs;
  final RxDouble detectedFrequency = 0.0.obs;
  // Waveform data for OnboardingTwo-style animation
  final RxList<double> waveformValues = List.generate(
    75,
    (index) => 0.7 + (Random().nextDouble() * 0.3),
  ).obs;
  Timer? _waveformTimer;

  // ----- Backend session & translation IDs -----
  String? _sessionId;
  String? _translationId;
  String? _detectedMood;

  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _recordingTimer;

  void _updateSelectedPetFromUser() {
    final user = AuthController.to.user.value;
    final activePetId = user?.activePetId;
    if (activePetId != null) {
      final pets = user?.pets;
      if (pets != null && pets.isNotEmpty) {
        final activePet = pets.firstWhere(
          (p) => p['id'] == activePetId,
          orElse: () => pets.first,
        );
        final typeStr = activePet['type'] as String?;
        if (typeStr == 'CAT') {
          selectedPet.value = PetType.cat;
        } else {
          selectedPet.value = PetType.dog;
        }
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is PetType) {
      selectedPet.value = arg;
    } else {
      _updateSelectedPetFromUser();
    }

    // Listen to changes in the active user's profile to dynamically update selectedPet
    ever(AuthController.to.user, (_) {
      _updateSelectedPetFromUser();
    });

    classifierService.init();
    _initTalkSession();

    _recordSub = audioRecorder.onStateChanged().listen((RecordState state) {
      if (state == RecordState.stop) {
        _stopRecordingTimer();
      }
    });

    _amplitudeSub = audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 50))
        .listen((amp) {
          amplitude.value = amp.current;
        });

    // Sync isPlaying with audio player state
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
      if (isPlaying.value) {
        _startPlaybackAnimation();
      } else {
        _stopPlaybackAnimation();
      }
    });
  }

  Timer? _playbackTimer;
  void _startPlaybackAnimation() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      amplitude.value = -20.0 + Random().nextDouble() * 20.0;

      // Update waveform values for "up and down" movement during playback
      final random = Random();
      final newList = List<double>.from(waveformValues);
      for (int i = 0; i < newList.length; i++) {
        newList[i] = 0.2 + (random.nextDouble() * 0.7);
      }
      waveformValues.value = newList;
    });
  }

  void _stopPlaybackAnimation() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    amplitude.value = -160.0;
    // Reset waveform values to a taller random static state
    final random = Random();
    waveformValues.value = List.generate(
      75,
      (index) => 0.2 + (random.nextDouble() * 0.6),
    );
  }

  // ---------------------------------------------------------------------------
  // Backend session initialisation
  // ---------------------------------------------------------------------------
  Future<void> _initTalkSession() async {
    try {
      final session = await _talkApi.createSession();
      if (session != null) {
        _sessionId = session.id;
        print('[Dashboard] Talk session created: $_sessionId');
      }
    } catch (e) {
      print('[Dashboard] Failed to create talk session: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Mode toggle
  // ---------------------------------------------------------------------------
  void toggleMode() {
    if (uiState.value == TranslationUIState.idle) {
      isHumanToDog.value = !isHumanToDog.value;
    }
  }

  // ---------------------------------------------------------------------------
  // Recording
  // ---------------------------------------------------------------------------
  void startRecording() async {
    if (uiState.value == TranslationUIState.recording) return;
    if (await audioRecorder.hasPermission()) {
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      currentRecordingPath.value = path;

      const config = RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      );

      await audioRecorder.start(config, path: path);
      _recordingStartTime = DateTime.now();
      uiState.value = TranslationUIState.recording;
      _startRecordingTimer();
      _startWaveformAnimation();
      HapticFeedback.mediumImpact();
    }
  }

  DateTime? _recordingStartTime;

  void stopRecording() async {
    if (uiState.value != TranslationUIState.recording) return;

    final duration = DateTime.now().difference(
      _recordingStartTime ?? DateTime.now(),
    );
    _stopWaveformAnimation();
    final path = await audioRecorder.stop();
    if (path != null) {
      if (duration.inMilliseconds < 500) {
        uiState.value = TranslationUIState.idle;
        print('[Dashboard] Recording too short ($duration), ignoring.');
        return;
      }

      currentRecordingPath.value = path;
      print('[Dashboard] Recording stopped, review path: $path');

      if (isHumanToDog.value) {
        // Human to Pet: Navigate to the specialized logo view
        uiState.value = TranslationUIState.idle;
        Get.toNamed(AppRoutes.talkHumanToPet);
        await _processHumanToPet(path);
      } else {
        // Pet to Human: Navigate to the text/waveform result view
        uiState.value = TranslationUIState.idle;
        Get.toNamed(AppRoutes.talkResult);
        await _processPetToHuman(path);
      }
    }
    HapticFeedback.lightImpact();
  }

  void _startWaveformAnimation() {
    _waveformTimer?.cancel();
    _waveformTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      final random = Random();
      // Normalize amplitude for animation scaling (-60dB to 0dB range)
      // We want high sensitivity so small changes in voice are visible
      double normalized = (amplitude.value + 55) / 55;
      normalized = normalized.clamp(0.0, 1.0);

      // Shift values to create flow
      final newList = List<double>.from(waveformValues);
      newList.removeAt(0);

      // New value: baseline + randomness + strong amplitude spike
      double nextValue = 0.1 + (random.nextDouble() * 0.1) + (normalized * 0.8);
      newList.add(nextValue.clamp(0.1, 1.0));

      waveformValues.value = newList;
    });
  }

  void _stopWaveformAnimation() {
    _waveformTimer?.cancel();
    _waveformTimer = null;
    // Reset waveform to idle state slowly or immediately
    waveformValues.value = List.generate(75, (index) => 0.1);
  }

  // ---------------------------------------------------------------------------
  // Human → Pet (user's voice → pet sound translation)
  // ---------------------------------------------------------------------------
  static const List<String> _dogRandomSounds = [
    'audio/dog-barking.mp3',
    'audio/dog-angry.mp3',
    'audio/dog-howl.mp3',
    'audio/dog-unhappy.mp3',
    'audio/dog-yelp.mp3',
    'audio/bark_1.wav',
  ];

  static const List<String> _catRandomSounds = [
    'audio/cat-cute-cat.mp3',
    'audio/cat-excited.mp3',
    'audio/cat-hungry.mp3',
    'audio/cat-purring.mp3',
    'audio/meow_1.wav',
  ];

  final RxString recognizedText = ''.obs;

  Future<void> _processHumanToPet(String path) async {
    setLoading(true);
    try {
      final isDog = selectedPet.value == PetType.dog;

      // 1. Recognize what the human said
      final text = await classifierService.recognizeSpeech(path);
      recognizedText.value = text?.toLowerCase().trim() ?? '';

      if (recognizedText.value.isNotEmpty) {
        resultText.value = 'You said: "${recognizedText.value}"';

        // 2. Check if we have a LEARNED translation for this specific phrase
        final box = GetStorage();
        final String storageKey =
            'learned_${isDog ? "dog" : "cat"}_${recognizedText.value}';
        final savedAsset = box.read<String>(storageKey);

        if (savedAsset != null) {
          responseAssetPath.value = savedAsset;
        } else {
          // 3. No learned phrase? Pick a random sound
          final randomList = isDog ? _dogRandomSounds : _catRandomSounds;
          responseAssetPath.value =
              randomList[Random().nextInt(randomList.length)];
        }

        // 4. Play the resulting pet sound
        playResponse();
      } else {
        // Fallback if no speech recognized
        resultText.value = 'No voice detected';
        responseAssetPath.value = ''; // No sound to play
      }

      // 5. Prepare the Pet Sound file to be saved to the backend (replacing human voice)
      String uploadPath = path;
      try {
        final byteData = await rootBundle.load(
          'assets/${responseAssetPath.value}',
        );
        final buffer = byteData.buffer;
        final tempDir = await getTemporaryDirectory();
        final tempPetSoundFile = File('${tempDir.path}/temp_pet_sound.mp3');
        await tempPetSoundFile.writeAsBytes(
          buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
        );
        uploadPath = tempPetSoundFile.path;
        print('[Dashboard] Prepared pet sound for upload: $uploadPath');
      } catch (e) {
        print('[Dashboard] Error preparing pet sound asset for upload: $e');
      }

      // 6. Background backend logging - Sending the PET sound as the main audio
      if (_sessionId != null) {
        final translation = await _talkApi.createTranslation(
          sessionId: _sessionId!,
          // Use TEXT here so the backend can actually create+store the translation.
          // Sending file:// paths from the phone doesn't work on the server.
          inputType: 'TEXT',
          direction: 'HUMAN_TO_PET',
          inputText: recognizedText.value,
          outputAudioUrl: responseAssetPath.value,
        );
        if (translation != null) {
          _translationId = translation.id;
        }
      }
    } catch (e) {
      print('[Dashboard] HumanToPet error: $e');
    } finally {
      setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Pet → Human (pet sound → english phrase)
  // ---------------------------------------------------------------------------
  Future<void> _processPetToHuman(String path) async {
    setLoading(true);
    try {
      final expectedPetType = selectedPet.value == PetType.dog ? 'dog' : 'cat';

      // Ensure the AI model is actually loaded before trying to use it
      if (!classifierService.isReady) {
        print('[Dashboard] Model not ready, attempting to initialize...');
        await classifierService.init().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print('[Dashboard] Model initialization timed out.');
          },
        );
      }

      // Local ML with frequency analysis and strict check
      final result = await classifierService.classify(path, expectedPetType);

      detectedFrequency.value = result.frequency;
      print(
        '[Dashboard] Classification complete. Freq: ${result.frequency} Hz, Match: ${result.isMatch}',
      );

      if (result.isMatch && result.mood != null) {
        resultMood.value = result.mood!;
        resultText.value = phrases.getPhraseFromMood(result.mood!);
        _detectedMood = result.mood;
        print(
          '[Dashboard] Match found! Mood: ${result.mood}, Freq: ${result.frequency}',
        );
      } else {
        // No match found - explain why for diagnostics
        if (classifierService.hasError) {
          resultText.value =
              "AI Model Error: ${classifierService.initError?.split('\n').first}";
        } else if (result.frequency == 0) {
          resultText.value = "Silence detected";
        } else if (result.detectedPet == 'human') {
          resultText.value = "Human voice blocked";
        } else {
          resultText.value = "No ${expectedPetType} sound detected";
        }

        _detectedMood = null;
        print('[Dashboard] No match. Status: ${resultText.value}');
      }

      // Then send to backend to store the translation record if a match was found
      if (_sessionId != null && result.isMatch) {
        final translation = await _talkApi.createTranslation(
          sessionId: _sessionId!,
          inputType: 'PET_VOICE',
          direction: 'PET_TO_HUMAN',
          inputAudioUrl: 'file://$path',
          inputText: resultMood.value,
          outputText: resultText.value, // The english phrase
        );
        if (translation != null) {
          _translationId = translation.id;
          /* 
          if (translation.outputText != null &&
              translation.outputText!.isNotEmpty) {
            resultText.value = translation.outputText!;
          }
          */
          if (translation.mood != null) {
            _detectedMood = translation.mood;
          }
        }
      }

      // Auto-play the recorded pet sound when the translation finishes
      if (result.isMatch) {
        Future.delayed(const Duration(milliseconds: 500), () {
          playRecording();
        });
      }
    } catch (e) {
      print('[Dashboard] PetToHuman error: $e');
      resultText.value = 'Error processing sound.';
    } finally {
      setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // Save voice to backend
  // ---------------------------------------------------------------------------
  Future<void> pauseAudio() async {
    await audioPlayer.pause();
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
  }

  Future<void> playRecording() async {
    // If we have a translated pet sound, play that!
    if (responseAssetPath.value.isNotEmpty) {
      await audioPlayer.play(AssetSource(responseAssetPath.value));
    }
    // Otherwise play the original recording (for Pet-to-Human mode)
    else if (currentRecordingPath.value.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(currentRecordingPath.value));
    }
  }

  String? _mapMoodToBackend(String? localMood) {
    if (localMood == null) return null;
    switch (localMood.toLowerCase()) {
      case 'happy':
        return 'EXCITED';
      case 'hungry':
        return 'HUNGRY';
      case 'playful':
        return 'PLAYFUL';
      case 'angry':
        return 'ANGRY';
      case 'sad':
        return 'SLEEPY';
      default:
        return null;
    }
  }

  Future<void> saveVoice() async {
    final name = voiceLabel.value.trim();
    if (name.isEmpty) {
      reset();
      return;
    }

    isSaving.value = true;
    try {
      // Check saved voices count limit on free accounts
      final user = AuthController.to.user.value;
      if (user != null && !user.isPremium) {
        final savedTalks = await _talkApi.listSaved();
        if (savedTalks.length >= 5) {
          reset();
          Get.offNamed(AppRoutes.payment);
          return;
        }
      }

      // 1. Voice Learning (Local save)
      if (isHumanToDog.value &&
          recognizedText.value.isNotEmpty &&
          responseAssetPath.value.isNotEmpty) {
        final isDog = selectedPet.value == PetType.dog;
        final box = GetStorage();
        final String storageKey =
            'learned_${isDog ? "dog" : "cat"}_${recognizedText.value}';

        await box.write(storageKey, responseAssetPath.value);
        print(
          '[Dashboard] Learned phrase saved locally: ${recognizedText.value} -> ${responseAssetPath.value}',
        );
      }

      // 2. Backend Save (Cloud)
      if (_translationId != null) {
        final saved = await _talkApi.saveTranslation(
          translationId: _translationId!,
          savedName: name,
          mood: _mapMoodToBackend(_detectedMood),
        );

        if (saved != null) {
          print('[Dashboard] Voice saved to backend successfully');
          reset();
          Get.offNamed(AppRoutes.savedTalks);
          return;
        }
      }

      // If we got here, we saved locally but maybe not to backend, or vice versa
      Get.snackbar('Success', 'Voice translation saved!');
      reset();
      Get.back();
    } catch (e) {
      print('[Dashboard] saveVoice error: $e');
      reset();
      Get.back();
    } finally {
      isSaving.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // Playback helpers
  // ---------------------------------------------------------------------------
  void playResponse() async {
    if (responseAssetPath.value.isNotEmpty) {
      await audioPlayer.play(AssetSource(responseAssetPath.value));
    }
  }

  void playRecordedVoice() async {
    if (currentRecordingPath.value.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(currentRecordingPath.value));
    }
  }

  // ---------------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------------
  void reset() {
    stopAudio();
    uiState.value = TranslationUIState.idle;
    resultText.value = '';
    recognizedText.value = '';
    voiceLabel.value = '';
    currentRecordingPath.value = '';
    responseAssetPath.value = '';
    _translationId = null;
    _detectedMood = null;
    // Keep session alive for the next recording
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer(const Duration(seconds: 30), () {
      if (uiState.value == TranslationUIState.recording) {
        stopRecording();
      }
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
  }

  @override
  void onClose() {
    _recordSub?.cancel();
    _amplitudeSub?.cancel();
    _recordingTimer?.cancel();
    _playbackTimer?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    classifierService.dispose();
    super.onClose();
  }
}
