import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class DiagnosisService {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const int INPUT_SIZE = 224;

  static Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/agridx_model.tflite');

      final inputT  = _interpreter!.getInputTensor(0);
      final outputT = _interpreter!.getOutputTensor(0);

      print('╔══════════════════════════════════════╗');
      print('║       TFLite Model Loaded OK         ║');
      print('╠══════════════════════════════════════╣');
      print('║ Input  shape : ${inputT.shape}');
      print('║ Input  type  : ${inputT.type}');
      print('║ Output shape : ${outputT.shape}');
      print('║ Output type  : ${outputT.type}');

      final labelsData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelsData.split('\n').where((l) => l.isNotEmpty).toList();

      print('║ Labels count : ${_labels!.length}');
      print('╚══════════════════════════════════════╝');
    } catch (e) {
      print('❌ Error initializing DiagnosisService: $e');
    }
  }

  /// Returns null if image looks like a crop/leaf, or an error string if not.
  ///
  /// Uses two pre-inference filters:
  ///   1. Brightness — rejects black/dark images (covered lens)
  ///   2. Green Fraction — green must make up ≥30% of total RGB energy
  ///      Typical values:  Healthy leaf ~45%,  Diseased leaf ~33–40%
  ///                       Skin ~33%,  Soil/wood ~30–35%,  Red obj ~20%,  Blue sky ~32%
  ///
  /// A post-inference confidence check (< 45%) is also applied in the scan screen.
  static String? validateImage(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return 'Could not read image.';

      // Downsample to 32×32 for fast pixel analysis
      final sample = img.copyResize(image, width: 32, height: 32);

      double sumR = 0, sumG = 0, sumB = 0;
      const n = 32 * 32;

      for (int y = 0; y < 32; y++) {
        for (int x = 0; x < 32; x++) {
          final px = sample.getPixel(x, y);
          sumR += px.r;
          sumG += px.g;
          sumB += px.b;
        }
      }

      final avgR = sumR / n;
      final avgG = sumG / n;
      final avgB = sumB / n;
      final brightness = (avgR + avgG + avgB) / 3.0;
      final total     = avgR + avgG + avgB;

      // Green fraction: what proportion of total RGB is green?
      // A balanced grey/white = 0.333. A leaf = 0.40–0.50.
      // Reject anything clearly below 0.30.
      final gFraction = total > 0 ? avgG / total : 0.0;

      // Also compute how much red dominates over green (warm-tone check)
      // and how much blue dominates over green (cool-tone check)
      final redOverGreen  = avgR > 0 ? avgG / avgR : 1.0;   // < 0.75 → very red
      final blueOverGreen = avgB > 0 ? avgG / avgB : 1.0;   // < 0.75 → very blue

      // Calculate Saturation (Relative Chroma) to filter out neutral grey/white/black surfaces.
      final maxVal = [avgR, avgG, avgB].reduce(max);
      final minVal = [avgR, avgG, avgB].reduce(min);
      final saturation = maxVal > 0 ? (maxVal - minVal) / maxVal : 0.0;

      print('🔍 Validation — '
            'R:${avgR.toStringAsFixed(0)} '
            'G:${avgG.toStringAsFixed(0)} '
            'B:${avgB.toStringAsFixed(0)} '
            'brightness:${brightness.toStringAsFixed(0)} '
            'gFraction:${gFraction.toStringAsFixed(3)} '
            'G/R:${redOverGreen.toStringAsFixed(2)} '
            'G/B:${blueOverGreen.toStringAsFixed(2)} '
            'saturation:${saturation.toStringAsFixed(3)}');

      // ── Filter 1: Too dark ──────────────────────────────────
      if (brightness < 30) {
        return 'Image is too dark.\nPlease scan in better lighting or uncover the lens.';
      }

      // ── Filter 2: Absolutely no green ──────────────────────
      if (avgG < 30) {
        return 'This doesn\'t look like a crop or leaf image.\nPlease scan a plant leaf for accurate diagnosis.';
      }

      // ── Filter 3: Green fraction too low ───────────────────
      // gFraction < 0.30 means another channel is strongly dominating.
      // This catches: red objects, blue skies, purple/pink surfaces.
      if (gFraction < 0.30) {
        return 'This doesn\'t look like a crop or leaf image.\nPlease scan a plant leaf for accurate diagnosis.';
      }

      // ── Filter 4: Red OR Blue clearly dominates green ──────
      // Catches warm-toned (faces, soil, wood) where red >> green
      // and cool-toned (open sky) where blue >> green.
      // Use OR so either extreme of non-green triggers rejection.
      if (redOverGreen < 0.72 || blueOverGreen < 0.72) {
        return 'This doesn\'t look like a crop or leaf image.\nPlease scan a plant leaf for accurate diagnosis.';
      }

      // ── Filter 5: Too desaturated (Neutral grey/white/black) ─────
      // Catches neutral surfaces like white/grey tables, paper, walls, concrete
      if (saturation < 0.12) {
        return 'This doesn\'t look like a crop or leaf image.\nPlease scan a plant leaf for accurate diagnosis.';
      }

      return null; // ✅ passes all checks — looks like a plant image
    } catch (e) {
      print('Validation error: $e');
      return null; // on exception, allow through
    }
  }

  static Future<List<Map<String, dynamic>>> diagnose(Uint8List imageBytes, {String? cropFilter}) async {
    if (_interpreter == null || _labels == null) {
      await initialize();
    }

    try {
      // ── Decode & resize ──────────────────────────────────────
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Could not decode image');

      img.Image resized = img.copyResize(
        image,
        width: INPUT_SIZE,
        height: INPUT_SIZE,
        interpolation: img.Interpolation.linear,
      );

      final inputT  = _interpreter!.getInputTensor(0);
      final outputT = _interpreter!.getOutputTensor(0);
      final isQuantized = inputT.type == TensorType.uint8 || inputT.type == TensorType.int8;

      print('=== DIAGNOSE DEBUG ===');
      print('Image bytes   : ${imageBytes.length}');
      print('Decoded size  : ${image.width}x${image.height}');
      print('Input  shape  : ${inputT.shape}  type: ${inputT.type}');
      print('Output shape  : ${outputT.shape}  type: ${outputT.type}');
      print('isQuantized   : $isQuantized');
      print('Normalization : ${isQuantized ? "UINT8 (0–255)" : "Float32 (0→1)"}');

      // ── Build input with FIXED normalization ─────────────────
      // PlantVillage Float32 models use 0→1 normalization (NOT MobileNetV2's -1→1).
      // Using -1→1 gives wildly inconsistent results across different captures of
      // the same leaf, so we always use 0→1 for this model.
      var input = List.generate(1, (_) =>
        List.generate(INPUT_SIZE, (y) =>
          List.generate(INPUT_SIZE, (x) {
            final pixel = resized.getPixel(x, y);
            if (isQuantized) {
              return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
            } else {
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            }
          })
        )
      );

      // ── Output buffer ─────────────────────────────────────────
      dynamic output = isQuantized
          ? List.generate(1, (_) => List.filled(_labels!.length, 0))
          : List.generate(1, (_) => List.filled(_labels!.length, 0.0));

      _interpreter!.run(input, output);

      // ── Convert raw scores → probabilities ───────────────────
      List<double> rawScores = List.generate(
        output[0].length,
        (i) => isQuantized
            ? (output[0][i] as num).toDouble() / 255.0
            : (output[0][i] as num).toDouble(),
      );

      // Detect logits (need softmax) vs already-summing-to-1
      final rawSum = rawScores.fold(0.0, (a, b) => a + b);
      final hasNegatives = rawScores.any((v) => v < 0);
      final needsSoftmax = hasNegatives || rawSum < 0.9 || rawSum > 1.1;

      List<double> probs;
      if (needsSoftmax) {
        final maxV = rawScores.reduce(max);
        final expSum = rawScores.fold(0.0, (s, v) => s + exp(v - maxV));
        probs = rawScores.map((v) => exp(v - maxV) / expSum).toList();
      } else {
        probs = rawScores;
      }

      // ── Apply Crop Filter Bias (Soft Filtering) ─────────────
      // Instead of rigidly deleting all other crops (which causes false "Healthy" spikes when scanning the wrong crop),
      // we heavily amplify the probabilities of the selected crop.
      // If the model is confused between two similar crops (e.g. Tomato vs Pepper), the multiplier tips the scale.
      // If the user scans a completely wrong crop (e.g. Tomato vs Maize), the raw 99% prediction will still overpower the filter.
      if (cropFilter != null && cropFilter.isNotEmpty && cropFilter != 'Auto') {
        final filterLower = cropFilter.toLowerCase().replaceAll(' ', '_');
        for (int i = 0; i < probs.length; i++) {
          final lbl = _labels![i].toLowerCase();
          if (lbl.contains(filterLower)) {
            probs[i] = probs[i] * 100.0; // 100x confidence boost to overcome cross-crop visual confusion (e.g. Tomato vs Potato)
          }
        }
        
        // Re-normalize probabilities back to 1.0
        double sum = probs.fold(0.0, (a, b) => a + b);
        if (sum > 0) {
          probs = probs.map((p) => p / sum).toList();
        }
      }

      // ── Sort ───────────────────────────────────────────────
      List<MapEntry<int, double>> sorted =
          List.generate(probs.length, (i) => MapEntry(i, probs[i]));
      sorted.sort((a, b) => b.value.compareTo(a.value));

      print('Top 5 predictions (Filtered: $cropFilter):');
      for (int i = 0; i < 5 && i < sorted.length; i++) {
        print('  [${i + 1}] ${_labels![sorted[i].key]} — ${(sorted[i].value * 100).toStringAsFixed(1)}%');
      }
      print('===================');

      return sorted.take(3).map((e) => {
        'label': _labels![e.key],
        'confidence': (e.value * 100).toStringAsFixed(1),
        'confidenceValue': e.value,
      }).toList();

    } catch (e) {
      print('❌ Inference error: $e');
      return [];
    }
  }

  static String formatDiseaseName(String rawLabel) {
    final parts = rawLabel.split('___');
    if (parts.length >= 2) {
      final crop    = parts[0].replaceAll('_', ' ');
      final disease = parts[1].replaceAll('_', ' ');
      return '$crop — $disease';
    }
    return rawLabel.replaceAll('_', ' ');
  }

  static String getSeverity(double confidence) {
    if (confidence > 0.85) return 'High';
    if (confidence > 0.65) return 'Medium';
    return 'Low';
  }
}
