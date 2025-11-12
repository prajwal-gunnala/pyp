import 'dart:convert';
import 'package:http/http.dart' as http;

class ElevenLabsAPI {
  // Chatbase credentials
  static const String apiKey = '712e5f73-c55f-4532-a8d8-368df88bdd28';
  
  // Chatbot ID from: https://www.chatbase.co/dashboard/prajwal-gunnalas-workspace/chatbot/lpquUPoQ33vnM49z9JBdT/playground
  static const String chatbotId = 'lpquUPoQ33vnM49z9JBdT';

  // Message history for optional UI display
  static final List<Map<String, String>> _messageHistory = [];

  // Send a text message and get AI text response from Chatbase
  static Future<String> getAgentReply(String userInput) async {
    print('DEBUG: 📤 Sending to Chatbase: $userInput');
    
    final url = Uri.parse('https://www.chatbase.co/api/v1/chat');

    // Record user message in local UI history
    _messageHistory.add({'role': 'user', 'content': userInput});

    final body = {
      'messages': [
        {'content': userInput, 'role': 'user'}
      ],
      'chatbotId': chatbotId,
      'stream': false,
      'temperature': 0.7,
    };

    print('DEBUG: 📨 Request body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('DEBUG: 📥 Response status: ${response.statusCode}');
    print('DEBUG: 📥 Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Chatbase error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    String reply = data['text'] ?? 'Sorry, I could not generate a response.';

    // Store assistant message in local UI history
    _messageHistory.add({'role': 'assistant', 'content': reply});

    print('DEBUG: ✅ Got reply: $reply');
    return reply;
  }

  // Reset conversation (UI helper)
  static void resetConversation() {
    _messageHistory.clear();
  }

  static List<Map<String, String>> getConversationHistory() {
    return List.from(_messageHistory);
  }
}
