import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Represents a single conversation in the chat
class ChatSummary {
  final DateTime timestamp;
  final String userMessage;
  final String botResponse;
  final bool navigationUsed;

  ChatSummary({
    required this.timestamp,
    required this.userMessage,
    required this.botResponse,
    this.navigationUsed = false,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'userMessage': userMessage,
    'botResponse': botResponse,
    'navigationUsed': navigationUsed,
  };

  factory ChatSummary.fromJson(Map<String, dynamic> json) => ChatSummary(
    timestamp: DateTime.parse(json['timestamp']),
    userMessage: json['userMessage'],
    botResponse: json['botResponse'],
    navigationUsed: json['navigationUsed'] ?? false,
  );
}

/// Represents all activities for a single day
class DailyActivity {
  final DateTime date;
  final List<ChatSummary> conversations;
  final Map<String, bool> tasksCompleted;
  final String? journalEntry;
  final String? journalMood;
  final int journalWordCount;
  final int musicUsageCount;
  final int gamesUsageCount;

  DailyActivity({
    required this.date,
    this.conversations = const [],
    this.tasksCompleted = const {},
    this.journalEntry,
    this.journalMood,
    this.journalWordCount = 0,
    this.musicUsageCount = 0,
    this.gamesUsageCount = 0,
  });

  /// Calculate wellness score (0-100)
  int calculateScore() {
    int score = 0;

    // CONVERSATIONS (0-30 points)
    if (conversations.isNotEmpty) {
      score += 10; // First conversation
      score += (conversations.length - 1) * 5; // Additional conversations (+5 each)
      score = score > 30 ? 30 : score;
      
      // Bonus for using navigation
      if (conversations.any((c) => c.navigationUsed)) {
        score += 5;
      }
    }

    // TASKS (0-40 points)
    int completedCount = tasksCompleted.values.where((completed) => completed).length;
    int totalTasks = tasksCompleted.length;
    if (totalTasks > 0) {
      score += ((completedCount / totalTasks) * 40).round();
    }

    // JOURNAL (0-30 points)
    if (journalEntry != null && journalEntry!.isNotEmpty) {
      score += 15; // Base points for journal entry
      if (journalWordCount > 50) score += 5; // Bonus for detailed entry
      if (journalMood != null) score += 5; // Bonus for mood tracking
      // Note: Streak bonus calculated separately in WellnessService
    }

    // BONUS: Music/Games usage (max 100 total)
    if (musicUsageCount > 0) score += 5;
    if (gamesUsageCount > 0) score += 5;

    return score > 100 ? 100 : score;
  }

  /// Get rating based on score
  String getRating() {
    int score = calculateScore();
    if (score >= 90) return 'Excellent! 🌟';
    if (score >= 75) return 'Great Day! 😊';
    if (score >= 60) return 'Good Progress 🙂';
    if (score >= 40) return 'Keep Going 😐';
    return 'Need Support 😔';
  }

  /// Get color based on score
  String getRatingColor() {
    int score = calculateScore();
    if (score >= 90) return '#4CAF50'; // Green
    if (score >= 75) return '#8BC34A'; // Light Green
    if (score >= 60) return '#FFC107'; // Yellow
    if (score >= 40) return '#FF9800'; // Orange
    return '#F44336'; // Red
  }

  /// Check if this day has any activity
  bool hasActivity() {
    return conversations.isNotEmpty ||
           tasksCompleted.values.any((completed) => completed) ||
           (journalEntry != null && journalEntry!.isNotEmpty) ||
           musicUsageCount > 0 ||
           gamesUsageCount > 0;
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'conversations': conversations.map((c) => c.toJson()).toList(),
    'tasksCompleted': tasksCompleted,
    'journalEntry': journalEntry,
    'journalMood': journalMood,
    'journalWordCount': journalWordCount,
    'musicUsageCount': musicUsageCount,
    'gamesUsageCount': gamesUsageCount,
  };

