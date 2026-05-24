import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

void main() async {
  // Try to read .env file manually since flutter_dotenv might fail in plain dart run
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ ERROR: .env file not found!');
    return;
  }
  
  final lines = await envFile.readAsLines();
  String? apiKey;
  for (final line in lines) {
    if (line.trim().startsWith('GEMINI_API_KEY=')) {
      apiKey = line.substring('GEMINI_API_KEY='.length).trim();
      break;
    }
  }

  if (apiKey == null || apiKey.isEmpty) {
    print('❌ ERROR: GEMINI_API_KEY is empty in .env!');
    return;
  }

  print('Found API Key ending in: ...\${apiKey.substring(apiKey.length > 5 ? apiKey.length - 5 : 0)}');

  try {
    print('Testing Gemini 2.5 Flash with user key...');
    final model25 = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
    final r25 = await model25.generateContent([Content.text('Hello')]);
    print('✅ Gemini 2.5: \${r25.text}');
  } catch (e) {
    print('❌ ERROR 2.5: ' + e.toString());
  }
}
