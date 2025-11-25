import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ElevenLabsAPI {
  // ElevenLabs API credentials
  static const String apiKey = '40254a8a0e10d078cd46eb2749eb5f9ec0ec43f14c1ba1e4854e529b24911dd6';
  
  // Agent ID from ElevenLabs dashboard
  static const String agentId = 'agent_9801k9j2cznxfc7ae9n3tfn835nd';

  // Message history for conversation context
  static final List<Map<String, String>> _messageHistory = [];
  
  // Conversation ID to maintain context across messages
  static String? _conversationId;
  
  // WebSocket connection
  static WebSocketChannel? _channel;
  static bool _isConnected = false;
  static StreamController<String>? _messageController;

  // Get signed WebSocket URL from ElevenLabs REST API
  static Future<String> _getSignedUrl() async {
    print('DEBUG: [URL] Getting signed WebSocket URL...');
    
    final url = Uri.parse(
      'https://api.elevenlabs.io/v1/convai/conversation/get_signed_url?agent_id=$agentId'
    );

    try {
      final response = await http.get(
        url,
        headers: {'xi-api-key': apiKey},
      );

      print('DEBUG: [URL] Signed URL response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final signedUrl = data['signed_url'] as String;
        print('DEBUG: [URL] Got signed URL: ${signedUrl.substring(0, 50)}...');
        return signedUrl;
      } else {
        throw Exception('Failed to get signed URL: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: [ERROR] Error getting signed URL: $e');
      rethrow;
    }
  }

  // Connect to WebSocket
  static Future<void> _connect() async {
    if (_isConnected && _channel != null) {
      print('DEBUG: [WS] Already connected to WebSocket');
      return;
    }

    try {
      print('DEBUG: [WS] Establishing WebSocket connection...');
      
      final signedUrl = await _getSignedUrl();
      _channel = WebSocketChannel.connect(Uri.parse(signedUrl));
      _messageController = StreamController<String>.broadcast();
      _isConnected = true;

      // Listen to WebSocket messages
      _channel!.stream.listen(
        (message) {
          print('DEBUG: [WS] Received WebSocket message: $message');
          _handleWebSocketMessage(message);
        },
        onError: (error) {
          print('DEBUG: [ERROR] WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          print('DEBUG: [WS] WebSocket connection closed');
          _isConnected = false;
        },
      );

      print('DEBUG: [WS] WebSocket connected successfully');
    } catch (e) {
      print('DEBUG: [ERROR] Error connecting to WebSocket: $e');
      _isConnected = false;
      rethrow;
    }
  }

  // Handle incoming WebSocket message
  static void _handleWebSocketMessage(dynamic message) {
    try {
      print('DEBUG: [WS] Parsing message...');
      
      // Try to parse as JSON
      final data = jsonDecode(message as String);
      print('DEBUG: [WS] Parsed JSON: $data');
      
      String? textResponse;
      
      // **CORRECT FORMAT**: ElevenLabs ConvAI sends text in agent_response_event
      if (data.containsKey('agent_response_event') && data['agent_response_event'] is Map) {
        textResponse = data['agent_response_event']['agent_response'];
        print('DEBUG: [RESPONSE] Found agent response: "$textResponse"');
      }
      // Fallback to other possible formats
      else if (data.containsKey('text')) {
        textResponse = data['text'];
        print('DEBUG: [RESPONSE] Found text in "text" field');
      } else if (data.containsKey('message')) {
        if (data['message'] is String) {
          textResponse = data['message'];
        } else if (data['message'] is Map) {
          textResponse = data['message']['text'] ?? data['message']['content'];
        }
        print('DEBUG: [RESPONSE] Found text in "message" field');
      } else if (data.containsKey('response')) {
        if (data['response'] is String) {
          textResponse = data['response'];
        } else if (data['response'] is Map) {
          textResponse = data['response']['text'];
        }
        print('DEBUG: [RESPONSE] Found text in "response" field');
      } else if (data.containsKey('content')) {
        textResponse = data['content'];
        print('DEBUG: [RESPONSE] Found text in "content" field');
      }
      
      // Store conversation ID if provided
      if (data.containsKey('conversation_id')) {
        _conversationId = data['conversation_id'];
        print('DEBUG: [CONV] Saved conversation ID: $_conversationId');
      }
      
      // Emit text response ONLY if found (ignore other message types like ping, audio, etc.)
      if (textResponse != null && textResponse.isNotEmpty) {
        print('DEBUG: [EMIT] Emitting text response: "$textResponse"');
        _messageController?.add(textResponse);
      } else {
        print('DEBUG: [SKIP] No text found in message (likely ping/audio/metadata - ignoring)');
      }
    } catch (e) {
      print('DEBUG: [WARN] Error parsing JSON, treating as plain text: $e');
      // If JSON parsing fails, treat as plain text
      final plainText = message.toString();
      if (plainText.isNotEmpty) {
        _messageController?.add(plainText);
      }
    }
  }

  // Send a text message and get AI text response via WebSocket
  static Future<String> getAgentReply(String userInput) async {
    print('DEBUG: ========================================');
    print('DEBUG: [AGENT] Starting ElevenLabs Agent request (WebSocket)');
    print('DEBUG: [INPUT] User input: "$userInput"');
    
    // Add user message to history
    _messageHistory.add({'role': 'user', 'content': userInput});
    print('DEBUG: [HISTORY] Count: ${_messageHistory.length}');

    try {
      // Ensure WebSocket connection
      await _connect();

      if (!_isConnected || _channel == null) {
        throw Exception('Failed to establish WebSocket connection');
      }

      // Prepare message - trying common formats
      final messagePayload = jsonEncode({
        'text': userInput,
        'type': 'user_message',
        if (_conversationId != null) 'conversation_id': _conversationId,
      });

      print('DEBUG: [SEND] Sending message via WebSocket: $messagePayload');
      _channel!.sink.add(messagePayload);

      // Wait for response with 30 second timeout
      print('DEBUG: [WAIT] Waiting for response...');
      final response = await _messageController!.stream.first.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('DEBUG: [TIMEOUT] Response timeout');
          return 'I apologize, but the response is taking longer than expected. Please try again.';
        },
      );

      print('DEBUG: [SUCCESS] Got response: "$response"');

      // Store assistant message in history
      _messageHistory.add({'role': 'assistant', 'content': response});
      print('DEBUG: [DONE] SUCCESS! Returning reply.');
      print('DEBUG: ========================================');

      return response;
    } catch (e) {
      print('DEBUG: [ERROR] EXCEPTION: $e');
      print('DEBUG: ========================================');
      
      // Clean up connection on error
      _disconnect();
      
      return 'I apologize, but I\'m having trouble connecting right now. Please check your internet connection and try again.';
    }
  }

  // Disconnect WebSocket
  static void _disconnect() {
    print('DEBUG: [WS] Disconnecting WebSocket...');
    _channel?.sink.close();
    _channel = null;
    _messageController?.close();
    _messageController = null;
    _isConnected = false;
  }

  // Reset conversation (UI helper)
  static void resetConversation() {
    _messageHistory.clear();
    _conversationId = null;
    _disconnect(); // Also disconnect WebSocket for fresh start
    print('DEBUG: [RESET] Conversation reset');
  }

  static List<Map<String, String>> getConversationHistory() {
    return List.from(_messageHistory);
  }
}
