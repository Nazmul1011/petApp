import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/modules/model_pharse/mood_phrases.dart' as phrases;
import '../services/classifier_service.dart';

enum TranslationUIState { idle, recording, result }

class DashboardController extends GetxController with BaseController {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ClassifierService classifierService = ClassifierService();

  // Observable states
  final Rx<TranslationUIState> uiState = TranslationUIState.idle.obs;
  final RxBool isHumanToDog = true.obs;
  final RxDouble amplitude = (-160.0).obs;
  final RxString resultText = "".obs;
  final RxString resultMood = "happy".obs;
  final RxString currentRecordingPath = "".obs;
  final RxString responseAssetPath = "".obs;
  final Rx<PetType> selectedPet = PetType.dog.obs;
  
  // Text input for save voice
  final RxString voiceLabel = "".obs;

  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
    classifierService.init();
    
    _recordSub = audioRecorder.onStateChanged().listen((RecordState state) {
      if (state == RecordState.stop) {
        _stopRecordingTimer();
      }
    });

    _amplitudeSub = audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen((amp) {
      amplitude.value = amp.current;
    });
  }

  void toggleMode() {
    if (uiState.value == TranslationUIState.idle) {
      isHumanToDog.value = !isHumanToDog.value;
    }
  }

  void startRecording() async {
    if (await audioRecorder.hasPermission()) {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
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
      if (isHumanToDog.value) {
        _processHumanToDog(path);
      } else {
        _processDogToHuman(path);
      }
    }
  }

  void _processHumanToDog(String path) {
    // Select random mock bark asset
    final randomBark = Random().nextInt(3) + 1;
    responseAssetPath.value = 'audio/bark_$randomBark.wav'; 
    resultText.value = "Translation Sent!";
    playResponse();
  }

  void _processDogToHuman(String path) async {
    setLoading(true);
    try {
      final mood = await classifierService.classify(path);
      resultMood.value = mood;
      resultText.value = phrases.getPhraseFromMood(mood);
    } catch (e) {
      resultText.value = "Translation error. Try again!";
    }
    setLoading(false);
  }

  void playResponse() async {
    if (isHumanToDog.value) {
      await audioPlayer.play(AssetSource(responseAssetPath.value));
    } else {
       // Optional: play back the human's translated phrase as audio if we had TTS
       // For now, just play a success ping or similar
    }
  }

  void playRecordedVoice() async {
    if (currentRecordingPath.value.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(currentRecordingPath.value));
    }
  }

  void reset() {
    uiState.value = TranslationUIState.idle;
    resultText.value = "";
    currentRecordingPath.value = "";
    responseAssetPath.value = "";
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    // Auto-stop after 4 seconds if they don't release
    _recordingTimer = Timer(const Duration(seconds: 4), () {
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
