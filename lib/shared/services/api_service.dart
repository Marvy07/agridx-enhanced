import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import '../../features/detection/models/detection_result.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static String get _baseUrl {
    try {
      final url = dotenv.env['BACKEND_URL'];
      return (url != null && url.isNotEmpty) ? url : '';
    } catch (_) {
      return '';
    }
  }

  bool get _isOffline => _baseUrl.isEmpty;

  Future<String?> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    return user?.getIdToken();
  }

  Future<Map<String, String>> _headers() async {
    final token = await _idToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: response.body,
    );
  }

  Future<DetectionResult> detectPlant(File image) async {
    if (_isOffline) {
      return _mockDetectionResult('plant');
    }

    final token = await _idToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/detect/plant'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return DetectionResult.fromJson(_decode(response));
  }

  Future<DetectionResult> detectAnimal(File image, String species) async {
    if (_isOffline) {
      return _mockDetectionResult('animal');
    }

    final token = await _idToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/detect/animal'),
    );
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    request.fields['species'] = species;

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    return DetectionResult.fromJson(_decode(response));
  }

  Future<Map<String, dynamic>> symptomCheck(
    String symptoms,
    String subjectType,
  ) async {
    if (_isOffline) {
      return {
        'possible_conditions': ['Mock Condition A', 'Mock Condition B'],
        'recommendations': 'Consult a veterinarian or agronomist.',
        'subject_type': subjectType,
      };
    }

    final headers = await _headers();
    final response = await http.post(
      Uri.parse('$_baseUrl/symptom-check'),
      headers: headers,
      body: jsonEncode({'symptoms': symptoms, 'subject_type': subjectType}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> getHealth() async {
    if (_isOffline) {
      return {'status': 'offline', 'message': 'Backend URL not configured'};
    }

    final headers = await _headers();
    final response = await http.get(
      Uri.parse('$_baseUrl/health'),
      headers: headers,
    );
    return _decode(response);
  }

  DetectionResult _mockDetectionResult(String type) {
    return DetectionResult(
      id: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      diseaseName: 'Mock Disease',
      confidence: 0.85,
      severity: 'moderate',
      description: 'This is a mock detection result for offline development.',
      treatments: ['Treatment A', 'Treatment B'],
      imageUrls: [],
      timestamp: DateTime.now(),
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
