import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/theme_mode.dart';
import '../../../core/models/reading_mode.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/reading_mode_provider.dart';
import '../../../core/providers/favourites_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final readingMode = ref.watch(readingModeProvider);
    final favourites = ref.watch(favouritesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          _buildThemeModeCard(context, ref, themeMode),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Reading'),
          _buildReadingModeCard(context, ref, readingMode),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Data'),
          _buildDataCard(context, ref, favourites),
          const SizedBox(height: 24),

          _buildSectionHeader(context, 'About'),
          _buildAboutCard(context),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeModeCard(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode currentMode,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(mode.displayName),
                subtitle: Text(_getThemeDescription(mode)),
                value: mode,
                groupValue: currentMode,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(themeModeProvider.notifier).setThemeMode(value);
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingModeCard(
    BuildContext context,
    WidgetRef ref,
    ReadingMode currentMode,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_module,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Reading Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...ReadingMode.values.map((mode) {
              return RadioListTile<ReadingMode>(
                title: Text(mode.displayName),
                subtitle: Text(mode.description),
                value: mode,
                groupValue: currentMode,
                onChanged: (value) {
                  if (value != null) {
                    ref
                        .read(readingModeProvider.notifier)
                        .setReadingMode(value);
                  }
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context, WidgetRef ref, List favourites) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.storage,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Local Data',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favourites'),
              subtitle: Text('${favourites.length} manga saved'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Favourites'),
              subtitle: const Text('Remove all saved manga from favourites'),
              onTap: () => _showClearFavouritesDialog(context, ref),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'About Hikari',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('Data Source'),
              subtitle: const Text('MangaDex API'),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Built with'),
              subtitle: const Text('Flutter & Riverpod'),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light theme for bright environments';
      case AppThemeMode.dark:
        return 'Dark theme for comfortable reading';
      case AppThemeMode.system:
        return 'Follow system theme setting';
    }
  }

  void _showClearFavouritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Favourites'),
        content: const Text(
          'Are you sure you want to remove all manga from your favourites? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear all favourites
              final favourites = ref.read(favouritesProvider);
              for (final manga in favourites) {
                ref.read(favouritesProvider.notifier).removeFavourite(manga.id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All favourites cleared'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
