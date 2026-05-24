import 'package:cloud_firestore/cloud_firestore.dart';

class DiagnosisHistoryModel {
  final String id;
  final String cropName;
  final String diseaseName;
  final double confidence;
  final String severity;
  final bool isHealthy;
  final DateTime timestamp;
  final Map<String, dynamic>? aiReportData;
  final String? imageUrl;

  DiagnosisHistoryModel({
    required this.id,
    required this.cropName,
    required this.diseaseName,
    required this.confidence,
    this.severity = 'Unknown',
    required this.isHealthy,
    required this.timestamp,
    this.aiReportData,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'cropName': cropName,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'severity': severity,
      'isHealthy': isHealthy,
      'timestamp': Timestamp.fromDate(timestamp),
      'aiReportData': aiReportData,
      'imageUrl': imageUrl,
    };
  }

  factory DiagnosisHistoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return DiagnosisHistoryModel(
      id: docId,
      cropName: map['cropName'] ?? '',
      diseaseName: map['diseaseName'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      severity: map['severity'] ?? 'Unknown',
      isHealthy: map['isHealthy'] ?? false,
      timestamp: map['timestamp'] != null 
          ? (map['timestamp'] as Timestamp).toDate() 
          : DateTime.now(),
      aiReportData: map['aiReportData'] as Map<String, dynamic>?,
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
