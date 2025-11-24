import 'package:shared_preferences/shared_preferences.dart';

/// Simple service for managing user profile and progress tracking.
/// All data is stored locally using SharedPreferences.
class UserProfileService {
  static const String _keyUserName = 'user_name';
  static const String _keySessions = 'sessions_count';
  static const String _keyMusicPlays = 'music_plays_count';
  static const String _keyGamesPlayed = 'games_played_count';
  static const String _keyAssessmentsTaken = 'assessments_taken_count';
  static const String _keyFirstLaunchDate = 'first_launch_date';
  static const String _keyLastActiveDate = 'last_active_date';
  static const String _keyStreak = 'streak_days';

  // ========== User Identity ==========

  /// Get the stored user name
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Set the user name
  static Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserName, name);
  }

  // ========== Session Tracking ==========

  /// Get total number of chat sessions
  static Future<int> getSessionsCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keySessions) ?? 0;
  }

  /// Increment session count (call when user starts a new chat)
  static Future<void> incrementSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keySessions) ?? 0;
    await prefs.setInt(_keySessions, current + 1);
  }

  // ========== Activity Tracking ==========

  /// Get total music plays
  static Future<int> getMusicPlaysCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyMusicPlays) ?? 0;
  }

  /// Increment music plays (call when user plays a track)
  static Future<void> incrementMusicPlays() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyMusicPlays) ?? 0;
    await prefs.setInt(_keyMusicPlays, current + 1);
  }

  /// Get total games played
  static Future<int> getGamesPlayedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyGamesPlayed) ?? 0;
  }

  /// Increment games played (call when user starts a game)
  static Future<void> incrementGamesPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyGamesPlayed) ?? 0;
    await prefs.setInt(_keyGamesPlayed, current + 1);
  }

  /// Get total assessments taken
  static Future<int> getAssessmentsTakenCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyAssessmentsTaken) ?? 0;
  }

  /// Increment assessments taken (call when user completes assessment)
  static Future<void> incrementAssessmentsTaken() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_keyAssessmentsTaken) ?? 0;
    await prefs.setInt(_keyAssessmentsTaken, current + 1);
  }

  // ========== Streak Tracking ==========

  /// Get first launch date (as ISO string)
  static Future<String?> getFirstLaunchDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFirstLaunchDate);
  }

  /// Set first launch date
  static Future<void> setFirstLaunchDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyFirstLaunchDate, date.toIso8601String());
  }

  /// Get last active date (as ISO string)
  static Future<String?> getLastActiveDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastActiveDate);
  }

  /// Update streak and last active date based on current date
  static Future<void> updateStreakForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastActiveDateStr = prefs.getString(_keyLastActiveDate);
    if (lastActiveDateStr == null) {
      // First time ever
      await prefs.setString(_keyLastActiveDate, today.toIso8601String());
      await prefs.setInt(_keyStreak, 1);
      
      // Also set first launch date if not set
      if (prefs.getString(_keyFirstLaunchDate) == null) {
        await prefs.setString(_keyFirstLaunchDate, today.toIso8601String());
      }
      return;
    }

    final lastActive = DateTime.parse(lastActiveDateStr);
    final lastActiveDay = DateTime(lastActive.year, lastActive.month, lastActive.day);
    final daysDifference = today.difference(lastActiveDay).inDays;

    final currentStreak = prefs.getInt(_keyStreak) ?? 1;

    if (daysDifference == 0) {
      // Same day, no change to streak
      return;
    } else if (daysDifference == 1) {
      // Consecutive day, increment streak
      await prefs.setInt(_keyStreak, currentStreak + 1);
      await prefs.setString(_keyLastActiveDate, today.toIso8601String());
    } else {
      // Missed days, reset streak
      await prefs.setInt(_keyStreak, 1);
      await prefs.setString(_keyLastActiveDate, today.toIso8601String());
    }
  }

  /// Get current streak in days
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  /// Get days since first launch
  static Future<int> getDaysSinceFirstLaunch() async {
    final firstLaunchStr = await getFirstLaunchDate();
    if (firstLaunchStr == null) return 0;
    
    final firstLaunch = DateTime.parse(firstLaunchStr);
    final now = DateTime.now();
    return now.difference(firstLaunch).inDays;
  }

  // ========== Reset / Clear ==========

  /// Clear all profile data (for testing or reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
