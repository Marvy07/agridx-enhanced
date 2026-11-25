import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../core/constants.dart';
import 'gemini_rate_limiter.dart';

class GeminiService {
  final String _apiKey = ApiConstants.geminiApiKey;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  final _rateLimiter = GeminiRateLimiter();
  final _diagnosisCache = <String, Map<String, dynamic>>{};

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 1000,
        responseMimeType: 'application/json',
      ),
    );
    _visionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.4,
        maxOutputTokens: 2000,
        responseMimeType: 'application/json',
      ),
    );
  }

  final String _pathologistSystemPrompt = """
You are an expert plant pathologist. 
Provide detailed diagnosis information in JSON format only.
The JSON must follow this structure:
{
  "description": "2 sentence description",
  "symptoms": ["bullet 1", "bullet 2", "bullet 3"],
  "chemical_treatment": [{"product": "name", "dosage": "amount"}, {"product": "name", "dosage": "amount"}],
  "organic_treatment": ["method 1", "method 2"],
  "prevention": ["tip 1", "tip 2", "tip 3"]
}
""";

  Future<Map<String, dynamic>> getDiagnosisDetails(String diseaseName, double confidence, String cropName) async {
    if (_diagnosisCache.containsKey(diseaseName)) {
      print('Returning cached diagnosis for $diseaseName');
      return _diagnosisCache[diseaseName]!;
    }

    final prompt = """
$_pathologistSystemPrompt

The AI model detected $diseaseName with ${confidence.toStringAsFixed(1)}% confidence on a $cropName plant. 
Provide the detailed report in the requested JSON format.
""";

    try {
      final result = await _retryWithBackoff(() async {
        await _rateLimiter.waitForSlot();
        final response = await _model.generateContent([Content.text(prompt)]);

        print('Gemini SDK Diagnosis Response Status: Success');
        print('Gemini SDK Diagnosis Response Body: ${response.text}');

        String text = response.text ?? '';
        
        // Find the actual JSON block in case the model added conversational text
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          text = text.substring(startIndex, endIndex + 1);
        }
        
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        Map<String, dynamic> decoded = json.decode(text) as Map<String, dynamic>;
        
        // Sometimes the AI nests the result in "report" or "disease"
        if (decoded.containsKey('report') && decoded['report'] is Map) {
          decoded = decoded['report'] as Map<String, dynamic>;
        } else if (decoded.containsKey('disease') && decoded['disease'] is Map) {
          decoded = decoded['disease'] as Map<String, dynamic>;
        }
        
        // Make keys lowercase to avoid capitalization issues
        final Map<String, dynamic> normalizedData = {};
        decoded.forEach((key, value) {
          normalizedData[key.toLowerCase()] = value;
        });
        
        return normalizedData;
      });
      _diagnosisCache[diseaseName] = result;
      return result;
    } catch (e) {
      print('Gemini SDK Diagnosis Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVisionDiagnosis(List<int> imageBytes) async {
    final prompt = """
$_pathologistSystemPrompt

Analyze this crop leaf image. Identify any plant diseases visible. 
Return JSON with the disease name, confidence (0-100), and the detailed report as defined in the structure. 
Make sure the top-level JSON includes "diseaseName" and "confidence" fields.
""";

    try {
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(imageBytes)),
        ])
      ];

      return await _retryWithBackoff(() async {
        await _rateLimiter.waitForSlot();
        final response = await _visionModel.generateContent(content);

        print('Gemini SDK Vision Response Status: Success');
        print('Gemini SDK Vision Response Body: ${response.text}');

        String text = response.text ?? '';
        
        final startIndex = text.indexOf('{');
        final endIndex = text.lastIndexOf('}');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          text = text.substring(startIndex, endIndex + 1);
        }
        
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        
        Map<String, dynamic> decoded = json.decode(text) as Map<String, dynamic>;
        
        // Handle nesting if the AI wrapped the detailed report
        if (decoded.containsKey('report') && decoded['report'] is Map) {
          final report = decoded['report'] as Map<String, dynamic>;
          decoded.addAll(report);
        }
        
        final Map<String, dynamic> normalizedData = {};
        decoded.forEach((key, value) {
          normalizedData[key.toLowerCase()] = value;
        });
        
        return {
          ...normalizedData,
          'diseaseName': normalizedData['diseasename'] ?? normalizedData['disease_name'] ?? 'Unknown Disease',
          'confidence': (normalizedData['confidence'] is num) ? (normalizedData['confidence'] as num).toDouble() : 0.0,
        };
      });
    } catch (e) {
      print('Gemini SDK Vision Error: $e');
      rethrow;
    }
  }

  Future<void> testConnection() async {
    print('Testing Gemini SDK Connection...');
    try {
      await _retryWithBackoff(() async {
        await _rateLimiter.waitForSlot();
        final response = await _model.generateContent([Content.text('hello')]);
        print('Gemini SDK Test Connection SUCCESS: ${response.text}');
      });
    } catch (e) {
      print('Gemini SDK Test Connection Error: $e');
    }
  }

  Future<T> _retryWithBackoff<T>(Future<T> Function() action) async {
    int retryCount = 0;
    int waitSeconds = 5;
    while (true) {
      try {
        return await action();
      } catch (e) {
        final errStr = e.toString();
        // Check for 429 rate limit errors in SDK exceptions
        if ((errStr.contains('429') || errStr.contains('RESOURCE_EXHAUSTED')) && retryCount < 3) {
          print('Gemini Rate Limit hit. Retrying in $waitSeconds seconds... (Attempt ${retryCount + 1})');
          await Future.delayed(Duration(seconds: waitSeconds));
          retryCount++;
          waitSeconds *= 2;
        } else {
          rethrow;
        }
      }
    }
  }
}

final geminiServiceProvider = Provider((ref) => GeminiService());
