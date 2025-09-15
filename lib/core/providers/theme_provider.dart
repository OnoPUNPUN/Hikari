import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/theme_mode.dart';
import '../services/storage_service.dart';
import 'storage_provider.dart';

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
      return ThemeModeNotifier(ref.read(storageServiceProvider));
    });

class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  final StorageService _storageService;

  ThemeModeNotifier(this._storageService) : super(AppThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await _storageService.getThemeMode();
    state = themeMode;
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = themeMode;
    await _storageService.setThemeMode(themeMode);
  }
}

final themeDataProvider = Provider<ThemeData>((ref) {
  final themeMode = ref.watch(themeModeProvider);

  switch (themeMode) {
    case AppThemeMode.light:
      return AppThemes.lightTheme;
    case AppThemeMode.dark:
      return AppThemes.darkTheme;
    case AppThemeMode.system:
      return AppThemes.darkTheme; // Default to dark theme
  }
});

class AppThemes {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}
