import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wellness_service.dart';

/// Model for a diary entry
class DiaryEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final String? mood; // Optional: happy, calm, anxious, sad, etc.

  DiaryEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.mood,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'mood': mood,
    };
  }

  // Create from JSON
  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mood: json['mood'] as String?,
    );
  }
}

/// Service to manage diary entries
class DiaryService {
  static const String _storageKey = 'diary_entries';

  /// Get all diary entries, sorted by newest first
  static Future<List<DiaryEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString(_storageKey);
    
    if (entriesJson == null || entriesJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(entriesJson);
      final entries = decoded
          .map((item) => DiaryEntry.fromJson(item as Map<String, dynamic>))
          .toList();
      
      // Sort by newest first
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      print('Error loading diary entries: $e');
      return [];
    }
  }

  /// Add a new diary entry
  static Future<void> addEntry({
    required String content,
    String? mood,
  }) async {
    if (content.trim().isEmpty) return;

    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content.trim(),
      timestamp: DateTime.now(),
      mood: mood,
    );

    final entries = await getEntries();
    entries.insert(0, entry); // Add to beginning
    await _saveEntries(entries);
    
    // Record in wellness service
    await WellnessService.recordJournalEntry(
      entry: content.trim(),
      mood: mood,
    );
  }

  /// Update an existing entry
  static Future<void> updateEntry({
    required String id,
    required String content,
    String? mood,
  }) async {
    if (content.trim().isEmpty) return;

    final entries = await getEntries();
    final index = entries.indexWhere((e) => e.id == id);
    
    if (index == -1) return;

    // Keep original timestamp, update content and mood
    entries[index] = DiaryEntry(
      id: id,
      content: content.trim(),
      timestamp: entries[index].timestamp,
      mood: mood,
    );

    await _saveEntries(entries);
    
    // Update in wellness service
    await WellnessService.recordJournalEntry(
      entry: content.trim(),
      mood: mood,
    );
  }

  /// Delete an entry
  static Future<void> deleteEntry(String id) async {
    final entries = await getEntries();
    entries.removeWhere((e) => e.id == id);
    await _saveEntries(entries);
  }

  /// Get entries for a specific date
  static Future<List<DiaryEntry>> getEntriesForDate(DateTime date) async {
    final entries = await getEntries();
    return entries.where((entry) {
      final entryDate = entry.timestamp;
      return entryDate.year == date.year &&
          entryDate.month == date.month &&
          entryDate.day == date.day;
    }).toList();
  }

  /// Get total number of entries
  static Future<int> getEntryCount() async {
    final entries = await getEntries();
    return entries.length;
  }

  /// Get entries from last N days
  static Future<List<DiaryEntry>> getRecentEntries(int days) async {
    final entries = await getEntries();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return entries.where((entry) => entry.timestamp.isAfter(cutoffDate)).toList();
  }

  /// Private helper to save entries
  static Future<void> _saveEntries(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        entries.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
