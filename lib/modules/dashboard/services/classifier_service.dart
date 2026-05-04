import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

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

/// Real on-device pet sound classifier using YAMNet TFLite model.
class ClassifierService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // -----------------------------------------------------------------------
  // Label → mood mapping
  // -----------------------------------------------------------------------
  static const Map<String, String> _dogLabels = {
    'Dog': 'playful',
    'Bark': 'playful',
    'Growling': 'angry',
    'Whimper (dog)': 'sad',
    'Canidae, dogs, wolves': 'playful',
  };

  static const Map<String, String> _catLabels = {
    'Cat': 'happy',
    'Purr': 'happy',
    'Meow': 'hungry',
    'Caterwaul': 'angry',
    'Roaring cats (lions, tigers)': 'angry',
  };

  static const List<String> _fallbackMoods = [
    'happy',
    'playful',
    'hungry',
    'sad',
    'calm',
  ];

  static const int _inputLength = 15600; // 0.975 s @ 16 kHz

  Future<void> init() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/yamnet.tflite');
      _labels = await _loadLabels();
      print('[ClassifierService] YAMNet loaded. Labels: ${_labels.length}');
    } catch (e) {
      print('[ClassifierService] Failed to load YAMNet: $e');
      _interpreter = null;
    }
  }

  Future<List<String>> _loadLabels() async {
    final raw = await rootBundle.loadString('assets/labels.txt');
    return raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
  }

  /// Main classification entry point.
  /// [expectedPet] can be 'dog' or 'cat'.
  Future<ClassificationResult> classify(String filePath, String expectedPet) async {
    double estimatedFreq = 0.0;

    if (_interpreter == null) {
      print('[ClassifierService] No interpreter');
      return ClassificationResult(frequency: 0, isMatch: false);
    }

    try {
      final pcm = await _readWavAsPcmFloat(filePath);
      if (pcm == null || pcm.isEmpty) {
        return ClassificationResult(frequency: 0, isMatch: false);
      }

      // 1. Estimate Frequency (Hz)
      estimatedFreq = _estimateFrequency(pcm);
      print('[ClassifierService] Estimated Frequency: ${estimatedFreq.toStringAsFixed(2)} Hz');

      // 2. AI Pattern Recognition
      final input = _prepareInput(pcm);
      final output = List.generate(1, (_) => List<double>.filled(521, 0.0));
      _interpreter!.run(input, output);

      final scores = output[0];
      
      // Find top-5 indices
      final indexed = List.generate(scores.length, (i) => [i, scores[i]]);
      indexed.sort((a, b) => (b[1] as double).compareTo(a[1] as double));
      final top5 = indexed.take(5).toList();

      String? detectedMood;
      bool isMatch = false;
      String? detectedPetType;

      // check if any top label matches the expected pet
      for (final item in top5) {
        final idx = item[0] as int;
        if (idx < _labels.length) {
          final label = _labels[idx];
          
          if (expectedPet == 'dog' && _dogLabels.containsKey(label)) {
            detectedMood = _dogLabels[label];
            isMatch = true;
            detectedPetType = 'dog';
            break;
          } else if (expectedPet == 'cat' && _catLabels.containsKey(label)) {
            detectedMood = _catLabels[label];
            isMatch = true;
            detectedPetType = 'cat';
            break;
          }
        }
      }

      // 3. Strict Frequency Check (Secondary validation)
      // Dogs usually 300-2500Hz, Cats usually 700-2000Hz (meow)
      // This is broad but helps filter out very low hums or very high whistles
      if (isMatch) {
        if (expectedPet == 'dog' && (estimatedFreq < 100 || estimatedFreq > 4000)) {
          isMatch = false; // Outside realistic dog range
        }
        if (expectedPet == 'cat' && (estimatedFreq < 300 || estimatedFreq > 5000)) {
          isMatch = false; // Outside realistic cat range
        }
      }

      return ClassificationResult(
        mood: detectedMood,
        frequency: estimatedFreq,
        isMatch: isMatch,
        detectedPet: detectedPetType,
      );

    } catch (e) {
      print('[ClassifierService] Inference error: $e');
      return ClassificationResult(frequency: 0, isMatch: false);
    }
  }

  /// Simple Zero-Crossing Rate (ZCR) frequency estimation
  double _estimateFrequency(List<double> pcm) {
    int signChanges = 0;
    for (int i = 1; i < pcm.length; i++) {
      if ((pcm[i] >= 0 && pcm[i - 1] < 0) || (pcm[i] < 0 && pcm[i - 1] >= 0)) {
        signChanges++;
      }
    }
    // For 16000Hz sampling rate:
    // duration = samples / 16000
    // frequency = (signChanges / 2) / duration
    // simplified: (signChanges * 16000) / (2 * samples)
    return (signChanges * 8000.0) / pcm.length;
  }

  List<List<double>> _prepareInput(List<double> pcm) {
    final result = List<double>.filled(_inputLength, 0.0);
    final copyLen = min(pcm.length, _inputLength);
    for (int i = 0; i < copyLen; i++) {
      result[i] = pcm[i];
    }
    return [result];
  }

  Future<List<double>?> _readWavAsPcmFloat(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;
      final bytes = await file.readAsBytes();
      final data = ByteData.sublistView(bytes);
      if (bytes.length < 44) return null;
      int dataOffset = 44;
      for (int i = 12; i < bytes.length - 8; i++) {
        if (bytes[i] == 0x64 && bytes[i + 1] == 0x61 && bytes[i + 2] == 0x74 && bytes[i + 3] == 0x61) {
          dataOffset = i + 8;
          break;
        }
      }
      final numSamples = (bytes.length - dataOffset) ~/ 2;
      final samples = List<double>.filled(numSamples, 0.0);
      for (int i = 0; i < numSamples; i++) {
        final rawOffset = dataOffset + i * 2;
        if (rawOffset + 1 >= bytes.length) break;
        final sample = data.getInt16(rawOffset, Endian.little);
        samples[i] = sample / 32768.0;
      }
      return samples;
    } catch (e) {
      print('[ClassifierService] WAV read error: $e');
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
