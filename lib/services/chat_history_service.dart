import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../chatbot.dart';

/// Service to persist chat history per day locally
/// Each day's conversation is stored separately with key: 'chat_history_YYYY-MM-DD'
/// This allows the bot to remember conversations within a day but start fresh each new day
class ChatHistoryService {
  static const String _keyPrefix = 'chat_history_';
  
  /// Get the storage key for a specific date
  static String _getKeyForDate(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '$_keyPrefix$dateStr';
  }
  
  /// Get the storage key for today
  static String _getTodayKey() {
    return _getKeyForDate(DateTime.now());
  }
  
  /// Load chat history for today
  /// Returns empty list if no history exists for today
  static Future<List<ChatMessage>> loadTodayHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final jsonStr = prefs.getString(key);
      
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chat history: $e');
      return [];
    }
  }
  
  /// Load chat history for a specific date
  /// Returns empty list if no history exists for that date
  static Future<List<ChatMessage>> loadHistoryForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForDate(date);
      final jsonStr = prefs.getString(key);
      
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }
      
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((json) => ChatMessage.fromJson(json)).toList();
    } catch (e) {
      print('Error loading chat history for date: $e');
      return [];
    }
  }
  
  /// Save current chat history for today
  /// Overwrites any existing history for today
  static Future<void> saveTodayHistory(List<ChatMessage> chatHistory) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      
      // Convert chat messages to JSON
      final jsonList = chatHistory.map((msg) => msg.toJson()).toList();
      final jsonStr = json.encode(jsonList);
      
      await prefs.setString(key, jsonStr);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }
  
  /// Clear chat history for today
  static Future<void> clearTodayHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      await prefs.remove(key);
    } catch (e) {
      print('Error clearing chat history: $e');
    }
  }
  
  /// Clear chat history for a specific date
  static Future<void> clearHistoryForDate(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKeyForDate(date);
      await prefs.remove(key);
    } catch (e) {
      print('Error clearing chat history for date: $e');
    }
  }
  
  /// Get all dates that have chat history
  /// Returns list of dates with stored conversations
  static Future<List<DateTime>> getDatesWithHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      final List<DateTime> dates = [];
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          // Extract date from key: 'chat_history_2025-11-24'
          final dateStr = key.substring(_keyPrefix.length);
          try {
            final parts = dateStr.split('-');
            if (parts.length == 3) {
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final day = int.parse(parts[2]);
              dates.add(DateTime(year, month, day));
            }
          } catch (e) {
            // Skip invalid date keys
            continue;
          }
        }
      }
      
      // Sort dates in descending order (most recent first)
      dates.sort((a, b) => b.compareTo(a));
      return dates;
    } catch (e) {
      print('Error getting dates with history: $e');
      return [];
    }
  }
  
  /// Check if the last saved chat was from a previous day
  /// If yes, returns true (indicating a new day has started)
  static Future<bool> isNewDay() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final exists = prefs.containsKey(key);
      
      // If today's key doesn't exist, it's either first time or a new day
      return !exists;
    } catch (e) {
      print('Error checking if new day: $e');
      return true;
    }
  }
  
  /// Clean up old chat history (keep only last 30 days)
  /// This prevents storage from growing indefinitely
  static Future<void> cleanupOldHistory({int keepDays = 30}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      
      for (final key in keys) {
        if (key.startsWith(_keyPrefix)) {
          final dateStr = key.substring(_keyPrefix.length);
          try {
            final parts = dateStr.split('-');
            if (parts.length == 3) {
              final year = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final day = int.parse(parts[2]);
              final date = DateTime(year, month, day);
              
              if (date.isBefore(cutoffDate)) {
                await prefs.remove(key);
              }
            }
          } catch (e) {
            // Skip invalid keys
            continue;
          }
        }
      }
    } catch (e) {
      print('Error cleaning up old history: $e');
    }
  }
}
