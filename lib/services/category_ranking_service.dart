import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CategoryRankingService {
  static const String _rankingKey = 'category_rankings';
  
  // Default categories with their colors
  static const List<Map<String, dynamic>> defaultCategories = [
    {'name': 'News', 'color': 0xFF29CC76},
    {'name': 'Politics', 'color': 0xFF4C5DFF},
    {'name': 'Sex', 'color': 0xFFFF4081},
    {'name': 'Entertainment', 'color': 0xFFA06A00},
    {'name': 'Sports', 'color': 0xFFC43DFF},
    {'name': 'Religion', 'color': 0xFF000000},
  ];

  // Save user's category rankings
  static Future<void> saveRankings(Map<String, int> rankings) async {
    final prefs = await SharedPreferences.getInstance();
    final rankingsJson = json.encode(rankings);
    await prefs.setString(_rankingKey, rankingsJson);
  }

  // Load user's category rankings
  static Future<Map<String, int>> loadRankings() async {
    final prefs = await SharedPreferences.getInstance();
    final rankingsJson = prefs.getString(_rankingKey);
    
    if (rankingsJson != null) {
      final Map<String, dynamic> decoded = json.decode(rankingsJson);
      return decoded.map((key, value) => MapEntry(key, value as int));
    }
    
    // Return default rankings if none saved
    return {
      'News': 1,
      'Politics': 2,
      'Sex': 3,
      'Entertainment': 4,
      'Sports': 5,
      'Religion': 6,
    };
  }

  // Get categories sorted by user's ranking
  static Future<List<Map<String, dynamic>>> getRankedCategories() async {
    final rankings = await loadRankings();
    
    List<Map<String, dynamic>> rankedCategories = [];
    
    for (var category in defaultCategories) {
      final categoryName = category['name'] as String;
      final rank = rankings[categoryName] ?? 999; // Default to end if not ranked
      
      rankedCategories.add({
        'name': categoryName,
        'color': category['color'],
        'rank': rank,
        'stars': _calculateStars(rank),
      });
    }
    
    // Sort by rank (lower number = higher priority)
    rankedCategories.sort((a, b) => a['rank'].compareTo(b['rank']));
    
    return rankedCategories;
  }

  // Calculate star rating based on rank (1st = 5 stars, 6th = 0 stars)
  static int _calculateStars(int rank) {
    switch (rank) {
      case 1: return 5;
      case 2: return 4;
      case 3: return 3;
      case 4: return 2;
      case 5: return 1;
      case 6: return 0;
      default: return 0;
    }
  }

  // Update a single category's rank
  static Future<void> updateCategoryRank(String categoryName, int newRank) async {
    final currentRankings = await loadRankings();
    
    // Find the category that currently has the new rank
    String? categoryToSwap;
    for (var entry in currentRankings.entries) {
      if (entry.value == newRank) {
        categoryToSwap = entry.key;
        break;
      }
    }
    
    // Swap ranks if needed
    if (categoryToSwap != null && categoryToSwap != categoryName) {
      final oldRank = currentRankings[categoryName] ?? 6;
      currentRankings[categoryToSwap] = oldRank;
    }
    
    // Set the new rank
    currentRankings[categoryName] = newRank;
    
    await saveRankings(currentRankings);
  }

  // Reorder categories (for drag and drop functionality)
  static Future<void> reorderCategories(List<String> orderedCategoryNames) async {
    Map<String, int> newRankings = {};
    
    for (int i = 0; i < orderedCategoryNames.length; i++) {
      newRankings[orderedCategoryNames[i]] = i + 1;
    }
    
    await saveRankings(newRankings);
  }

  // Get category color by name
  static int getCategoryColor(String categoryName) {
    for (var category in defaultCategories) {
      if (category['name'] == categoryName) {
        return category['color'] as int;
      }
    }
    return 0xFF000000; // Default to black
  }

  // Check if user has set custom rankings
  static Future<bool> hasCustomRankings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_rankingKey);
  }

  // Reset rankings to default
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_rankingKey);
  }
}
