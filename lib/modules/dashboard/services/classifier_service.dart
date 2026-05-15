import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// Represents the result of a pet sound classification
class ClassificationResult {
  final String? mood;
  final double frequency;
  final bool isMatch;
  final String? detectedPet;

  ClassificationResult({
    this.mood,
    required this.frequency,
    required this.isMatch,
    this.detectedPet,
  });
}

/// Real on-device pet sound classifier using Apple's native Sound Analysis framework.
class ClassifierService {
  static const _channel = MethodChannel('com.nazmul.petapp1/sound_classifier');
  
  bool _isInitializing = false;
  String? initError;

  // SoundAnalysis is always ready on iOS 13+
  bool get isReady => true;
  bool get hasError => initError != null;

  // -----------------------------------------------------------------------
  // Label → mood mapping (Apple SoundAnalysis Labels)
  // -----------------------------------------------------------------------
  static const Map<String, String> _dogLabels = {
    'bark': 'playful',
    'dog_barking': 'playful',
    'howl': 'sad',
    'growl': 'angry',
    'whimper': 'sad',
    'dog': 'playful',
  };

  static const Map<String, String> _catLabels = {
    'meow': 'hungry',
    'cat_meow': 'hungry',
    'purr': 'happy',
    'hiss': 'angry',
    'cat': 'happy',
  };

  static const List<String> _humanLabels = [
    'speech',
    'laughter',
    'shouting',
    'screaming',
    'human_voice',
    'conversation',
    'babbling',
    'whispering',
  ];

  Future<void> init() async {
    // No explicit initialization needed for native framework
    print('[ClassifierService] Using Apple Native Sound Analysis');
    return;
  }

  /// Main classification entry point.
  Future<ClassificationResult> classify(
    String filePath,
    String expectedPet,
  ) async {
    double estimatedFreq = 0.0;

    try {
      final pcm = await _readWavAsPcmFloat(filePath);
      if (pcm == null || pcm.isEmpty) {
        return ClassificationResult(frequency: 0, isMatch: false);
      }

      // 1. Volume Check (Silence Filter)
      double sumSquares = 0.0;
      for (final sample in pcm) {
        sumSquares += sample * sample;
      }
      final double rms = sqrt(sumSquares / pcm.length);
      if (rms < 0.005) {
        print('[ClassifierService] Silence detected (RMS: $rms)');
        return ClassificationResult(frequency: 0, isMatch: false);
      }

      // 2. Estimate Frequency
      estimatedFreq = _estimateFrequency(pcm);

      // 3. Apple Native AI Classification
      final Map<dynamic, dynamic>? nativeResults = await _channel.invokeMethod(
        'classifyAudio',
        {'filePath': filePath},
      );

      if (nativeResults == null || nativeResults.isEmpty) {
        print('[ClassifierService] Native analysis returned no results');
        return ClassificationResult(frequency: estimatedFreq, isMatch: false);
      }

      print('[ClassifierService] Native Results: $nativeResults');

      String? detectedMood;
      bool isMatch = false;
      String? detectedPetType;
      bool isHumanDetected = false;

      // 4. Check for Human Speech First
      for (var label in _humanLabels) {
        if (nativeResults.containsKey(label) && (nativeResults[label] as double) > 0.4) {
          isHumanDetected = true;
          print('[ClassifierService] Human detected: $label. Blocking.');
          break;
        }
      }

      // 5. Match Pet Sounds
      if (!isHumanDetected) {
        // Find highest confidence pet label
        double bestScore = 0.0;
        
        nativeResults.forEach((label, score) {
          final String labelStr = label.toString().toLowerCase();
          final double scoreVal = score as double;

          if (expectedPet == 'dog' && _dogLabels.containsKey(labelStr)) {
            if (scoreVal > bestScore && scoreVal > 0.3) {
              bestScore = scoreVal;
              detectedMood = _dogLabels[labelStr];
              isMatch = true;
              detectedPetType = 'dog';
            }
          } else if (expectedPet == 'cat' && _catLabels.containsKey(labelStr)) {
            if (scoreVal > bestScore && scoreVal > 0.3) {
              bestScore = scoreVal;
              detectedMood = _catLabels[labelStr];
              isMatch = true;
              detectedPetType = 'cat';
            }
          }
        });
      }

      return ClassificationResult(
        mood: detectedMood,
        frequency: estimatedFreq,
        isMatch: isMatch,
        detectedPet: detectedPetType,
      );
    } catch (e) {
      print('[ClassifierService] Analysis error: $e');
      return ClassificationResult(frequency: 0, isMatch: false);
    }
  }

  double _estimateFrequency(List<double> pcm) {
    int signChanges = 0;
    for (int i = 1; i < pcm.length; i++) {
      if ((pcm[i] >= 0 && pcm[i - 1] < 0) || (pcm[i] < 0 && pcm[i - 1] >= 0)) {
        signChanges++;
      }
    }
    return (signChanges * 8000.0) / pcm.length;
  }

  Future<List<double>?> _readWavAsPcmFloat(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      final bytes = await file.readAsBytes();
      if (bytes.length < 44) return null;
      
      // Simple WAV parser
      int dataOffset = 44;
      for (int i = 12; i < bytes.length - 8; i++) {
        if (bytes[i] == 0x64 && bytes[i + 1] == 0x61 && bytes[i + 2] == 0x74 && bytes[i + 3] == 0x61) {
          dataOffset = i + 8;
          break;
        }
      }
      
      final data = ByteData.sublistView(bytes);
      final numSamples = (bytes.length - dataOffset) ~/ 2;
      final samples = List<double>.filled(numSamples, 0.0);
      for (int i = 0; i < numSamples; i++) {
        final rawOffset = dataOffset + i * 2;
        if (rawOffset + 1 >= bytes.length) break;
        samples[i] = data.getInt16(rawOffset, Endian.little) / 32768.0;
      }
      return samples;
    } catch (e) {
      return null;
    }
  }

  void dispose() {}
}