  factory DailyActivity.fromJson(Map<String, dynamic> json) => DailyActivity(
    date: DateTime.parse(json['date']),
    conversations: (json['conversations'] as List?)
        ?.map((c) => ChatSummary.fromJson(c))
        .toList() ?? [],
    tasksCompleted: Map<String, bool>.from(json['tasksCompleted'] ?? {}),
    journalEntry: json['journalEntry'],
    journalMood: json['journalMood'],
    journalWordCount: json['journalWordCount'] ?? 0,
    musicUsageCount: json['musicUsageCount'] ?? 0,
    gamesUsageCount: json['gamesUsageCount'] ?? 0,
  );

  /// Create a copy with updated values
  DailyActivity copyWith({
    List<ChatSummary>? conversations,
    Map<String, bool>? tasksCompleted,
    String? journalEntry,
    String? journalMood,
    int? journalWordCount,
    int? musicUsageCount,
    int? gamesUsageCount,
  }) {
    return DailyActivity(
      date: date,
      conversations: conversations ?? this.conversations,
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      journalEntry: journalEntry ?? this.journalEntry,
      journalMood: journalMood ?? this.journalMood,
      journalWordCount: journalWordCount ?? this.journalWordCount,
      musicUsageCount: musicUsageCount ?? this.musicUsageCount,
      gamesUsageCount: gamesUsageCount ?? this.gamesUsageCount,
    );
  }
}

/// Main wellness service for tracking and calculating wellness data
class WellnessService {
  static const String _keyPrefix = 'wellness_data_';
  static const String _keyCurrentStreak = 'wellness_current_streak';
  static const String _keyLastActivityDate = 'wellness_last_activity_date';

  /// Get today's date (normalized to midnight)
  static DateTime _getToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get date key for storage
  static String _getDateKey(DateTime date) {
    return '$_keyPrefix${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get or create today's activity
  static Future<DailyActivity> getTodayActivity() async {
    return getActivityForDate(_getToday());
  }

  /// Get activity for specific date
  static Future<DailyActivity> getActivityForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = DateTime(date.year, date.month, date.day);
    final key = _getDateKey(normalized);
    final jsonStr = prefs.getString(key);
    
    if (jsonStr != null) {
      return DailyActivity.fromJson(json.decode(jsonStr));
    }
    
    // Return empty activity for this date
    return DailyActivity(date: normalized);
  }

  /// Save activity for a date
  static Future<void> _saveActivity(DailyActivity activity) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getDateKey(activity.date);
    await prefs.setString(key, json.encode(activity.toJson()));
  }

  /// Record a conversation
  static Future<void> recordConversation({
    required String userMessage,
    required String botResponse,
    bool navigationUsed = false,
  }) async {
    final activity = await getTodayActivity();
    final conversation = ChatSummary(
      timestamp: DateTime.now(),
      userMessage: userMessage,
      botResponse: botResponse,
      navigationUsed: navigationUsed,
    );
    
    final updatedConversations = List<ChatSummary>.from(activity.conversations)
      ..add(conversation);
    
    final updatedActivity = activity.copyWith(conversations: updatedConversations);
    await _saveActivity(updatedActivity);
    await _updateStreak();
  }

  /// Record task completion
  static Future<void> recordTaskCompletion({
    required Map<String, bool> tasksCompleted,
  }) async {
    final activity = await getTodayActivity();
    final updatedActivity = activity.copyWith(tasksCompleted: tasksCompleted);
    await _saveActivity(updatedActivity);
    await _updateStreak();
  }

  /// Record journal entry
  static Future<void> recordJournalEntry({
    required String entry,
    String? mood,
  }) async {
    final activity = await getTodayActivity();
    final wordCount = entry.trim().split(RegExp(r'\s+')).length;
    final updatedActivity = activity.copyWith(
      journalEntry: entry,
      journalMood: mood,
      journalWordCount: wordCount,
    );
    await _saveActivity(updatedActivity);
    await _updateStreak();
  }

