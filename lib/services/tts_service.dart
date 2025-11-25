import 'package:flutter_tts/flutter_tts.dart';

/// Service for managing Text-to-Speech functionality
/// Provides a simple interface for speaking text with animation callbacks
class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;

  // Callbacks for animation synchronization
  static Function()? onSpeakStart;
  static Function()? onSpeakComplete;
  static Function(String)? onSpeakError;

  /// Initialize the TTS engine with male voice settings
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Set language to English (US)
      await _flutterTts.setLanguage("en-US");

      // Set speech rate (0.0 to 1.0, default 0.5)
      await _flutterTts.setSpeechRate(0.45);

      // Set pitch (0.5 to 2.0, default 1.0)
      await _flutterTts.setPitch(1.0);

      // Set volume (0.0 to 1.0, default 1.0)
      await _flutterTts.setVolume(1.0);

      // Try to set a male voice (this is platform-dependent)
      // WEB FIX: Handle empty voices list
      var voices = await _flutterTts.getVoices;
      if (voices != null && voices.isNotEmpty) {
        // Look for male voices in the available voices
        var maleVoice = voices.firstWhere(
          (voice) =>
              voice['name'].toString().toLowerCase().contains('male') ||
              voice['name'].toString().contains('David') ||
              voice['name'].toString().contains('James'),
          orElse: () => voices.first,
        );
        await _flutterTts.setVoice(
            {"name": maleVoice['name'], "locale": maleVoice['locale']});
      } else {
        print('TTS: No voices available on this platform (normal for web)');
      }

      // Set up handlers for animation synchronization
      _flutterTts.setStartHandler(() {
        if (onSpeakStart != null) {
          onSpeakStart!();
        }
      });

      _flutterTts.setCompletionHandler(() {
        if (onSpeakComplete != null) {
          onSpeakComplete!();
        }
      });

      _flutterTts.setErrorHandler((msg) {
        if (onSpeakError != null) {
          onSpeakError!(msg);
        }
        if (onSpeakComplete != null) {
          onSpeakComplete!();
        }
      });

      _isInitialized = true;
    } catch (e) {
      print('TTS initialization error: $e');
      if (onSpeakError != null) {
        onSpeakError!('Failed to initialize TTS: $e');
      }
    }
  }

  /// Speak the given text
  /// Returns true if speech started successfully, false otherwise
  static Future<bool> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) {
      return false;
    }

    try {
      // Stop any ongoing speech
      await stop();

      // Start speaking
      var result = await _flutterTts.speak(text);
      return result == 1; // 1 means success
    } catch (e) {
      print('TTS speak error: $e');
      if (onSpeakError != null) {
        onSpeakError!('Failed to speak: $e');
      }
      return false;
    }
  }

  /// Stop the current speech
  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS stop error: $e');
    }
  }

  /// Pause the current speech
  static Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print('TTS pause error: $e');
    }
  }

  /// Check if TTS is currently speaking
  static Future<bool> isSpeaking() async {
    try {
      var result = await _flutterTts.awaitSpeakCompletion(false);
      return result == false; // false means still speaking
    } catch (e) {
      return false;
    }
  }

  /// Get available voices
  static Future<List<dynamic>> getVoices() async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      var voices = await _flutterTts.getVoices;
      return voices ?? [];
    } catch (e) {
      print('TTS getVoices error: $e');
      return [];
    }
  }

  /// Set a specific voice by name
  static Future<void> setVoice(String voiceName, String locale) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await _flutterTts.setVoice({"name": voiceName, "locale": locale});
    } catch (e) {
      print('TTS setVoice error: $e');
    }
  }

  /// Clean up resources
  static void dispose() {
    _flutterTts.stop();
    onSpeakStart = null;
    onSpeakComplete = null;
    onSpeakError = null;
  }
}
