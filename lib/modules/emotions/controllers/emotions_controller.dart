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

    // Play Sound (using local assets to bypass internet issues)
    try {
      if (isPlayingSound.value) {
        await _audioPlayer.stop();
      }

      isPlayingSound.value = true;

      // Safe lookup for active pet type
      String petType = 'bark';
      final user = AuthController.to.user.value;
      if (user != null && user.activePetId != null) {
        final activePet = user.pets.firstWhereOrNull(
          (p) => p['id'] == user.activePetId,
        );
        if (activePet != null && activePet['type'] == 'CAT') {
          petType = 'meow';
        }
      }

      await _audioPlayer.play(AssetSource('audio/${petType}_1.wav'));
    } catch (e) {
      print("Error playing sound: $e");
      // Silently fail or show a more descriptive error if local assets are missing
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
