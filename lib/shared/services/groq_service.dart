import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';

class GroqService {
  final String _apiKey = ApiConstants.groqApiKey;
  final String _baseUrl = ApiConstants.groqBaseUrl;
  final String _model = 'llama-3.1-8b-instant';

  final String _agriBotSystemPrompt = """
You are AgriBot, an expert AI assistant for African farmers. 
You specialize in crop diseases, pest management, fertilizer recommendations, weather interpretation, and farming best practices in Cameroon and West Africa. 
Give practical, actionable advice in simple language. 
When diagnosing diseases always mention: disease name, symptoms, treatment options, prevention tips.
""";

  Future<String> getChatResponse(List<Map<String, String>> history) async {
    if (_apiKey.isEmpty) {
      return "Groq API key is missing. Please add GROQ_API_KEY to your .env file.";
    }

    final url = Uri.parse('$_baseUrl/chat/completions');

    final messages = [
      {'role': 'system', 'content': _agriBotSystemPrompt},
    ];

    for (var m in history) {
      messages.add({
        'role': m['role'] == 'user' ? 'user' : 'assistant',
        'content': m['text'] ?? '',
      });
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'No response from AI.';
      } else {
        final data = jsonDecode(response.body);
        final errorMessage = data['error']?['message'] ?? response.body;
        return "Groq API Error (${response.statusCode}): $errorMessage\n\nPlease check your GROQ_API_KEY in the .env file.";
      }
    } catch (e) {
      return "Network Error: Could not connect to Groq. Please check your internet connection. Details: $e";
    }
  }

  Future<String> getWeatherSummary(String location, double temp, double humidity, String condition, List<String> forecast) async {
    if (_apiKey.isEmpty) {
      return "Groq API key is missing.";
    }

    final prompt = """
$_agriBotSystemPrompt

The current weather in $location is $temp°C, $humidity% humidity, with $condition conditions.
The forecast for the next few days includes: ${forecast.join(', ')}.

Provide a short, practical farming advisory (2-3 sentences) based on this weather. Focus on pest/disease risk, irrigation needs, or field work suitability. Do not use markdown formatting.
""";

    final url = Uri.parse('$_baseUrl/chat/completions');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.7,
          'max_tokens': 150,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['choices'][0]['message']['content'] as String).trim();
      } else {
        print('Groq API Weather Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get weather summary from Groq');
      }
    } catch (e) {
      print('Groq Weather Error: $e');
      rethrow;
    }
  }
}

final groqServiceProvider = Provider((ref) => GroqService());
