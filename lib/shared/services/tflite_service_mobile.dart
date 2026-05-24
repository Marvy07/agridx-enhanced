import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'tflite_service.dart';

TFLiteService getTFLiteService(Ref ref) {
  final service = _TFLiteServiceMobile();
  ref.onDispose(service.dispose);
  return service;
}

class _TFLiteServiceMobile implements TFLiteService {
  static const String _modelPath = 'assets/models/agridx_model.tflite';
  static const String _labelsPath = 'assets/models/labels.txt';
  static const int _inputSize = 224;

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  @override
  Future<void> loadModel() async {
    if (_isLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      final raw = await rootBundle.loadString(_labelsPath);
      _labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      throw Exception('TFLite model failed to load: $e');
    }
  }

  @override
  Future<DiagnosisResult> classify(String imagePath) async {
    if (!_isLoaded) {
      await loadModel();
    }

    final interpreter = _interpreter;
    if (interpreter == null) {
      throw Exception('TFLite interpreter is not initialised.');
    }

    final imageBytes = await File(imagePath).readAsBytes();
    final input = await _preprocessImage(imageBytes);

    final numClasses = _labels.length;
    final outputBuffer = List.filled(numClasses, 0.0).reshape([1, numClasses]);

    interpreter.run(input, outputBuffer);

    final probabilities = List<double>.from(outputBuffer[0] as List);
    final topIndex = _argmax(probabilities);
    final confidence = probabilities[topIndex] * 100.0;
    final rawLabel = topIndex < _labels.length ? _labels[topIndex] : 'Unknown';

    final parsed = _parseLabel(rawLabel);

    return DiagnosisResult(
      cropName: parsed.$1,
      diseaseName: parsed.$2,
      confidence: confidence,
      rawLabel: rawLabel,
    );
  }

  Future<List<List<List<List<double>>>>> _preprocessImage(
      Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: _inputSize,
      targetHeight: _inputSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final rawBytes = await image.toByteData();
    image.dispose();

    if (rawBytes == null) {
      throw Exception('Failed to decode image bytes.');
    }

    final tensor = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(
          _inputSize,
          (x) {
            final offset = (y * _inputSize + x) * 4;

            final r = rawBytes.getUint8(offset) / 255.0;
            final g = rawBytes.getUint8(offset + 1) / 255.0;
            final b = rawBytes.getUint8(offset + 2) / 255.0;

            return [r, g, b];
          },
        ),
      ),
    );

    return tensor;
  }

  int _argmax(List<double> list) {
    int maxIdx = 0;
    double maxVal = list[0];
    for (int i = 1; i < list.length; i++) {
      if (list[i] > maxVal) {
        maxVal = list[i];
        maxIdx = i;
      }
    }
    return maxIdx;
  }

  (String, String) _parseLabel(String label) {
    final parts = label.split('___');
    if (parts.length < 2) return (label, label);

    final crop = parts[0].replaceAll('_', ' ').trim();
    final disease = parts[1].replaceAll('_', ' ').trim();

    return (crop, disease);
  }

  @override
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
  }
}
