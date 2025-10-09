import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const String _bookmarksKey = 'bookmarks';
  static const String _historyKey = 'history';

  // Sauvegarder un favori
  Future<void> saveBookmark(int surahNumber, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();

    // Récupérer les favoris existants
    final bookmarks = await getBookmarks();

    // Ajouter le nouveau favori
    final bookmark = {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'timestamp': DateTime.now().toIso8601String(),
    };

    bookmarks.add(bookmark);

    // Sauvegarder
    await prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  // Récupérer tous les favoris
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarksJson = prefs.getString(_bookmarksKey);

    if (bookmarksJson == null) return [];

    final List decoded = json.decode(bookmarksJson);
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // Supprimer un favori
  Future<void> removeBookmark(int surahNumber, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks();

    bookmarks.removeWhere(
      (bookmark) =>
          bookmark['surahNumber'] == surahNumber &&
          bookmark['verseNumber'] == verseNumber,
    );

    await prefs.setString(_bookmarksKey, json.encode(bookmarks));
  }

  // Vérifier si un verset est en favori
  Future<bool> isBookmarked(int surahNumber, int verseNumber) async {
    final bookmarks = await getBookmarks();
    return bookmarks.any(
      (bookmark) =>
          bookmark['surahNumber'] == surahNumber &&
          bookmark['verseNumber'] == verseNumber,
    );
  }

  // Sauvegarder l'historique de lecture
  Future<void> saveHistory(int surahNumber, int verseNumber) async {
    final prefs = await SharedPreferences.getInstance();

    final history = await getHistory();

    final item = {
      'surahNumber': surahNumber,
      'verseNumber': verseNumber,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Retirer l'élément s'il existe déjà
    history.removeWhere(
      (h) => h['surahNumber'] == surahNumber && h['verseNumber'] == verseNumber,
    );

    // Ajouter en premier
    history.insert(0, item);

    // Garder seulement les 50 derniers
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }

    await prefs.setString(_historyKey, json.encode(history));
  }

  // Récupérer l'historique
  Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_historyKey);

    if (historyJson == null) return [];

    final List decoded = json.decode(historyJson);
    return decoded.map((item) => item as Map<String, dynamic>).toList();
  }

  // Sauvegarder les paramètres
  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();

    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
  }

  // Récupérer un paramètre
  Future<T?> getSetting<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();

    if (T == String) {
      return prefs.getString(key) as T?;
    } else if (T == int) {
      return prefs.getInt(key) as T?;
    } else if (T == double) {
      return prefs.getDouble(key) as T?;
    } else if (T == bool) {
      return prefs.getBool(key) as T?;
    }

    return null;
  }

  // Effacer toutes les données
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
