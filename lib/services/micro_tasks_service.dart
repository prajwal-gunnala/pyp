import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'wellness_service.dart';

/// Model for a daily micro-task
class MicroTask {
  final String id;
  final String title;
  final String? description;
  final String category; // physical, mental, social, self-care
  final bool isCompleted;
  final DateTime? completedAt;

  MicroTask({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  // Create from JSON
  factory MicroTask.fromJson(Map<String, dynamic> json) {
    return MicroTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  // Create a copy with updated fields
  MicroTask copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return MicroTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

/// Service to manage daily micro-tasks
class MicroTasksService {
  static const String _storageKey = 'micro_tasks';
  static const String _lastResetKey = 'tasks_last_reset_date';

  /// Default tasks for the day - 18 mental health focused tasks with breaks
  static List<MicroTask> _getDefaultTasks() {
    return [
      // MORNING ROUTINE (6:00 AM - 9:00 AM)
      MicroTask(
        id: 'task_bed',
        title: 'Make your bed',
        description: 'Start the day with a small win and sense of order',
        category: 'physical',
      ),
      MicroTask(
        id: 'task_water',
        title: 'Drink a glass of water',
        description: 'Rehydrate after sleep, boost energy and focus',
        category: 'self-care',
      ),
      MicroTask(
        id: 'task_stretch',
        title: 'Morning stretch (3 minutes)',
        description: 'Wake up your body, release tension, improve circulation',
        category: 'physical',
      ),
      MicroTask(
        id: 'task_gratitude',
        title: 'List 3 things you\'re grateful for',
        description: 'Start with positivity, improve mood and outlook',
        category: 'mental',
      ),
      MicroTask(
        id: 'task_intention',
        title: 'Set one intention for today',
        description: 'Give your day purpose and direction',
        category: 'mental',
      ),
      
      // MID-MORNING BREAK (10:00 AM - 11:00 AM)
      MicroTask(
        id: 'task_breath',
        title: 'Practice deep breathing (5 breaths)',
        description: 'Pause and center yourself, reduce stress hormones',
        category: 'mental',
      ),
      MicroTask(
        id: 'task_posture',
        title: 'Check your posture',
        description: 'Sit up straight, shoulders back, prevent pain',
        category: 'physical',
      ),
      MicroTask(
        id: 'task_eyes',
        title: 'Rest your eyes (20-20-20 rule)',
        description: 'Look 20 feet away for 20 seconds, reduce eye strain',
        category: 'self-care',
      ),
      
      // MIDDAY WELLNESS (12:00 PM - 2:00 PM)
      MicroTask(
        id: 'task_walk',
        title: 'Take a 5-minute walk',
        description: 'Get sunlight, move your body, clear your mind',
        category: 'physical',
      ),
      MicroTask(
        id: 'task_meal',
        title: 'Eat a mindful meal',
        description: 'Focus on your food, no screens, enjoy each bite',
        category: 'self-care',
      ),
      MicroTask(
        id: 'task_connect',
        title: 'Connect with someone',
        description: 'Send a kind message or have a real conversation',
        category: 'social',
      ),
      
      // AFTERNOON RECHARGE (3:00 PM - 4:00 PM)
      MicroTask(
        id: 'task_music',
        title: 'Listen to calming music (5 min)',
        description: 'Take a mental break, reduce stress, restore focus',
        category: 'mental',
      ),
      MicroTask(
        id: 'task_tidy',
        title: 'Tidy your space',
        description: 'Clear physical clutter = clear mental space',
        category: 'physical',
      ),
      MicroTask(
        id: 'task_progress',
        title: 'Celebrate one win today',
        description: 'Acknowledge your progress, build confidence',
        category: 'mental',
      ),
      
      // EVENING WIND-DOWN (7:00 PM - 9:00 PM)
      MicroTask(
        id: 'task_journal',
        title: 'Write in your journal',
        description: 'Process your day, release thoughts, gain clarity',
        category: 'mental',
      ),
      MicroTask(
        id: 'task_screen',
        title: 'Screen-free time (30 min)',
        description: 'Give your mind a break, improve sleep quality',
        category: 'self-care',
      ),
      MicroTask(
        id: 'task_prepare',
        title: 'Prepare for tomorrow',
        description: 'Plan ahead, reduce morning stress, sleep easier',
        category: 'mental',
      ),
      MicroTask(
        id: 'task_reflect',
        title: 'Evening reflection (2 min)',
        description: 'What went well? What did you learn? End with kindness',
        category: 'mental',
      ),
    ];
  }

  /// Get tasks for today, resetting if it's a new day
  static Future<List<MicroTask>> getTodaysTasks() async {
    await _checkAndResetIfNeeded();
    
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString(_storageKey);
    
    if (tasksJson == null || tasksJson.isEmpty) {
      // First time or no tasks - return defaults
      final defaultTasks = _getDefaultTasks();
      await _saveTasks(defaultTasks);
      return defaultTasks;
    }

    try {
      final List<dynamic> decoded = jsonDecode(tasksJson);
      return decoded
          .map((item) => MicroTask.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return _getDefaultTasks();
    }
  }

  /// Toggle task completion
  static Future<void> toggleTask(String taskId) async {
    final tasks = await getTodaysTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    
    if (index == -1) return;

    final task = tasks[index];
    tasks[index] = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );

    await _saveTasks(tasks);
    
    // Record task completion in wellness service
    final tasksMap = {for (var t in tasks) t.id: t.isCompleted};
    await WellnessService.recordTaskCompletion(tasksCompleted: tasksMap);
  }

  /// Get completion stats
  static Future<Map<String, int>> getStats() async {
    final tasks = await getTodaysTasks();
    final completed = tasks.where((t) => t.isCompleted).length;
    
    return {
      'total': tasks.length,
      'completed': completed,
      'remaining': tasks.length - completed,
    };
  }

  /// Get total tasks completed all time
  static Future<int> getTotalCompletedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('total_tasks_completed') ?? 0;
  }

  /// Increment total completed counter
  static Future<void> _incrementTotalCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getTotalCompletedCount();
    await prefs.setInt('total_tasks_completed', current + 1);
  }

  /// Check if tasks need to be reset for new day
  static Future<void> _checkAndResetIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResetString = prefs.getString(_lastResetKey);
    
    if (lastResetString == null) {
      // First time
      await _resetTasks();
      return;
    }

    final lastReset = DateTime.parse(lastResetString);
    final now = DateTime.now();
    
    // Check if it's a new day
    if (now.year != lastReset.year ||
        now.month != lastReset.month ||
        now.day != lastReset.day) {
      // Count completed tasks before reset
      final tasks = await getTodaysTasks();
      final completedCount = tasks.where((t) => t.isCompleted).length;
      
      // Add to total
      for (int i = 0; i < completedCount; i++) {
        await _incrementTotalCompleted();
      }
      
      // Reset for new day
      await _resetTasks();
    }
  }

  /// Reset tasks to defaults
  static Future<void> _resetTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultTasks = _getDefaultTasks();
    await _saveTasks(defaultTasks);
    await prefs.setString(_lastResetKey, DateTime.now().toIso8601String());
  }

  /// Private helper to save tasks
  static Future<void> _saveTasks(List<MicroTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        tasks.map((t) => t.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// Add a custom task
  static Future<void> addCustomTask({
    required String title,
    String? description,
    String category = 'self-care',
  }) async {
    final tasks = await getTodaysTasks();
    final newTask = MicroTask(
      id: 'task_custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: description,
      category: category,
    );
    
    tasks.add(newTask);
    await _saveTasks(tasks);
  }
}
