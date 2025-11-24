import 'package:flutter/material.dart';

/// Represents a navigation action extracted from bot response
class NavigationAction {
  final String target;
  final String? parameter;

  NavigationAction({
    required this.target,
    this.parameter,
  });

  /// Parse action tags from bot response
  /// Simple keyword-based approach: detects keywords and creates buttons
  static List<NavigationAction> parseFromResponse(String response) {
    List<NavigationAction> actions = [];
    String lowerResponse = response.toLowerCase();
    
    // Check for each feature keyword in the response
    Map<String, List<String>> keywords = {
      'music': ['music', 'frequency', 'hz', 'healing'],
      'games': ['game', 'play', 'puzzle', 'tic tac toe', 'fruit slicer', 'flow free'],
      'assessment': ['assessment', 'check-in', 'mental health check', 'questionnaire'],
      'diary': ['diary', 'journal', 'write', 'journaling'],
      'tasks': ['task', 'daily tasks', 'routine', 'habit'],
      'doctor': ['doctor', 'consultant', 'therapist', 'professional', 'counselor'],
    };
    
    // Check each feature
    for (var entry in keywords.entries) {
      String feature = entry.key;
      List<String> featureKeywords = entry.value;
      
      // If any keyword matches, add the navigation action
      for (String keyword in featureKeywords) {
        if (lowerResponse.contains(keyword)) {
          actions.add(NavigationAction(target: feature));
          break; // Only add once per feature
        }
      }
    }
    
    return actions;
  }

  /// Remove action tags from response text (no longer needed, but keeping for compatibility)
  static String cleanResponse(String response) {
    // No XML tags to remove anymore, just return the original response
    return response.trim();
  }

  /// Get icon for navigation target
  IconData getIcon() {
    switch (target.toLowerCase()) {
      case 'music':
        return Icons.music_note_rounded;
      case 'games':
        return Icons.games_rounded;
      case 'assessment':
        return Icons.assignment_rounded;
      case 'diary':
        return Icons.book_outlined;
      case 'tasks':
        return Icons.check_circle_outline;
      case 'doctor':
        return Icons.medical_services_rounded;
      default:
        return Icons.arrow_forward_rounded;
    }
  }

  /// Get display label for navigation target
  String getLabel() {
    switch (target.toLowerCase()) {
      case 'music':
        return 'Open Music Therapy';
      case 'games':
        return 'Play Mind Games';
      case 'assessment':
        return 'Take Mental Check-in';
      case 'diary':
        return 'Open My Journal';
      case 'tasks':
        return 'View Daily Tasks';
      case 'doctor':
        return 'Find Consultant';
      default:
        return 'Open';
    }
  }

  /// Get short label for compact display
  String getShortLabel() {
    switch (target.toLowerCase()) {
      case 'music':
        return 'Music';
      case 'games':
        return 'Games';
      case 'assessment':
        return 'Assessment';
      case 'diary':
        return 'Journal';
      case 'tasks':
        return 'Tasks';
      case 'doctor':
        return 'Consultant';
      default:
        return target;
    }
  }
  
  /// Convert NavigationAction to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'target': target,
      'parameter': parameter,
    };
  }
  
  /// Create NavigationAction from JSON
  factory NavigationAction.fromJson(Map<String, dynamic> json) {
    return NavigationAction(
      target: json['target'] as String,
      parameter: json['parameter'] as String?,
    );
  }
}
