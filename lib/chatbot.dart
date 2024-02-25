import 'package:flutter/material.dart';
import 'package:pyph/api/gemini_api.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({Key? key}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  final TextEditingController textController = TextEditingController();
  final List<ChatMessage> chatHistory = [];
  bool isLoading = false; // Track loading state

  void sendMessage() async {
    String message = textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        isLoading = true; // Show loader
      });
      try {
        String response = await GeminiAPI.getGeminiData(message);
        setState(() {
          chatHistory.add(ChatMessage(text: message, isUserMessage: true));
          chatHistory.add(ChatMessage(text: response, isUserMessage: false));
          isLoading = false; // Hide loader
        });
      } catch (e) {
        print('Error fetching response: $e');
        setState(() {
          isLoading = false; // Hide loader
        });
      } finally {
        textController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Friend'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: chatHistory.length,
                  itemBuilder: (context, index) {
                    return ChatBubble(chatMessage: chatHistory[index]);
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Center(
              child: CircularProgressIndicator(), // Show loader
            ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;

  const ChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: chatMessage.isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: chatMessage.isUserMessage ? Colors.blue.withOpacity(0.8) : Colors.green.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Text(
            chatMessage.text,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
