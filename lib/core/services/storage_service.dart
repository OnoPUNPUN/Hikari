import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manga.dart';
import '../models/theme_mode.dart';
import '../models/reading_mode.dart';

class StorageService {
  static const String _favouritesKey = 'favourites';
  static const String _themeModeKey = 'theme_mode';
  static const String _readingModeKey = 'reading_mode';

  Future<List<Manga>> getFavourites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favouritesJson = prefs.getStringList(_favouritesKey) ?? [];

      return favouritesJson
          .map((json) => Manga.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addFavourite(Manga manga) async {
    try {
      final favourites = await getFavourites();
      if (!favourites.any((fav) => fav.id == manga.id)) {
        favourites.add(manga);
        await _saveFavourites(favourites);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> removeFavourite(String mangaId) async {
    try {
      final favourites = await getFavourites();
      favourites.removeWhere((fav) => fav.id == mangaId);
      await _saveFavourites(favourites);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<bool> isFavourite(String mangaId) async {
    try {
      final favourites = await getFavourites();
      return favourites.any((fav) => fav.id == mangaId);
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveFavourites(List<Manga> favourites) async {
    final prefs = await SharedPreferences.getInstance();
    final favouritesJson = favourites
        .map((manga) => jsonEncode(manga.toJson()))
        .toList();
    await prefs.setStringList(_favouritesKey, favouritesJson);
  }

  /// Helper method to save favorites
  Future<void> saveFavorites(List<Manga> favourites) async {
    await _saveFavourites(favourites);
  }

  /// Helper method to load favorites
  Future<List<Manga>> loadFavorites() async {
    return await getFavourites();
  }

  /// Helper method to toggle favorite status
  Future<void> toggleFavorite(Manga manga) async {
    final isCurrentlyFavorite = await isFavourite(manga.id);
    if (isCurrentlyFavorite) {
      await removeFavourite(manga.id);
    } else {
      await addFavourite(manga);
    }
  }

  Future<AppThemeMode> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeModeKey) ?? 0;
      return AppThemeMode.values[themeIndex];
    } catch (e) {
      return AppThemeMode.system;
    }
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeMode.index);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<ReadingMode> getReadingMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final readingModeIndex = prefs.getInt(_readingModeKey) ?? 0;
      return ReadingMode.values[readingModeIndex];
    } catch (e) {
      return ReadingMode.classic;
    }
  }

  Future<void> setReadingMode(ReadingMode readingMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_readingModeKey, readingMode.index);
    } catch (e) {
      // Handle error silently
    }
  }
}
