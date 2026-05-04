import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
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

  // ----- Backend session & translation IDs -----
  String? _sessionId;
  String? _translationId;
  String? _detectedMood;

  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is PetType) {
      selectedPet.value = arg;
    } else {
      // Try to get from active user profile if no arg
      final activePetId = AuthController.to.user.value?.activePetId;
      if (activePetId != null) {
        // Simple logic: if profile exists, we can infer or fetch.
        // For now, mirroring user's pet list lookup:
        final pets = AuthController.to.user.value?.pets;
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

    classifierService.init();
    _initTalkSession();

    _recordSub = audioRecorder.onStateChanged().listen((RecordState state) {
      if (state == RecordState.stop) {
        _stopRecordingTimer();
      }
    });

    _amplitudeSub = audioRecorder
        .onAmplitudeChanged(const Duration(milliseconds: 100))
        .listen((amp) {
          amplitude.value = amp.current;
        });

    // Sync isPlaying with audio player state
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying.value = state == PlayerState.playing;
    });
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
      uiState.value = TranslationUIState.recording;
      _startRecordingTimer();
    }
  }

  void stopRecording() async {
    final path = await audioRecorder.stop();
    uiState.value = TranslationUIState.result;

    if (path != null) {
      currentRecordingPath.value = path;
      print('[Dashboard] Recording stopped, review path: $path');

      // Trigger automatic ML processing/translation immediately
      if (isHumanToDog.value) {
        await _processHumanToPet(path);
      } else {
        await _processPetToHuman(path);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Human → Pet (user's voice → pet sound translation)
  // ---------------------------------------------------------------------------
  Future<void> _processHumanToPet(String path) async {
    final isDog = selectedPet.value == PetType.dog;
    resultText.value = isDog
        ? 'Dog translation sent!'
        : 'Cat translation sent!';
    playRecording();

    // Post to backend in background
    if (_sessionId != null) {
      try {
        final translation = await _talkApi.createTranslation(
          sessionId: _sessionId!,
          inputType: 'HUMAN_VOICE',
          direction: 'HUMAN_TO_PET',
          inputAudioUrl: 'file://$path',
        );
        if (translation != null) {
          _translationId = translation.id;
          // If backend returned proper pet sound, use it
          if (translation.outputText != null &&
              translation.outputText!.isNotEmpty) {
            resultText.value = translation.outputText!;
          }
        }
      } catch (e) {
        print('[Dashboard] Backend translate error (human→pet): $e');
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Pet → Human (pet sound → english phrase)
  // ---------------------------------------------------------------------------
  Future<void> _processPetToHuman(String path) async {
    setLoading(true);
    try {
      // Local ML first for immediate result
      final localMood = await classifierService.classify(path);
      resultMood.value = localMood;
      resultText.value = phrases.getPhraseFromMood(localMood);
      _detectedMood = localMood;

      // Then send to backend to store the translation record
      if (_sessionId != null) {
        final translation = await _talkApi.createTranslation(
          sessionId: _sessionId!,
          inputType: 'PET_VOICE',
          direction: 'PET_TO_HUMAN',
          inputAudioUrl: 'file://$path',
          inputText: resultText.value,
        );
        if (translation != null) {
          _translationId = translation.id;
          // Use backend mood/text if richer
          if (translation.outputText != null &&
              translation.outputText!.isNotEmpty) {
            resultText.value = translation.outputText!;
          }
          if (translation.mood != null) {
            _detectedMood = translation.mood;
          }
        }
      }
    } catch (e) {
      resultText.value = 'Translation error. Try again!';
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
    // Both modes now play the original recorded sound as per user request
    if (currentRecordingPath.value.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(currentRecordingPath.value));
    }
  }

  String _mapMoodToBackend(String? localMood) {
    if (localMood == null) return 'NEUTRAL';
    switch (localMood.toLowerCase()) {
      case 'happy': return 'EXCITED';
      case 'hungry': return 'HUNGRY';
      case 'playful': return 'PLAYFUL';
      case 'angry': return 'ANGRY';
      case 'sad': return 'SLEEPY';
      default: return 'NEUTRAL';
    }
  }

  Future<void> saveVoice() async {
    final name = voiceLabel.value.trim();
    if (name.isEmpty) {
      reset();
      return;
    }

    if (_translationId == null) {
      print('[Dashboard] No translation record found to save');
      reset();
      return;
    }

    isSaving.value = true;
    try {
      final saved = await _talkApi.saveTranslation(
        translationId: _translationId!,
        savedName: name,
        mood: _mapMoodToBackend(_detectedMood),
      );

      if (saved != null) {
        print('[Dashboard] Voice saved successfully');
        Get.toNamed(AppRoutes.savedTalks);
      }
    } catch (e) {
      print('[Dashboard] saveVoice error: $e');
      reset();
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
    uiState.value = TranslationUIState.idle;
    resultText.value = '';
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
    audioRecorder.dispose();
    audioPlayer.dispose();
    classifierService.dispose();
    super.onClose();
  }
}
