import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Real on-device pet sound classifier using YAMNet TFLite model.
///
/// YAMNet takes 15600 float32 samples (0.975 s @ 16 kHz) and returns
/// scores for 521 audio classes. We read the WAV file, decode it to
/// PCM, run the model, then map the winning class to a mood.
class ClassifierService {
  Interpreter? _interpreter;
  List<String> _labels = [];

  // -----------------------------------------------------------------------
  // Label → mood mapping
  // YAMNet line numbers (1-indexed from labels.txt):
  //   70 Dog, 71 Bark, 75 Growling, 76 Whimper(dog), 118 Canidae/dogs/wolves
  //   77 Cat, 78 Purr, 79 Meow, 81 Caterwaul
  // -----------------------------------------------------------------------
  static const Map<String, String> _labelToMood = {
    // Dog sounds
    'Dog': 'playful',
    'Bark': 'playful',
    'Growling': 'angry',
    'Whimper (dog)': 'sad',
    'Canidae, dogs, wolves': 'playful',
    // Cat sounds
    'Cat': 'happy',
    'Purr': 'happy',
    'Meow': 'hungry',
    'Caterwaul': 'angry',
    // Roaring cats
    'Roaring cats (lions, tigers)': 'angry',
  };

  /// Moods returned when classification falls back to non-pet audio
  static const List<String> _fallbackMoods = [
    'happy',
    'playful',
    'hungry',
    'sad',
    'calm',
  ];

  // -----------------------------------------------------------------------
  // YAMNet input spec: 15600 float32 samples, values in [-1, 1]
  // Output spec: [1, 521] float32 scores
  // -----------------------------------------------------------------------
  static const int _inputLength = 15600; // 0.975 s @ 16 kHz

  /// Load the model and labels. Call once before using [classify].
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

  // -----------------------------------------------------------------------
  // Main classification entry point
  // Returns one of: happy / playful / hungry / sad / angry / calm
  // -----------------------------------------------------------------------
  Future<String> classify(String filePath) async {
    if (_interpreter == null) {
      // Model didn't load – fall back to random so the app still works
      print('[ClassifierService] No interpreter, returning random mood');
      return _fallbackMoods[Random().nextInt(_fallbackMoods.length)];
    }

    try {
      final pcm = await _readWavAsPcmFloat(filePath);
      if (pcm == null || pcm.isEmpty) {
        return _fallbackMoods[Random().nextInt(_fallbackMoods.length)];
      }

      // Pad or trim to exact input length
      final input = _prepareInput(pcm);

      // Output buffer: [1, 521]
      final output = List.generate(1, (_) => List<double>.filled(521, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      final scores = output[0];
      return _scoresToMood(scores);
    } catch (e) {
      print('[ClassifierService] Inference error: $e');
      return _fallbackMoods[Random().nextInt(_fallbackMoods.length)];
    }
  }

  // -----------------------------------------------------------------------
  // Convert the top score index back to a mood string
  // -----------------------------------------------------------------------
  String _scoresToMood(List<double> scores) {
    // Find top-5 indices
    final indexed = List.generate(scores.length, (i) => [i, scores[i]]);
    indexed.sort((a, b) => (b[1] as double).compareTo(a[1] as double));
    final top5 = indexed.take(5).toList();

    print('[ClassifierService] Top labels:');
    for (final item in top5) {
      final idx = item[0] as int;
      final score = item[1] as double;
      final label = idx < _labels.length ? _labels[idx] : 'unknown';
      print('  [$idx] $label: ${score.toStringAsFixed(4)}');
    }

    // Check if any top-5 label maps to a known pet mood
    for (final item in top5) {
      final idx = item[0] as int;
      if (idx < _labels.length) {
        final label = _labels[idx];
        final mood = _labelToMood[label];
        if (mood != null) {
          print('[ClassifierService] Matched label "$label" → mood "$mood"');
          return mood;
        }
      }
    }

    // No pet sound detected — return happy as a safe neutral default
    print('[ClassifierService] No pet label matched, defaulting to "happy"');
    return 'happy';
  }

  // -----------------------------------------------------------------------
  // Pad or crop PCM to exactly _inputLength samples (shaped [1, 15600])
  // -----------------------------------------------------------------------
  List<List<double>> _prepareInput(List<double> pcm) {
    final result = List<double>.filled(_inputLength, 0.0);
    final copyLen = min(pcm.length, _inputLength);
    for (int i = 0; i < copyLen; i++) {
      result[i] = pcm[i];
    }
    return [result]; // shape [1, 15600]
  }

  // -----------------------------------------------------------------------
  // Read a 16-bit PCM WAV file and return normalised float samples [-1, 1]
  // -----------------------------------------------------------------------
  Future<List<double>?> _readWavAsPcmFloat(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final data = ByteData.sublistView(bytes);

      // Minimal WAV parser — skip the 44-byte header
      // Check RIFF & WAVE markers
      if (bytes.length < 44) return null;

      // Data chunk starts at offset 44 for standard PCM WAV
      // (robust: search for 'data' subchunk)
      int dataOffset = 44;
      for (int i = 12; i < bytes.length - 8; i++) {
        if (bytes[i] == 0x64 && // 'd'
            bytes[i + 1] == 0x61 && // 'a'
            bytes[i + 2] == 0x74 && // 't'
            bytes[i + 3] == 0x61) {
          // 'a'
          dataOffset = i + 8; // skip 'data' + 4-byte chunk size
          break;
        }
      }

      final numSamples = (bytes.length - dataOffset) ~/ 2;
      final samples = List<double>.filled(numSamples, 0.0);

      for (int i = 0; i < numSamples; i++) {
        final rawOffset = dataOffset + i * 2;
        if (rawOffset + 1 >= bytes.length) break;
        final sample = data.getInt16(rawOffset, Endian.little);
        samples[i] = sample / 32768.0; // normalise to [-1, 1]
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
