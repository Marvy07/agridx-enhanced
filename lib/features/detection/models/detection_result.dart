class DetectionResult {
  final String id;
  final String type;
  final String diseaseName;
  final double confidence;
  final String severity;
  final String description;
  final List<String> treatments;
  final List<String> imageUrls;
  final DateTime timestamp;

  const DetectionResult({
    required this.id,
    required this.type,
    required this.diseaseName,
    required this.confidence,
    required this.severity,
    required this.description,
    required this.treatments,
    required this.imageUrls,
    required this.timestamp,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] as String,
      type: json['type'] as String,
      diseaseName: json['disease_name'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String,
      description: json['description'] as String,
      treatments: List<String>.from(json['treatments'] as List),
      imageUrls: List<String>.from(json['image_urls'] as List),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'disease_name': diseaseName,
        'confidence': confidence,
        'severity': severity,
        'description': description,
        'treatments': treatments,
        'image_urls': imageUrls,
        'timestamp': timestamp.toIso8601String(),
      };
}
