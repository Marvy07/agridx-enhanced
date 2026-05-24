import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  final key = dotenv.env['GROQ_API_KEY'] ?? '';
  print('Key length: ${key.length}');

  if (key.isEmpty) {
    print('Key is empty!');
    return;
  }

  final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'llama-3.1-8b-instant',
        'messages': [
          {'role': 'user', 'content': 'Hello'}
        ]
      }),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
  } catch(e) {
    print('Exception: $e');
  }
}
