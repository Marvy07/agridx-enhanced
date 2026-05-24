import 'dart:typed_data';

class DiagnosisService {
  static Future<void> initialize() async {
    print('TFLite not supported on this platform. Initialization skipped.');
  }

  static Future<List<Map<String, dynamic>>> diagnose(Uint8List imageBytes, {String? cropFilter}) async {
    return [];
  }

  static String? validateImage(Uint8List imageBytes) => null;

  static String formatDiseaseName(String rawLabel) {
    final parts = rawLabel.split('___');
    if (parts.length >= 2) {
      final crop = parts[0].replaceAll('_', ' ');
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
