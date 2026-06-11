import 'package:shared_preferences/shared_preferences.dart';

class DiseaseGuideService {
  static const _bookmarksKey = 'disease_guide_bookmarks';
  static const _viewedKey = 'disease_guide_viewed';
  static const _studiedKey = 'disease_guide_studied';

  Future<Set<String>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_bookmarksKey)?.toSet() ?? {};
  }

  Future<bool> isBookmarked(String id) async {
    final bookmarks = await getBookmarks();
    return bookmarks.contains(id);
  }

  Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_bookmarksKey)?.toList() ?? [];
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    await prefs.setStringList(_bookmarksKey, list);
  }

  Future<Set<String>> getViewed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_viewedKey)?.toSet() ?? {};
  }

  Future<void> markViewed(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_viewedKey)?.toList() ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_viewedKey, list);
    }
  }

  Future<Set<String>> getStudied() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_studiedKey)?.toSet() ?? {};
  }

  Future<void> markStudied(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_studiedKey)?.toList() ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_studiedKey, list);
    }
  }
}
