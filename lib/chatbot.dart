import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pyph/api/chatbase_api.dart';

class ChatBot extends StatefulWidget {
  const ChatBot({Key? key}) : super(key: key);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> with SingleTickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();
  final List<ChatMessage> chatHistory = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  

  @override
  void initState() {
    super.initState();
    // No need to connect - using REST API now
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    String message = textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        chatHistory.add(ChatMessage(text: message, isUserMessage: true));
        isLoading = true;
      });
      textController.clear();
      
      _scrollToBottom();
      
      try {
        final responseText = await ChatbaseAPI.getAgentReply(message);
        setState(() {
          chatHistory.add(ChatMessage(
            text: responseText,
            isUserMessage: false,
          ));
          isLoading = false;
        });
        _scrollToBottom();
      } catch (e) {
        print('Error fetching response: $e');
        setState(() {
          chatHistory.add(ChatMessage(
            text: 'Error: Unable to get response. Please try again.', 
            isUserMessage: false
          ));
          isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetConversation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFFF3EDE0),
          title: Text('New Conversation', style: GoogleFonts.abrilFatface(fontSize: 20)),
          content: Text(
            'This will start a fresh conversation. The AI will not remember previous messages.',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.lato(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  chatHistory.clear();
                  ChatbaseAPI.resetConversation();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Started a new conversation', style: GoogleFonts.lato()),
                    backgroundColor: Colors.black87,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
              ),
              child: Text('Start New', style: GoogleFonts.lato()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3EDE0),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.black87,
              child: Icon(Icons.psychology_rounded, color: Color(0xFFF3EDE0)),
            ),
            SizedBox(width: 12),
            Text('AI Friend', style: GoogleFonts.abrilFatface(fontSize: 20)),
          ],
        ),
        backgroundColor: Color(0xFFF3EDE0),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: Colors.black87),
            onSelected: (value) {
              if (value == 'reset') {
                _resetConversation();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.black87),
                    SizedBox(width: 12),
                    Text('New Conversation', style: GoogleFonts.lato(fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (chatHistory.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 80, color: Colors.black26),
                    SizedBox(height: 16),
                    Text(
                      'Start a conversation',
                      style: GoogleFonts.abrilFatface(fontSize: 20, color: Colors.black54),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your AI friend is here to listen',
                      style: GoogleFonts.lato(fontSize: 16, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16),
                itemCount: chatHistory.length,
                itemBuilder: (context, index) {
                  return ChatBubble(chatMessage: chatHistory[index]);
                },
              ),
            ),
          if (isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black87,
                    radius: 16,
                    child: Icon(Icons.psychology_rounded, color: Color(0xFFF3EDE0), size: 18),
                  ),
                  SizedBox(width: 12),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87),
                        ),
                        SizedBox(width: 12),
                        Text('Thinking...', style: GoogleFonts.lato(color: Colors.black54)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF3EDE0),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: TextField(
                      controller: textController,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: GoogleFonts.lato(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      style: GoogleFonts.lato(fontSize: 16),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Send button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send_rounded, color: Color(0xFFF3EDE0)),
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({
    required this.text, 
    required this.isUserMessage,
  });
}

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;

  const ChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: chatMessage.isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!chatMessage.isUserMessage)
            CircleAvatar(
              backgroundColor: Colors.black87,
              radius: 16,
              child: Icon(Icons.psychology_rounded, color: Color(0xFFF3EDE0), size: 18),
            ),
          if (!chatMessage.isUserMessage) SizedBox(width: 12),
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: chatMessage.isUserMessage ? Colors.black87 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomLeft: chatMessage.isUserMessage ? Radius.circular(20) : Radius.circular(4),
                  bottomRight: chatMessage.isUserMessage ? Radius.circular(4) : Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                chatMessage.text,
                style: GoogleFonts.lato(
                  color: chatMessage.isUserMessage ? Colors.white : Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (chatMessage.isUserMessage) SizedBox(width: 12),
          if (chatMessage.isUserMessage)
            CircleAvatar(
              backgroundColor: Colors.black87,
              radius: 16,
              child: Icon(Icons.person_rounded, color: Color(0xFFF3EDE0), size: 18),
            ),
        ],
      ),
    );
  }
}
