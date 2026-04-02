import 'dart:math';

/// Mock ClassifierService - simulates YAMNet mood detection.
/// Replace with real tflite_flutter implementation once the native
/// binary download issue is resolved.
class ClassifierService {
  final _random = Random();
  final _moods = ['happy', 'playful', 'sad', 'angry', 'hungry'];

  Future<void> init() async {
    // No-op: real init would load yamnet.tflite here
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Simulates audio classification by returning a random mood.
  /// In the real implementation this processes 16kHz PCM via TFLite.
  Future<String> classify(String filePath) async {
    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _moods[_random.nextInt(_moods.length)];
  }

  void dispose() {
    // No-op
  }
}