  /// Record feature usage (music/games)
  static Future<void> recordFeatureUsage(String feature) async {
    final activity = await getTodayActivity();
    if (feature == 'music') {
      final updatedActivity = activity.copyWith(
        musicUsageCount: activity.musicUsageCount + 1,
      );
      await _saveActivity(updatedActivity);
    } else if (feature == 'games') {
      final updatedActivity = activity.copyWith(
        gamesUsageCount: activity.gamesUsageCount + 1,
      );
      await _saveActivity(updatedActivity);
    }
    await _updateStreak();
  }

  /// Update streak counter
  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getToday();
    final lastActivityStr = prefs.getString(_keyLastActivityDate);
    
    if (lastActivityStr == null) {
      // First activity ever
      await prefs.setInt(_keyCurrentStreak, 1);
      await prefs.setString(_keyLastActivityDate, today.toIso8601String());
      return;
    }
    
    final lastActivity = DateTime.parse(lastActivityStr);
    final daysDifference = today.difference(lastActivity).inDays;
    
    if (daysDifference == 0) {
      // Same day, no change
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      final currentStreak = prefs.getInt(_keyCurrentStreak) ?? 0;
      await prefs.setInt(_keyCurrentStreak, currentStreak + 1);
      await prefs.setString(_keyLastActivityDate, today.toIso8601String());
    } else {
      // Streak broken, reset to 1
      await prefs.setInt(_keyCurrentStreak, 1);
      await prefs.setString(_keyLastActivityDate, today.toIso8601String());
    }
  }

  /// Get current streak
  static Future<int> getCurrentStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCurrentStreak) ?? 0;
  }

  /// Get last 30 days of scores
  static Future<List<int>> getLast30DaysScores() async {
    final scores = <int>[];
    final today = _getToday();
    
    for (int i = 29; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final activity = await getActivityForDate(date);
      scores.add(activity.calculateScore());
    }
    
    return scores;
  }

  /// Get weekly average score
  static Future<double> getWeeklyAverage() async {
    final today = _getToday();
    int totalScore = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final activity = await getActivityForDate(date);
      totalScore += activity.calculateScore();
    }
    
    return totalScore / 7;
  }

  /// Get monthly average score
  static Future<double> getMonthlyAverage() async {
    final today = _getToday();
    int totalScore = 0;
    int daysInMonth = DateTime(today.year, today.month + 1, 0).day;
    
    for (int i = 0; i < daysInMonth; i++) {
      final date = DateTime(today.year, today.month, i + 1);
      if (date.isAfter(today)) break;
      final activity = await getActivityForDate(date);
      totalScore += activity.calculateScore();
    }
    
    return totalScore / (today.day);
  }

  /// Check if a date has any activity
  static Future<bool> hasActivityOnDate(DateTime date) async {
    final activity = await getActivityForDate(date);
    return activity.hasActivity();
  }

  /// Get all dates with activity in a month
  static Future<List<DateTime>> getActivityDatesInMonth(int year, int month) async {
    final dates = <DateTime>[];
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      if (await hasActivityOnDate(date)) {
        dates.add(date);
      }
    }
    
    return dates;
  }

  /// Get trend indicator
  static Future<String> getTrendIndicator() async {
    final scores = await getLast30DaysScores();
    if (scores.length < 7) return '→';
    
    final lastWeek = scores.sublist(scores.length - 7);
    final previousWeek = scores.sublist(scores.length - 14, scores.length - 7);
    
    final lastWeekAvg = lastWeek.reduce((a, b) => a + b) / 7;
    final previousWeekAvg = previousWeek.reduce((a, b) => a + b) / 7;
    
    if (lastWeekAvg > previousWeekAvg + 5) return '↑';
    if (lastWeekAvg < previousWeekAvg - 5) return '↓';
    return '→';
  }
}
