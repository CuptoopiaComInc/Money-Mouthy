import 'package:shared_preferences/shared_preferences.dart';

class CategoryPreferenceService {
  static const String _lastSelectedCategoryKey = 'last_selected_category';
  static const String _defaultCategory = 'News'; // Changed from Politics to News

  // Save the last selected category
  static Future<void> saveLastSelectedCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastSelectedCategoryKey, category);
  }

  // Get the last selected category
  static Future<String> getLastSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastSelectedCategoryKey) ?? _defaultCategory;
  }

  // Clear the saved category (reset to default)
  static Future<void> clearLastSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastSelectedCategoryKey);
  }

  // Get the default category
  static String getDefaultCategory() {
    return _defaultCategory;
  }
}
