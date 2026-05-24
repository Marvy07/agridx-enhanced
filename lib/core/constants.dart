import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get groqApiKey => dotenv.env['GROQ_API_KEY'] ?? '';
  static String get newsApiKey => dotenv.env['NEWS_API_KEY'] ?? '';
  static String get openWeatherApiKey => dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  static const String geminiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String groqBaseUrl = 'https://api.groq.com/openai/v1';
  static const String newsBaseUrl = 'https://newsapi.org/v2';

  static const String newsSearchQuery = 'crop disease agriculture farming Africa';
}
