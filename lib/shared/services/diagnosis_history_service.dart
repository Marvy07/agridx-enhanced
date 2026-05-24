import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/diagnosis_history_model.dart';
import 'auth_service.dart';

class DiagnosisHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> saveDiagnosis(String userId, DiagnosisHistoryModel diagnosis, {File? imageFile}) async {
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('diagnoses')
        .doc(); // Auto-generate ID

    String? imageUrl;
    if (imageFile != null) {
      try {
        final storageRef = _storage.ref().child('users/$userId/diagnoses/${docRef.id}.jpg');
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      } catch (e) {
        print('Error uploading diagnosis image: $e');
      }
    }

    final newDiagnosis = DiagnosisHistoryModel(
      id: docRef.id,
      cropName: diagnosis.cropName,
      diseaseName: diagnosis.diseaseName,
      confidence: diagnosis.confidence,
      severity: diagnosis.severity,
      isHealthy: diagnosis.isHealthy,
      timestamp: diagnosis.timestamp,
      imageUrl: imageUrl,
    );

    await docRef.set(newDiagnosis.toMap());

    // Also update totalScans and totalDiagnoses on the user document
    await _db.collection('users').doc(userId).update({
      'totalScans': FieldValue.increment(1),
      if (!diagnosis.isHealthy) 'totalDiagnoses': FieldValue.increment(1),
      'communityPoints': FieldValue.increment(1), // +1 pt for scan
    });

    return docRef.id;
  }

  Future<void> updateDiagnosisReport(String userId, String diagnosisId, Map<String, dynamic> aiReportData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('diagnoses')
        .doc(diagnosisId)
        .update({'aiReportData': aiReportData});
  }

  Stream<List<DiagnosisHistoryModel>> getDiagnoses(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('diagnoses')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DiagnosisHistoryModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

final diagnosisHistoryServiceProvider = Provider<DiagnosisHistoryService>((ref) {
  return DiagnosisHistoryService();
});

final userDiagnosesProvider = StreamProvider<List<DiagnosisHistoryModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);
  return ref.watch(diagnosisHistoryServiceProvider).getDiagnoses(user.uid);
});
