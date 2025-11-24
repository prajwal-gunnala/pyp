import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pyph/api/elevenlabs_api.dart';
import 'services/user_profile_service.dart';
import 'services/tts_service.dart';
import 'services/wellness_service.dart';
import 'services/chat_history_service.dart';
import 'widgets/talking_bot_avatar.dart';
import 'models/navigation_action.dart';
import 'music.dart';
import 'games.dart';
import 'doctor.dart';
import 'assessment.dart';
import 'diary_page.dart';
import 'micro_tasks_page.dart';
import 'voice_chat_page.dart';
import 'calendar_page.dart';

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
  bool isTalkingBotEnabled = false;
  bool isSpeaking = false;
  

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _loadTodaysChatHistory(); // Load history FIRST
    _loadUserProfileAndGreet(); // Then add greeting if needed
  }

  Future<void> _initializeTts() async {
    await TtsService.initialize();
    
    // Set up callbacks for animation synchronization
    TtsService.onSpeakStart = () {
      if (mounted) {
        setState(() {
          isSpeaking = true;
        });
      }
    };
    
    TtsService.onSpeakComplete = () {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
      }
    };
    
    TtsService.onSpeakError = (error) {
      if (mounted) {
        setState(() {
          isSpeaking = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voice error: $error', style: GoogleFonts.lato()),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    };
  }

  /// Load user profile and add greeting ONLY if chat history is empty
  /// This prevents the greeting from being shown and then immediately cleared
  Future<void> _loadUserProfileAndGreet() async {
    try {
      // Update streak for today
      await UserProfileService.updateStreakForToday();
      
      // Increment session count
      await UserProfileService.incrementSessions();
      
      // Wait a bit for history to fully load
      await Future.delayed(Duration(milliseconds: 150));
      
      // Only add greeting if no chat history exists for today
      if (!mounted) return;
      
      if (chatHistory.isEmpty) {
        final name = await UserProfileService.getUserName();
        if (name != null && name.trim().isNotEmpty) {
          setState(() {
            chatHistory.add(
              ChatMessage(
                text:
                    'Hi ${name.trim()}, I\'m glad you\'re here today. We can talk about whatever is on your mind, or I can suggest some small exercises, music, or games to help you feel a bit better.',
                isUserMessage: false,
              ),
            );
          });
        }
      }
    } catch (_) {
      // If loading fails, just skip personalized greeting.
    }
  }
  
  /// Load chat history for today from local storage
  /// This allows the bot to remember conversations within the same day
  Future<void> _loadTodaysChatHistory() async {
    try {
      final savedHistory = await ChatHistoryService.loadTodayHistory();
      if (!mounted) return;
      
      if (savedHistory.isNotEmpty) {
        setState(() {
          chatHistory.clear();
          chatHistory.addAll(savedHistory);
        });
        
        // Scroll to bottom to show latest messages
        Future.delayed(Duration(milliseconds: 300), () {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('Error loading chat history: $e');
      // If loading fails, just continue with empty history
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    textController.dispose();
    TtsService.dispose();
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
        final responseText = await ElevenLabsAPI.getAgentReply(message);
        
        // Parse navigation actions from response
        final actions = NavigationAction.parseFromResponse(responseText);
        final cleanText = NavigationAction.cleanResponse(responseText);
        
        setState(() {
          chatHistory.add(ChatMessage(
            text: cleanText,
            isUserMessage: false,
            actions: actions,
          ));
          isLoading = false;
        });
        _scrollToBottom();
        
        // Save chat history to local storage after each exchange
        await ChatHistoryService.saveTodayHistory(chatHistory);
        
        // Record conversation in wellness service
        await WellnessService.recordConversation(
          userMessage: message,
          botResponse: cleanText,
          navigationUsed: actions.isNotEmpty,
        );
        
        // Speak the response if talking bot is enabled
        if (isTalkingBotEnabled) {
          await TtsService.speak(cleanText);
        }
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
        
        // Save even error messages to maintain conversation continuity
        await ChatHistoryService.saveTodayHistory(chatHistory);
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
            'This will clear today\'s conversation and start fresh. Previous days\' conversations are preserved.',
            style: GoogleFonts.lato(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.lato(color: Colors.black54)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Clear today's chat history from local storage
                await ChatHistoryService.clearTodayHistory();
                
                setState(() {
                  chatHistory.clear();
                  ElevenLabsAPI.resetConversation();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Started a new conversation for today', style: GoogleFonts.lato()),
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
            icon: Icon(Icons.menu_rounded, color: Colors.black87, size: 28),
            color: Color(0xFFF3EDE0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            offset: Offset(0, 50),
            itemBuilder: (BuildContext context) => [
              // New Conversation
              PopupMenuItem<String>(
                value: 'new_conversation',
                child: Row(
                  children: [
                    Icon(Icons.refresh_rounded, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'New Conversation',
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                enabled: false,
                child: Divider(color: Color(0xFFDBC59C), thickness: 1),
              ),
              // Categories Header
              PopupMenuItem<String>(
                enabled: false,
                child: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    'CATEGORIES',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B7355),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              // Calendar (TOP PRIORITY - Wellness tracking)
              PopupMenuItem<String>(
                value: 'calendar',
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: Color(0xFF4CAF50), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Wellness Calendar',
                      style: GoogleFonts.lato(
                        fontSize: 15, 
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Music
              PopupMenuItem<String>(
                value: 'music',
                child: Row(
                  children: [
                    Icon(Icons.music_note_rounded, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Healing Music',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Games
              PopupMenuItem<String>(
                value: 'games',
                child: Row(
                  children: [
                    Icon(Icons.games_rounded, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Relaxation Games',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Assessment
              PopupMenuItem<String>(
                value: 'assessment',
                child: Row(
                  children: [
                    Icon(Icons.assignment_rounded, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Mental Check-in',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Diary
              PopupMenuItem<String>(
                value: 'diary',
                child: Row(
                  children: [
                    Icon(Icons.book_outlined, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'My Journal',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Tasks
              PopupMenuItem<String>(
                value: 'tasks',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Daily Tasks',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Consultants
              PopupMenuItem<String>(
                value: 'doctor',
                child: Row(
                  children: [
                    Icon(Icons.medical_services_rounded, color: Color(0xFF5D4E37), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Find Consultant',
                      style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              if (value == 'new_conversation') {
                _resetConversation();
              } else if (value == 'calendar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CalendarPage()),
                );
              } else if (value == 'music') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Music()),
                );
              } else if (value == 'games') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Games()),
                );
              } else if (value == 'assessment') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Assessment()),
                );
              } else if (value == 'diary') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DiaryPage()),
                );
              } else if (value == 'tasks') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MicroTasksPage()),
                );
              } else if (value == 'doctor') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Doctor()),
                );
              }
            },
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Talking bot avatar (always visible when voice is enabled)
                if (isTalkingBotEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TalkingBotAvatar(
                      isSpeaking: isSpeaking,
                      size: 80,
                    ),
                  ),
                Row(
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
                    // Voice Chat button (opens full-screen voice page)
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFF8B7355),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF5D4E37),
                          width: 2,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.mic,
                          color: Color(0xFFF3EDE0),
                        ),
                        tooltip: 'Voice Chat',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceChatPage(),
                            ),
                          );
                        },
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
  final List<NavigationAction> actions;

  ChatMessage({
    required this.text, 
    required this.isUserMessage,
    this.actions = const [],
  });
  
  /// Convert ChatMessage to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUserMessage': isUserMessage,
      'actions': actions.map((action) => action.toJson()).toList(),
    };
  }
  
  /// Create ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String,
      isUserMessage: json['isUserMessage'] as bool,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((actionJson) => NavigationAction.fromJson(actionJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ChatBubble extends StatelessWidget {
  final ChatMessage chatMessage;

  const ChatBubble({Key? key, required this.chatMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: chatMessage.isUserMessage 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: chatMessage.isUserMessage 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            children: [
              if (!chatMessage.isUserMessage)
                CircleAvatar(
                  backgroundColor: Colors.black87,
                  radius: 16,
                  child: Icon(Icons.psychology_rounded, 
                      color: Color(0xFFF3EDE0), size: 18),
                ),
              if (!chatMessage.isUserMessage) SizedBox(width: 12),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: chatMessage.isUserMessage 
                        ? Colors.black87 
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomLeft: chatMessage.isUserMessage 
                          ? Radius.circular(20) 
                          : Radius.circular(4),
                      bottomRight: chatMessage.isUserMessage 
                          ? Radius.circular(4) 
                          : Radius.circular(20),
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
                      color: chatMessage.isUserMessage 
                          ? Colors.white 
                          : Colors.black87,
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
                  child: Icon(Icons.person_rounded, 
                      color: Color(0xFFF3EDE0), size: 18),
                ),
            ],
          ),
          // Action buttons (only for bot messages with actions)
          if (!chatMessage.isUserMessage && chatMessage.actions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chatMessage.actions.map((action) {
                  return _buildActionButton(context, action);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, NavigationAction action) {
    return ElevatedButton.icon(
      onPressed: () => _handleNavigation(context, action.target),
      icon: Icon(action.getIcon(), size: 18),
      label: Text(
        action.getShortLabel(),
        style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF5D4E37),
        foregroundColor: Color(0xFFF3EDE0),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 2,
      ),
    );
  }

  void _handleNavigation(BuildContext context, String target) {
    Widget? page;
    
    switch (target.toLowerCase()) {
      case 'music':
        page = Music();
        break;
      case 'games':
        page = Games();
        break;
      case 'assessment':
        page = Assessment();
        break;
      case 'diary':
        page = DiaryPage();
        break;
      case 'tasks':
        page = MicroTasksPage();
        break;
      case 'doctor':
        page = Doctor();
        break;
      default:
        // Show snackbar for unknown target
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Feature not available', 
                style: GoogleFonts.lato()),
            backgroundColor: Colors.red.shade700,
          ),
        );
        return;
    }
    
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => page!),
    );
  }
}
