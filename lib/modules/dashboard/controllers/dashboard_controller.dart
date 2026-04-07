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

class SavedVoice {
  final String id;
  final String name;
  final String filePath;
  final DateTime createdAt;
  SavedVoice({required this.id, required this.name, required this.filePath, required this.createdAt});
}

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
  
  // Memory storage for saved voices
  final RxList<SavedVoice> savedVoices = <SavedVoice>[].obs;

  StreamSubscription<RecordState>? _recordSub;
  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
    classifierService.init();
    
    // Ensure iOS plays sound even if device is on silent mode
    final audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {},
      ),
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
    );
    AudioPlayer.global.setAudioContext(audioContext);
    
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
      final ext = isHumanToDog.value ? 'm4a' : 'wav';
      final path = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.$ext';
      currentRecordingPath.value = path;

      // Human Voice typically prefers m4a/aac with a standard sample rate of 44.1kHz.
      // Yamnet dog analysis model explicitly requires wav encoding at 16000Hz mono.
      final config = isHumanToDog.value 
         ? const RecordConfig(
             encoder: AudioEncoder.aacLc, 
             sampleRate: 44100, 
             numChannels: 1
           )
         : const RecordConfig(
             encoder: AudioEncoder.wav,
             sampleRate: 16000,
             numChannels: 1,
           );

      await audioRecorder.start(config, path: path);
      uiState.value = TranslationUIState.recording;
      _startRecordingTimer();
    }
  }

  void saveCurrentVoice() {
    if (voiceLabel.value.trim().isEmpty) {
       Get.snackbar("Error", "Please enter a name for the voice");
       return;
    }
    if (currentRecordingPath.value.isEmpty) {
       Get.snackbar("Error", "No voice recorded");
       return;
    }

    final newVoice = SavedVoice(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: voiceLabel.value.trim(),
      filePath: currentRecordingPath.value,
      createdAt: DateTime.now(),
    );

    savedVoices.add(newVoice);
    Get.snackbar("Success", "Voice saved temporarily!");
    
    // Clear label after saving
    voiceLabel.value = "";
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
    await audioPlayer.stop(); // Stop any currently playing audio
    if (isHumanToDog.value) {
      await audioPlayer.play(AssetSource(responseAssetPath.value));
    } else {
       // If Dog-to-Human, play back the recorded dog bark as the "voice"
       playRecordedVoice();
    }
  }

  void playRecordedVoice() async {
    await audioPlayer.stop(); // Stop any currently playing audio
    if (currentRecordingPath.value.isNotEmpty) {
      await audioPlayer.play(DeviceFileSource(currentRecordingPath.value));
    }
  }

  void stopAudio() async {
    await audioPlayer.stop();
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
