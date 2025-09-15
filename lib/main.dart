import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/theme_provider.dart';
import 'core/models/theme_mode.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/favourites/presentation/favourites_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

void main() {
  runApp(const ProviderScope(child: MangaApp()));
}

class MangaApp extends ConsumerStatefulWidget {
  const MangaApp({super.key});

  @override
  ConsumerState<MangaApp> createState() => _MangaAppState();
}

class _MangaAppState extends ConsumerState<MangaApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavouritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeDataProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: "Hikari - Manga Reader",
      debugShowCheckedModeBanner: false,
      theme: themeData,
      darkTheme: themeData,
      themeMode: themeMode == AppThemeMode.system
          ? ThemeMode.system
          : themeMode == AppThemeMode.light
          ? ThemeMode.light
          : ThemeMode.dark,
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: "Favourites",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      ),
    );
  }
}
