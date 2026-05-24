import 'dart:typed_data';

class DiagnosisService {
  static Future<void> initialize() async {
    print('Web uses Gemini AI, skipping TFLite offline initialization.');
  }

  static Future<List<Map<String, dynamic>>> diagnose(Uint8List imageBytes, {String? cropFilter}) async {
    // Web relies on Gemini Vision API, so offline TFLite returns a mock prediction for testing
    return [
      {'label': 'Tomato___Bacterial_spot', 'confidence': '92.4', 'confidenceValue': 0.924},
      {'label': 'Tomato___Early_blight', 'confidence': '6.1', 'confidenceValue': 0.061},
      {'label': 'Tomato___healthy', 'confidence': '1.5', 'confidenceValue': 0.015},
    ];
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
