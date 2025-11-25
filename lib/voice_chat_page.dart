import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:pyph/api/elevenlabs_api.dart';
import 'package:pyph/services/tts_service.dart';
import 'package:pyph/widgets/talking_bot_avatar.dart';

class VoiceChatPage extends StatefulWidget {
  const VoiceChatPage({super.key});

  @override
  _VoiceChatPageState createState() => _VoiceChatPageState();
}

class _VoiceChatPageState extends State<VoiceChatPage> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _isThinking = false;
  String _displayText = 'Tap the microphone to speak';
  String _userSpeechText = '';

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTts();
  }

  Future<void> _initSpeechToText() async {
    _speechToText = stt.SpeechToText();
    await _speechToText.initialize(
      onError: (error) => print('Speech recognition error: $error'),
      onStatus: (status) => print('Speech recognition status: $status'),
    );
  }

  Future<void> _initTts() async {
    await TtsService.initialize();
    
    TtsService.onSpeakStart = () {
      if (mounted) {
        setState(() {
          _isSpeaking = true;
        });
      }
    };
    
    TtsService.onSpeakComplete = () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
          _displayText = 'Tap the microphone to speak';
        });
      }
    };
  }

  Future<void> _startListening() async {
    if (!_speechToText.isAvailable) {
      setState(() {
        _displayText = 'Speech recognition not available';
      });
      return;
    }

    setState(() {
      _isListening = true;
      _userSpeechText = '';
      _displayText = 'Listening...';
    });

    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _userSpeechText = result.recognizedWords;
          _displayText = _userSpeechText;
        });
      },
      listenMode: stt.ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  Future<void> _stopListeningAndSend() async {
    await _speechToText.stop();
    
    if (_userSpeechText.trim().isEmpty) {
      setState(() {
        _isListening = false;
        _displayText = 'No speech detected. Try again.';
      });
      return;
    }

    setState(() {
      _isListening = false;
      _isThinking = true;
      _displayText = 'Thinking...';
    });

    try {
      // Send to AI
      final response = await ElevenLabsAPI.getAgentReply(_userSpeechText);
      
      setState(() {
        _isThinking = false;
        _displayText = response;
      });

      // Speak the response
      await TtsService.speak(response);
      
    } catch (e) {
      setState(() {
        _isThinking = false;
        _displayText = 'Sorry, I couldn\'t understand that. Try again.';
      });
    }
  }

  @override
  void dispose() {
    _speechToText.cancel();
    TtsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDE0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EDE0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voice Chat',
          style: GoogleFonts.abrilFatface(
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Talking Character Avatar
                  TalkingBotAvatar(
                    isSpeaking: _isSpeaking,
                    size: 300,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Display Text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Text(
                        _displayText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Microphone Button at Bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: GestureDetector(
              onTap: _isListening ? _stopListeningAndSend : _startListening,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isListening ? 90 : 80,
                height: _isListening ? 90 : 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening 
                    ? Colors.red.shade400 
                    : (_isSpeaking || _isThinking)
                      ? Colors.grey.shade400
                      : const Color(0xFF5D4E37),
                  boxShadow: [
                    BoxShadow(
                      color: _isListening 
                        ? Colors.red.shade300.withOpacity(0.5)
                        : Colors.black26,
                      blurRadius: 20,
                      spreadRadius: _isListening ? 5 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
