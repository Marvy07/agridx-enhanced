import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tflite_service_unsupported.dart'
    if (dart.library.io) 'tflite_service_mobile.dart';

/// Result returned by the TFLite classifier.
class DiagnosisResult {
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String rawLabel;

  const DiagnosisResult({
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    required this.rawLabel,
  });

  /// Whether the model believes the plant is healthy.
  bool get isHealthy => diseaseName.toLowerCase() == 'healthy';

  @override
  String toString() =>
      'DiagnosisResult(crop: $cropName, disease: $diseaseName, conf: ${confidence.toStringAsFixed(1)}%)';
}

/// Abstract offline TFLite inference service.
abstract class TFLiteService {
  Future<void> loadModel();
  Future<DiagnosisResult> classify(String imagePath);
  void dispose();
}

/// Global [TFLiteService] provider. 
/// Automatically loads mobile native TFLite implementation on Android/iOS,
/// and a no-op stub on Web to avoid compilation errors due to dart:ffi.
final tfliteServiceProvider = Provider<TFLiteService>((ref) {
  return getTFLiteService(ref);
});
