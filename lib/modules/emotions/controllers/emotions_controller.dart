import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/services/api_service.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../main/controllers/main_controller.dart';
import '../models/emotion_item.dart';

class EmotionsController extends GetxController with BaseController {
  final _apiService = ApiService();
  final _audioPlayer = AudioPlayer();

  final emotions = <EmotionItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupAudio();
    fetchEmotions();

    // Re-fetch emotions when user state changes (e.g., premium upgrade)
    ever(AuthController.to.user, (_) {
      fetchEmotions();
    });

    // Stop sound when switching tabs
    try {
      final mainController = Get.find<MainController>();
      ever(mainController.currentIndex, (index) {
        if (index != 1) {
          // 1 is the Emotions tab index
          _audioPlayer.stop();
        }
      });
    } catch (_) {
      // MainController might not be initialized in some test scenarios
    }
  }

  void _setupAudio() {
    // Simplified setup to avoid conflicts with other audio packages
    // This uses default playback routing
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchEmotions() async {
    try {
      setLoading(true);
      final response = await _apiService.get('/mood/presets');

      if (response.data != null && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final isPremiumUser = AuthController.to.user.value?.isPremium ?? false;

        emotions.value = data.map((json) {
          final isPremiumItem = json['isPremium'] ?? false;
          // Item is locked if it is premium but user is not a premium subscriber
          final bool isLocked = isPremiumItem && !isPremiumUser;
          return EmotionItem.fromJson(json, isLocked: isLocked);
        }).toList();
      }
      setLoading(false);
    } catch (e) {
      setLoading(false);
      showSnack(
        content: "Failed to load emotions: ${e.toString()}",
        status: SnackBarStatus.error,
      );
    }
  }

  final RxBool isPlayingSound = false.obs;

  Future<void> selectEmotion(EmotionItem item) async {
    if (item.isLocked) {
      showSnack(
        content: "This emotion is premium. Upgrade to unlock!",
        status: SnackBarStatus.warning,
      );
      return;
    }

    // Play Sound
    try {
      if (isPlayingSound.value) {
        await _audioPlayer.stop();
      }

      isPlayingSound.value = true;

      // Helper function for local fallback
      Future<void> playLocalFallback() async {
        String getAudioFileForEmotion(String emotionName, String petType) {
          final lowerName = emotionName.toLowerCase();
          if (petType == 'CAT') {
            if (lowerName == 'happy') return 'cat-purring.mp3';
            if (lowerName == 'attention') return 'cat-hungry.mp3';
            if (lowerName == 'angry') return 'cat-arngry.mp3';
            if (lowerName == 'love') return 'cat-cute-cat.mp3';
            if (lowerName == 'sleep') return 'cat-kitten.mp3';
            return 'meow_1.wav';
          } else {
            if (lowerName == 'happy') return 'dog-barking.mp3';
            if (lowerName == 'attention') return 'dog-barking.mp3';
            if (lowerName == 'angry') return 'angry-pitbull-dog-barking-aggressive-guard-dog-sound-effect-313317.mp3';
            if (lowerName == 'love') return 'puppy_howl.mp3';
            if (lowerName == 'sleep') return 'old-dog-howl.mp3';
            if (lowerName == 'grumpy') return 'dog-unhappy.mp3';
            if (lowerName == 'scared') return 'dog-yelp.mp3';
            if (lowerName == 'neutral') return 'bark_1.wav';
            return 'bark_1.wav';
          }
        }

        // Safe lookup for active pet type
        String petType = 'DOG';
        final user = AuthController.to.user.value;
        if (user != null && user.activePetId != null) {
          final activePet = user.pets.firstWhereOrNull(
            (p) => p['id'] == user.activePetId,
          );
          if (activePet != null && activePet['type'] == 'CAT') {
            petType = 'CAT';
          }
        }

        final fileName = getAudioFileForEmotion(item.name, petType);
        await _audioPlayer.play(AssetSource('audio/$fileName'));
      }

      // Prefer backend URL if available
      if (item.audioUrl != null && item.audioUrl!.isNotEmpty && item.audioUrl!.startsWith('http')) {
        try {
          await _audioPlayer.play(UrlSource(item.audioUrl!));
        } catch (e) {
          print("Network audio failed, falling back to local: $e");
          await playLocalFallback();
        }
      } else {
        // Fallback to local assets immediately if no valid absolute URL
        await playLocalFallback();
      }
    } catch (e) {
      // Silently fail or show a more descriptive error if local assets are missing
      // print("Error playing sound: $e");
    } finally {
      isPlayingSound.value = false;
    }

    // Optional: Record the selection in the backend history
    /*
    try {
      final payload = {
        "mood": _mapToBackendMoodType(item.name),
        "detectedSound": item.name,
        "confidence": 1.0
      };
      await _apiService.post('/mood', data: payload);
    } catch (e) {
      // Silent error for recording
    }
    */
  }
}
