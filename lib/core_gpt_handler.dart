import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CoreGPTHelper {
  static final String? _apiKey = dotenv.env['OPENAI_API_KEY'];

  static Future<String> sendCommandToGPT(String userCommand) async {
    const url = 'https://api.openai.com/v1/chat/completions';

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
    };

    final body = jsonEncode({
      'model': 'gpt-4o',
      'messages': [
        {
          'role': 'system',
          'content': 'You are a Flutter code generator assistant helping build futuristic mobile apps with security, avatars, and animation.'
        },
        {
          'role': 'user',
          'content': userCommand,
        }
      ],
      'temperature': 0.7,
      'max_tokens': 2048,
      'top_p': 1,
      'frequency_penalty': 0,
      'presence_penalty': 0,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final reply = decoded['choices'][0]['message']['content'];
        return reply.toString();
      } else {
        return '❌ GPT Error (${response.statusCode}): ${response.body}';
      }
    } catch (e) {
      return '❌ Network or API error: $e';
    }
  }
}
