  import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbaseAPI {
  // Chatbase API credentials
  static const String apiKey = '712e5f73-c55f-4532-a8d8-368df88bdd28';
  
  // Chatbot ID from: https://www.chatbase.co/dashboard/prajwal-gunnalas-workspace/chatbot/lpquUPoQ33vnM49z9JBdT/playground
  static const String chatbotId = 'lpquUPoQ33vnM49z9JBdT';

  // Message history for conversation context
  static final List<Map<String, String>> _messageHistory = [];

  // Send a text message and get AI text response
  static Future<String> getAgentReply(String userInput) async {
    print('DEBUG: ========================================');
    print('DEBUG: 🚀 Starting Chatbase request');
    print('DEBUG: 📝 User input: "$userInput"');
    print('DEBUG: 🔑 API Key (first 10 chars): ${apiKey.substring(0, 10)}...');
    print('DEBUG: 🤖 Chatbot ID: $chatbotId');
    
    // Check if chatbot ID is configured
    if (chatbotId == 'YOUR_CHATBOT_ID') {
      print('DEBUG: ❌ ERROR - Chatbot ID not configured!');
      throw Exception(
        'Please configure your Chatbot ID!\n\n'
        'Steps:\n'
        '1. Go to https://www.chatbase.co/dashboard\n'
        '2. Select your chatbot\n'
        '3. Go to Settings → General\n'
        '4. Copy the Chatbot ID (UUID format)\n'
        '5. Replace "YOUR_CHATBOT_ID" in lib/api/chatbase_api.dart'
      );
    }

    final url = Uri.parse('https://www.chatbase.co/api/v1/chat');
    print('DEBUG: 🌐 URL: $url');

    // Add user message to history
    _messageHistory.add({'role': 'user', 'content': userInput});
    print('DEBUG: 📚 History count: ${_messageHistory.length}');

    // Prepare messages array with conversation history
    final messages = _messageHistory.map((msg) => {
      'content': msg['content'],
      'role': msg['role'],
    }).toList();

    final body = {
      'messages': messages,
      'chatbotId': chatbotId,
      'stream': false, // Set to false for simple JSON response
    };

    print('DEBUG: � Request body:');
    print(jsonEncode(body));
    print('DEBUG: � Sending POST request...');

    final resp = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    print('DEBUG: � Response received!');
    print('DEBUG: 🔢 Status Code: ${resp.statusCode}');
    print('DEBUG: � Response Body: ${resp.body}');
    print('DEBUG: 🗂️ Response Headers: ${resp.headers}');

    if (resp.statusCode != 200) {
      print('DEBUG: ❌ ERROR - Non-200 status code!');
      throw Exception('Chatbase error ${resp.statusCode}: ${resp.body}');
    }

    final data = jsonDecode(resp.body);
    print('DEBUG: 🔍 Decoded JSON: $data');
    
    final reply = data['text'] as String? ?? 'Sorry, I could not generate a response.';
    print('DEBUG: 💬 Extracted reply: "$reply"');

    // Store assistant message in history
    _messageHistory.add({'role': 'assistant', 'content': reply});
    print('DEBUG: ✅ SUCCESS! Returning reply.');
    print('DEBUG: ========================================');

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
