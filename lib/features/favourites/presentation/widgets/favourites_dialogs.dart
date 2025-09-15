import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/manga.dart';
import '../../../../core/providers/favourites_provider.dart';

class FavouritesDialogs {
  static void showClearAllDialog(
    BuildContext context,
    WidgetRef ref,
    List<Manga> favourites,
  ) {
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
              _clearAllFavourites(context, ref, favourites);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  static void _clearAllFavourites(
    BuildContext context,
    WidgetRef ref,
    List<Manga> favourites,
  ) {
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
  }

  static void showRemoveSnackBar(
    BuildContext context,
    WidgetRef ref,
    Manga manga,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${manga.title} removed from favourites'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            ref.read(favouritesProvider.notifier).addFavourite(manga);
          },
        ),
      ),
    );
  }
}
